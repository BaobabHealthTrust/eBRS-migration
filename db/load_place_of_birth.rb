
puts "Loading Places of Birth"

location_tag = LocationTag.where(name: 'Place of Birth').first

CSV.foreach("#{Rails.root}/app/assets/data/place_of_birth.csv", :headers => true) do |row|
 	next if row[0].blank?
 	place = Location.new
 	place.name = row[0].to_s
 	if place.save
 		LocationTagMap.create(location_id: place.id, location_tag_id: location_tag.id)
 	end

end
puts "Loaded Place of Birth !!!"
