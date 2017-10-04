require 'couchrest_model'
require 'thread'

class Hospital < CouchRest::Model::Base

  def hospital_id=(value)
    self['_id']=value.to_s
  end

  def hospital_id
    self['_id']
  end

  property :region, String
  property :district, String
  property :lon, String
  property :lat, String

  timestamps!

  design do
    view :by_district,
         :map => "function(doc) {
                  if ((doc['type'] == 'Hospital')) {
                    emit(doc['district'], 1);
                  }
                }"

    view :by_region,
         :map => "function(doc) {
                  if ((doc['type'] == 'Hospital')) {
                    emit(doc['region'], 1);
                  }
                }"

    view :by_facility,
         :map => "function(doc) {
                  if ((doc['type'] == 'Hospital')) {
                    emit(doc['_id'], 1);
                  }
                }"
  end

end