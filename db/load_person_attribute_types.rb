puts "Loading Person Attribute Types"
CSV.foreach("#{Rails.root}/app/assets/data/person_attribute_types.csv", :headers => true) do |row|
 next if row[0].blank?
 person_attribute_type = PersonAttributeType.create(name: row[0], description: row[1])
 puts "Loaded #{person_attribute_type.name}"
end
puts "Loaded Person Attribute Types !!!"