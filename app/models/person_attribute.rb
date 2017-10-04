class PersonAttribute < ActiveRecord::Base
    self.table_name = :person_attributes
    self.primary_key = :person_attribute_id
    belongs_to :core_person, foreign_key: "person_id"
    belongs_to :person_attribute_type, foreign_key: "person_attribute_type_id"
    include EbrsAttribute

end
