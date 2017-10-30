puts "Loading Delivery Modes"
CSV.foreach("#{Rails.root}/app/assets/data/delivery_modes.csv", :headers => false) do |row|
 next if row[0].blank?
 delivery_mode = ModeOfDelivery.create!(name: row[0].squish)
 puts "Loaded #{delivery_mode.name}"
end
puts "Loaded Delivery Types !!!"