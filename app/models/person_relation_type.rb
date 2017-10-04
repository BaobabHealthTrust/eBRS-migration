class PersonRelationType < ActiveRecord::Base
    self.table_name = :person_relationship_types
    self.primary_key = :person_relationship_type_id
end
