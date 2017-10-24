module PersonService
  require 'bean'
  require 'json'

  def self.create_record(params)

    registration_type   = params[:person][:relationship].downcase #rescue (raise params.inspect)
    person  = MigrateChild.new_child(params)

    case registration_type
      when "normal"
        mother   = MigrateMother.new_mother(person, params, 'Mother')
        father   = MigrateFather.new_father(person, params,'Father')
        informant = MigrateInformant.new_informant(person, params, mother, father)
      when "orphaned"
        mother   = Lib.new_mother(person, params, 'Adoptive-Mother') #rescue nil
        father   = Lib.new_father(person, params,'Adoptive-Father') #rescue nil
        informant = MigrateInformant.new_informant(person, params, mother, father)
      when "adopted"

        foster_mother = params[:person][:foster_mother].values.reject{|e| e.blank?} rescue nil
        foster_father = params[:person][:foster_father].values.reject{|e| e.blank?} rescue nil

        if params[:biological_parents] == "Both" || params[:biological_parents] =="Mother"
          mother   =MigrateMother.new_mother(person, params, 'Mother')
        end
        if params[:biological_parents] == "Both" || params[:biological_parents] =="Father" || !foster_father.blank?
          father   = MigrateFather.new_father(person, params,'Father')
        end
        if params[:foster_parents] == "Both" || params[:foster_parents] =="Mother" || !foster_mother.blank?
          adoptive_mother   = MigrateMother.new_mother(person, params, 'Adoptive-Mother')
        end
        if params[:foster_parents] == "Both" || params[:foster_parents] =="Mother"  || !foster_father.blank?
          adoptive_father   = Lib.new_father(person, params,'Adoptive-Father')
        end
        mother = mother.present? ? mother : adoptive_mother
        father = father.present? ? father : adoptive_father
        informant = MigrateInformant.new_informant(person, params, mother, father)
      when "abandoned"
        if params[:parents_details_available] == "Both" || params[:parents_details_available] == "Mother"
          mother   = MigrateMother.new_mother(person, params, 'Mother')
        end
        if params[:parents_details_available] == "Both" || params[:parents_details_available] == "Father"
          mother   = MigrateFather.new_father(person, params, 'Father')
        end

        informant = MigrateInformant.new_informant(person, params, mother, father)
      else

          puts "Write some to track registration type not present"
      end

    details = MigrateBirthDetails.new_birth_details(person, params)

    status = MigrateChild.workflow_init(person,params)


    return person
  end


  def self.update_record(params)

  end

  def self.is_num?(val)

    #checks if the val is numeric or string
      !!Integer(val)
    rescue ArgumentError, TypeError
      false

  end

  def self.verify_location(owner, location_type, data)

    location_found = false

   if owner == "Mother"

     if location_type == "TA"
          cur_district_id  = Location.locate_id_by_tag(data[:person][:mother][:current_district], 'District')
          cur_ta_id        = Location.locate_id(data[:person][:mother][:current_ta], 'Traditional Authority', cur_district_id)
          home_district_id  = Location.locate_id_by_tag(data[:person][:mother][:home_district], 'District')
          home_ta_id        = Location.locate_id(data[:person][:mother][:home_ta], 'Traditional Authority', home_district_id)

        unless cur_ta_id.blank? || home_ta_id.blank?
          location_found = true
        else
          location_found = false
        end

     elsif location_type == "Village"

          cur_district_id  = Location.locate_id_by_tag(data[:person][:mother][:current_district], 'District')
          cur_ta_id        = Location.locate_id(data[:person][:mother][:current_ta], 'Traditional Authority', cur_district_id)
          cur_village_id   = Location.locate_id(data[:person][:mother][:current_village], 'Village', cur_ta_id)
          home_district_id  = Location.locate_id_by_tag(data[:person][:mother][:current_district], 'District')
          home_ta_id        = Location.locate_id(data[:person][:mother][:current_ta], 'Traditional Authority', home_district_id)
          home_village_id   = Location.locate_id(data[:person][:mother][:current_village], 'Village', home_ta_id)

        unless cur_village_id.blank? || home_village_id.blank?
          location_found = true
        else
          location_found = false
        end

     elsif location_type == "District"

         cur_district_id  = Location.locate_id_by_tag(data[:person][:mother][:current_district], 'District')
         home_district_id  = Location.locate_id_by_tag(data[:person][:mother][:home_district], 'District')

        unless cur_district_id.blank? || home_district_id.blank?
          location_found = true
        else
          location_found = false
        end
     else
        citizenship = Location.where(country: data[:person][:mother][:citizenship]).last.id rescue nil
        residential_country = Location.where(name: data[:person][:mother][:residential_country]).last.id rescue nil

          unless citizenship.blank? || residential_country.blank?
            location_found = true
          else
            location_found = false
          end
     end

   else

     if location_type == "TA"
          cur_district_id  = Location.locate_id_by_tag(data[:person][:father][:current_district], 'District')
          cur_ta_id        = Location.locate_id(data[:person][:father][:current_ta], 'Traditional Authority', cur_district_id)
          home_district_id  = Location.locate_id_by_tag(data[:person][:father][:home_district], 'District')
          home_ta_id        = Location.locate_id(data[:person][:father][:home_ta], 'Traditional Authority', home_district_id)

          unless cur_ta_id.blank? || home_ta_id.blank?
            location_found = true
          else
            location_found = false
          end

     elsif location_type == "Village"

          cur_district_id  = Location.locate_id_by_tag(data[:person][:father][:current_district], 'District')
          cur_ta_id        = Location.locate_id(data[:person][:father][:current_ta], 'Traditional Authority', cur_district_id)
          cur_village_id   = Location.locate_id(data[:person][:father][:current_village], 'Village', cur_ta_id)
          home_district_id  = Location.locate_id_by_tag(data[:person][:father][:current_district], 'District')
          home_ta_id        = Location.locate_id(data[:person][:father][:current_ta], 'Traditional Authority', home_district_id)
          home_village_id   = Location.locate_id(data[:person][:father][:current_village], 'Village', home_ta_id)

          unless cur_village_id.blank? || home_village_id.blank?
              location_found = true
          else
              location_found = false
          end

     elsif location_type == "District"

          cur_district_id  = Location.locate_id_by_tag(data[:person][:father][:current_district], 'District')
          home_district_id  = Location.locate_id_by_tag(data[:person][:father][:current_district], 'District')

          unless cur_district_id.blank? || home_district_id.blank?
            location_found = true
          else
            location_found = false
          end
    else
        citizenship = Location.where(country: data[:person][:father][:citizenship]).last.id rescue nil
        residential_country = Location.where(name: data[:person][:father][:residential_country]).last.id rescue nil

        unless citizenship.blank? || residential_country.blank?
            location_found = true
        else
            location_found = false
        end

    end

  end

   return location_found
