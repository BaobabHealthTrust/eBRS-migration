require 'couchrest_model'
require 'thread'

class DistrictNumber < CouchRest::Model::Base

  use_database "local"

  cattr_accessor :mutex

  property :year, Integer
  property :auto_increment_count, Integer, :default => 0
  property :district_code, String

  timestamps!

  def self.assign_district_number(child, district_code, year)

    return false if (child.class.name.to_s.downcase != "child" rescue true)

    @mutex = Mutex.new if @mutex.blank?

    t = Thread.new do

      @mutex.lock

      counter = self.by_year.key([district_code, year]).each.first

      counter = self.create(:year => year, :auto_increment_count => 0, :district_code => district_code) if counter.nil?

      next_number = counter.auto_increment_count + 1

      district_id = "#{district_code}/%07d/#{year}" % next_number

      @mutex.unlock if !child.district_id_number.blank?

      return false if !child.district_id_number.blank?

      counter.update_attributes(:auto_increment_count => next_number)

      child.update_attributes(:district_id_number => district_id, :record_status => "DC OPEN", :request_status => "ACTIVE")

      @mutex.unlock

      return true

    end

  end

  design do
    view :by_year,
         :map => "function(doc) {
                  if ((doc['type'] == 'DistrictNumber')) {
                    emit([doc['district_code'], doc['year']], doc['auto_increment_count']);
                  }
                }"
  end

end