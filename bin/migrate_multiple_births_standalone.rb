require "csv"
require'migration-lib/migrate_child'
require 'migration-lib/migrate_mother'
require 'migration-lib/migrate_father'
require 'migration-lib/migrate_informant'
require "migration-lib/migrate_birth_details"
require 'migration-lib/person_service'
require "simple_elastic_search"
require 'json'

User.current = User.last

OTHER_TYPES_OF_BIRTH = "#{Rails.root}/app/assets/data/multiple_birth_children.csv"

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

def log_error(error_msge, content)

    file_path = "#{Rails.root}/log/migration_multiple_error_log.txt"
    if !File.exists?(file_path)
           file = File.new(file_path, 'w')
    else

       File.open(file_path, 'a') do |f|
          f.puts "#{error_msge} >>>>>> {\"id\" : #{content[:_id]}, \"rev\" : #{content[:_rev]} }"

      end
    end

end

def save_data(r,multiple_person=nil)
	person = nil

	return if r.blank?
	if defined?(r[:last_name]).blank?
		raise r.inspect
	end

	data = { person: {duplicate: "", is_exact_duplicate: "",
               relationship: (r[:relationship] rescue "normal"),
               last_name: r[:last_name],
               first_name: r[:first_name],
               middle_name: r[:middle_name],
               birthdate: r[:birthdate],
               birth_district: r[:birth_district],
               gender: r[:gender],
               place_of_birth: r[:place_of_birth],
               hospital_of_birth: r[:hospital_of_birth],
               birth_weight: r[:birth_weight],
               type_of_birth: r[:type_of_birth],
               parents_married_to_each_other: r[:parents_married_to_each_other],
               date_of_marriage: r[:date_of_marriage],
               court_order_attached: r[:court_order_attached],
               created_at: r[:created_at],
               created_by: r[:created_by],
               updated_at: r[:updated_at],
               parents_signed: "",
               district_id_number: r[:district_id_number],
               national_serial_number: r[:national_serial_number],
               facility_serial_number: r[:facility_serial_number],
               mother: {},
               father:{},
               npid: r[:npid],
               mode_of_delivery: r[:mode_of_delivery],
               level_of_education: r[:level_of_education],
               informant: {},
              foster_mother: {},
              foster_father: {},
              form_signed: r[:form_signed],
               acknowledgement_of_receipt_date: r[:acknowledgement_of_receipt_date]
              },
               home_address_same_as_physical: "Yes",
               gestation_at_birth: r[:gestation_at_birth],
               number_of_prenatal_visits: r[:number_of_prenatal_visits],
               month_prenatal_care_started: r[:month_prenatal_care_started],
               number_of_children_born_alive_inclusive: r[:number_of_children_born_alive_inclusive],
               number_of_children_born_still_alive: r[:number_of_children_born_still_alive],
               same_address_with_mother: "",
               informant_same_as_mother: (r[:informant][:relationship_to_child] == "Mother" ? "Yes" : "No"),
               registration_type: (r[:relationship].blank? ? 'normal' : r[:relationship]),
               record_status: r[:record_status],
               _rev: r[:_rev],
               _id: r[:_id],
               request_status: r[:request_status],
               biological_parents: "",
               foster_parents: "",
               parents_details_available: "",
               copy_mother_name: "No",
               controller: "person",
               action: "create",
               district_code: (r[:district_code] rescue nil),
               facility_code: (r[:facility_code] rescue nil)
            }

    if multiple_person.present?
        data[:person][:prev_child_id] = multiple_person.id
    end

    if defined?(r.multiple_birth_id).present? && r.multiple_birth_id.present?
    	data[:person][:multiple_birth_id] = r.multiple_birth_id
    else
    	data[:person][:multiple_birth_id] = nil
    end

    if !r[:mother].blank?
                data[:person][:mother] = {
                    last_name: r[:mother][:last_name] ,
                    first_name: r[:mother][:first_name],
                    middle_name: r[:mother][:middle_name],
                    birthdate: r[:mother][:birthdate],
                    birthdate_estimated: r[:mother][:birthdate_estimated],
                    citizenship: r[:mother][:citizenship],
                    residential_country: r[:mother][:residential_country],
                    current_district: (r[:mother][:current_district]  rescue nil),
                    current_ta: (r[:mother][:current_ta]  rescue nil),
                    current_village: (r[:mother][:current_village]  rescue nil),
                    home_district: (r[:mother][:home_district]  rescue nil),
                    home_ta: (r[:mother][:home_ta]  rescue nil),
                    home_village: (r[:mother][:home_village]  rescue nil),
                    foreigner_current_district: (r[:mother][:foreigner_current_district] rescue nil),
                    foreigner_current_village: (r[:mother][:foreigner_current_village] rescue nil),
                    foreigner_current_ta: (r[:mother][:foreigner_current_ta] rescue nil),
                    foreigner_home_district: (r[:mother][:foreigner_home_district] rescue nil),
                    foreigner_home_village: (r[:mother][:foreigner_home_village] rescue nil),
                    foreigner_home_ta: (r[:mother][:foreigner_home_ta] rescue nil)
                }
    end

    if !r[:father].blank?
                data[:person][:father] =  {
                    last_name: r[:father][:last_name],
                    first_name: r[:father][:first_name],
                    middle_name: r[:father][:middle_name],
                    birthdate: r[:father][:birthdate],
                    birthdate_estimated: r[:father][:birthdate_estimated],
                    citizenship: r[:father][:citizenship],
                    residential_country: r[:father][:residential_country],
                    current_district: (r[:father][:current_district]  rescue nil),
                    current_ta: (r[:father][:current_ta]  rescue nil),
                    current_village: (r[:father][:current_village]  rescue nil),
                    home_district: (r[:father][:home_district]  rescue nil),
                    home_ta: (r[:father][:home_ta]  rescue nil),
                    home_village: (r[:father][:home_village]  rescue nil),
                    foreigner_current_district: (r[:father][:foreigner_current_district] rescue nil),
                    foreigner_current_village: (r[:father][:foreigner_current_village] rescue nil),
                    foreigner_current_ta: (r[:father][:foreigner_current_ta] rescue nil),
                    foreigner_home_district: (r[:father][:foreigner_home_district] rescue nil),
                    foreigner_home_village: (r[:father][:foreigner_home_village] rescue nil),
                    foreigner_home_ta: (r[:father][:foreigner_home_ta] rescue nil)
                }
    end

    if !r[:informant].blank?
                data[:person][:informant] =  {
                    last_name: r[:informant][:last_name],
                    first_name: r[:informant][:first_name],
                    middle_name: r[:informant][:middle_name],
                    relationship_to_person: r[:informant][:relationship_to_child],
                    current_district: r[:informant][:current_district],
                    current_ta: r[:informant][:current_ta],
                    current_village: r[:informant][:current_village],
                    addressline1: r[:informant][:addressline1],
                    addressline2: r[:informant][:addressline2],
                    phone_number: r[:informant][:phone_number]
                }
    end

    if !r[:foster_mother].blank?
                data[:person][:foster_mother] ={
                    id_number: (r[:foster_mother][:id_number] rescue nil),
                    first_name: (r[:foster_mother][:first_name] rescue nil),
                    middle_name: (r[:foster_mother][:middle_name] rescue nil),
                    last_name: (r[:foster_mother][:last_name] rescue nil),
                    birthdate: (r[:foster_mother][:birthdate] rescue nil),
                    birthdate_estimated: (r[:foster_mother][:birthdate_estimated] rescue nil),
                    current_village: (r[:foster_mother][:current_village] rescue nil),
                    current_ta: (r[:foster_mother][:current_ta] rescue nil),
                    current_district: (r[:foster_mother][:current_district] rescue nil),
                    home_village: (r[:foster_mother][:home_village] rescue nil),
                    home_ta: (r[:foster_mother][:home_ta] rescue nil),
                    home_district: (r[:foster_mother][:home_district] rescue nil),
                    home_country: (r[:foster_mother][:home_country] rescue nil),
                    citizenship: (r[:foster_mother][:citizenship] rescue nil),
                    residential_country: (r[:foster_mother][:residential_country] rescue nil),
                    foreigner_current_district: (r[:foster_mother][:foreigner_current_district] rescue nil),
                    foreigner_current_village: (r[:foster_mother][:foreigner_current_village] rescue nil),
                    foreigner_current_ta: (r[:foster_mother][:foreigner_current_ta] rescue nil),
                    foreigner_home_district: (r[:foster_mother][:foreigner_home_district] rescue nil),
                    foreigner_home_village: (r[:foster_mother][:foreigner_home_village] rescue nil),
                    foreigner_home_ta: (r[:foster_mother][:foreigner_home_ta] rescue nil)
                }
    end

    if !r[:foster_father].blank?
                data[:person][:foster_father] =   {
                    id_number: (r[:foster_father][:id_number] rescue nil),
                    first_name: (r[:foster_father][:first_name] rescue nil),
                    middle_name: (r[:foster_father][:middle_name] rescue nil),
                    last_name: (r[:foster_father][:last_name] rescue nil),
                    birthdate: (r[:foster_father][:birthdate] rescue nil),
                    birthdate_estimated: (r[:foster_father][:birthdate_estimated] rescue nil),
                    current_village: (r[:foster_father][:current_village] rescue nil),
                    current_ta: (r[:foster_father][:current_ta] rescue nil),
                    current_district: (r[:foster_father][:current_district] rescue nil),
                    home_village: (r[:foster_father][:home_village] rescue nil),
                    home_ta: (r[:foster_father][:home_ta] rescue nil),
                    home_district: (r[:foster_father][:home_district] rescue nil),
                    home_country: (r[:foster_father][:home_country] rescue nil),
                    citizenship: (r[:foster_father][:citizenship] rescue nil),
                    residential_country: (r[:foster_father][:residential_country] rescue nil),
                    foreigner_current_district: (r[:foster_father][:foreigner_current_district] rescue nil),
                    foreigner_current_village: (r[:foster_father][:foreigner_current_village] rescue nil),
                    foreigner_current_ta: (r[:foster_father][:foreigner_current_ta] rescue nil),
                    foreigner_home_district: (r[:foster_father][:foreigner_home_district] rescue nil),
                    foreigner_home_village: (r[:foster_father][:foreigner_home_village] rescue nil),
                    foreigner_home_ta: (r[:foster_father][:foreigner_home_ta] rescue nil)
                }
    end

    puts "#{data[:person][:last_name]} #{data[:person][:first_name]}"
    data[:record_status] = get_record_status(data[:record_status],data[:request_status]).upcase.squish!
    begin
    	person = PersonService.create_record(data)
    rescue Exception => e
    	log_error(e, data)
    end
   
	return person
