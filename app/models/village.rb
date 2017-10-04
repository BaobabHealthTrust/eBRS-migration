require 'couchrest_model'

class Village < CouchRest::Model::Base

  property :village, String
  property :ta, String
  property :district, String
  
  timestamps!

  design do
      view :by__id
      view :by_village
      view :by_ta
      view :by_district

      view :by_district_ta_and_village,
           :map => "function(doc) {
                  if (doc['type'] == 'Village' && doc['village'] != null && doc['ta'] != null && doc['district'] != null ) {
                    emit([doc['district'], doc['ta'], doc['village']], 1);
                  }
                }"

      view :by_district_and_ta,
           :map => "function(doc) {
                  if (doc['type'] == 'Village' && doc['ta'] != null && doc['district'] != null ) {
                    emit([doc['district'], doc['ta']], 1);
                  }
                }"

      view :by_district,
           :map => "function(doc) {
                  if (doc['type'] == 'Village' && doc['district'] != null ) {
                      emit([doc['district']], 1);
                  }
                }"
  end

end
