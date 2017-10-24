module MigrateChild
  require 'bean'
  require 'json'
  @rec_count = 0

  def self.new_child(params)
    core_person = CorePerson.create(
    person_type_id: PersonType.where(name: 'Client').last.id,
    created_at: params[:person][:created_at].to_date,
    updated_at: params[:person][:updated_at].to_date)
    #core_person.save
    @rec_count = @rec_count.to_i + 1
    person_id = CorePerson.first.person_id.to_i + @rec_count.to_i
    person = Person.create(
        :person_id          => core_person.id,
        :gender             => params[:person][:gender].first,
        :birthdate          => params[:person][:birthdate].to_date,
        :created_at         => params[:person][:created_at].to_date,
        :updated_at         => params[:person][:updated_at].to_date
     )

    PersonName.create(
        :person_id          => core_person.id,
        :first_name         => params[:person][:first_name],
        :middle_name        => (params[:person][:middle_name] rescue nil),
        :last_name          => params[:person][:last_name],
        :created_at         => params[:person][:created_at].to_date,
        :updated_at         => params[:person][:updated_at].to_date
    )
    person
  end

  def self.search_citizenship(name)
      name = name.strip rescue name

      wrong_countries_map = JSON.parse(File.read("#{Rails.root}/wrong_countries.json")) rescue {}
      name = wrong_countries_map[name] if wrong_countries_map[name].present?
      citizenship = Location.where(country: name).last

      if citizenship.blank?
        citizenship = Location.where(name: name).last

        if citizenship.blank?
          citizenship = Location.where(name: 'Malawi').last
        end
      end
      return citizenship
  end
  def self.workflow_init(person,params)

    status = nil
    is_record_a_duplicate = params[:person][:duplicate] rescue nil
    if is_record_a_duplicate.present?
        if params[:person][:is_exact_duplicate].present? && eval(params[:person][:is_exact_duplicate].to_s)
            status = PersonRecordStatus.new_record_state(person.id, 'DC-DUPLICATE')
        else
          if SETTINGS["application_mode"] == "FC"
            status = PersonRecordStatus.new_record_state(person.id, 'FC-POTENTIAL DUPLICATE')
          else
            status = PersonRecordStatus.new_record_state(person.id, 'DC-POTENTIAL DUPLICATE')
          end
        end
        potential_duplicate = PotentialDuplicate.create(person_id: person.id,created_at: (Time.now))
        if potential_duplicate.present?
             is_record_a_duplicate.split("|").each do |id|
                potential_duplicate.create_duplicate(id)
             end
        end
    else
       #status = PersonRecordStatus.new_record_state(person.id, 'DC-ACTIVE')
       status = PersonRecordStatus.new_record_state(person.id, params[:record_status])
    end

    return status
  end

  def self.log_error(error_msge, content)
    file_path = "#{Rails.root}/log/migration_error_log.txt"
    if !File.exists?(file_path)
           file = File.new(file_path, 'w')
    else

       File.open(file_path, 'a') do |f|
          f.puts "#{error_msge} >>>>>> {\"id\" : #{content['_id']}, \"rev\" : #{content['_rev']} }"

      end
    end

  end

  def self.save_ids(content)
     `echo #{content} >> #{Rails.root}/app/assets/data/person.csv`
  end

  def self.write_to_dump(filename,content)

     `echo -n '#{content}' >> #{Rails.root}/app/assets/data/migration_dumps/#{filename}`
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


def self.is_twin_or_triplet(type_of_birth,params)
    response = false

    if params[:person][:multiple_birth_id].blank?
      return response
    end

    if ["second twin","second triplet","third triplet"].include?(type_of_birth.downcase.strip)
        if params[:person][:multiple_birth_id].present?
          response = true
        end
    end
    return response
end

  def self.log_error(error_msge, content)

    file_path = "#{Rails.root}/log/migration_error_log.txt"
    if !File.exists?(file_path)
           file = File.new(file_path, 'w')
    else

       File.open(file_path, 'a') do |f|
          f.puts "#{error_msge} >>>>>> #{content}"

      end
    end

 end
end