end

def migrate_record(type, child, multiple_person = nil)
	person = nil
	case type
	when "Twin"
		person = save_data(child)
	when "Second Twin"
		if defined?(child.multiple_birth_id).present? && child.multiple_birth_id.present?			
			twin =  PersonBirthDetail.where(source_id: child.multiple_birth_id).last
			if twin.blank?
				first_twin = Child.find(child.multiple_birth_id)
				twin = migrate_record("Twin",first_twin)
			else
				person = save_data(child, Person.find(twin.person_id)) 
			end
			
		else
			puts "Multiple ID not present"
			person = save_data(child)
		end
	when "Triplet"
		person = save_data(child)
	when "Second Triplet"
		if defined?(child.multiple_birth_id).present? && child.multiple_birth_id.present?			
			triplet =  PersonBirthDetail.where(source_id: child.multiple_birth_id).last
			if triplet.blank?
				first_triplet = Child.find(child.multiple_birth_id )
				triplet = migrate_record("Triplet",first_triplet) 
			else
				person = save_data(child, Person.find(triplet.person_id)) 
			end
		else
			person = save_data(child)
		end
	when "Third Triplet"
		if defined?(child.multiple_birth_id).present? && child.multiple_birth_id.present?			
			triplet =  PersonBirthDetail.where(source_id: child.multiple_birth_id).last
			if triplet.blank?
				second_triplet = Child.find(child.multiple_birth_id )
				triplet = migrate_record("Second Triplet",second_triplet) 
			else
				person = save_data(child, Person.find(triplet.person_id)) 
			end
		else
			person = save_data(child)
		end
	else
		person = save_data(child)						
	end
	return person
end

i = 0
start_time = Time.now
CSV.foreach(OTHER_TYPES_OF_BIRTH, :headers => true) do |row|
	next unless PersonBirthDetail.where(source_id: row[0]).last.blank?
	child = Child.find(row[0])
	person = migrate_record(row[1],child)
	i = i + 1
	if i % 500 == 0
		puts "Time interval : #{(Time.now - start_time) /60}"
	end
end

puts "Finished in : #{(Time.now - start_time) /60}"