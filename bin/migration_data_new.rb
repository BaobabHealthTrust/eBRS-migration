require'migration-lib/migrate_child'
require 'migration-lib/migrate_mother'
require 'migration-lib/migrate_father'
require 'migration-lib/migrate_informant'
require "migration-lib/migrate_birth_details"
require 'migration-lib/person_service'
require "simple_elastic_search"
require 'json'

@missing_district_ids = "#{Rails.root}/app/assets/data/missing_district_ids.txt"
@loaded_data = "#{Rails.root}/app/assets/data/loaded_data.txt"
@file_path = "#{Rails.root}/app/assets/data/missing_district_id_num_docs.txt"
@multiple_birth_file = "#{Rails.root}/app/assets/data/multiple_birth_children.json"
@failed_to_save = "#{Rails.root}/app/assets/data/failed_to_save.txt"
@suspected = "#{Rails.root}/app/assets/data/suspected.txt"
@analysis = "#{Rails.root}/app/assets/data/analysis.txt"
OTHER_TYPES_OF_BIRTH = "#{Rails.root}/app/assets/data/multiple_birth_children.csv"

User.current = User.last

Duplicate_attribute_type_id = PersonAttributeType.where(name: 'Duplicate Ben').first.id

password = CONFIG["crtkey"] rescue nil
$private_key = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/config/private.pem"), password)
$old_ben_type = PersonIdentifierType.where(name: 'Old Birth Entry Number').first.id
$old_brn_type = PersonIdentifierType.where(name: 'Old Birth Registration Number').first.id
$old_serial_type = PersonIdentifierType.where(name: 'Old Facility Number').first.id
$index = {}

if password.blank? || $private_key.blank?
  raise "Invalid Decryption Key".inspect
end

def write_log(file, content)

  if !File.exists?(file)
           file = File.new(file, 'w')
    else

       File.open(file, 'a') do |f|
          f.puts "#{content}"

      end


    end
end