end

  def self.mother(person_id)
    birth_details = PersonBirthDetail.where(person_id: person_id).first
    birth_registration_type_id = birth_details.birth_registration_type_id
    registration_name = BirthRegistrationType.where(birth_registration_type_id: birth_registration_type_id).last.name
    case registration_name
    when "Adopted"
         relationship_name = "Adoptive-Mother"
    else
        relationship_name = "Mother"
    end

    result = nil
    relationship_type = PersonRelationType.find_by_name(relationship_name)

    relationship = PersonRelationship.where(:person_a => person_id, :person_relationship_type_id => relationship_type.id).last

    unless relationship.blank?
      result = PersonName.where(:person_id => relationship.person_b).last
    end

    result
  end

  def self.father(person_id)
    birth_details = PersonBirthDetail.where(person_id: person_id).first
    birth_registration_type_id = birth_details.birth_registration_type_id
    registration_name = BirthRegistrationType.where(birth_registration_type_id: birth_registration_type_id).last.name
    case registration_name
    when "Adopted"
         relationship_name = "Adoptive-Father"
    else
        relationship_name = "Father"
    end

    result = nil
    relationship_type = PersonRelationType.find_by_name(relationship_name)

    relationship = PersonRelationship.where(:person_a => person_id, :person_relationship_type_id => relationship_type.id).last

    unless relationship.blank?
      result = PersonName.where(:person_id => relationship.person_b).last
    end

    result
  end

  def self.query_for_display(states, types=['Normal', 'Abandoned', 'Adopted', 'Orphaned'])

    state_ids = states.collect{|s| Status.find_by_name(s).id} + [-1]

    person_reg_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]

    main = Person.find_by_sql(
        "SELECT n.*, prs.status_id, pbd.district_id_number AS ben, pbd.national_serial_number AS brn FROM person p
            INNER JOIN core_person cp ON p.person_id = cp.person_id
            INNER JOIN person_name n ON p.person_id = n.person_id
            INNER JOIN person_record_statuses prs ON p.person_id = prs.person_id AND COALESCE(prs.voided, 0) = 0
            INNER JOIN person_birth_details pbd ON p.person_id = pbd.person_id
          WHERE prs.status_id IN (#{state_ids.join(', ')})
            AND pbd.birth_registration_type_id IN (#{person_reg_type_ids.join(', ')})
          GROUP BY p.person_id
          ORDER BY p.updated_at DESC
           "
    )

    results = []

    main.each do |data|
      mother = self.mother(data.person_id)
      father = self.father(data.person_id)
      #For abandoned cases mother details may not be availabe
      #next if mother.blank?
      #next if mother.first_name.blank?
      #The form treat Father as optional
      #next if father.blank?
      #next if father.first_name.blank?
      name          = ("#{data['first_name']} #{data['middle_name']} #{data['last_name']}")
      mother_name   = ("#{mother.first_name rescue 'N/A'} #{mother.middle_name rescue ''} #{mother.last_name rescue ''}")
      father_name   = ("#{father.first_name rescue 'N/A'} #{father.middle_name rescue ''} #{father.last_name rescue ''}")

      results << {
          'id' => data.person_id,
          'ben' => data.ben,
          'brn' => data.brn,
          'name'        => name,
          'father_name'       => father_name,
          'mother_name'       => mother_name,
          'status'            => Status.find(data.status_id).name, #.gsub(/DC\-|FC\-|HQ\-/, '')
          'date_of_reporting' => data['created_at'].to_date.strftime("%d/%b/%Y"),
      }
    end

    results

  end

  def self.search_results(filters={})

    if filters.blank?
      return []
    end
    entry_num_query = ''; fac_serial_query = ''; name_query = ''; limit = ' '
    limit = ' LIMIT 10 ' if filters.blank?
    gender_query = ''; place_of_birth_query = ''; status_query=''

    filters.keys.each do |k|
      case k
        when 'Birth Entry Number'
          entry_num_query = " AND pbd.district_id_number = '#{filters[k]['person[birth_entry_number]']}' "
        when 'Facility Serial Number'
          fac_serial_query =  " AND pbd.facility_serial_number = '#{filters[k]['person[facility_serial_number]']}' "
        when 'Child Name'
          if filters[k]["person[last_name]"].present?
            name_query += " AND  n.last_name = '#{filters[k]["person[last_name]"]}'"
          end
          if filters[k]["person[middle_name]"].present?
            name_query += " AND n.middle_name = '#{filters[k]["person[middle_name]"]}'"
          end
          if filters[k]["person[first_name]"].present?
            name_query += " AND n.first_name = '#{filters[k]["person[first_name]"]}'"
          end
        when 'Child Gender'
          gender_query = " AND p.gender = '#{filters[k]["person[gender]"].split('')[0]}' "
        when 'Place of Birth'
          place_id = Location.locate_id_by_tag(filters[k]["person[place_of_birth]"], 'Place of Birth')
          if place_id.present?
            place_of_birth_query = " AND  place_of_birth = #{place_id} "
          end
          district_id = Location.locate_id_by_tag(filters[k]["person[birth_district]"], 'District')
          if district_id.present?
            place_of_birth_query += " AND  district_of_birth = #{district_id} "
          end
          ta_id = Location.locate_id(filters[k]["person[birth_ta]"], 'Traditional Authority', district_id)
          if ta_id.present?
            village_id = Location.locate_id(filters[k]["person[birth_village]"], 'Village', ta_id)
            place_of_birth_query += " AND  birth_location_id = #{village_id} "
          end

          hospital_id = Location.locate_id(filters[k]["person[hospital_of_birth]"], 'Health Facility', district_id)
          if hospital_id.present?
            place_of_birth_query += " AND  birth_location_id = #{hospital_id} "
          end

          if filters[k]["other_birth_place"].present?
            place_of_birth_query += " AND  other_birth_location = '#{filters[k]["other_birth_place"].strip}' "
          end
        when 'Record Status'
          status_id = Status.where(name: filters[k]["person[record_status]"]).last.id
          status_query = " AND prs.status_id = #{status_id} "
      end
    end

    main = Person.find_by_sql(
        "SELECT n.*, prs.status_id, pbd.district_id_number AS ben, pbd.national_serial_number AS brn FROM person p
            INNER JOIN core_person cp ON p.person_id = cp.person_id
            INNER JOIN person_name n ON p.person_id = n.person_id
            INNER JOIN person_record_statuses prs ON p.person_id = prs.person_id
            INNER JOIN person_birth_details pbd ON p.person_id = pbd.person_id
          WHERE COALESCE(prs.voided, 0) = 0
            #{entry_num_query} #{fac_serial_query} #{name_query} #{gender_query} #{place_of_birth_query} #{status_query}
          GROUP BY p.person_id
          ORDER BY p.updated_at DESC
            #{limit}
           "
    )

    results = []

    main.each do |data|
      mother = self.mother(data.person_id)
      father = self.father(data.person_id)
      #For abandoned cases mother details may not be availabe
      #next if mother.blank?
      #next if mother.first_name.blank?
      #The form treat Father as optional
      #next if father.blank?
      #next if father.first_name.blank?
      name          = ("#{data['first_name']} #{data['middle_name']} #{data['last_name']}")
      mother_name   = ("#{mother.first_name rescue 'N/A'} #{mother.middle_name rescue ''} #{mother.last_name rescue ''}")
      father_name   = ("#{father.first_name rescue 'N/A'} #{father.middle_name rescue ''} #{father.last_name rescue ''}")

      results << {
          'id' => data.person_id,
          'ben' => data.ben,
          'brn' => data.brn,
          'name'        => name,
          'father_name'       => father_name,
          'mother_name'       => mother_name,
          'status'            => Status.find(data.status_id).name, #.gsub(/DC\-|FC\-|HQ\-/, '')
          'date_of_reporting' => data['created_at'].to_date.strftime("%d/%b/%Y"),
      }
    end

    results

  end


  def self.record_complete?(child)
      name = PersonName.find_by_person_id(child.id)
      pbs = PersonBirthDetail.find_by_person_id(child.id) rescue nil
      birth_type = BirthRegistrationType.find(pbs.birth_registration_type_id).name rescue nil
      mother_name = self.mother(child.id)
      father_name = self.father(child.id)
      complete = false

      return false if pbs.blank?

      if name.first_name.blank?
        return complete
      end

      if name.last_name.blank?
        return complete
      end

      if (child.birthdate.to_date.blank? rescue true)
          return complete
      end

      if child.gender.blank? || child.gender == 'N/A'
        return complete
      end

      if birth_type.downcase == "normal"

        if mother_name.first_name.blank?
          return complete
        end

        if mother_name.last_name.blank?
          return complete
        end

      end

      if pbs.parents_married_to_each_other.to_s == '1'
        if father_name.first_name.blank?
          return complete
        end

        if father_name.last_name.blank?
          return complete
        end
      end

      return true

  end

end
