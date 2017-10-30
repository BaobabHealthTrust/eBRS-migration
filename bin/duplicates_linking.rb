status = [["DC OPEN".soundex, "POTENTIAL DUPLICATE".soundex],["DC OPEN".soundex, "POTENTIAL-DUPLICATE".soundex],["HQ OPEN".soundex,"POTENTIAL DUPLICATE".soundex],["HQ OPEN".soundex,"TBA-POTENTIAL DUPLICATE".soundex],["DUPLICATE".soundex,"VOIDED".soundex]] 
i = 0
linked = 0
Child.by_record_status_code_and_request_status_code.keys(status).each do |child|
	person_details = PersonBirthDetail.where(source_id: child.id).last
	next if person_details.blank?
    duplicates = Child.by_child_demographics.keys([[child[:first_name].soundex, child[:last_name].soundex,child[:gender],child[:birthdate],child[:mother][:first_name].soundex,child[:mother][:last_name].soundex]]).each rescue []
    if duplicates.present?
        potential_duplicate = PotentialDuplicate.create(person_id: person_details.person_id,created_at: (child.created_at rescue Time.now))
        if potential_duplicate.present?
             duplicates.each do |result|
                next if child.id == result.id
                duplicate_details = PersonBirthDetail.where(source_id: result.id).last
                next if duplicate_details.blank?
                potential_duplicate.create_duplicate(duplicate_details.person_id,child.created_at)
            end
        end
        linked = linked + 1
    end
    i = i + 1
    if i % 100
        puts "#{i} duplicates linked"
    end
end

puts "#{linked} out of #{i} duplicate linked" if i > 0

