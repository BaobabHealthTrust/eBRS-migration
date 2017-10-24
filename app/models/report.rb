class Report < ActiveRecord::Base
  def self.births_report(params)
    start_date = params[:start_date].to_date.to_s rescue Date.today.to_s
    end_date = params[:end_date].to_date.to_s rescue Date.today.to_s

    if params[:status].blank?
      status = "Reported"
      status_ids = Status.all.map{|m| m.status_id}.join(",")
    else
      status = params[:status]
      status_ids = Status.where(name: status).map{|m| m.status_id}.join(",")
    end

    if params[:district].present?
       locations = Location.find(params[:district]).children << Location.find(params[:district]).id
    else
      locations = []
    end

    age_sql = ""
    if params[:operator].present?
        case params[:operator]
        when "BETWEEN"
            age_sql = " AND (DATEDIFF(NOW(),p.birthdate)/365) >= #{params[:start_age]} AND (DATEDIFF(NOW(),p.birthdate)/365) <= #{params[:end_age]} "
        else
            age_sql = " AND (DATEDIFF(NOW(),p.birthdate)/365) #{params[:operator]} #{params[:start_age]} "
        end
    end
    
    total_male   =  0
    total_female =  0

    reg_type = {}
    ['Normal', 'Abandoned', 'Adopted', 'Orphaned'].each do |type|
      reg_type[type] = {}
      
      male =  ActiveRecord::Base.connection.select_all(

            "SELECT COUNT(*) AS total FROM person_birth_details pbd
                  INNER JOIN person p ON p.person_id = pbd.person_id
                  INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                  INNER JOIN birth_registration_type t ON t.birth_registration_type_id = pbd.birth_registration_type_id AND t.name = '#{type}'
                WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'M'
                AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                #{age_sql} GROUP BY p.gender, pbd.birth_registration_type_id
              "
      ).as_json.last['total'] rescue 0
      reg_type[type]['Male']  = male

      female =  ActiveRecord::Base.connection.select_all(

          "SELECT COUNT(*) AS total FROM person_birth_details pbd
                  INNER JOIN person p ON p.person_id = pbd.person_id
                  INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                  INNER JOIN birth_registration_type t ON t.birth_registration_type_id = pbd.birth_registration_type_id AND t.name = '#{type}'
                  WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'F'
                  AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                  #{age_sql} GROUP BY p.gender, pbd.birth_registration_type_id
              "
      ).as_json.last['total'] rescue 0
      reg_type[type]['Female'] = female

      total_male = total_male + male
      total_female = total_female + female
      
    end

    parents_married  = {}
    [0, 1].each do |k|
      parents_married[(k == 0 ? 'No' : 'Yes')] = {}
      parents_married[(k == 0 ? 'No' : 'Yes')]['Male'] =  ActiveRecord::Base.connection.select_all(

          "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}'
                    AND pbd.parents_married_to_each_other = #{k} AND p.gender = 'M'
                    AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                    #{age_sql} GROUP BY p.gender, pbd.parents_married_to_each_other
                "
      ).as_json.last['total'] rescue 0
      parents_married[(k == 0 ? 'No' : 'Yes')]['Female'] =  ActiveRecord::Base.connection.select_all(

          "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}'
                    AND pbd.parents_married_to_each_other = #{k} AND p.gender = 'F'
                    AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                    #{age_sql} GROUP BY p.gender, pbd.parents_married_to_each_other
                "
      ).as_json.last['total'] rescue 0
    end

    delayed = {}
    ['No', 'Yes'].each do |k|
      delayed[k] = {}
      c = (k == 'Yes') ? '>' : '<='

      delayed[k]['Male'] =  ActiveRecord::Base.connection.select_all(
          "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                  WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'M'
                  AND DATEDIFF(pbd.date_registered, p.birthdate) #{c} 42
                  AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                  #{age_sql}
                "
      ).as_json.last['total'] rescue 0

      delayed[k]['Female'] =  ActiveRecord::Base.connection.select_all(
          "SELECT COUNT(*) AS total, p.gender FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                  WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'F'
                  AND DATEDIFF(pbd.date_registered, p.birthdate) #{c} 42
                  AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                  #{age_sql}
                "
      ).as_json.last['total'] rescue 0
    end

    place_of_birth = {}

    ['Home','Hospital','Other'].each do |k|
        place_of_birth[k] = {}
        
        male =  ActiveRecord::Base.connection.select_all(

                "SELECT COUNT(*) AS total FROM person_birth_details pbd
                      INNER JOIN person p ON p.person_id = pbd.person_id
                      INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE  pbd.place_of_birth = (SELECT location_id FROM location WHERE name = '#{k}') AND DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'M'
                    AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                    #{age_sql} GROUP BY p.gender, pbd.birth_registration_type_id
                  "
        ).as_json.last['total'] rescue 0
        place_of_birth[k]['Male']  = male

        female=  ActiveRecord::Base.connection.select_all(

                "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE  pbd.place_of_birth = (SELECT location_id FROM location WHERE name = '#{k}') AND DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'F'
                    AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                    #{age_sql} GROUP BY p.gender, pbd.birth_registration_type_id
                  "
        ).as_json.last['total'] rescue 0
        place_of_birth[k]['Female']  = female

    end
    type_of_birth = {}
    ["Single","First Twin","Second Twin","First Triplet","Second Triplet", "Third Triplet","Other"].each do |type|
       type_of_birth[type] = {}
       male =  ActiveRecord::Base.connection.select_all(

                "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE  pbd.type_of_birth = (SELECT person_type_of_birth_id FROM person_type_of_births WHERE name = '#{type}') AND DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'M'
                    AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                    #{age_sql} GROUP BY p.gender, pbd.birth_registration_type_id
                  "
        ).as_json.last['total'] rescue 0

        type_of_birth[type]["Male"] = male

        female=  ActiveRecord::Base.connection.select_all(

                "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE  pbd.type_of_birth = (SELECT person_type_of_birth_id FROM person_type_of_births WHERE name = '#{type}') AND DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'F'
                    AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                    #{age_sql} GROUP BY p.gender, pbd.birth_registration_type_id
                  "
        ).as_json.last['total'] rescue 0
        type_of_birth[type]["Female"] = female
    end
    mode_of_delivery = {}
    ["SVD","Vacuum Extraction","Breech","Forceps","Caesarean Section"].each do |mode|
      mode_of_delivery[mode] = {}
      male =  ActiveRecord::Base.connection.select_all(

                "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE  pbd.mode_of_delivery_id = (SELECT mode_of_delivery_id FROM mode_of_delivery WHERE name = '#{mode}') AND DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'M'
                    AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                    #{age_sql} GROUP BY p.gender, pbd.birth_registration_type_id
                  "
        ).as_json.last['total'] rescue 0

        mode_of_delivery[mode]["Male"] = male
        
        female=  ActiveRecord::Base.connection.select_all(

                "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE  pbd.mode_of_delivery_id = (SELECT mode_of_delivery_id FROM mode_of_delivery WHERE name = '#{mode}') AND DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'F'
                    AND prs.status_id IN (#{status_ids}) #{locations.present? ? ' AND pbd.location_created_at IN('+locations.join(',')+')' : ''}
                    #{age_sql} GROUP BY p.gender, pbd.birth_registration_type_id
                  "
        ).as_json.last['total'] rescue 0
        mode_of_delivery[mode]["Female"] = female
    end

    total = {"Total" =>{"Male" => total_male, "Female" => total_female}}.as_json
    data = {
      'Registration Types' => reg_type.as_json,
      'Parents Married'    => parents_married.as_json,
      'Delayed Registrations' => delayed.as_json,
      'Place of Birth' => place_of_birth.as_json,
      'Type of Birth'  => type_of_birth.as_json,
      'Mode of Delivery'  => mode_of_delivery.as_json,
      "#{status}" => total.as_json
     }
    data
  end
  def self.by_status(status, start_date,end_date)
    

  end

  def self.user_audits(user = nil ,person = nil, start_date =nil,end_date = nil)

      start_date = Date.today.strftime('%Y-%m-%d 00:00:00') if start_date.blank?
      end_date = Date.today.strftime('%Y-%m-%d 23:59:59') if end_date.blank?


      query = "SELECT CONCAT(first_name,\" \", last_name) as name,username, table_name, comment, 
              (SELECT CONCAT(first_name, \" \", last_name) FROM person_name a 
              WHERE a.person_id = audit_trails.person_id AND a.voided =0) as client,
              (SELECT name FROM location l WHERE l.location_id = audit_trails.location_id) 
              as location,DATE_FORMAT(audit_trails.created_at,\"%Y-%m-%d %H:%i:%s\")as created_at,
              audit_trails.mac_address, audit_trails.ip_address FROM audit_trails 
              INNER JOIN person_name ON audit_trails.creator = person_name.person_id
              INNER JOIN users ON users.user_id = audit_trails.creator WHERE 
              DATE(audit_trails.created_at) >=  '#{start_date}' AND DATE(audit_trails.created_at) <= '#{end_date}' 
              ORDER BY audit_trails.created_at"

      return ActiveRecord::Base.connection.select_all(query).as_json
  end
end
