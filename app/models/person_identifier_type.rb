class PersonIdentifierType < ActiveRecord::Base
    self.table_name = :person_identifier_types
    self.primary_key = :person_identifier_type_id
    has_many :person_identifiers, foreign_key: "person_identifier_type_id"
end