def log_error(error_msge, content)

    file_path = "#{Rails.root}/log/migration_error_log.txt"
    if !File.exists?(file_path)
           file = File.new(file_path, 'w')
    else

       File.open(file_path, 'a') do |f|
          f.puts "#{error_msge} >>>>>> {\"id\" : #{content[:_id]}, \"rev\" : #{content[:_rev]} }"

      end
    end

 end

 def write_csv_header(file, header)
    CSV.open(file, 'w' ) do |exporter|
        exporter << header
    end
 end

 def write_csv_content(file, content)
    CSV.open(file, 'a+' ) do |exporter|
        exporter << content
    end
 end

 def person_for_elastic_search(core_person,params)

      person = {}
      person["id"] = core_person.person_id
      person["first_name"]= params[:person][:first_name]
      person["last_name"] =  params[:person][:last_name]
      person["middle_name"] = params[:person][:middle_name]
      person["gender"] = params[:person][:gender]
      person["birthdate"]= params[:person][:birthdate].to_date.strftime('%Y-%m-%d')
      person["birthdate_estimated"] = params[:person][:birthdate_estimated]

      if MigrateChild.is_twin_or_triplet(params[:person][:type_of_birth].to_s)
         prev_child = Person.find(params[:person][:prev_child_id].to_i)
         if params[:relationship] == "opharned" || params[:relationship] == "adopted"
           mother = prev_child.adoptive_mother
         else
           mother = prev_child.mother
         end

         if mother.present?
            mother_name =  mother.person_names.first
         else
            mother_name = nil
         end

         person["mother_first_name"] = mother_name.first_name rescue ""
         person["mother_last_name"] =   mother_name.last_name rescue ""
         person["mother_middle_name"] =  mother_name.first_name rescue ""

         person["mother_home_district"] = Location.find(mother.addresses.last.home_district).name rescue nil
         person["mother_home_ta"] = Location.find(mother.addresses.last.home_ta).name rescue nil
         person["mother_home_village"] = Location.find(mother.addresses.last.home_village).name rescue nil

         person["mother_current_district"] = Location.find(mother.addresses.last.current_district).name rescue nil
         person["mother_current_ta"] = Location.find(mother.addresses.last.current_ta).name rescue nil
         person["mother_current_village"] = Location.find(mother.addresses.last.current_village).name rescue nil

         if params[:relationship] == "opharned" || params[:relationship] == "adopted"
           father = prev_child.adoptive_father
         else
           father = prev_child.father
         end

         if father.present?
            father_name =  father.person_names.first
         else
            father_name = nil
         end

         person["father_first_name"] = father_name.first_name rescue ""
         person["father_last_name"] =   father_name.last_name rescue ""
         person["father_middle_name"] = father_name.first_name rescue ""

         person["father_home_district"] = params[:person][:mother][:home_district] rescue nil
         person["father_home_ta"] = params[:person][:mother][:home_ta] rescue nil
         person["father_home_village"] = params[:person][:mother][:home_village] rescue nil

         person["father_current_district"] = params[:person][:mother][:home_district] rescue nil
         person["father_current_ta"] = params[:person][:mother][:home_ta] rescue nil
         person["father_current_village"] = params[:person][:mother][:home_village] rescue nil

         birth_details = prev_details = PersonBirthDetail.where(person_id: params[:person][:prev_child_id].to_i).first
         person["place_of_birth"] = Location.find(birth_details.place_of_birth).name
         person["district"] = Location.find(birth_details.district_of_birth).name
         person["nationality"]= Location.find(mother.addresses.first.citizenship).name rescue "Malawian"

      else

        person["place_of_birth"] = params[:person][:place_of_birth]
        person["district"] = params[:person][:birth_district]
        person["nationality"]=  params[:person][:mother][:citizenship]

        person["mother_first_name"]= params[:person][:mother][:first_name] rescue nil
        person["mother_last_name"] =  params[:person][:mother][:last_name] rescue nil
        person["mother_middle_name"] = params[:person][:mother][:middle_name] rescue nil

        person["mother_home_district"] = params[:person][:mother][:home_district] rescue nil
        person["mother_home_ta"] = params[:person][:mother][:home_ta] rescue nil
        person["mother_home_village"] = params[:person][:mother][:home_village] rescue nil

        person["mother_current_district"] = params[:person][:mother][:home_district] rescue nil
        person["mother_current_ta"] = params[:person][:mother][:home_ta] rescue nil
        person["mother_current_village"] = params[:person][:mother][:home_village] rescue nil

        person["father_first_name"]= params[:person][:father][:first_name] rescue nil
        person["father_last_name"] =  params[:person][:father][:last_name] rescue nil
        person["father_middle_name"] = params[:person][:father][:middle_name] rescue nil

        person["father_home_district"] = params[:person][:father][:home_district] rescue nil
        person["father_home_ta"] = params[:person][:father][:home_ta] rescue nil
        person["father_home_village"] = params[:person][:father][:home_village] rescue nil

        person["father_current_district"] = params[:person][:father][:home_district] rescue nil
        person["father_current_ta"] = params[:person][:father][:home_ta] rescue nil
        person["father_current_village"] = params[:person][:father][:home_village] rescue nil

      end
      return person
 end

 def pre_migration_check(params)

    if params[:person][:created_by].blank?
        content = "#{params[:_id]},#{params[:person][:created_at]},#{params[:person][:created_by]},#{params[:person][:approved]},#{params[:person][:approved_by]}"
        write_log(@missing_doc_creator, content)
      end

      if ["Second Twin","Second Triplet","Third Triplet"].include? params[:person][:type_of_birth]
        if params[:person][:multiple_birth_id].blank?
         content = "#{params[:_id]},#{params[:person][:multiple_birth_id]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
         write_log(@missing_multiple_birth_ids, content)
        end
      end

    if params[:person][:type_of_birth].blank?
        content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
        write_log(@missing_birth_type, content)
      end

        status = get_record_status(params[:record_status],params[:request_status]).upcase.squish! rescue nil
    if  status.blank?
        content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:record_status]},#{params[:request_status]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
        write_log(@missing_record_statuses, content)
      end

      if verify_location("Mother", "TA", params) == false
         content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:person][:mother][:home_ta]},#{params[:person][:mother][:home_district]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
         write_log(@missing_tas, content)
      end

      if verify_location("Mother", "Village", params) == false
         content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:person][:mother][:home_village]},#{params[:person][:mother][:home_ta]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
         write_log(@missing_villages, content)
      end

      if verify_location("Mother", "District", params) == false
         content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:person][:mother][:home_district]},#{params[:person][:mother][:residential_country]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
         write_log(@missing_districts, content)
      end

      if verify_location("Mother", "Citizenship", params) == false
         content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:person][:mother][:citizenship]},#{params[:person][:mother][:residential_country]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
         write_log(@missing_citizenships, content)
      end

      if verify_location("Father", "TA", params) == false
         content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:person][:father][:home_ta]},#{params[:person][:father][:home_district]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
         write_log(@missing_tas, content)
      end

      if verify_location("Father", "Village", params) == false
         content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:person][:father][:home_village]},#{params[:person][:father][:home_ta]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
         write_log(@missing_villages, content)
      end

      if verify_location("Father", "District", params) == false
         content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:person][:father][:home_district]},#{params[:person][:father][:residential_country]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
         write_log(@missing_districts, content)
      end

      if verify_location("Father", "Citizenship", params) == false
         content = "#{params[:_id]},#{params[:person][:type_of_birth]},#{params[:person][:father][:citizenship]},#{params[:person][:father][:residential_country]},#{params[:person][:created_at]},#{params[:person][:created_by]}"
         write_log(@missing_citizenships, content)
      end

