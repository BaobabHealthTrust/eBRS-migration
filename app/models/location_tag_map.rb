class LocationTagMap < ActiveRecord::Base
    self.table_name = :location_tag_map
    self.primary_keys = :location_id, :location_tag_id
    belongs_to  :location_tag, class_name: 'LocationTag', foreign_key: 'location_tag_id'
    include EbrsMetadata
end
