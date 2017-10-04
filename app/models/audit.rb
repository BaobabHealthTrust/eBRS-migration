require 'couchrest_model'

class Audit	< CouchRest::Model::Base

  use_database "audit"

  before_save :set_site_type, :set_user_id

  def audit_id=(value)
    self['_id']=value.to_s
  end

  def audit_id
    self['_id']
  end

  property :record_id, String # Certificate/Child id
  property :audit_type, String # Quality Control | Reprint | Audit | Deduplication | Incomplete Record | DC Record Rejection | HQ Record Rejection | HQ Void | HQ Re-Open | Potential Duplicate
  property :level, String # Child | User
  property :reason, String
  property :user_id, String # User id
  property :site_id, String
  property :site_type, String  #FACILITY, DC, HQ
  property :change_log, [], :default => []
  property :voided, TrueClass, :default => false

  timestamps!

  design do
    view :by__id
    view :by_record_id
    view :by_record_id_and_audit_type
    view :by_audit_type
    view :by_level
    view :by_reason
    view :by_record_id_and_reason
    view :by_user_id
    view :by_site_id
    view :by_site_type
    view :by_voided
    view :by_created_at
    view :by_updated_at
    view :by_level_and_created_at
    view :by_level_and_user_id
    filter :facility_sync, "function(doc,req) {return req.query.site_id == doc.site_id}"

  end

  def set_user_id
    self.user_id = User.current_user.id rescue 'admin'
  end

  def set_site_type
    self.site_type = "HQ"
  end

end
