module EbrsMetadata

  def self.included(base)
    base.class_eval do
      before_create :check_record_complteness_before_creating
      before_save :check_record_complteness_before_updating
      #before_create :generate_key
    end
  end

  def check_record_complteness_before_creating
    self.creator = User.current.id if self.attribute_names.include?("creator") \
    and (self.creator.blank? || self.creator == 0)and User.current != nil
    self.provider_id = User.current.person.id if self.attribute_names.include?("provider_id") and \
      (self.provider_id.blank? || self.provider_id == 0)and User.current != nil
    self.created_at = Time.now if self.attribute_names.include?("created_at")
    self.updated_at = Time.now if self.attribute_names.include?("updated_at")
    self.uuid = ActiveRecord::Base.connection.select_one("SELECT UUID() as uuid")['uuid'] \
      if self.attribute_names.include?("uuid")
    self.voided = false if self.attribute_names.include?("voided") and (self.voided.to_s.blank? rescue true)
  end

  def check_record_complteness_before_updating
    self.changed_by = User.current.id if self.attribute_names.include?("changed_by") and (self.creator.blank? || self.creator == 0)and User.current != nil
    self.changed_at = Time.now if self.attribute_names.include?("changed_at")
  end

  def next_primary_key
    max = (ActiveRecord::Base.connection.select_all("SELECT MAX(#{self.class.primary_key}) FROM #{self.class.table_name}").last.values.last.to_i rescue 0)
    autoincpart = max.to_s.split('')[6 .. 1000].join('').to_i rescue 0
    auto_id = autoincpart + 1
    location_pad = SETTINGS['location_id'].to_s.rjust(5, '0').rjust(6, '1')
    new_id = (location_pad + auto_id.to_s).to_i
    new_id
  end

  def generate_key
    if !self.class.primary_key.blank? && !self.class.primary_key.class.to_s.match('CompositePrimaryKeys')
      eval("self.#{self.class.primary_key} = next_primary_key") if self.attributes[self.class.primary_key].blank?
    end
  end

end
