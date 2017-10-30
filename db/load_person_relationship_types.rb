puts "Loading Person Relationship Types"
CSV.foreach("#{Rails.root}/app/assets/data/person_relationship_types.csv", :headers => true) do |row|
 next if row[0].blank?
 person_relationship_type = PersonRelationType.create!(name: row[0].squish)
 puts "Loaded #{person_relationship_type.name}"
end
puts "Loaded Person Relationship Types !!!"
