class Location < ActiveRecord::Base
  self.table_name = :location
  self.primary_key = :location_id

  def self.locate_id_by_tag(name, tag)
    tag_id = LocationTag.where(name: tag).last.id rescue nil
    LocationTagMap.find_by_sql("SELECT * FROM location_tag_map m INNER JOIN location l ON l.location_id = m.location_id
      WHERE m.location_tag_id = #{tag_id} AND l.name = '#{name}'").last.location_id  rescue nil
  end

  def self.locate_id(name, tag, parent_id)
    tag_id = LocationTag.where(name: tag).last.id rescue nil
    LocationTagMap.find_by_sql("SELECT * FROM location_tag_map m INNER JOIN location l ON l.location_id = m.location_id
      WHERE m.location_tag_id = #{tag_id} AND l.parent_location = #{parent_id} AND l.name = \"#{name}\"").last.location_id  rescue nil
  end

end
