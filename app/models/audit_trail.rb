class AuditTrail < ActiveRecord::Base
	before_create :set_location
	self.table_name = :audit_trails
    self.primary_key = :audit_trail_id
    belongs_to :audit_trail_types , foreign_key: "audit_trail_type_id"
    include EbrsAttribute
    def set_location
    	self.location_id =  SETTINGS['location_id']
    end
end

