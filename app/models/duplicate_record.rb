class DuplicateRecord < ActiveRecord::Base
    self.table_name = :duplicate_records
    self.primary_key = :duplicate_record_id
    include EbrsAttribute
    belongs_to :potential_duplicates, foreign_key: "potential_duplicate_id"
end
