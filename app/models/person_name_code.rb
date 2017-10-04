class PersonNameCode < ActiveRecord::Base
    self.table_name = :person_name_code
    self.primary_key = :person_name_code_id
    include EbrsAttribute
    belongs_to :person_name, foreign_key: "person_name_id"
end
