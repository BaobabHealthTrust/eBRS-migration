require 'couchrest_model'
class Nationality < CouchRest::Model::Base

  def nationality=(value)
    self['_id'] = value
  end

  def nationality
    self['_id']
  end

  design do
    view :by__id
    view :all
  end

end
