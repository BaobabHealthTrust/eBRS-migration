module MigrateInformant
	def self.new_informant(person, params, mother=nil, father=nil)

	    informant_person = nil; core_person = nil

	    informant = params[:person][:informant]
	    informant[:citizenship] = 'Malawian' if informant[:citizenship].blank?
	    informant[:residential_country] = 'Malawi' if informant[:residential_country].blank?

	    if MigrateChild.is_twin_or_triplet(params[:person][:type_of_birth].to_s,params)
	      informant_person = Person.find(params[:person][:prev_child_id]).informant
	    elsif params[:informant_same_as_mother] == 'Yes'
	      informant_person = mother
	    elsif params[:informant_same_as_father] == 'Yes'
	        informant_person = father
      elsif (params[:informant_same_as_father].blank? || params[:informant_same_as_mother].blank?) && (!mother.blank? || !father.blank?)
	    	if mother.present?
	    		informant_person = mother
	    	elsif father.present?
	    		informant_person = father

	    	end
      end

      if informant_person.blank?
	      core_person = CorePerson.create(
	          :person_type_id => PersonType.where(:name => 'Informant').last.id,
	          :created_at     => params[:person][:created_at].to_date.to_s,
	          :updated_at     => params[:person][:updated_at].to_date.to_s
	      )

	      informant_person = Person.create(
	          :person_id          => core_person.id,
	          :gender             => "N/A",
	          :birthdate          => (informant[:birthdate].blank? ? "1900-01-01" : informant[:birthdate].to_date),
	          :birthdate_estimated => (informant[:birthdate].blank? ? 1 : 0),
	          :created_at         => params[:person][:created_at].to_date.to_s,
	          :updated_at         => params[:person][:updated_at].to_date.to_s
	      )

	      PersonName.create(
	          :person_id   => informant_person.id,
	          :first_name  => (informant[:first_name] rescue "@@@@@"),
	          :middle_name => informant[:middle_name],
	          :last_name   => (informant[:last_name] rescue "@@@@@"),
	          :created_at  => params[:person][:created_at].to_date.to_s,
	          :updated_at  => params[:person][:updated_at].to_date.to_s
	      )

	      cur_district_id         = Location.locate_id_by_tag(informant[:current_district], 'District')
	      cur_ta_id               = Location.locate_id(informant[:current_ta], 'Traditional Authority', cur_district_id)
	      cur_village_id          = Location.locate_id(informant[:current_village], 'Village', cur_ta_id)

	      home_district_id        = Location.locate_id_by_tag(informant[:home_district], 'District')
	      home_ta_id              = Location.locate_id(informant[:home_ta], 'Traditional Authority', home_district_id)
	      home_village_id         = Location.locate_id(informant[:home_village], 'Village', home_ta_id)
	     
	      citizenship = MigrateChild.search_citizenship(informant[:citizenship].squish)
	      residential_country = MigrateChild.search_citizenship(informant[:residential_country].squish)

	      PersonAddress.create(
	          :person_id          => core_person.id,
	          :current_district   => cur_district_id,
	          :current_ta         => cur_ta_id,
	          :current_village    => cur_village_id,
	          :home_district   => home_district_id,
	          :home_ta            => home_ta_id,
	          :home_village       => home_village_id,
	          :citizenship            => citizenship.id,
	          :residential_country    => residential_country.id,
	          :address_line_1         => informant[:addressline1],
	          :address_line_2         => informant[:addressline2],
	          :created_at         => params[:person][:created_at].to_date.to_s,
	          :updated_at         => params[:person][:updated_at].to_date.to_s
	      )


	    end

      person_id = person.id

      if informant_person.blank?
      	raise params[:_id].inspect
      end

      informant_id = informant_person.id

	    PersonRelationship.create(
	        person_a: person_id, person_b: informant_id,
	        person_relationship_type_id: PersonRelationType.where(name: 'Informant').last.id,
	        created_at: params[:person][:created_at].to_date.to_s,
	        updated_at: params[:person][:updated_at].to_date.to_s
	    )


	    if informant[:phone_number].present?
	      PersonAttribute.create(
	          :person_id                => informant_person.id,
	          :person_attribute_type_id => PersonAttributeType.where(name: 'cell phone number').last.id,
	          :value                    => informant[:phone_number],
	          :voided                   => 0,
	          :created_at               => params[:person][:created_at].to_date.to_s,
	          :updated_at               => params[:person][:updated_at].to_date.to_s
	      )
	    end

	    informant_person
	end
end