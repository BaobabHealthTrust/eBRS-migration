puts "Loading Types Of Birth"
CSV.foreach("#{Rails.root}/app/assets/data/types_of_birth.csv", :headers => false) do |row|
 next if row[0].blank?
 type_of_birth = PersonTypeOfBirth.create!(name: row[0].squish)
 puts "Loaded #{type_of_birth.name}"
end
puts "Loaded Types Of Birth !!!"