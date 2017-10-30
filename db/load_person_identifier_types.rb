puts "Loading Person Identfier Types"
CSV.foreach("#{Rails.root}/app/assets/data/person_identifier_types.csv", :headers => true) do |row|
 next if row[0].blank?
 person_identifier_type = PersonIdentifierType.create(name: row[0], description: row[1])
 puts "Loaded #{person_identifier_type.name}"
end
puts "Loaded Person Identifier Types !!!"