class Role < ActiveRecord::Base
    self.table_name = :role
    self.primary_key = :role_id
    has_many :user_roles, class_name: 'UserRole', foreign_key: 'role_id'
    include EbrsMetadata
end
