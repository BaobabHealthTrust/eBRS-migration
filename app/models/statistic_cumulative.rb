require 'couchrest_model'
class StatisticCumulative < CouchRest::Model::Base

  use_database "stats_cumulative"

  property :district_code, String
  property :reported, Integer, :default => 0
  property :printed, Integer, :default => 0
  property :verified, Integer, :default => 0
  property :reprinted, Integer, :default => 0
  property :incomplete, Integer, :default => 0
  property :suspectd_duplicates, Integer, :default => 0
  property :amendements_requests, Integer, :default => 0
  timestamps!

  design do
    view :by__id
    view :by_district_code
  end
end

