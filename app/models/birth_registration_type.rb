class BirthRegistrationType < ActiveRecord::Base
  self.table_name   = :birth_registration_type
  self.primary_key  = :birth_registration_type_id
  include EbrsMetadata
end
