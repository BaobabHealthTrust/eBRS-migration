class Location < ActiveRecord::Base
  include EbrsMetadata

  self.table_name = :location
  self.primary_key = :location_id
  has_many  :users
  has_one   :location_tag_map, class_name: 'LocationTagMap', foreign_key: 'location_id'


  cattr_accessor :current_district
  cattr_accessor :current_health_facility
  cattr_accessor :current
    
  def facility_district
    if self.parent_location.blank?
      return self 
    else
      if self.location_tag_map.location_tag.name.match(/Health facility/i)
        return Location.find(self.parent_location)
      else
        return nil
      end
    end

  end

  def district(raw=false)
    ta = self.ta(true)
    if !ta.blank?
      tag = LocationTag.where(name: 'District').last.id
      tag_map = LocationTagMap.where(location_tag_id: tag, location_id: ta.parent_location)

      if tag_map.present?
        if raw
          return Location.find(ta.parent_location)
        else
          return Location.find(ta.parent_location).name
        end
      end
    end

    tag = LocationTag.where(name: 'District').last.id
    tag_map = LocationTagMap.where(location_tag_id: tag, location_id: self.id)

    if tag_map.present?
      if raw
        return self
      else
        return self.name
      end
    end
  end

  def ta(raw=false)
    tag = LocationTag.where(name: 'Village').last.id
    tag_map = LocationTagMap.where(location_tag_id: tag, location_id: self.id)

    if tag_map.present?
      tag = LocationTag.where(name: 'Traditional Authority').last.id
      tag_map = LocationTagMap.where(location_tag_id: tag, location_id: self.parent_location)
      if tag_map.present?
        if raw
          return Location.find(self.parent_location)
        else
          return Location.find(self.parent_location).name
        end
      end
    else
      tag = LocationTag.where(name: 'Traditional Authority').last.id
      tag_map = LocationTagMap.where(location_tag_id: tag, location_id: self.id)

      if tag_map.present?
        if raw
          return self
        else
          return self.name
        end
      end
    end

    return nil
  end

  def village(raw=false)
    tag = LocationTag.where(name: 'Village').last.id
    tag_map = LocationTagMap.where(location_tag_id: tag, location_id: self.id)
    if tag_map.present?
      if raw
        return self
      else
        return self.name
      end
    else
      return nil
    end
  end

  def self.locate_id(name, tag, parent_id)
    tag_id = LocationTag.where(name: tag).last.id rescue nil
    LocationTagMap.find_by_sql("SELECT * FROM location_tag_map m INNER JOIN location l ON l.location_id = m.location_id
      WHERE m.location_tag_id = #{tag_id} AND l.parent_location = #{parent_id} AND l.name = \"#{name}\"").last.location_id  rescue nil
  end

  def self.locate_id_by_tag(name, tag)
    tag_id = LocationTag.where(name: tag).last.id rescue nil
    LocationTagMap.find_by_sql("SELECT * FROM location_tag_map m INNER JOIN location l ON l.location_id = m.location_id
      WHERE m.location_tag_id = #{tag_id} AND l.name = '#{name}'").last.location_id  rescue nil
  end
end