end


def save_full_record(params, district_id_number)

  params[:record_status] = get_record_status(params[:record_status],params[:request_status]).upcase.squish! rescue (raise params.inspect)
  person = PersonService.create_record(params)

  if !person.blank?
    #SimpleElasticSearch.add(person_for_elastic_search(person,params))
    assign_identifiers(person.person_id, params)
  end
end

def precision_level(mothers, record)

  fnames = []
  lnames =[]
  home_villages =[]
  home_ta =[]
  home_districts =[]
  birthdates =[]
  citizenships =[]

  match_count = 0

  mothers.each do |x|

    fnames << x['first_name']
    lnames << x['last_name']
    home_villages << x['home_village']
        home_districts << x['home_district']
        birthdates << x['birthdate']
        citizenships << x['citizenship']
        home_ta << x['home_ta']

  end

    if fnames.include? record[:person][:mother][:first_name]
     match_count = match_count + 1
  end
    if lnames.include? record[:person][:mother][:last_name]
     match_count = match_count + 1
  end
  if home_villages.include? record[:person][:mother][:home_village]
     match_count = match_count + 1
  end
  if home_ta.include? record[:person][:mother][:home_ta]
     match_count = match_count + 1
  end
  if birthdates.include? record[:person][:mother][:birthdate]
     match_count = match_count + 1
  end
  if home_districts.include? record[:person][:mother][:home_district]
     match_count = match_count + 1
  end
  if citizenships.include? record[:person][:mother][:citizenship]
     match_count = match_count + 1
  end

   if match_count == 7
    if !File.exists?(@suspected)
      file = File.new(@suspected, 'w')
    else
      File.open(@suspected, 'a')do |f|
           f.puts "match count: #{match_count} Name: #{record[:person][:mother][:first_name]}"
        end

    end
   end

   return match_count

end

