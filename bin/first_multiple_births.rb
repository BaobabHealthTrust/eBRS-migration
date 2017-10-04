
require'migration-lib/lib'
require'migration-lib/person_service'
@file_path = "#{Rails.root}/app/assets/data/"
@error_log = "#{Rails.root}/app/assets/data/error_log.txt"
@multiple_births = "#{Rails.root}/app/assets/data/multiple_births.csv"
@suspected = "#{Rails.root}/app/assets/data/suspected.txt"

User.current = User.last

Duplicate_attribute_type_id = PersonAttributeType.where(name: 'Duplicate Ben').first.id

def get_record_status(rec_status, req_status)


 status = {"DC OPEN" => {'ACTIVE' =>'DC-ACTIVE',
      							'IN-COMPLETE' =>'DC-INCOMPLETE',
      							'COMPLETE' =>'DC-COMPLETE',
      							'DUPLICATE' =>'DC-DUPLICATE',
      							'POTENTIAL DUPLICATE' =>'DC-POTENTIAL DUPLICATE',
      							'GRANTED' =>'DC-GRANTED',
      							'PENDING' => 'DC-PENDING',
      							'CAN-REPRINT' => 'DC-CAN-REPRINT',
      							'REJECTED' =>'DC-REJECTED'},
		"POTENTIAL DUPLICATE" => {'ACTIVE' =>'FC-POTENTIAL DUPLICATE'},
		"POTENTIAL-DUPLICATE" =>{'VOIDED'=>'DC-VOIDED'},
		"VOIDED" =>{'CLOSED' =>'DC-VOIDED',
					'CLOSED' =>'HQ-VOIDED'},
		"PRINTED" =>{'CLOSED' =>'HQ-PRINTED',
					'DISPATCHED' =>'HQ-DISPATCHED'},
		"HQ-PRINTED" =>{'CLOSED' =>'HQ-PRINTED'},
		"HQ-DISPATCHED" =>{'DISPATCHED' =>'HQ-DISPATCHED'},
		"HQ-CAN-PRINT" =>{'CAN PRINT' =>'HQ-CAN-REPRINT'},
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


   return status[rec_status][req_status]

end

def format_csv_file(file)

    raw_csv = File.read("#{file}")[0...-2]

    File.open("#{file}", "w") {|csv| csv.puts raw_csv << ""}

end


def mother_records

	 mothers = []

	 records = PersonName.find_by_sql("SELECT P.person_id,first_name,last_name,birthdate,birthdate_estimated,home_village,home_ta,citizenship,home_district
	 	                               FROM person_name PN INNER JOIN person P ON P.person_id = PN.person_id
	 	                               INNER JOIN person_addresses PA ON PA.person_id = P.person_id WHERE PN.person_id
	 	                               IN (select person_b from person_relationship where person_relationship_type_id = 6)")

     (records || []).each do |rec|
         mothers << {'person_id' => rec.person_id,
         	        'first_name' => rec.first_name,
                   'last_name' => rec.last_name,
                   'birthdate' => rec.birthdate,
                   'birthdate_estimated' => rec.birthdate_estimated,
                   'home_village' => rec.home_village,
                   'home_ta' => rec.home_ta,
                   'citizenship'=> rec.citizenship,
                   'home_district' => rec.home_district }
     end

     return mothers
end

def log_error(error_msge, content)

    
    if !File.exists?(@error_log)
           file = File.new(@error_log, 'w')
    else

       File.open(@error_log, 'a') do |f|
          f.puts "#{error_msge} >>>>>> #{content}"

      end
    end

 end

def write_log(filename,content)

    if !File.exists?(filename)
           file = File.new(filename, 'w')
    else
       File.open(filename, 'a') do |f|
          f.puts "#{content}"
      end
    end
end

def save_full_record(params, district_id_number)

   begin
        params[:record_status] = get_record_status(params[:record_status],params[:request_status]).upcase.squish!
    	person = PersonService.create_record(params)

    	row = "#{params[:_id]},#{person.person_id},"

        write_log(@multiple_births,row)

      if !person.blank?
        
        record_status = PersonRecordStatus.where(person_id: person.person_id).first
        
        	#status = get_record_status(params[:record_status],params[:request_status]).upcase.squish!
	        #record_status.update_attributes(status_id: Status.where(name: status).last.id)
	    assign_district_id(person.person_id, (district_id_number.to_s rescue "NULL"))
	    puts "Record for #{params[:person][:first_name]} #{params[:person][:middle_name]} #{params[:person][:last_name]} Created ............. "

        
      end

   rescue StandardError => e
          log_error(e.message, params)
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

def assign_district_id(person_id, ben)

	ben_exist = PersonBirthDetail.where(district_id_number: ben)

	if ben_exist.blank?
		birth_details = PersonBirthDetail.where(person_id: person_id).first
	    birth_details.update_attributes(district_id_number: ben)

	else
		PersonAttribute.create(value: ben, person_id: person_id, person_attribute_type_id: Duplicate_attribute_type_id )
		(ben_exist || []).each do |r|
			r.update_attributes(district_id_number: nil)
			PersonAttribute.create(value: ben, person_id: r.person_id, person_attribute_type_id: Duplicate_attribute_type_id)
		 end
	end

end


def build_client_record(current_pge, pge_size)

  data ={}

  records = Child.all.page(current_pge).limit(pge_size)

  (records || []).each do |r|

   data = { person: {duplicate: "", is_exact_duplicate: "", 
				   relationship: r[:relationship], 
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
				   court_order_attached: r[:court_order_attached],
				   created_at: r[:created_at],
				   created_by: r[:created_by],
				   updated_at: r[:updated_at], 
				   parents_signed: "",
				   national_serial_number: r[:national_serial_number],
				   district_id_number: r[:district_id_number],
				   prev_child_id: "", 
				   mother:{
				     last_name: r[:mother][:last_name], 
				     first_name: r[:mother][:first_name], 
				     middle_name: r[:mother][:middle_name], 
				     birthdate: r[:mother][:birthdate], 
				     birthdate_estimated: r[:mother][:birthdate_estimated], 
				     citizenship: r[:mother][:citizenship], 
				     residential_country: r[:mother][:residential_country], 
				     current_district: r[:mother][:current_district], 
				     current_ta: r[:mother][:current_ta], 
				     current_village: r[:mother][:current_village], 
				     home_district: r[:mother][:home_district], 
				     home_ta: r[:mother][:home_ta], 
				     home_village: r[:mother][:home_village]
				  }, 
				   mode_of_delivery: r[:mode_of_delivery], 
				   level_of_education: r[:level_of_education], 
				   father: {
				     birthdate_estimated: r[:father][:birthdate_estimated], 
				     residential_country: r[:father][:residential_country]
				  }, 
				   informant: {
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
				  }, 
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
				   informant_same_as_father: (r[:informant][:relationship_to_child] == "Father" ? "Yes" : "No"), 
				   registration_type: r[:relationship],
				   record_status: r[:record_status],
				   _rev: r[:_rev],
				   _id: r[:_id],
				   request_status: r[:request_status], 
				   copy_mother_name: "No", 
				   controller: "person", 
				   action: "create"
				  }

			if data[:person][:type_of_birth] == "Twin" || data[:person][:type_of_birth] == "Triplet"
				if precision_level(mother_records, data) == 7
            	   #potential duplicate for the mother exist...
            	   #log the record for further analysis
            	else
            		save_full_record(data, data[:person][:district_id_number])
            	end
			end
	end
            
end

def initiate_migration

	total_records = Child.count
	page_size = 100
	total_pages = (total_records / page_size) + (total_records % page_size)
	current_page = 1

	while (current_page < total_pages) do

        build_client_record(current_page, page_size)
        current_page = current_page + 1
	end
  	 
     format_csv_file(@multiple_births)
	 puts "\n"
	 puts "Completed migration of 2 of 3 batch of records! To verify the completeness, please review the log files..."
     puts "\n"
end

initiate_migration
