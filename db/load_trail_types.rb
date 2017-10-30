puts "Loading Trail Types"
CSV.foreach("#{Rails.root}/app/assets/data/audit_trail_type.csv", :headers => false) do |row|
 next if row[0].blank?
 trail_type = AuditTrailType.create!(name: row[0].squish)
 puts "Loaded #{trail_type.name}"
end
puts "Loaded Trail Types !!!"