class EbrsMigration < ActiveRecord::Base
	self.table_name = :ebrs_migration
    self.primary_key = :ebrs_migration_id
    include EbrsMetadata
end
