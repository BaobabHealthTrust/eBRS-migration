class PersonBirthDetail < ActiveRecord::Base
    self.table_name = :person_birth_details
    self.primary_key = :person_birth_details_id
    include EbrsAttribute

    belongs_to :core_person, foreign_key: "person_id"
    has_one :location, foreign_key: "location_id"
    has_one :level_of_education, foreign_key: "level_of_education_id"
    has_one :guardianship, foreign_key: ":guardianship_id"
    has_one :mode_of_delivery, foreign_key: "mode_of_delivery"
    has_one :person_type_of_birth, foreign_key: "person_type_of_birth_id"
    before_create :set_level

  def set_level
    self.level = 'HQ'
  end
  def birth_type
    PersonTypeOfBirth.find(self.type_of_birth)
  end

  def reg_type
    BirthRegistrationType.find(self.birth_registration_type_id)
  end

  def mode_of_delivery
    ModeOfDelivery.find(self.mode_of_delivery_id)
  end

  def level_of_education
    LevelOfEducation.find(self.level_of_education_id).name
  end

  def brn
    n = self.national_serial_number
    return nil if n.blank?
    gender = Person.find(self.person_id).gender == 'M' ? '2' : '1'
    n = n.to_s.rjust(10, '0')
    n.insert(n.length/2, gender)
  end

  def ben
    self.district_id_number
  end

  def fsn
    self.facility_serial_number
  end

  def birth_place
    Location.find(self.place_of_birth)
  end
end
