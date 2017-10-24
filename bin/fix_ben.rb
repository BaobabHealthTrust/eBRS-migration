puts "Running script to fix BEN's"
old_brn_type_id = PersonIdentifierType.where(name: "Old Birth Entry Number").first.id
data = PersonIdentifier.find_by_sql("
  SELECT value, person_id  FROM person_identifiers
  WHERE person_identifier_type_id = #{old_brn_type_id}
  GROUP BY SUBSTRING(value, 1, 3), SUBSTRING(value, -4, 4), person_id
  ORDER BY SUBSTRING(value, 1, 3) ASC,  SUBSTRING(value, -4, 4) ASC, SUBSTRING(value, -12, 7) ASC;
")

index = {}
data.each do |d|
  #create fixed BEN
  old_ben = d.value
  code, inc, year = old_ben.split("/")
  index[code] = {} if index[code].blank?
  index[code][year] = 0 if index[code][year].blank?
  index[code][year] += 1

  new_inc =  index[code][year].to_s.rjust(8,'0')
  new_ben = "#{code}/#{new_inc}/#{year}"

  PersonBirthDetail.where(person_id: d.person_id).first.update_columns(district_id_number: new_ben)
end