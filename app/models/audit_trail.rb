class AuditTrail < ActiveRecord::Base
	before_create :set_location
	self.table_name = :audit_trails
    self.primary_key = :audit_trail_id
    belongs_to :audit_trail_types , foreign_key: "audit_trail_type_id"
    include EbrsAttribute
     class << self
	    attr_accessor :ip_address_accessor
	    attr_accessor :mac_address_accessor
	  end
    def set_location
    	self.location_id =  SETTINGS['location_id']
    	self.ip_address = 	(AuditTrail.ip_address_accessor rescue (request.remote_ip rescue `ip route show`[/default.*/][/\d+\.\d+\.\d+\.\d+/]))
    	self.mac_address =  (AuditTrail.mac_address_accessor rescue (` arp #{request.remote_ip}`.split(/\n/).last.split(/\s+/)[2] rescue MacAddress.address))
    end
end

