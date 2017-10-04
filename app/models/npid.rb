require 'couchrest_model'

class Npid < CouchRest::Model::Base

  use_database "npid"
  
  def incremental_id=(value)
    self['_id']=value.to_s
  end

  def incremental_id
      self['_id']
  end

  property :national_id, String
  property :site_code, String
  property :assigned, TrueClass, :default => false
  property :region, String
  property :child_id, String

  timestamps!

  design do
    view :by__id
    view :by_national_id
    view :by_site_code
    view :by_site_code_and_assigned
    view :by_child_id_and_assigned
    view :by_assigned
    view :by_updated_at
    view :by_created_at
  end

end

