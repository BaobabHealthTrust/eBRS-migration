puts "Loading Birth registration types"
CSV.foreach("#{Rails.root}/app/assets/data/birth_registration_types.csv", :headers => true) do |row|
 next if row[0].blank?
 details = BirthRegistrationType.create!(name: row[0].squish)
 puts "Loaded #{details.name}"
end
puts "Loaded Birth registration types !!!"
