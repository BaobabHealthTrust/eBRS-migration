class PersonAddress < ActiveRecord::Base
    self.table_name = :person_addresses
    self.primary_key = :person_addresses_id
    belongs_to :core_person, foreign_key: "person_id"
    include EbrsAttribute

end
