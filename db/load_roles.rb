puts "Loading User Roles"
CSV.foreach("#{Rails.root}/app/assets/data/user_roles.csv", :headers => false) do |row|
 next if row[0].blank?
 user_role = Role.create!(role: row[0].squish, level: row[1].squish)
 puts "Loaded #{user_role.role}"
end
puts "Loaded User Role !!!"