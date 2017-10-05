module Lib
  require 'bean'
  require 'json'
  

  def self.new_child(params, document_tracker)
        
        core_person = CorePerson.new
        core_person.person_type_id = PersonType.where(name: 'Client').last.id
        core_person.created_at = params[:person][:created_at].to_date.strftime("%Y-%m-%d HH:MM:00")
        core_person.updated_at = params[:person][:updated_at].to_date
        #core_person.save
        #@rec_count = @rec_count.to_i + 1
        #person_id = CorePerson.first.person_id.to_i + @rec_count.to_i 
        person_id = document_tracker[params[:_id]][:client_id]
        
        sql_query = "(#{person_id}, #{core_person.person_type_id},\"#{params[:person][:created_at].to_date}\", \"#{params[:person][:updated_at].to_date}\"),"
        #row = "#{params[:_id]},#{core_person.person_id},"
        
        #save_ids(row)
        self.write_to_dump("core_person.sql",sql_query)

        
        
   
    person = Person.new
    person.person_id          = person_id
    person.gender             = params[:person][:gender].first
    person.birthdate          = params[:person][:birthdate].to_date
    person.created_at         = params[:person][:created_at].to_date
    person.updated_at         = params[:person][:updated_at].to_date
     

    person_sql = "(#{person_id},\"#{person.gender}\",\"#{person.birthdate}\",\"#{person.created_at}\""
    person_sql += ",\"#{person.updated_at}\"),"

    self.write_to_dump("person.sql", person_sql)
    
    person_name = PersonName.new
    person_name.person_id          = person_id
    person_name.first_name         = params[:person][:first_name]
    person_name.middle_name        = params[:person][:middle_name]
    person_name.last_name          = params[:person][:last_name]
    person_name.created_at         = params[:person][:created_at].to_date
    person_name.updated_at         = params[:person][:updated_at].to_date
    
    person_name_sql = "(#{person_id},\"#{person_name.first_name}\",\"#{person_name.middle_name}\",\"#{person_name.last_name}\","
    person_name_sql += "\"#{person_name.created_at}\",\"#{person_name.updated_at}\"),"

    self.write_to_dump("person_name.sql", person_name_sql)
    
    return person_id
  end

  def self.new_mother(params,mother_type, document_tracker)

    doc_id = params[:_id]

    if self.is_twin_or_triplet(params[:person][:type_of_birth])
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
        
     #begin
         
        core_person = CorePerson.new
        core_person.person_type_id     = PersonType.where(name: mother_type).last.id
        core_person.created_at         = params[:person][:created_at].to_date.to_s
        core_person.updated_at         = params[:person][:updated_at].to_date.to_s
        
        core_person_sql = "(#{document_tracker[doc_id][:mother_id]},#{core_person.person_type_id},"
        core_person_sql += "\"#{core_person.created_at},\"#{core_person.updated_at}\"),"
        
        self.write_to_dump("core_person.sql",core_person_sql)
      
        mother[:citizenship] = 'Malawian' if mother[:citizenship].blank?
        mother[:residential_country] = 'Malawi' if mother[:residential_country].blank?

      puts "Creating mother for: #{document_tracker[doc_id][:client_id]} Mother_id: #{document_tracker[doc_id][:mother_id]} >>>>"

        mother_person = Person.new
        mother_person.person_id          = document_tracker[doc_id][:mother_id]
        mother_person.gender             = 'F'
        mother_person.birthdate          = ((mother[:birthdate].to_date.present? rescue false) ? mother[:birthdate].to_date : "1900-01-01")
        mother_person.birthdate_estimated = ((mother[:birthdate].to_date.present? rescue false) ? 0 : 1)
        mother_person.created_at         = params[:person][:created_at].to_date.to_s
        mother_person.updated_at         = params[:person][:updated_at].to_date.to_s


        mother_person_sql = "(#{document_tracker[doc_id][:mother_id]},\"#{mother_person.gender}\","
        mother_person_sql += "\"#{mother_person.birthdate}\",\"#{mother_person.birthdate_estimated}\","
        mother_person_sql += "\"#{mother_person.created_at}\",\"#{mother_person.updated_at}\"),"

        self.write_to_dump("person.sql",mother_person_sql)

        
      puts " Person created...\n"

      puts "Creating PersonName for #{core_person.id} ....\n"

        person_name = PersonName.new
        person_name.person_id          = core_person.id
        person_name.first_name         = mother[:first_name]
        person_name.middle_name        = mother[:middle_name]
        person_name.last_name          = mother[:last_name]
        person_name.created_at         = params[:person][:created_at].to_date.to_s
        person_name.updated_at         = params[:person][:updated_at].to_date.to_s

        person_name_sql = "(#{document_tracker[doc_id][:mother_id]},\"#{person_name.first_name}\","
        person_name_sql += "\"#{person_name.middle_name}\",\"#{person_name.last_name}\",\"#{person_name.created_at}\","
        person_name_sql += "\"#{person_name.updated_at}\"),"

        self.write_to_dump("person_name.sql",person_name_sql)
        
        
        puts " PersonName created...\n"

      
        cur_district_id         = Location.locate_id_by_tag(mother[:current_district], 'District')
        cur_ta_id               = Location.locate_id(mother[:current_ta], 'Traditional Authority', cur_district_id)
        cur_village_id          = Location.locate_id(mother[:current_village], 'Village', cur_ta_id)
        
        home_district_id        = Location.locate_id_by_tag(mother[:home_district], 'District')
        home_ta_id              = Location.locate_id(mother[:home_ta], 'Traditional Authority', home_district_id)
        home_village_id         = Location.locate_id(mother[:home_village], 'Village', home_ta_id)
        
        puts "Creating personAddress for #{core_person.id}...\n"
      
        person_address = PersonAddress.new
        person_address.person_id          = core_person.id
        person_address.current_district   = cur_district_id
        person_address.current_ta         = cur_ta_id
        person_address.current_village    = cur_village_id
        person_address.home_district   = home_district_id
        person_address.home_ta            = home_ta_id
        person_address.home_village       = home_village_id

        person_address.current_district_other   = mother[:foreigner_home_district]
        person_address.current_ta_other         = mother[:foreigner_current_ta]
        person_address.current_village_other    = mother[:foreigner_current_village]
        person_address.home_district_other      = mother[:foreigner_home_district]
        person_address.home_ta_other            = mother[:foreigner_home_ta]
        person_address.home_village_other       = mother[:foreigner_home_village]

        person_address.citizenship            = Location.where(country: mother[:citizenship]).last.id
        person_address.residential_country    = Location.locate_id_by_tag(mother[:residential_country], 'Country')
        person_address.address_line_1         = (params[:informant_same_as_mother].present? && params[:informant_same_as_mother] == "Yes" ? params[:person][:informant][:addressline1] : nil)
        person_address.address_line_2         = (params[:informant_same_as_mother].present? && params[:informant_same_as_mother] == "Yes" ? params[:person][:informant][:addressline2] : nil)
        person_address.created_at         = params[:person][:created_at].to_date.to_s
        person_address.updated_at         = params[:person][:updated_at].to_date.to_s

        person_address_sql = "(#{document_tracker[doc_id][:mother_id]},#{person_address.current_district},"
        person_address_sql += "#{person_address.current_ta},#{person_address.current_village},"
        person_address_sql += "#{person_address.home_district},#{person_address.home_ta},#{person_address.home_village},"
        person_address_sql += "\"#{person_address.current_district_other}\",\"#{person_address.current_ta_other}\","
        person_address_sql += "\"#{person_address.current_village_other}\",\"#{person_address.home_district_other}\","
        person_address_sql += "\"#{person_address.home_ta_other}\",\"#{person_address.home_village_other}\","
        person_address_sql += "#{person_address.citizenship},#{person_address.residential_country},"
        person_address_sql += "\"#{person_address.address_line_1}\",\"#{person_address.address_line_2}\","
        person_address_sql += "\"#{person_address.created_at}\",\"#{person_address.updated_at}\"),"

        self.write_to_dump("person_addresses.sql",person_address_sql)
        
       puts " PersonAddress created...\n" 
     #rescue StandardError => e

          #self.log_error(e.message, params)
     #end

    end

    unless mother_person.blank?
      person_relationship = PersonRelationship.new
      person_relationship.person_a                    = document_tracker[doc_id][:client_id]
      person_relationship.person_b                    = document_tracker[doc_id][:mother_id]
      person_relationship.person_relationship_type_id = PersonRelationType.where(name: mother_type).last.id
      person_relationship.created_at                  = params[:person][:created_at].to_date.to_s
      person_relationship.updated_at                  = params[:person][:updated_at].to_date.to_s

      person_relationship_sql = "(#{document_tracker[doc_id][:client_id]},#{document_tracker[doc_id][:mother_id]},"
      person_relationship_sql += "#{person_relationship.person_relationship_type_id},\"#{person_relationship.created_at}\","
      person_relationship_sql += "\"#{person_relationship.updated_at}\"),"
    
      self.write_to_dump("person_relationship.sql",person_relationship_sql)

    end

    puts "Mother record for client: #{person_relationship.person_a} created..."
     
    mother_person
  end

  def self.new_father(params, father_type,document_tracker)
       
     doc_id = params[:_id]
     
    if self.is_twin_or_triplet(params[:person][:type_of_birth].to_s)

      father_person = Person.find(params[:person][:prev_child_id]).father
    else

      if father_type =="Adoptive-Father"

        father = params[:person][:foster_father]
      else

        father = params[:person][:father]
        
      end
      father[:citizenship] = 'Malawian' if father[:citizenship].blank?
      father[:residential_country] = 'Malawi' if father[:residential_country].blank?

      if father[:first_name].blank?
        return nil
      end

     

     #begin
           
      core_person = CorePerson.new
      core_person.person_type_id     = PersonType.where(name: father_type).last.id
      core_person.created_at         = params[:person][:created_at].to_date.to_s
      core_person.updated_at         = params[:person][:updated_at].to_date.to_s
      
      core_person_sql = "(#{document_tracker[doc_id][:father_id]},#{core_person.person_type_id},"
      core_person_sql += "\"#{core_person.created_at},\"#{core_person.updated_at}\"),"
        
      self.write_to_dump("core_person.sql",core_person_sql)
      

      father_person = Person.create(
          :person_id          => core_person.id,
          :gender             => 'F',
          :birthdate          => (father[:birthdate].blank? ? "1900-01-01" : father[:birthdate].to_date),
          :birthdate_estimated => (father[:birthdate].blank? ? 1 : 0),
          :created_at         => params[:person][:created_at].to_date.to_s,
          :updated_at         => params[:person][:updated_at].to_date.to_s
      )

      PersonName.create(
          :person_id          => core_person.id,
          :first_name         => father[:first_name],
          :middle_name        => father[:middle_name],
          :last_name          => father[:last_name],
          :created_at         => params[:person][:created_at].to_date.to_s,
          :updated_at         => params[:person][:updated_at].to_date.to_s
      )

      cur_district_id         = Location.locate_id_by_tag(father[:current_district], 'District')
      cur_ta_id               = Location.locate_id(father[:current_ta], 'Traditional Authority', cur_district_id)
      cur_village_id          = Location.locate_id(father[:current_village], 'Village', cur_ta_id)

      home_district_id        = Location.locate_id_by_tag(father[:home_district], 'District')
      home_ta_id              = Location.locate_id(father[:home_ta], 'Traditional Authority', home_district_id)
      home_village_id         = Location.locate_id(father[:home_village], 'Village', home_ta_id)
    
     
      PersonAddress.create(
          :person_id          => core_person.id,
          :current_district   => cur_district_id,
          :current_ta         => cur_ta_id,
          :current_village    => cur_village_id,
          :home_district   => home_district_id,
          :home_ta            => home_ta_id,
          :home_village       => home_village_id,

          :current_district_other   => father[:foreigner_home_district],
          :current_ta_other         => father[:foreigner_current_ta],
          :current_village_other    => father[:foreigner_current_village],
          :home_district_other      => father[:foreigner_home_district],
          :home_ta_other            => father[:foreigner_home_ta],
          :home_village_other       => father[:foreigner_home_village],

          :citizenship            => Location.where(country: father[:citizenship]).last.id,
          :residential_country    => Location.locate_id_by_tag(father[:residential_country], 'Country'),
          :address_line_1         => (params[:informant_same_as_father].present? && params[:informant_same_as_father] == "Yes" ? params[:person][:informant][:addressline1] : nil),
          :address_line_2         => (params[:informant_same_as_father].present? && params[:informant_same_as_father] == "Yes" ? params[:person][:informant][:addressline2] : nil),
          :created_at         => params[:person][:created_at].to_date.to_s,
          :updated_at         => params[:person][:updated_at].to_date.to_s
      )
     #rescue StandardError => e

          self.log_error(e.message, params)
     #end
    end

    unless father_person.blank?
      PersonRelationship.create(
              person_a: person.id, person_b: father_person.person_id,
              person_relationship_type_id: PersonRelationType.where(name: father_type).last.id,
              created_at: params[:person][:created_at].to_date.to_s,
              updated_at: params[:person][:updated_at].to_date.to_s
      )
    end
    
    puts "Father record for client: #{person.person_id} created..."

    father_person

  end

