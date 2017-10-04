require 'couchrest_model'

class Hq < CouchRest::Model::Base
  use_database "hq_dashboard"
  property :category, String
  property :month_count, Integer
  property :year_count, Integer
  property :month, String
  property :year, Integer
   
  timestamps!
  
  design do
    view :by__id
    view :by_category
    view :by_month_count
    view :by_year_count
    view :by_month
    view :by_year
    view :by_category_and_month_and_year
    view :by_category_and_month_and_year_and_month_count_and_year_count
  end 
end
