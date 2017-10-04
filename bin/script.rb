def start
mothers = Person.find_by_sql
          ("SELECT first_name, middle_name, last_name, birthdate, estimated_birthdate, home_ta, home_village, citizenship
            FROM person p
            INNER JOIN person_addresses pa ON pa.person_id = p.person_id
            INNER JOIN person_name pn ON pn.person_id = p.person_id
            WHERE p.person_id IN (SELECT person_b FROM person_relationship WHERE person_attribute_type_id = 6)
          GROUP_BY p.person_id")

  results = []

    mothers.each do |data|
      name          = ("#{data['first_name']} #{data['middle_name']} #{data['last_name']}")
      mother_name   = ("#{mother.first_name rescue 'N/A'} #{mother.middle_name rescue ''} #{mother.last_name rescue ''}")
      mother_birthdate   = ("#{mother.birthdate rescue ''} #{mother.estimated_birthdate rescue ''}")
      mother_address = ("#{mother.home_ta rescue ''} #{mother.home_village rescue ''} #{mother.citizenship rescue ''}")

      results << {
          'id' => data.person_id,
          'name'        => name,
          'mother_name'       => mother_name,
          'mother_birthdate' => mother_birthdate,
          'mother_address'  => mother_address,
            }
    end

    results
end

start