def self.new_informant(params,document_tracker)
    doc_id = params[:_id]
    informant_person = nil; core_person = nil

    informant = params[:person][:informant]
    informant[:citizenship] = 'Malawian' if informant[:citizenship].blank?
    informant[:residential_country] = 'Malawi' if informant[:residential_country].blank?
  #begin

    if self.is_twin_or_triplet(params[:person][:type_of_birth].to_s)

      informant_person = Person.find(params[:person][:prev_child_id]).informant
    elsif params[:informant_same_as_mother] == 'Yes'
          
      if params[:person][:relationship] == "adopted"
          informant_person = params[:person][:adoptive_mother]
      else
         informant_person = params[:person][:mother]

      end
    elsif params[:informant_same_as_father] == 'Yes'
      
      if params[:person][:relationship] == "adopted"
          informant_person = params[:person][:adoptive_father]
      else
         informant_person = params[:person][:father]
      end
    else
    
    
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
          :first_name  => informant[:first_name],
          :middle_name => informant[:middle_name],
          :last_name   => informant[:last_name],
          :created_at  => params[:person][:created_at].to_date.to_s,
          :updated_at  => params[:person][:updated_at].to_date.to_s
      )

      cur_district_id         = Location.locate_id_by_tag(informant[:current_district], 'District')
      cur_ta_id               = Location.locate_id(informant[:current_ta], 'Traditional Authority', cur_district_id)
      cur_village_id          = Location.locate_id(informant[:current_village], 'Village', cur_ta_id)

      home_district_id        = Location.locate_id_by_tag(informant[:home_district], 'District')
      home_ta_id              = Location.locate_id(informant[:home_ta], 'Traditional Authority', home_district_id)
      home_village_id         = Location.locate_id(informant[:home_village], 'Village', home_ta_id)
     
      PersonAddress.create(
          :person_id          => core_person.id,
          :current_district   => cur_district_id,
          :current_ta         => cur_ta_id,
          :current_village    => cur_village_id,
          :home_district   => home_district_id,
          :home_ta            => home_ta_id,
          :home_village       => home_village_id,
          :citizenship            => Location.where(country: informant[:citizenship]).last.id,
          :residential_country    => Location.locate_id_by_tag(informant[:residential_country], 'Country'),
          :address_line_1         => informant[:addressline1],
          :address_line_2         => informant[:addressline2],
          :created_at         => params[:person][:created_at].to_date.to_s,
          :updated_at         => params[:person][:updated_at].to_date.to_s
      )
  

    end
   
  if params[:informant_same_as_father] == 'Yes'

      person_relationship = PersonRelationship.new
      person_relationship.person_a                    = document_tracker[doc_id][:client_id] 
      person_relationship.person_b                    = document_tracker[doc_id][:father_id] 
      person_relationship.person_relationship_type_id = PersonRelationType.where(name: 'Informant').last.id
      person_relationship.updated_at                  = params[:person][:created_at].to_date.to_s
      person_relationship.updated_at                  = params[:person][:updated_at].to_date.to_s

      person_relationship_sql = "(#{document_tracker[doc_id][:client_id]},#{document_tracker[doc_id][:father_id]},"
      person_relationship_sql += "#{person_relationship.person_relationship_type_id},\"#{person_relationship.created_at}\","
      person_relationship_sql += "\"#{person_relationship.updated_at}\"),"
    
      self.write_to_dump("person_relationship.sql",person_relationship_sql)      
  end
  if params[:informant_same_as_mother] == 'Yes'

      person_relationship = PersonRelationship.new
      person_relationship.person_a                    = document_tracker[doc_id][:client_id] 
      person_relationship.person_b                    = document_tracker[doc_id][:mother_id] 
      person_relationship.person_relationship_type_id = PersonRelationType.where(name: 'Informant').last.id
      person_relationship.updated_at                  = params[:person][:created_at].to_date.to_s
      person_relationship.updated_at                  = params[:person][:updated_at].to_date.to_s

      person_relationship_sql = "(#{document_tracker[doc_id][:client_id]},#{document_tracker[doc_id][:mother_id]},"
      person_relationship_sql += "#{person_relationship.person_relationship_type_id},\"#{person_relationship.created_at}\","
      person_relationship_sql += "\"#{person_relationship.updated_at}\"),"
    
      self.write_to_dump("person_relationship.sql",person_relationship_sql)
      
      raise "============Up in here now...#{informant_person}".inspect 
  end

    puts "Informant record for client: #{person.person_id} created..."

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

  #rescue StandardError => e
          
          self.log_error(e.message, params)        
  #end

    informant_person
