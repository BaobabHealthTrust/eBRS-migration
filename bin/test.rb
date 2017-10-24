require'migration-lib/migrate_child'
@file_path = "#{Rails.root}/app/assets/data/"
@multiple_births = "#{Rails.root}/app/assets/data/multiple_births.csv"
@dump_files = "#{Rails.root}/app/assets/data/migration_dumps/"

def prepare_dump_files

	core_person ="INSERT INTO core_person (person_id,person_type_id,created_at,updated_at) VALUES "
	person = "INSERT INTO person () VALUES "
	person_name = "INSERT INTO person_name () VALUES "
	person_addresses = "INSERT INTO person_addresses () VALUES ()"
	person_relationship = "INSERT INTO person_relationship () VALUES "
	person_attribute = "INSERT INTO person_attribute () VALUES "
	person_birth_details = "INSERT INTO person_birth_details () VALUES "
	potential_duplicate = "INSERT INTO potential_duplicate () VALUES "
	identifier_allocation_queue = "INSERT INTO identifier_allocation_queue () VALUES "
	person_record_status = "INSERT INTO person_record_status () VALUES "

	`cd #{@dump_files} && [ -f core_person.sql ] && rm core_person.sql && [ -f person_name.sql ] && rm person_name.sql && [ -f person_addresses.sql ] && rm person_addresses.sql && [ -f person_relationship.sql ] && rm person_relationship.sql && [ -f person_attribute.sql ] && rm person_attribute.sql && [ -f identifier_allocation_queue.sql ] && rm identifier_allocation_queue.sql && [ -f person_birth_details.sql ] && rm person_birth_details.sql && [ -f potential_duplicate.sql ] && rm potential_duplicate.sql && [ -f person_record_status.sql ] && rm person_record_status.sql`
    `cd #{@dump_files} && touch core_person.sql person.sql person_name.sql person_addresses.sql person_attribute.sql person_identifier.sql person_relationship.sql person_birth_details.sql potential_duplicate.sql identifier_allocation_queue.sql potential_duplicate.sql person_record_status.sql`
    `echo -n '#{core_person}' >> #{@dump_files}core_person.sql`
    `echo -n '#{person}' >> #{@dump_files}person.sql`
    `echo -n '#{person_name}' >> #{@dump_files}person_name.sql`
    `echo -n '#{person_addresses}' >> #{@dump_files}person_addresses.sql`
    `echo -n '#{person_relationship}' >> #{@dump_files}person_relationship.sql`
    `echo -n '#{person_attribute}' >> #{@dump_files}person_attribute.sql`
    `echo -n '#{person_birth_details}' >> #{@dump_files}person_birth_details.sql`
    `echo -n '#{person_record_status}' >> #{@dump_files}person_record_status.sql`
    `echo -n '#{potential_duplicate}' >> #{@dump_files}potential_duplicate.sql`
    `echo -n '#{identifier_allocation_queue}' >> #{@dump_files}identifier_allocation_queue.sql`
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

def get_prev_child_id

   data = {}

    CSV.foreach("#{@file_path}/multiple_births.csv") do |row|
         data[row[0]] = row[1]
    end

  return data
end

def save_record(record, district_id_number)

end

def transform_data(record, ids)

	if !record[:person][:multiple_birth_id].blank?
	  record[:person][:prev_child_id] = ids[record[:person][:multiple_birth_id]]
	else
		 #multiple_birth_id missing, log this record to suspected file for further analysis
	end

    return record
end

def get_record_status(rec_status, req_status)

    puts "<<<<<<<<<<< #{rec_status}   #{req_status}"

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

def func

  data ={}
  records = Child.all.limit(20).each
  count = 1
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
				   registration_type: r[:relationship],
				   record_status: r[:record_status],
				   _rev: r[:_rev],
				   _id: r[:_id],
				   count: count,
				   request_status: r[:request_status],
				   copy_mother_name: "No",
				   controller: "person",
				   action: "create"
				  }


