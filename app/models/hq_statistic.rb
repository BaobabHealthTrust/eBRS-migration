require 'couchrest_model'
class HQStatistic < CouchRest::Model::Base

  use_database "daily_stats"

  property :district_code, String
  property :reported_date, Date
  property :reported, Integer, :default => 0
  property :printed, Integer, :default => 0
  property :reprinted, Integer, :default => 0
  property :incomplete, Integer, :default => 0
  property :suspectd_duplicates, Integer, :default => 0
  property :amendements_requests, Integer, :default => 0
  property :approved, Integer, :default => 0
  timestamps!

  design do
    view :by__id
    view :by_district_code
    view :by_reported_date
    view :by_district_code_and_reported_date
  end
end