end

def self.new_birth_details(person, params)

    if self.is_twin_or_triplet(params[:person][:type_of_birth].to_s)
      return self.birth_details_multiple(person,params)
    end
    person_id = person.id; place_of_birth_id = nil; location_id = nil; other_place_of_birth = nil
    person = params[:person]

    if SETTINGS['application_mode'] == 'FC'
      place_of_birth_id = Location.where(name: 'Hospital').last.id
      location_id = SETTINGS['location_id']
    else
      unless person[:place_of_birth].blank?
        place_of_birth_id = Location.locate_id_by_tag(person[:place_of_birth], 'Place of Birth')
      else
        place_of_birth_id = Location.locate_id_by_tag("Other", 'Place of Birth')
      end

      if person[:place_of_birth] == 'Home'
        district_id = Location.locate_id_by_tag(person[:birth_district], 'District')
        ta_id = Location.locate_id(person[:birth_ta], 'Traditional Authority', district_id)
        village_id = Location.locate_id(person[:birth_village], 'Village', ta_id)
        location_id = [village_id, ta_id, district_id].compact.first #Notice the order

      elsif person[:place_of_birth] == 'Hospital'
        map =  {'Mzuzu City' => 'Mzimba',
                'Lilongwe City' => 'Lilongwe',
                'Zomba City' => 'Zomba',
                'Blantyre City' => 'Blantyre'}

        person[:birth_district] = map[person[:birth_district]] if person[:birth_district].match(/City$/)

        district_id = Location.locate_id_by_tag(person[:birth_district], 'District')
        location_id = Location.locate_id(person[:hospital_of_birth], 'Health Facility', district_id)

        location_id = [location_id, district_id].compact.first

      else #Other
        location_id = Location.where(name: 'Other').last.id #Location.locate_id_by_tag(person[:birth_district], 'District')
        other_place_of_birth = params[:other_birth_place_details]
      end
    end

    reg_type = SETTINGS['application_mode'] =='FC' ? BirthRegistrationType.where(name: 'Normal').first.birth_registration_type_id :
        BirthRegistrationType.where(name: params[:person][:relationship]).last.birth_registration_type_id
    
    puts "creating new birth details... Type of birth #{person[:type_of_birth]}"

    unless person[:type_of_birth].blank?

      if person[:type_of_birth]=='Twin'

         person[:type_of_birth] ='First Twin'
      end
      if person[:type_of_birth]=='Triplet'

         person[:type_of_birth] ='First Triplet'
      end

      type_of_birth_id = PersonTypeOfBirth.where(name: person[:type_of_birth]).last.id

    else
      type_of_birth_id = PersonTypeOfBirth.where(name:  'Single').last.id
    end

    
    rel = nil
    if params[:informant_same_as_mother] == 'Yes'
      rel = 'Mother'
    elsif params[:informant_same_as_father] == 'Yes'
      rel = 'Father'
    else
      rel = params[:person][:informant][:relationship_to_person] rescue nil
    end
   
  begin

    details = PersonBirthDetail.create(
        person_id:                                person_id,
        birth_registration_type_id:               reg_type,
        place_of_birth:                           place_of_birth_id,
        birth_location_id:                        location_id,
        district_of_birth:                        Location.where("name = '#{params[:person][:birth_district]}' AND code IS NOT NULL").first.id,
        other_birth_location:                     other_place_of_birth,
        birth_weight:                             (person[:birth_weight].blank? ? nil : person[:birth_weight]),
        type_of_birth:                            type_of_birth_id,
        parents_married_to_each_other:            (person[:parents_married_to_each_other] == 'No' ? 0 : 1),
        date_of_marriage:                         (person[:date_of_marriage] rescue nil),
        gestation_at_birth:                       (params[:gestation_at_birth].blank? ? nil : params[:gestation_at_birth]),
        number_of_prenatal_visits:                (params[:number_of_prenatal_visits].blank? ? nil : params[:number_of_prenatal_visits]),
        month_prenatal_care_started:              (params[:month_prenatal_care_started].blank? ? nil : params[:month_prenatal_care_started]),
        mode_of_delivery_id:                      (ModeOfDelivery.where(name: person[:mode_of_delivery]).first.id rescue 1),
        number_of_children_born_alive_inclusive:  (params[:number_of_children_born_alive_inclusive].present? ? params[:number_of_children_born_alive_inclusive] : 1),
        number_of_children_born_still_alive:      (params[:number_of_children_born_still_alive].present? ? params[:number_of_children_born_still_alive] : 1),
        level_of_education_id:                    (LevelOfEducation.where(name: person[:level_of_education]).last.id rescue 1),
        court_order_attached:                     (person[:court_order_attached] == 'Yes' ? 1 : 0),
        parents_signed:                           (person[:parents_signed] == 'Yes' ? 1 : 0),
        form_signed:                              (person[:form_signed] == 'Yes' ? 1 : 0),
        informant_designation:                    (params[:person][:informant][:designation].present? ? params[:person][:informant][:designation].to_s : nil),
        informant_relationship_to_person:          rel,
        other_informant_relationship_to_person:   (params[:person][:informant][:relationship_to_person].to_s == "Other" ? (params[:person][:informant][:other_informant_relationship_to_person] rescue nil) : nil),
        acknowledgement_of_receipt_date:          (person[:acknowledgement_of_receipt_date].to_date rescue nil),
        location_created_at:                      SETTINGS['location_id'],
        date_registered:                          (Date.today.to_s),
        created_at:                               params[:person][:created_at].to_date.to_s,
        updated_at:                               params[:person][:updated_at].to_date.to_s
    )
    
  rescue StandardError => e
    self.log_error(e.message, params)
  end

    return details

