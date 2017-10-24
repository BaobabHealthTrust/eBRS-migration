$configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")['user_migration']
$database = "#{$configs['prefix']}_local_#{$configs['suffix']}".gsub(/^\_|\_$/, '')
$couch_link = "#{$configs['protocol']}://#{$configs['username']}:#{$configs['password']}@#{$configs['host']}:#{$configs['port']}/#{$database}/"
$couch_link += "_design/User/_view/all?include_docs=true"

users = JSON.parse(`curl -X GET #{$couch_link}`)

raise " No Users Found".to_s if users.blank?

=begin
{"_id"=>"cmponda", "_rev"=>"10-62b438eedf7a8c467fc684361f84ec59",
 "first_name"=>"Chisomo",
 "last_name"=>"Mponda",
 "password_hash"=>"$2a$10$syClDsDR9B6gg89nt3HMSun02jeSs9JBEYcvDNL09hd1baOROHVTa",
 "last_password_date"=>"2016-08-18T06:28:41.780Z",
 "password_attempt"=>0,
 "login_attempt"=>0,
 "email"=>"",
 "active"=>true, "notify"=>false,
 "role"=>"Data Checking Clerk",
 "creator"=>"admin",
 "updated_at"=>"2016-08-18T06:28:41.781Z",
 "created_at"=>"2016-01-20T06:08:23.393Z",
 "type"=>"User"}

#<User user_id: 1002511,
# location_id: 251, username: "admin251",
# plain_password: nil, password_hash: "$2a$10$VE9BW8uG3yBghmJa5b6VdOQjODg7LAo9Z2FjvTxj7YT...",
# creator: 1002511,
person_id: 1002511,
# active: 1,
# un_or_block_reason: nil,
# voided: 0,
# voided_by: nil,
# date_voided: nil,
# void_reason: nil,
# email: nil, notify: 0,
# preferred_keyboard: "abc", password_attempt: 0,
# last_password_date: "2017-10-05 15:21:04",
# uuid: "0a585655-a9d0-11e7-a700-f406691514db",
# updated_at: "2017-10-05 13:21:04",
# created_at: "2017-10-05 13:21:04"
=end

users['rows'].each do |user|
 user = user['doc']
 puts "#{user['_id']}"
 u =  User.where(username: user['_id']).last rescue nil

=begin
#If you want to UNDO/REMOVE users added by this script remove this comment and run again
 if u.present?
   UserRole.where(user_id: u.id).each do |a|
     a.destroy
   end
   u.destroy
 end
 next
=end

  level = SETTINGS['application_mode']
  level = 'HQ' if level.blank?
  role_name = user['role']
  role_name = 'Administrator' if role_name == "System Administrator"

  if u.blank?
    person = CorePerson.create(
        person_type_id: PersonType.where(name: 'User').first.id
    )

    PersonName.create(
        person_id: person.id,
        first_name: user['first_name'],
        last_name: user['last_name']
    )
    u = User.create(
        username: user['_id'],
        location_id: SETTINGS['location_id'],
        password_hash: user['password_hash'],
        creator: User.first.id,
        person_id: person.id,
        active: (user['active'] == true ? 1 : 0),
        last_password_date: (user['last_password_date'].to_datetime rescue nil),
        email: user['email']
    )

    UserRole.create(
        user_id: u.id,
        role_id: Role.where(level: level,
                            role: role_name).first.id
    ) rescue (raise user.inspect)
  end
end