=begin
            if ["Twin","Triplet","Second Twin","Second Triplet","Third Triplet"].include? data[:person][:type_of_birth]
            	if data[:person][:type_of_birth] == "Twin" || data[:person][:type_of_birth] == "Triplet"
            		 row = "#{data[:person][:type_of_birth]},#{data[:_id]},"
            	     write_log(@multiple_births, row)
            	else
            	    #1. build a json object
            	    #2. read the multiple_birth csv and populate the hash
            	    #3. fetch records filter them by type_of_birth. Type of birth should be equal
            	    #   Second Twin,Second Triplet or Third Triplet
            	    #4. from each record filtered, use the multiple_birth_id to lookup in the hash
            	    #   and pick the person_id
            	    #5. change the value of data[:person][:prev_child_id]= person_id
            	    #6. call the PersonService.create_record method...
            	    #7. change the PersonAttribute

            	end


        end
=end
     #puts "Location found: #{	PersonService.verify_location('Mother','District',data[:person][:mother][:current_district])}"
     puts ">>>>>>>>>>>>>>Number: #{count}"
     count = count + 1
   end

end


def kick_start

	total_records = Child.count
	page_size = 100
	total_pages = (total_records / page_size) + (total_records % page_size)
	current_page = 1

	while (current_page < total_pages) do
        puts "<<<<<<<<<<<<<<<< Page number: #{current_page}"
        puts "\n"
        test_method(current_page, page_size)
		    current_page = current_page + 1
	end
end

def test_method(current_pge, pge_size)

	data ={}
=begin
	data = {person:{duplicate:"", is_exact_duplicate:"", relationship:"normal", last_name:"Ndala",
	        first_name:"Zimbota", middle_name:"", birthdate:"30/Oct/2015", birth_district:"Blantyre",
	        gender:"Male", place_of_birth:"Hospital", hospital_of_birth:"Mlambe Hospital",
	        birth_weight:"3.700", type_of_birth:"Single", parents_married_to_each_other:"Yes",
	        court_order_attached:"", parents_signed:"", national_serial_number:"00000214140",
	        district_id_number:"BT/0000125/2016", mother:{last_name:"Mkuwu", first_name:"Angella",
	        middle_name:"", birthdate:"22/Oct/1985", birthdate_estimated:"",
	        citizenship:"Malawian", residential_country:"Malawi", current_district:"Blantyre",
	        current_ta:"Machinjiri", current_village:"Machinjiri", home_district:"Mangochi",
	        home_ta:"Mponda", home_village:"Michesi"}, mode_of_delivery:"SVD",
	        level_of_education:"Secondary", father:{birthdate_estimated:"",
	        residential_country:"Malawi"}, informant:{last_name:"Mkuwu", first_name:"Angella",
	        middle_name:"", relationship_to_person:"Mother", current_district:"Blantyre",
	        current_ta:"Machinjiri", current_village:"Machinjiri", addressline1:"",
	        addressline2:"", phone_number:"0993853933"}, form_signed:"Yes",
	        acknowledgement_of_receipt_date:"2015-11-06 160456 -1000".to_date.strftime("%d/%b/%Y")},
	        home_address_same_as_physical:"Yes", gestation_at_birth:"37", number_of_prenatal_visits:"4",
	        month_prenatal_care_started:"3", number_of_children_born_alive_inclusive:"2",
	        number_of_children_born_still_alive:"2", same_address_with_mother:"",
	        informant_same_as_mother:"Yes", registration_type:"normal",
	        record_status:"PRINTED", _rev:"7-213580c4bcfdf268c901d5c3b11617c2",
	        _id:"0275f9967f6069e00bbf2d310871a2f8", request_status:"DISPATCHED",
	        biological_parents:"", foster_parents:"", parents_details_available:"",
	        copy_mother_name:"No", controller:"person", action:"create"}
