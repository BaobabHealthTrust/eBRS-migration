puts "Loading Person Types"
CSV.foreach("#{Rails.root}/app/assets/data/person_types.csv", :headers => false) do |row|
 next if row[0].blank?
 person_type = PersonType.create!(name: row[0].squish)
 puts "Loaded #{person_type.name}"
end
puts "Loaded Person Types !!!"
