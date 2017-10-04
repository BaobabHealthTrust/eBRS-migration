class Person < ActiveRecord::Base
  self.table_name = :person
  self.primary_key = :person_id
  belongs_to :core_person, foreign_key: "person_id"
  has_many :person_names
  has_many :person_addresses

  include EbrsAttribute

  def addresses
    PersonAddress.where(person_id: self.id)
  end

  def mother
    result = nil
    relationship_type = PersonRelationType.find_by_name("Mother")

    relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
    unless relationship.blank?
      result = Person.where(:person_id => relationship.person_b).last
    end

    result
  end

  def father
    result = nil
    relationship_type = PersonRelationType.find_by_name("Father")

    relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
    unless relationship.blank?
      result = Person.where(:person_id => relationship.person_b).last
    end

    result
  end

  def informant
    result = nil
    relationship_type = PersonRelationType.find_by_name("Informant")

    relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
    unless relationship.blank?
      result = Person.where(:person_id => relationship.person_b).last
    end

    result
  end

  def citizenship
    adr = PersonAddress.where(person_id: self.id).last
    loc_name = Location.find(adr.citizenship).country  rescue nil
    loc_name
  end

  def name
    name = self.person_names.last
    "#{name.first_name} #{name.middle_name} #{name.last_name}".gsub(/\s+/, ' ')
  end

  def full_gender
    {'M' => 'Male', 'F' => 'Female'}[self.gender]
  end

  def get_attribute(type)
    type_id = PersonAttributeType.where(name: type).last.id rescue nil
    PersonAttribute.where(person_id: self.person_id, person_attribute_type_id: type_id, voided: 0).last.value rescue nil
  end

  def first_name
    name = self.person_names.last
    name.first_name.gsub(/\s+/, ' ')
  end

  def middle_name
    name = self.person_names.last
    name.middle_name.gsub(/\s+/, ' ') rescue nil
  end

  def last_name
    name = self.person_names.last
    name.last_name.gsub(/\s+/, ' ')
  end

end
