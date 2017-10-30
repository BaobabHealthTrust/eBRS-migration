puts "Loading Status"
CSV.foreach("#{Rails.root}/app/assets/data/person_status.csv", :headers => true) do |row|
 next if row[3].blank?
 status_type = Status.create!(name: row[3].squish, description: row[4].squish)
 puts "Loaded #{status_type.name}"
end
puts "Loaded Statuses !!!"
