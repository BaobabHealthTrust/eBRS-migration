require 'couchrest_model'

class NationalIdNumber < CouchRest::Model::Base

  use_database "local"

  before_save      EncryptionWrapper.new("national_serial_number")
  after_save       EncryptionWrapper.new("national_serial_number")
  after_initialize EncryptionWrapper.new("national_serial_number")

  before_save      EncryptionWrapper.new("district_id_number")
  after_save       EncryptionWrapper.new("district_id_number")
  after_initialize EncryptionWrapper.new("district_id_number")

  property :national_serial_number_value, Integer
  property :national_serial_number, String
  property :district_id_number, String

  timestamps!
   
  design do
    view :by_national_serial_number_value
    view :by_national_serial_number
    view :by_district_id_number
    view :by_updated_at
    view :by_created_at
  end

end
