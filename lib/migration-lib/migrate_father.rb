module MigrateFather
  def self.new_father(person, params, father_type)
    if MigrateChild.is_twin_or_triplet(params[:person][:type_of_birth].to_s,params)
      father_person = Person.find(params[:person][:prev_child_id]).father
    else
      if father_type =="Adoptive-Father"
        father = params[:person][:foster_father]
      else
        father = params[:person][:father]
      end
      father[:citizenship] = 'Malawian' if father[:citizenship].blank?
      father[:residential_country] = 'Malawi' if father[:residential_country].blank?

      if ((father[:first_name].blank?) rescue false)
        return nil
      end

      core_person = CorePerson.create(
          :person_type_id     => PersonType.where(name: father_type).last.id,
          :created_at         => params[:person][:created_at].to_date.to_s,
          :updated_at         => params[:person][:updated_at].to_date.to_s
      )


      father_person = Person.create(
          :person_id          => core_person.id,
          :gender             => 'M',
          :birthdate          => ((father[:birthdate].blank? ? "1900-01-01" : father[:birthdate].to_date) rescue "1900-01-01"),
          :birthdate_estimated => (father[:birthdate].blank? ? 1 : 0),
          :created_at         => params[:person][:created_at].to_date.to_s,
          :updated_at         => params[:person][:updated_at].to_date.to_s
      )

      PersonName.create(
          :person_id          => core_person.id,
          :first_name         => (father[:first_name].squish rescue "@@@@@"),
          :middle_name        => (father[:middle_name].squish rescue nil),
          :last_name          => (father[:last_name].squish rescue "@@@@@"),
          :created_at         => params[:person][:created_at].to_date.to_s,
          :updated_at         => params[:person][:updated_at].to_date.to_s
      )

      current_district_id        = Location.where(:name =>"Other").last.id
      current_ta_id              = Location.where(:name =>"Other").last.id
      current_village_id         = Location.where(:name =>"Other").last.id


      if father[:current_district].present?
         cur_district_id         = Location.locate_id_by_tag(father[:current_district].squish, 'District')
         if cur_district_id.blank?
            cur_district_id         = Location.where(:name =>"Other").last.id
            current_district_other  = father[:current_district]
         end
      elsif father[:foreigner_current_district].present?
            cur_district_id         = Location.where(:name =>"Other").last.id
            current_district_other  = father[:foreigner_current_district]
      end

      if father[:current_ta].present?
          cur_ta_id               = Location.locate_id(father[:current_ta].squish, 'Traditional Authority', cur_district_id)
          if cur_ta_id.blank?
             cur_ta_id         = Location.where(:name =>"Other").last.id
             current_ta_other  = father[:current_ta]
          end
      elsif father[:foreigner_current_ta].present?
          cur_ta_id         = Location.where(:name =>"Other").last.id
          current_ta_other  = father[:foreigner_current_ta]
      end

      if father[:current_village].present?
          cur_village_id          = Location.locate_id(father[:current_village].squish, 'Village', cur_ta_id)
          if cur_village_id.blank?
             cur_village_id         = Location.where(:name =>"Other").last.id
             cur_village_other  = father[:current_village]
          end
      elsif father[:foreigner_current_village].present?
          cur_village_id         = Location.where(:name =>"Other").last.id
          current_village_other  = father[:foreigner_current_village]
      end

      home_district_id        = Location.where(:name =>"Other").last.id
      home_ta_id              = Location.where(:name =>"Other").last.id
      home_village_id         = Location.where(:name =>"Other").last.id

      if father[:home_district].present?
         home_district_id  = Location.locate_id_by_tag(father[:home_district].squish, 'District')
         if home_district_id.blank?
            home_district_id = Location.where(:name =>"Other").last.id
            home_district_other  = father[:home_district].squish
         end
      elsif father[:foreigner_home_district].present?
            home_district_id         = Location.where(:name =>"Other").last.id
            home_district_other  = father[:foreigner_home_district].squish
      end
      if father[:home_ta].present?
          home_ta_id   = Location.locate_id(father[:home_ta].squish, 'Traditional Authority', home_district_id)
          if home_ta_id.blank?
             home_ta_id  = Location.where(:name =>"Other").last.id
             home_ta_other  = father[:home_ta].squish
          end
      elsif father[:foreigner_home_ta].present?
          home_ta_id  = Location.where(:name =>"Other").last.id
          home_district_other  = father[:foreigner_home_ta]
      end

      if father[:current_village].present?
          home_village_id = Location.locate_id(father[:current_village].squish, 'Village', home_ta_id)
          if home_village_id.blank?
             home_village_id         = Location.where(:name =>"Other").last.id
             home_village_other  = father[:home_village]
          end
      elsif father[:foreigner_home_village].present?
          home_village_id = Location.where(:name =>"Other").last.id
          home_village_other  = father[:foreigner_home_village]
      end

      citizenship = MigrateChild.search_citizenship(father[:citizenship].squish)
      residential_country = MigrateChild.search_citizenship(father[:residential_country].squish)

      PersonAddress.create(
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
          :address_line_1         => (params[:informant_same_as_father].present? && params[:informant_same_as_father] == "Yes" ? params[:person][:informant][:addressline1] : nil),
          :address_line_2         => (params[:informant_same_as_father].present? && params[:informant_same_as_father] == "Yes" ? params[:person][:informant][:addressline2] : nil),
          :created_at         => params[:person][:created_at].to_date.to_s,
          :updated_at         => params[:person][:updated_at].to_date.to_s
      )
    end

    unless father_person.blank?
      PersonRelationship.create(
              person_a: person.id, person_b: father_person.person_id,
              person_relationship_type_id: PersonRelationType.where(name: father_type).last.id,
              created_at: params[:person][:created_at].to_date.to_s,
              updated_at: params[:person][:updated_at].to_date.to_s
      )
    end


    father_person

  end
end
