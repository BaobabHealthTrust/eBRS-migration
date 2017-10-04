class CorePerson < ActiveRecord::Base
    self.table_name = :core_person
    include EbrsAttribute

    has_one :person, foreign_key: "person_id"
    has_one :person_birth_detail, foreign_key: "person_id"
    has_one :person_address, foreign_key: "person_id"
    has_one :person_attribute, foreign_key: "person_id"
    has_one :person_identifier, foreign_key: "person_id"
    has_one :person_name, foreign_key: "person_id"
    has_many :person_relationships, foreign_key:  [:person_a, :person_b]
    has_many :person_record_status, foreign_key: "person_id"
    belongs_to :person_type , foreign_key: "person_type_id"
    has_one :user
end
