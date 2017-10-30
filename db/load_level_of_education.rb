puts "Loading Level of  Educaton"
CSV.foreach("#{Rails.root}/app/assets/data/level_of_education.csv", :headers => false) do |row|
 next if row[0].blank?
 level_of_education = LevelOfEducation.create!(name: row[0].squish)
 puts "Loaded #{level_of_education.name}"
end
puts "Loaded Level of Education !!!"