end

  def self.birth_details_multiple(person,params)
    
    prev_details = PersonBirthDetail.where(person_id: params[:person][:prev_child_id].to_s).first
    
    begin
    prev_details_keys = prev_details.attributes.keys
    exclude_these = ['person_id','person_birth_details_id',"birth_weight","type_of_birth","mode_of_delivery_id","document_id"]
    prev_details_keys = prev_details_keys - exclude_these

    details = PersonBirthDetail.new
    details["person_id"] = person.id
    details["birth_weight"] = params[:person][:birth_weight]

    type_of_birth_id = PersonTypeOfBirth.where(name: params[:person][:type_of_birth]).last.id
    details["type_of_birth"] = type_of_birth_id

    details["mode_of_delivery_id"] = (ModeOfDelivery.where(name: params[:person][:mode_of_delivery]).first.id rescue 1)

    prev_details_keys.each do |field|
        details[field] = prev_details[field]
    end
    details.save!

    rescue StandardError =>e

      self.log_error(e.message,person)

    end

    return details
  end

  def self.workflow_init(person,params)
    
    status = nil
    is_record_a_duplicate = params[:person][:duplicate] rescue nil
    begin
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
    rescue StandardError =>e

        self.log_error(e.message, params)
    end

    return status
  end

  def self.log_error(error_msge, content)

    file_path = "#{Rails.root}/app/assets/data/error_log.txt"
    if !File.exists?(file_path)
           file = File.new(file_path, 'w')
    else

       File.open(file_path, 'a') do |f|
          f.puts "#{error_msge} >>>>>> #{content}"

      end
    end

  end

  def self.save_ids(content)
    
     file_path = "#{Rails.root}/app/assets/data/person.csv"
     if !File.exists?(file_path)
         file = File.new(file_path, 'w')
     else
       File.open(file_path, 'a') do |f|
         f.puts "#{content}"
       end
     end
  end

  def self.write_to_dump(filename,content)
     
     `echo -n '#{content}' >> #{Rails.root}/app/assets/data/migration_dumps/#{filename}`    
  end
  
  def self.is_twin_or_triplet(type_of_birth)
    if type_of_birth == "Second Twin" 
      return true 
    elsif type_of_birth == "Second Triplet" 
      return true 
    elsif type_of_birth == "Third Triplet"
      return true
    else
      return false
    end
  end
end