=end
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
					   registration_type: r[:relationship],
					   record_status: r[:record_status],
					   _rev: r[:_rev],
					   _id: r[:_id],
					   request_status: r[:request_status],
					   biological_parents: "",
					   foster_parents: "",
					   parents_details_available: "",
					   copy_mother_name: "No",
					   controller: "person",
					   action: "create"
					  }

			transform_record(data)
   end
end

def self.verify_location(owner, location_type, data)
	location_found = false

 if owner == "Mother"

	 if location_type == "TA"
				cur_district_id  = Location.locate_id_by_tag(data, 'District')
				cur_ta_id        = Location.locate_id(data, 'Traditional Authority', cur_district_id)
				home_district_id  = Location.locate_id_by_tag(data, 'District')
				home_ta_id        = Location.locate_id(data, 'Traditional Authority', home_district_id)

			unless cur_ta_id.blank? || home_ta_id.blank?
				location_found = true
			else
				location_found = false
			end

	 elsif location_type == "Village"

				cur_district_id  = Location.locate_id_by_tag(data, 'District')
				cur_ta_id        = Location.locate_id(data, 'Traditional Authority', cur_district_id)
				cur_village_id   = Location.locate_id(data, 'Village', cur_ta_id)
				home_district_id  = Location.locate_id_by_tag(data, 'District')
				home_ta_id        = Location.locate_id(data, 'Traditional Authority', home_district_id)
				home_village_id   = Location.locate_id(data, 'Village', home_ta_id)

			unless cur_village_id.blank? || home_village_id.blank?
				location_found = true
			else
				location_found = false
			end

	 elsif location_type == "District"

			 cur_district_id  = Location.locate_id_by_tag(data, 'District')
			 home_district_id  = Location.locate_id_by_tag(data, 'District')

			unless cur_district_id.blank? || home_district_id.blank?
				location_found = true
			else
				location_found = false
			end
	 else
			citizenship = Location.where(country: data).last.id rescue nil
			residential_country = Location.where(name: data).last.id rescue nil

				unless citizenship.blank? || residential_country.blank?
					location_found = true
				else
					location_found = false
				end
	 end

 else

	 if location_type == "TA"
				cur_district_id  = Location.locate_id_by_tag(data, 'District')
				cur_ta_id        = Location.locate_id(data, 'Traditional Authority', cur_district_id)
				home_district_id  = Location.locate_id_by_tag(data, 'District')
				home_ta_id        = Location.locate_id(data, 'Traditional Authority', home_district_id)

				unless cur_ta_id.blank? || home_ta_id.blank?
					location_found = true
				else
					location_found = false
				end

	 elsif location_type == "Village"

				cur_district_id  = Location.locate_id_by_tag(data, 'District')
				cur_ta_id        = Location.locate_id(data, 'Traditional Authority', cur_district_id)
				cur_village_id   = Location.locate_id(data, 'Village', cur_ta_id)
				home_district_id  = Location.locate_id_by_tag(data, 'District')
				home_ta_id        = Location.locate_id(data, 'Traditional Authority', home_district_id)
				home_village_id   = Location.locate_id(data, 'Village', home_ta_id)

				unless cur_village_id.blank? || home_village_id.blank?
						location_found = true
				else
						location_found = false
				end

	 elsif location_type == "District"

				cur_district_id  = Location.locate_id_by_tag(data, 'District')
				home_district_id  = Location.locate_id_by_tag(data, 'District')

				unless cur_district_id.blank? || home_district_id.blank?
					location_found = true
				else
					location_found = false
				end
	else
			citizenship = Location.where(country: data).last.id rescue nil
			residential_country = Location.where(name: data).last.id rescue nil

			unless citizenship.blank? || residential_country.blank?
					location_found = true
			else
					location_found = false
			end

	end

end

 return location_found
end


def format_date(date)
	unless date.blank?
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
	 end
	return date
end

def try_loc
	puts " #{self.verify_location('Mother','District','Blantyre')}"
end

#try_loc

func
#get_prev_child_id
#prepare_dump_files
