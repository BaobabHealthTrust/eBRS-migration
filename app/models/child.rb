require 'couchrest_model'

class Child < CouchRest::Model::Base

#  use_database "child"

  validates :national_serial_number , uniqueness: {allow_blank: true, message: "BRN cannot be duplicate"}

  validates :district_id_number , uniqueness: {allow_blank: true, message: "BEN cannot be duplicate"}

  validates :npid , uniqueness: {allow_blank: true, message: "NPID cannot be duplicate"}

  validates_with ChildValidator

  before_save NameCodes.new("first_name"), NameCodes.new("last_name"), NameCodes.new("middle_name"),
              NameCodes.new("middle_name", "mother"), NameCodes.new("middle_name", "father"),
              NameCodes.new("middle_name", "informant"), NameCodes.new("first_name", "mother"),
              NameCodes.new("last_name", "mother"), NameCodes.new("first_name", "father"),
              NameCodes.new("last_name", "father"), NameCodes.new("first_name", "informant"),
              NameCodes.new("last_name", "informant"), NameCodes.new("record_status"), NameCodes.new("request_status"),
              RecordState.new("record_status"), RecordState.new("request_status"), RecordState.new("facility_code"),
              RecordState.new("district_code"), EncryptionWrapper.new("first_name"), EncryptionWrapper.new("middle_name"),
              EncryptionWrapper.new("last_name"), EncryptionWrapper.new("first_name", "mother"),
              EncryptionWrapper.new("middle_name", "mother"), EncryptionWrapper.new("last_name", "mother"),
              EncryptionWrapper.new("id_number", "mother"), EncryptionWrapper.new("first_name", "father"),
              EncryptionWrapper.new("middle_name", "father"), EncryptionWrapper.new("last_name", "father"),
              EncryptionWrapper.new("id_number", "father"), EncryptionWrapper.new("first_name", "informant"),
              EncryptionWrapper.new("middle_name", "informant"), EncryptionWrapper.new("last_name", "informant"),
              EncryptionWrapper.new("id_number", "informant"), EncryptionWrapper.new("record_status"),
              EncryptionWrapper.new("request_status"), # EncryptionWrapper.new("national_serial_number"),
              EncryptionWrapper.new("npid")

  after_initialize EncryptionWrapper.new("first_name"), EncryptionWrapper.new("middle_name"),
                   EncryptionWrapper.new("last_name"), EncryptionWrapper.new("first_name", "mother"),
                   EncryptionWrapper.new("middle_name", "mother"), EncryptionWrapper.new("last_name", "mother"),
                   EncryptionWrapper.new("id_number", "mother"), EncryptionWrapper.new("first_name", "father"),
                   EncryptionWrapper.new("middle_name", "father"), EncryptionWrapper.new("last_name", "father"),
                   EncryptionWrapper.new("id_number", "father"), EncryptionWrapper.new("first_name", "informant"),
                   EncryptionWrapper.new("middle_name", "informant"), EncryptionWrapper.new("last_name", "informant"),
                   EncryptionWrapper.new("id_number", "informant"), EncryptionWrapper.new("record_status"),
                   EncryptionWrapper.new("request_status"), # EncryptionWrapper.new("national_serial_number"),
                   EncryptionWrapper.new("npid"), if: proc{|c| self.new_record?; !self.new_record? }


  def person_id=(value)
    self['_id']=value.to_s
  end

  def person_id
    self['_id']
  end

  #Child properties
  property :first_name, String
  property :middle_name, String
  property :last_name, String
  property :first_name_code, String
  property :last_name_code, String
  property :middle_name_code, String
  property :gender, String
  property :birthdate, String
  property :birthdate_estimated, String
  property :place_of_birth, String
  property :hospital_of_birth, String
  property :birth_address, String
  property :birth_village, String
  property :birth_ta, String
  property :birth_district, String
  property :other_birth_place_details, String
  property :birth_weight, String
  property :created_by, String
  property :date_created, String
  property :certificate_issued, String
  property :date_certificate_issued, String
  property :type_of_birth, String
  property :other_type_of_birth, String
  property :multiple_birth_id, String
  property :parents_married_to_each_other, String
  property :date_of_marriage, String
  property :gestation_at_birth, String
  property :number_of_prenatal_visits, String
  property :month_prenatal_care_started, String
  property :mode_of_delivery, String
  property :number_of_children_born_alive_inclusive, String
  property :number_of_children_born_still_alive, String
  property :level_of_education, String
  property :completed_level_of_education, String
  property :record_status, String # PRINTED | HQ OPEN | DUPLICATE | FACILITY OPEN | DC OPEN | VOIDED
  property :record_status_code, String
  property :request_status, String # ACTIVE | DC_ASK | GRANTED | REJECTED | CLOSED | APPROVED | RE-PRINT |
                                  # CAN PRINT | POTENTIAL DUPLICATE | INCOMPLETE | CAN REJECT | DISPATCHED
  property :request_status_code, String
  property :district_id_number, String
  property :district_id_number_value, Integer
  property :date_registered, String
  property :facility_code, String
  property :district_code, String
  property :national_serial_number, String
  property :court_order_attached, String
  property :npid, String
  property :parents_signed, String
  property :updated_by, String
  property :form_signed, String
  property :approved, String, :default => 'No'
  property :approved_by, String
  property :approved_at, Time
  property :printed_at, Time
  property :dispatched_at, Time
  property :acknowledgement_of_receipt_date, Time
  property :facility_serial_number, String
  property :potentialduplicate, String
  property :dispatched_to, String
  property :dispatched_date, String
  property :dispatched_by, String
  property :locked, TrueClass, :default => false
  property :voided_by, String
  property :date_voided, Time
  property :relationship, String, :default => "normal" # normal | adopted | orphaned | abandoned
  property :adoption_court_order, String, :default => "No"


  #Child's mother properties
  property :mother do
    property :id_number, String
    property :first_name, String
    property :middle_name, String
    property :last_name, String
    property :first_name_code, String
    property :last_name_code, String
    property :middle_name_code, String
    property :gender, String
    property :birthdate, String
    property :birthdate_estimated, String
    property :current_village, String
    property :current_ta, String
    property :current_district, String
    property :home_village, String
    property :home_ta, String
    property :home_district, String
    property :home_country, String
    property :citizenship, String

    #Address details for foreigner

    property :residential_country, String #Country

    property :foreigner_current_district, String #District/State
    property :foreigner_current_village, String #Village/Town
    property :foreigner_current_ta, String #Address

    property :foreigner_home_district, String #District/State
    property :foreigner_home_village, String #Village/Town
    property :foreigner_home_ta, String #Address

  end

  #Child's father properties
  property :father do
    property :id_number, String
    property :first_name, String
    property :middle_name, String
    property :last_name, String
    property :first_name_code, String
    property :last_name_code, String
    property :middle_name_code, String
    property :gender, String
    property :birthdate, String
    property :birthdate_estimated, String
    property :current_village, String
    property :current_ta, String
    property :current_district, String
    property :home_village, String
    property :home_ta, String
    property :home_district, String
    property :home_country, String
    property :citizenship, String

    #Address details for foreigner

    property :residential_country, String #Country

    property :foreigner_current_district, String #District/State
    property :foreigner_current_village, String #Village/Town
    property :foreigner_current_ta, String #Address

    property :foreigner_home_district, String #District/State
    property :foreigner_home_village, String #Village/Town
    property :foreigner_home_ta, String #Address

  end

  #Birth informant properties
  property :informant do
    property :id_number, String
    property :first_name, String
    property :middle_name, String
    property :last_name, String
    property :first_name_code, String
    property :last_name_code, String
    property :middle_name_code, String
    property :relationship_to_child, String
    property :current_village, String
    property :current_ta, String
    property :current_district, String
    property :addressline1, String
    property :addressline2, String
    property :city, String
    property :phone_number, String
  end



  #Foster parents_details

  #Foster father

  property :foster_father do
    property :id_number, String
    property :first_name, String
    property :middle_name, String
    property :last_name, String
    property :first_name_code, String
    property :last_name_code, String
    property :gender, String
    property :birthdate, String
    property :birthdate_estimated, String
    property :current_village, String
    property :current_ta, String
    property :current_district, String
    property :home_village, String
    property :home_ta, String
    property :home_district, String
    property :home_country, String
    property :citizenship, String

    #Address details for foreigner

    property :residential_country, String #Country

    property :foreigner_current_district, String #District/State
    property :foreigner_current_village, String #Village/Town
    property :foreigner_current_ta, String #Address

    property :foreigner_home_district, String #District/State
    property :foreigner_home_village, String #Village/Town
    property :foreigner_home_ta, String #Address

  end


  #Foster father

  property :foster_mother do
    property :id_number, String
    property :first_name, String
    property :middle_name, String
    property :last_name, String
    property :first_name_code, String
    property :last_name_code, String
    property :gender, String
    property :birthdate, String
    property :birthdate_estimated, String
    property :current_village, String
    property :current_ta, String
    property :current_district, String
    property :home_village, String
    property :home_ta, String
    property :home_district, String
    property :home_country, String
    property :citizenship, String

    #Address details for foreigner

    property :residential_country, String #Country

    property :foreigner_current_district, String #District/State
    property :foreigner_current_village, String #Village/Town
    property :foreigner_current_ta, String #Address

    property :foreigner_home_district, String #District/State
    property :foreigner_home_village, String #Village/Town
    property :foreigner_home_ta, String #Address

  end

  property :merged, String, :default => nil
  property :_deleted, TrueClass, :default => false
  property :_rev, String

  property :previous_duplicate_checks, [], :default => []

  timestamps!

  def place_birth_was_recorded
    (self.facility_code.to_s.blank? ? District.find(self.district_code.to_s).name + " District Office" : HealthFacility.find(self.facility_code.to_s).name) rescue nil
  end

  def self.search_for_similar_record(child)

    child_records = Child.by_child_demographics.keys([[child[:first_name].soundex,
                                                       child[:last_name].soundex,
                                                       child[:gender],
                                                       child[:birthdate],
                                                       child[:mother][:first_name].soundex,
                                                       child[:mother][:last_name].soundex]]).each rescue nil

    records = []

    child_records.each do |i_child|

      next if i_child.request_status.to_s.upcase == "VOIDED"

      next if i_child.id != child.id and (child.previous_duplicate_checks.include?( i_child.id ) or i_child.previous_duplicate_checks.include?( child.id ) )

      records << i_child

    end

    return records

  end

  def self.potential_duplicates(child)
       records = []
       child.previous_duplicate_checks.each do |child_id|
         found_child = Child.find(child_id)
         next if found_child.request_status.to_s.upcase == "VOIDED"
         records <<  Child.find(child_id)
       end
       return records
  end

  def locked?
		 return self.locked == true ? true : false
	end

	def self.lock(id)
	    Child.find(id).update_attributes(:locked => true)
	end

	def self.unlock(id)
	    Child.find(id).update_attributes(:locked => false)
	end

  design do

    view :by__id

    view :by_multiple_birth_id

    view :by_national_serial_number

    view :by_npid

    view :by_relationship

    view :by_approved_at

    view :by_approved_at_and_gender

    view :by_created_at

    view :by_updated_at

    view :by_record_status_code_and_request_status_code

  end

end
