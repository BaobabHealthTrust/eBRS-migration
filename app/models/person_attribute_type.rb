class PersonAttributeType < ActiveRecord::Base
    self.table_name = :person_attribute_types
    self.primary_key = :person_attribute_type_id
    has_many :person_attributes, :foreign_key => "person_attribute_type_id"
    include EbrsMetadata
end
