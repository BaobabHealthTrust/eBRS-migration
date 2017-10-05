class PotentialDuplicate < ActiveRecord::Base
    self.table_name = :potential_duplicates
    self.primary_key = :potential_duplicate_id
    belongs_to :person, foreign_key: "person_id"
    has_many :duplicate_records, foreign_key: "potential_duplicate_id"
    def create_duplicate(id)
    	duplicate_record = DuplicateRecord.new
    	duplicate_record.potential_duplicate_id = self.id
    	duplicate_record.person_id = id
    	duplicate_record.created_at = (Time.now))
    
      sql = "(#{duplicate_record.potential_duplicate_id},#{duplicate_record.person_id},#{duplicate_record.created_at}),"
      `echo -n '#{sql}' >> #{Rails.root}/app/assets/data/migration_dumps/potential_duplicate.sql`
    end
end
