status = [["DC OPEN".soundex, "POTENTIAL DUPLICATE".soundex],["DC OPEN".soundex, "POTENTIAL-DUPLICATE".soundex],["HQ OPEN".soundex,"POTENTIAL DUPLICATE".soundex],["HQ OPEN".soundex,"TBA-POTENTIAL DUPLICATE".soundex],["DUPLICATE".soundex,"VOIDED".soundex]] 
i = 0
Child.by_record_status_code_and_request_status_code.keys(status).each do |child|
		break unless SETTINGS['potential_search']
		person_details = PersonBirthDetail.where(source_id: child.id).last
		next if person_details.blank?
		person = {}
        person["id"] = person_details.person_id
        person["first_name"]= child.first_name 
        person["last_name"] =  child.last_name
        person["middle_name"] = child.middle_name rescue ""
        person["gender"] = child.gender
        person["birthdate"]= child.birthdate.to_date.strftime('%Y-%m-%d')
        person["birthdate_estimated"] = child.birthdate_estimated
	    person["place_of_birth"] = child.place_of_birth
        person["district"] = child.birth_district
        person["nationality"]=  child.mother.citizenship rescue "Malawian"

        person["mother_first_name"]= child.mother.first_name rescue ""
        person["mother_last_name"] = child.mother.last_name rescue ""
        person["mother_middle_name"] = child.mother.middle_name rescue ""

        person["mother_home_district"] = child.mother.home_district rescue ""
        person["mother_home_ta"] = child.mother.home_ta rescue ""
        person["mother_home_village"] = child.mother.home_village rescue ""

        person["mother_current_district"] = child.mother.current_district rescue ""
        person["mother_current_ta"] = child.mother.current_ta rescue ""
        person["mother_current_village"] = child.mother.current_village rescue ""

        person["father_first_name"]= child.father.first_name  rescue ""
        person["father_last_name"] =  child.father.last_name rescue ""
        person["father_middle_name"] = child.father.middle_name rescue ""

        person["father_home_district"] = child.father.home_district  rescue ""
        person["father_home_ta"] = child.father.home_ta rescue ""
        person["father_home_village"] = child.father.home_village rescue ""

        person["father_current_district"] = child.father.current_district rescue ""
        person["father_current_ta"] = child.father.current_ta rescue ""
        person["father_current_village"] = child.father.current_village rescue ""

        @results = []

        duplicates = SimpleElasticSearch.query_duplicate_coded(person,SETTINGS['duplicate_precision']) 
	
        duplicates.each do |dup|
            next if DuplicateRecord.where(person_id: person['id']).present?
            @results << dup if PotentialDuplicate.where(person_id: dup['_id']).blank? 
        end  
        
        if @results.present?
           potential_duplicate = PotentialDuplicate.create(person_id: person_details.person_id,created_at: (child.created_at rescue Time.now))
           if potential_duplicate.present?
                 @results.each do |result|
                    potential_duplicate.create_duplicate(result["_id"])
                 end
           end
        end

        i = i + 1
        if i % 5
        	puts "Linked #{i} duplicates"
        end
end
