require 'couchrest_model'

class District < CouchRest::Model::Base

  def district_code=(value)
    self['_id']=value.to_s
  end

  def district_code
    self['_id']
  end

  property :name, String
  property :region, String
  
  timestamps!

  design do
      view :by__id
      view :by_name
      view :by_region
  end

end
