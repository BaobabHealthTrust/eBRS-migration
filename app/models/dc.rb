require 'couchrest_model'

class Dc < CouchRest::Model::Base
  
  use_database "dashboard"
  
  property :district_code, String
  property :registered, Integer
  property :approved, Integer
  property :date_created, String
   
  timestamps!
  
  design do
    view :by__id
    view :by_district_code
    view :by_registered
    view :by_approved
    view :by_district_code_and_registered_and_approved
    
    filter :dashboard_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
    
  end 
  
end
