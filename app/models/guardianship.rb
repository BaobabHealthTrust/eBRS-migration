class Guardianship < ActiveRecord::Base
    self.table_name = :guardianship
    self.primary_key = :guardianship_id
    has_many :person_birth_details, foreign_key: "guardianship_id"
    include EbrsAttribute
end
