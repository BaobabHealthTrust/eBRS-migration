class PersonRelationship < ActiveRecord::Base
    self.table_name = :person_relationship
    self.primary_key = :person_relationship_id
    include EbrsAttribute

    belongs_to :core_person, foreign_key: "person_id"
    belongs_to :person_relationship_type,  foreign_key: "person_relationship_type_id"

end
