class AuditTrailType < ActiveRecord::Base
	self.table_name = :audit_trail_types
    self.primary_key = :audit_trail_type_id
    has_many  :audit_trails
    include EbrsMetadata
end