def assign_identifiers(person_id, params)

    if !params[:person][:district_id_number].blank?
      PersonIdentifier.create(value: params[:person][:district_id_number], person_id: person_id, person_identifier_type_id: $old_ben_type)
    end

    if !params[:person][:national_serial_number].blank?
      PersonIdentifier.create(value: params[:person][:national_serial_number], person_id: person_id, person_identifier_type_id: $old_brn_type)
    end

    if !params[:person][:facility_serial_number].blank?
      PersonIdentifier.create(value: params[:person][:facility_serial_number], person_id: person_id, person_identifier_type_id: $old_serial_type)
    end
end


def transform_record(data)

    case data[:registration_type]
       when "adopted"
        if !data[:person][:mother][:first_name].blank? && !data[:person][:mother][:last_name].blank? && !data[:person][:father][:first_name].blank? && !data[:person][:father][:last_name].blank?
          data[:biological_parents] = "Both"
        end
        if !data[:person][:mother][:first_name].blank? && data[:person][:father][:first_name].blank?
          data[:biological_parents] = "Mother"
        end
        if  data[:person][:mother][:first_name].blank? && !data[:person][:father][:first_name].blank?
          data[:biological_parents] = "Father"
        end
       when "abandoned"
        if !data[:person][:mother][:first_name].blank? && !data[:person][:mother][:last_name].blank? && !data[:person][:father][:first_name].blank? && !data[:person][:father][:last_name].blank?
            data[:parents_details_available] = "Both"
        end
        if !data[:person][:mother][:first_name].blank? && data[:person][:father][:first_name].blank?
          data[:parents_details_available] = "Mother"
        end
        if  data[:person][:mother][:first_name].blank? && !data[:person][:father][:first_name].blank?
          data[:parents_details_available] = "Father"
        end
    else
    end

    #================== Transforming the marriage date and or estimated marriage date iis partly known
    unless data[:person][:date_of_marriage].blank?
         format_date(data[:person][:date_of_marriage])
    end

    if data[:person][:type_of_birth]== 'Single'
      begin
          save_full_record(data,data[:person][:district_id_number])
      rescue Exception => e
          log_error(e, data)
      end

    else
        write_csv_content(OTHER_TYPES_OF_BIRTH, [data[:_id],data[:person][:type_of_birth]])
    end
end

def format_date(date)
  unless date.blank?
    if date.to_s.split("/").length <= 1
       return date
    end
    if date.split("/")[0]  == "?"
       estimated_date = date.split("/")
       estimated_date[0] = 15
       date = estimated_date.join("/")
    end
    if date.split("/")[1]  == "?"
       estimated_date = date.split("/")
       estimated_date[1] = 7
       date = estimated_date.join("/")
    end
    if date.split("/")[2]  == "?"
       date = nil
    end
   end
  return date
end

