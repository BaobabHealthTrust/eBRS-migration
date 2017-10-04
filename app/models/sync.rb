require 'couchrest_model'
class Sync < CouchRest::Model::Base
	use_database "sync"
	property :person_id, String
	property :dc_sync_status, TrueClass, :default => false
	property :hq_sync_status, TrueClass, :default => false
	property :record_status, String
	property :request_status, String
	property :facility_code, String
	property :district_code, String
	timestamps!
	design do
		view :by__id
		view :by_person_id
		view :by_sync_status
		view :by_district_code
		view :by_facility_code
		view :by_created_at
		view :by_district_code_and_hq_sync_status
		view :by_facility_code_and_dc_sync_status
		filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
		filter :facility_sync, "function(doc,req) {return req.query.facility_code == doc.facility_code}"

	end
	
end