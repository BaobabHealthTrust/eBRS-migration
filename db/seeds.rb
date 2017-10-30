#Create couch DB

def create_user
  puts "Creating Person Type for User"

  person_type = PersonType.where(name: 'User').first

  puts "Creating Core Person for User"

  core_person = CorePerson.create!(person_type_id: person_type.id)

  puts "Creating Person Name for User"

  person_name = PersonName.create!(person_id: core_person.person_id, 
                                   first_name: 'System', 
                                   last_name: 'Admin')
  
  puts "Creating Person Name Code for User"

  person_name_code = PersonNameCode.create!(person_name_id: person_name.person_name_id, 
                                            first_name_code: 'System'.soundex, 
                                            last_name_code: 'Admin'.soundex )

  puts "Creating Role for User"
 
  role = Role.where(role: 'Administrator', :level => 'HQ').first

  puts "Creating User"

  user = User.create!(username: "admin#{SETTINGS['location_id']}",
                      password_hash: 'adminebrs', 
                      creator: User.new.next_primary_key, last_password_date: Time.now().strftime('%Y-%m-%d %H:%M:%S'),
                      person_id: core_person.person_id)

  puts "Creating Role for User"

  UserRole.create!(user_id: user.id, 
                   role_id: role.id)

  User.current = User.first
      
  puts "Successfully created local System Administrator: your new username is: #{user.username}  and password: adminebrs"

  CouchdbSequence.create!(seq: 0)

end

begin
    ActiveRecord::Base.transaction do
      require Rails.root.join('db','load_person_types.rb')
      require Rails.root.join('db','load_person_relationship_types.rb')
      require Rails.root.join('db','load_delivery_modes.rb')
      require Rails.root.join('db','load_level_of_education.rb')
      require Rails.root.join('db','load_types_of_birth.rb')
      require Rails.root.join('db','load_roles.rb')
      require Rails.root.join('db','load_location_tags.rb')
      require Rails.root.join('db','load_countries.rb')
      require Rails.root.join('db','load_districts.rb')
      require Rails.root.join('db','load_tas_and_villages.rb')
      require Rails.root.join('db','load_health_facilities.rb')
      require Rails.root.join('db','load_place_of_birth.rb')
      require Rails.root.join('db','load_statuses.rb')
      require Rails.root.join('db','load_person_attribute_types.rb')
      require Rails.root.join('db','load_person_identifier_types.rb')
      require Rails.root.join('db','load_birth_registration_type.rb')
      require Rails.root.join("db","load_trail_types.rb")
      #require Rails.root.join('db','load_couch_data.rb') #This will be handled by metadata
      create_user
    end
rescue => e
	puts "Error ::::  #{e.message}  ::  #{e.backtrace.inspect}"
end
