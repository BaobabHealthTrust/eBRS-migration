class User < ActiveRecord::Base
  self.table_name = :users
  self.primary_key = :user_id
  include EbrsAttribute
  default_scope { where(voided: 0) }

  cattr_accessor :current

  belongs_to :core_person, foreign_key: "person_id"
  belongs_to :location
  has_one :user_role

  def has_role?(role_name)
    self.current.role == role_name ? true : false
  end

  before_save do |pass|
    check_password = BCrypt::Password.new(self.password_hash) rescue 'invalid hash'
    self.password_hash = BCrypt::Password.create(self.password_hash) if (check_password == 'invalid hash')
    self.location_id = SETTINGS['location_id'] if self.location_id.blank?
  end

  def password_matches?(plain_password)
    !plain_password.nil? and BCrypt::Password.new(self.password_hash) == plain_password
  end

  def password
    @password ||= BCrypt::Password.new(password_hash)
  rescue BCrypt::Errors::InvalidHash
    Rails.logger.error "The password_hash attribute of User[#{self.username}] does not contain a valid BCrypt Hash."
    return nil
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
  end

  def self.get_active_user(username)
    user = User.find_by_sql("SELECT u.* FROM users u
               INNER JOIN user_role ur ON ur.user_id = u.user_id
               INNER JOIN role r ON r.role_id = ur.role_id WHERE r.level = 'HQ' AND u.username = '#{username}' ").first rescue nil

   return user
  end

  def confirm_password
    password_hash
  end

  def first_name
    self.core_person.person_name.first_name rescue nil
  end

  def last_name
    self.core_person.person_name.last_name rescue nil
  end

  def create_audit
    #Audit.create(record_id: self.id, audit_type: "Audit", level: "User", reason: "Created user record")
  end

end





