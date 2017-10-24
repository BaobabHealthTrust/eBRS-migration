module MigrateMother
	def self.new_mother(person, params,mother_type)
      begin
      mother_person = nil
	  if MigrateChild.is_twin_or_triplet(params[:person][:type_of_birth],params)
	      mother_person = Person.find(params[:person][:prev_child_id]).mother
      else
	        if mother_type =="Adoptive-Mother"
	          mother = params[:person][:foster_mother]
	        else
	          mother = params[:person][:mother]
	        end
	        if mother[:first_name].blank?
	          return nil
	        end

	        core_person = CorePerson.create(
	            :person_type_id     => PersonType.where(name: mother_type).last.id,
	            :created_at         => params[:person][:created_at].to_date.to_s,
	            :updated_at         => params[:person][:updated_at].to_date.to_s
	        )

	        mother[:citizenship] = 'Malawian' if mother[:citizenship].blank?
	        mother[:residential_country] = 'Malawi' if mother[:residential_country].blank?


	        mother_person = Person.create(
	            :person_id          => core_person.id,
	            :gender             => 'F',
	            :birthdate          => ((mother[:birthdate].to_date.present? rescue false) ? mother[:birthdate].to_date : "1900-01-01"),
	            :birthdate_estimated => ((mother[:birthdate].to_date.present? rescue false) ? 0 : 1),
	            :created_at         => params[:person][:created_at].to_date.to_s,
	            :updated_at         => params[:person][:updated_at].to_date.to_s
	        )

	        person_name = PersonName.create(
	            :person_id          => core_person.id,
	            :first_name         => (mother[:first_name] rescue "@@@@@"),
	            :middle_name        => mother[:middle_name],
	            :last_name          => (mother[:last_name] rescue "@@@@@"),
	            :created_at         => params[:person][:created_at].to_date.to_s,
	            :updated_at         => params[:person][:updated_at].to_date.to_s
	        )

		      current_district_id        = Location.where(:name =>"Other").last.id
		      current_ta_id              = Location.where(:name =>"Other").last.id
		      current_village_id         = Location.where(:name =>"Other").last.id


		      if mother[:current_district].present?
		         cur_district_id         = Location.locate_id_by_tag(mother[:current_district].squish, 'District')
		         if cur_district_id.blank?
		            cur_district_id         = Location.where(:name =>"Other").last.id
		            current_district_other  = mother[:current_district]
		         end
		      elsif mother[:foreigner_current_district].present?
		            cur_district_id         = Location.where(:name =>"Other").last.id
		            current_district_other  = mother[:foreigner_current_district]
		      end

		      if mother[:current_ta].present?
		          cur_ta_id               = Location.locate_id(mother[:current_ta].squish, 'Traditional Authority', cur_district_id)
		          if cur_ta_id.blank?
		             cur_ta_id         = Location.where(:name =>"Other").last.id
		             current_ta_other  = mother[:current_ta]
		          end
		      elsif mother[:foreigner_current_ta].present?
		          cur_ta_id         = Location.where(:name =>"Other").last.id
		          current_ta_other  = mother[:foreigner_current_ta]
		      end

		      if mother[:current_village].present?
		          cur_village_id          = Location.locate_id(mother[:current_village].squish, 'Village', cur_ta_id)
		          if cur_village_id.blank?
		             cur_village_id         = Location.where(:name =>"Other").last.id
		             cur_village_other  = mother[:current_village]
		          end
		      elsif mother[:foreigner_current_village].present?
		          cur_village_id         = Location.where(:name =>"Other").last.id
		          current_village_other  = mother[:foreigner_current_village]
		      end

		      home_district_id        = Location.where(:name =>"Other").last.id
		      home_ta_id              = Location.where(:name =>"Other").last.id
		      home_village_id         = Location.where(:name =>"Other").last.id

		      if mother[:home_district].present?
		         home_district_id  = Location.locate_id_by_tag(mother[:home_district].squish, 'District')
		         if home_district_id.blank?
		            home_district_id = Location.where(:name =>"Other").last.id
		            home_district_other  = mother[:home_district].squish
		         end
		      elsif mother[:foreigner_home_district].present?
		            home_district_id         = Location.where(:name =>"Other").last.id
		            home_district_other  = mother[:foreigner_home_district].squish
		      end
		      if mother[:home_ta].present?
		          home_ta_id   = Location.locate_id(mother[:home_ta].squish, 'Traditional Authority', home_district_id)
		          if home_ta_id.blank?
		             home_ta_id  = Location.where(:name =>"Other").last.id
		             home_ta_other  = mother[:home_ta].squish
		          end
		      elsif mother[:foreigner_home_ta].present?
		          home_ta_id  = Location.where(:name =>"Other").last.id
		          home_district_other  = mother[:foreigner_home_ta]
		      end

		      if mother[:current_village].present?
		          home_village_id = Location.locate_id(mother[:current_village].squish, 'Village', home_ta_id)
		          if home_village_id.blank?
		             home_village_id         = Location.where(:name =>"Other").last.id
		             home_village_other  = mother[:home_village]
		          end
		      elsif mother[:foreigner_home_village].present?
		          home_village_id = Location.where(:name =>"Other").last.id
		          home_village_other  = mother[:foreigner_home_village]
		      end

	        citizenship = MigrateChild.search_citizenship(mother[:citizenship].squish)
	        residential_country = MigrateChild.search_citizenship(mother[:residential_country].squish)


	      	person_address = PersonAddress.create(
	            :person_id          => core_person.id,
	            :current_district   => cur_district_id,
	            :current_ta         => cur_ta_id,
	            :current_village    => cur_village_id,
	            :home_district   => home_district_id,
	            :home_ta            => home_ta_id,
	            :home_village       => home_village_id,

          		:current_district_other   => (current_district_other  rescue nil),
          		:current_ta_other         => (current_ta_other  rescue nil),
          		:current_village_other    => (current_village_other  rescue nil),
          		:home_district_other      => (home_district_other  rescue nil),
          		:home_ta_other            => (home_ta_other  rescue nil),
          		:home_village_other       => (home_village_other  rescue nil),

	            :citizenship            => citizenship.id,
	            :residential_country    => residential_country.id,
	            :address_line_1         => (params[:informant_same_as_mother].present? && params[:informant_same_as_mother] == "Yes" ? params[:person][:informant][:addressline1] : nil),
	            :address_line_2         => (params[:informant_same_as_mother].present? && params[:informant_same_as_mother] == "Yes" ? params[:person][:informant][:addressline2] : nil),
	            :created_at         => params[:person][:created_at].to_date.to_s,
	            :updated_at         => params[:person][:updated_at].to_date.to_s
	        )



	    end

	    unless mother_person.blank?
	      PersonRelationship.create(
	              person_a: person.id, person_b: mother_person.person_id,
	              person_relationship_type_id: PersonRelationType.where(name: mother_type).last.id,
	              created_at: params[:person][:created_at].to_date.to_s,
	              updated_at: params[:person][:updated_at].to_date.to_s
	      )
	    end
		rescue Exception => e
				raise "#{e.message} >>>>>>>>>>>>>>>>>>>> #{params}".inspect
		end

	    mother_person
	end
end