def get_record_status(rec_status, req_status)


 status = {"DC OPEN" => {'ACTIVE' =>'DC-ACTIVE',
                    'IN-COMPLETE' =>'DC-INCOMPLETE',
                    'COMPLETE' =>'DC-COMPLETE',
                    'DUPLICATE' =>'DC-DUPLICATE',
                    'POTENTIAL DUPLICATE' =>'DC-POTENTIAL DUPLICATE',
                    'GRANTED' =>'DC-GRANTED',
                    'PENDING' => 'DC-PENDING',
                    'CAN-REPRINT' => 'HQ-CAN-RE-PRINT',
                    'CAN RE_PRINT' => 'HQ-CAN-RE-PRINT',
                    'REJECTED' =>'DC-REJECTED'},
    "POTENTIAL DUPLICATE" => {'ACTIVE' =>'FC-POTENTIAL DUPLICATE'},
    "POTENTIAL-DUPLICATE" =>{'VOIDED'=>'DC-VOIDED'},
    "VOIDED" =>{'CLOSED' =>'DC-VOIDED',
          'CLOSED' =>'HQ-VOIDED'},
    "PRINTED" =>{'CLOSED' =>'HQ-PRINTED',
          'DISPATCHED' =>'HQ-DISPATCHED'},
    "HQ-PRINTED" =>{'CLOSED' =>'HQ-PRINTED'},
    "HQ-DISPATCHED" =>{'DISPATCHED' =>'HQ-DISPATCHED'},
    "HQ-CAN-PRINT" =>{'CAN PRINT' =>'HQ-CAN-RE-PRINT'},
    "HQ OPEN" =>{'ACTIVE' =>'HQ-ACTIVE',
          'RE-APPROVED' =>'HQ-RE-APPROVED',
          'DC_ASK' =>'DC-ASK',
          'GRANTED' =>'HQ-GRANTED',
          'REJECTED' =>'HQ-REJECTED',
          'COMPLETE' =>'HQ-INCOMPLETE-TBA',
          'COMPLETE' =>'HQ-COMPLETE',
          'CAN PRINT' =>'HQ-CAN-PRINT',
          'CAN REJECT' =>'HQ-CAN-REJECT',
          'APPROVED' =>'HQ-APPROVED',
          'TBA-CONFLICT' =>'HQ-CONFLICT',
          'TBA-POTENTIAL DUPLICATE' =>'HQ-POTENTIAL DUPLICATE-TBA',
          'CAN VOID' =>'HQ-CAN-VOID',
          'INCOMPLETE' =>'HQ-INCOMPLETE',
          'RE-PRINT' =>'HQ-RE-PRINT',
          'CAN RE_PRINT' =>'HQ-CAN-RE-PRINT',
          'POTENTIAL DUPLICATE' =>'HQ-POTENTIAL DUPLICATE'},
    "DUPLICATE" =>{'VOIDED' =>'HQ-VOIDED'}}

   s = status[rec_status][req_status] rescue (raise "rec:  #{rec_status}   ----   req:   #{req_status}    NOT FOUND!".inspect)
   return s
end

def decrypt(value)
    string = $private_key.private_decrypt(Base64.decode64(value)) rescue nil
    special = "?<>',?[]}{=)(*&^%$#`~{}"
    regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/
    return "Not decrypted" if (string =~ regex).to_i > 0
    return value if string.nil?

    return string

end

def build_client_record(records, n)

    data ={}


   i = 0
   start_time = Time.now



   records.each do |doc|
      ActiveRecord::Base.transaction do
          transform_record(doc[1])
          i = i + 1
          if i % 100 == 0
            puts n + i
          end
          if i % 1000 == 0
            puts "Time interval : #{(Time.now - start_time) /60}"
          end
      end
    end
     records = nil


end


def initiate_migration(records)

  total_records = records.count
  puts "\n"
  puts "Completed migration of 1 of 3 batch of records! Please review the log files to verify.."
  puts "\n"
end

write_csv_header(OTHER_TYPES_OF_BIRTH, ["Couch ID","Type of Birth"])

configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]

#count = JSON.parse(` curl -s -X GET http://admin:password@localhost:5984/ebrs_child_hq_2_0/_design/Child/_view/by__id`)["rows"][0]["value"].to_i

#number_of_files = (count / 1000) + (count % 1000 > 0 ? 1 : 0)
files = Dir.glob(File.expand_path("~/")+"/ebrs_chunks/*.json").sort
number_of_files = files.length
file_number = 5
last_file_migrated = EbrsMigration.last
if last_file_migrated.present?
  file_number = last_file_migrated.file_number  + 1
else
  last_file_migrated = EbrsMigration.new
end
start_time = Time.now
while file_number < number_of_files
  GC.start

  records = eval((File.read(File.expand_path("~/")+"/ebrs_chuncks/#{file_number}.json"))) rescue []
  next if records.blank?
  build_client_record(records, file_number * 1000, )

  last_file_migrated.file_number =  file_number
  last_file_migrated.save
  file_number = file_number + 1
end
puts "Time interval : #{(Time.now - start_time) /60}"
