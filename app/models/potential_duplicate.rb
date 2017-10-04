class PotentialDuplicate < ActiveRecord::Base
    self.table_name = :potential_duplicates
    self.primary_key = :potential_duplicate_id
    belongs_to :person, foreign_key: "person_id"
    has_many :duplicate_records, foreign_key: "potential_duplicate_id"
    def create_duplicate(id)
    	DuplicateRecord.create(potential_duplicate_id: self.id, person_id: id , created_at:(Time.now))
    end
end
