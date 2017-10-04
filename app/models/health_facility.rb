require 'couchrest_model'

class HealthFacility < CouchRest::Model::Base
 
  property :district,String
  property :district_code, String
  property :name, String
  property :zone,String
  property :fac_type, String
  property :mga,String
  property :f_type, String
  property :latitude,String
  property :longitude,String
 
  
  def facility_code=(value)
    self['_id']=value.to_s
  end

  def facility_code
    self['_id']
  end
  
  timestamps!
 
  design do
      view :by__id
      view :by_name
      view :by_facility_code
      view :by_district
      view :by_latitude_and_longitude
      view :by_name_and_district
      view :by_district_code
      view :by_mga
      view :by_f_type
      view :by_fac_type
  end
  
end
