class ChildValidator < ActiveModel::Validator

	def validate(child)
    
		if child.first_name.blank?
				child.errors[:child_first_name] << "cannot be blank" 
		end
			
		if child.last_name.blank?
				child.errors[:child_surname] << "cannot be blank" 
		end
			
		if child.birthdate.present?
			unless valid_dob?(child.birthdate) 
				child.errors[:child_birthdate] << "has invalid date : (#{child.birthdate})" 
			end
		end
			
		if child.gender.blank?
			child.errors[:child_gender] << "cannot be blank" 
		end
			
		if child.relationship.downcase == "normal"
		
			if child.birthdate.blank?
				child.errors[:child_birthdate] << "cannot be blank" 
			end

			if child.mother.first_name.blank?
				child.errors[:mother_first_name] << "cannot be blank" 
			end

			if child.mother.last_name.blank?
				child.errors[:mother_surname] << "cannot be blank" 
			end
			
			if child.mother.birthdate.present?
				unless valid_dob?(child.mother.birthdate) 
						child.errors[:mother_birthdate] << "has invalid date (#{child.mother.birthdate})" 
				end
			end
		
		end
		
		if child.record_status.blank?
		child.errors[:record_status] << "cannot be blank"
		end

		if child.request_status.blank?
		child.errors[:request_status] << "cannot be blank"
		end

		if child.record_status_code.blank?
		child.errors[:record_status_code] << "cannot be blank"
		end

		if child.request_status_code.blank?
		child.errors[:request_status_code] << "cannot be blank"
		end
		
		if child.parents_married_to_each_other == 'Yes'
			if child.father.first_name.blank?
				child.errors[:father_first_name] << "cannot be blank" 
			end
				
			if child.father.last_name.blank?
				child.errors[:father_surname] << "cannot be blank" 
			end
		
			if child.father.birthdate.present?
				unless valid_dob?(child.father.birthdate) 
						child.errors[:father_birthdate] << "has invalid date : (#{child.father.birthdate})" 
				end
			end
		end
						
		if child.relationship.downcase == 'adopted'
		
			if child.foster_mother.first_name.blank? && child.foster_father.first_name.blank?
				child.errors[:foster_mother_first_name] << "cannot be blank" if child.foster_mother.first_name.blank?
				child.errors[:foster_father_first_name] << "cannot be blank" if child.foster_father.first_name.blank?
			end

			if child.foster_mother.last_name.blank? && child.foster_father.last_name.blank?
				child.errors[:foster_mother_last_name] << "cannot be blank" if child.foster_mother.last_name.blank?
				child.errors[:foster_father_last_name] << "cannot be blank" if child.foster_father.last_name.blank?
			end

			if child.foster_mother.citizenship.blank? && child.foster_father.citizenship.blank?
				child.errors[:foster_mother_citizenship] << "cannot be blank" if child.foster_mother.citizenship.blank?
				child.errors[:foster_father_citizenship] << "cannot be blank" if child.foster_father.citizenship.blank?
			end

			if child.adoption_court_order.blank?
				child.errors[:adoption_court_order] << "cannot be blank"
			end
			
		end

		if child.relationship.downcase == 'abandoned' || child.relationship.downcase == 'orphaned' || child.relationship.downcase == 'adopted'
				
			if child.informant.first_name.blank? 
				child.errors[:informant_first_name] << "cannot be blank"
			end

			if child.informant.last_name.blank? 
				child.errors[:informant_last_name] << "cannot be blank" 
			end

			if child.informant.relationship_to_child.blank?
				child.errors[:informant_relationship_to_child] << "cannot be blank"
			end
			
		end

	end

	def valid_dob?(dob)
		valid_dob = Date.parse(dob) rescue nil
		return valid_dob.present? ? true : false
	end
  
end
