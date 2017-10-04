require 'couchrest_model'

class Child < CouchRest::Model::Base
  #use_database "child"

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
                   
=begin
  after_save RecordState.new("record_status"), RecordState.new("request_status"), RecordState.new("facility_code"),
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
=end                 

  #Child methods
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

    view :by_last_name_code
    
    view :by_relationship

    view :by_first_name_code

    view :by_middle_name_code

    view :by_last_name_code_and_first_name_code

    view :by_last_name_code_and_first_name_code_and_middle_name_code

    view :by_national_serial_number
    
    view :by_npid

    view :by_birthdate_estimated

    view :by_hospital_of_birth

    view :by_district_code_and_place_of_birth

    view :by_place_of_birth

    view :by_birth_village

    view :by_birth_ta

    view :by_birth_district

    view :by_birth_district_and_birth_ta

    view :by_birth_district_and_birth_ta_and_birth_village

    view :by_facility_code

    view :by_district_code

    view :by_district_code_and_facility_code
    
    view :by_district_code_and_gender_and_birthdate

    view :by_date_certificate_issued
    
    view :by_gender
    
    view :by_district_code_and_created_at
    
    view :by_acknowledgement_of_receipt_date
    
    view :by_approved_at
    
    view :by_approved_at_and_gender
    
    view :by_created_at
    
    view :by_updated_at
    
    view :by_locked 
    
    view :by_facility_serial_number
  
    view :by_record_status_code_and_request_status_code_and_relationship
    
    view :by_record_status_code
    
    view :by_request_status_code

    view :by_type_of_birth
    
    view :by_date_registered,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['date_registered'] != null) {
                      if (doc['date_registered'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['date_registered'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['date_registered'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                            emit(date, 1);
                      } else {
                        emit(doc['date_registered'], 1);
                      }
                  }
                }"

    view :by_date_registered_range,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['date_registered'] != null) {
                      if (doc['date_registered'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['date_registered'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['date_registered'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                            emit((new Date(date)), 1);
                      } else {
                        emit((new Date(doc['date_registered'])), 1);
                      }
                  }
                }"

    view :by_date_certificate_issued,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null) {
                    if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                            emit(date, 1);
                    } else if(doc['date_certificate_issued'].trim().length > 10){
                        var date = doc['date_certificate_issued'].trim().substring(0, 10);
                        emit(date, 1);
                    } else {
                      emit(doc['date_certificate_issued'], 1);
                    }
                  }
                }"

    view :by_date_certificate_issued_range,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null) {
                    if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                            emit((new Date(date)), 1);
                    } else if(doc['date_certificate_issued'].trim().length > 10){
                        var date = doc['date_certificate_issued'].trim().substring(0, 10);
                        emit((new Date(date)), 1);
                    } else {
                      emit((new Date(doc['date_certificate_issued'])), 1);
                    }
                  }
                }"

    view :by_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child') {
                    emit([doc['first_name_code'], doc['last_name_code']], 1);
                  }
                }"

    view :by_district_id_number
         
    view :by_first_names,
         :map => "function(doc) {
                  if (doc['type'] == 'Child') {
                   emit(doc['first_name_code'], 1);
                   emit(doc['mother']['first_name_code'], 1);
                   emit(doc['father']['first_name_code'], 1);
                  }
                }"

    view :by_last_names,
         :map => "function(doc) {
                  if (doc['type'] == 'Child') {
		               emit(doc['last_name_code'], 1);
		               emit(doc['mother']['last_name_code'], 1);
		               emit(doc['father']['last_name_code'], 1);
                  }
                }"

    view :by_child_demographics,
         :map => "function(doc) {
                  if (doc['type'] == 'Child') {
                    emit([doc['first_name_code'], doc['last_name_code'], doc['gender'], doc['birthdate'],
                      doc['mother']['first_name_code'], doc['mother']['last_name_code']], 1);
                  }
                }"

    view :by_coded_values,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['record_status_code'] != null &&
                        doc['request_status_code'] != null && doc['district_id_number'] != null) 
                  {
                    emit([doc['request_status_code'], doc['record_status_code']], 1);
                  }
                }"

    view :by_coded_request,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['record_status_code'] != null &&
                        doc['request_status_code'] != null && doc['district_id_number'] != null ) 
                  {
                    emit([doc['request_status_code']], 1);
                  }
                }"

    view :by_coded_record,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['record_status_code'] != null &&
                        doc['request_status_code'] != null && doc['district_id_number'] != null) 
                  {
                    emit([doc['record_status_code']], 1);
                  }
                }"

    view :by_specific_birthdate,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['birthdate'] != null) {
                    var tokens = doc['birthdate'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit(date, 1);
                  }
                }"

    view :by_birthdate_range,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['birthdate'] != null) {
                    var tokens = doc['birthdate'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit((new Date(date)), 1);
                  }
                }"

    view :by_mothers_home_district,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.home_district != null) {
                    emit(doc.mother.home_district, 1);
                  }
                }"

    view :by_mothers_home_district_and_ta,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.home_district != null && doc.mother.home_ta != null) {
                    emit([ doc.mother.home_district, doc.mother.home_ta ], 1);
                  }
                }"

    view :by_mothers_home_district_ta_and_village,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.home_district != null && doc.mother.home_ta != null && doc.mother.home_village != null) {
                    emit([ doc.mother.home_district, doc.mother.home_ta, doc.mother.home_village ], 1);
                  }
                }"

    view :by_fathers_home_district,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.home_district != null) {
                    emit(doc.father.home_district, 1);
                  }
                }"

    view :by_fathers_home_district_and_ta,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.home_district != null && doc.father.home_ta != null) {
                    emit([ doc.father.home_district, doc.father.home_ta ], 1);
                  }
                }"

    view :by_fathers_home_district_ta_and_village,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.home_district != null && doc.father.home_ta != null && doc.father.home_village != null) {
                    emit([ doc.father.home_district, doc.father.home_ta, doc.father.home_village ], 1);
                  }
                }"

    view :by_mothers_nationality,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.citizenship != null) {
                    emit(doc.mother.citizenship, 1);
                  }
                }"

    view :by_fathers_nationality,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.citizenship != null) {
                    emit(doc.father.citizenship, 1);
                  }
                }"

    view :by_father_last_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.last_name_code != null) {
                    emit(doc.father.last_name_code, 1);
                  }
                }"

    view :by_father_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.first_name_code != null) {
                    emit(doc.father.first_name_code, 1);
                  }
                }"

    view :by_father_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.middle_name_code != null) {
                    emit(doc.father.middle_name_code, 1);
                  }
                }"

    view :by_father_last_name_and_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.last_name_code != null && doc.father.first_name_code != null) {
                    emit([ doc.father.last_name_code, doc.father.first_name_code ], 1);
                  }
                }"

    view :by_father_last_name_first_name_and_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.last_name_code != null && doc.father.first_name_code != null ) {
                    emit([ doc.father.last_name_code, doc.father.first_name_code, doc.father.middle_name_code ], 1);
                  }
                }"

    view :by_mother_last_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.last_name_code != null) {
                    emit(doc.mother.last_name_code, 1);
                  }
                }"

    view :by_mother_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.first_name_code != null) {
                    emit(doc.mother.first_name_code, 1);
                  }
                }"

    view :by_mother_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.middle_name_code != null) {
                    emit(doc.mother.middle_name_code, 1);
                  }
                }"

    view :by_mother_last_name_and_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.last_name_code != null && doc.mother.first_name_code != null) {
                    emit([ doc.mother.last_name_code, doc.mother.first_name_code ], 1);
                  }
                }"

    view :by_mother_last_name_first_name_and_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.last_name_code != null && doc.mother.first_name_code != null ) {
                    emit([ doc.mother.last_name_code, doc.mother.first_name_code, doc.mother.middle_name_code ], 1);
                  }
                }"

    view :by_informant_last_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.last_name_code != null) {
                    emit(doc.informant.last_name_code, 1);
                  }
                }"

    view :by_informant_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.first_name_code != null) {
                    emit(doc.informant.first_name_code, 1);
                  }
                }"

    view :by_informant_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.middle_name_code != null) {
                    emit(doc.informant.middle_name_code, 1);
                  }
                }"

    view :by_informant_last_name_and_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.last_name_code != null && doc.informant.first_name_code != null) {
                    emit([ doc.informant.last_name_code, doc.informant.first_name_code ], 1);
                  }
                }"

    view :by_informant_last_name_first_name_and_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.last_name_code != null && doc.informant.first_name_code != null ) {
                    emit([ doc.informant.last_name_code, doc.informant.first_name_code, doc.informant.middle_name_code ], 1);
                  }
                }"

    view :by_informants_current_district,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.current_district != null) {
                    emit(doc.informant.current_district, 1);
                  }
                }"

    view :by_informants_current_district_and_ta,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.current_district != null && doc.informant.current_ta != null) {
                    emit([ doc.informant.current_district, doc.informant.current_ta ], 1);
                  }
                }"

    view :by_informants_current_district_ta_and_village,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.current_district != null && doc.informant.current_ta != null && doc.informant.current_village != null) {
                    emit([ doc.informant.current_district, doc.informant.current_ta, doc.informant.current_village ], 1);
                  }
                }"

    # --------------------------- VIEW BY STATES START -------------------------------------

    view :by_last_name_code_and_record_status_code_and_request_status_code

    view :by_first_name_code_and_record_status_code_and_request_status_code

    view :by_middle_name_code_and_record_status_code_and_request_status_code

    view :by_last_name_code_and_first_name_code_and_record_status_code_and_request_status_code

    view :by_last_name_code_and_first_name_code_and_middle_name_code_and_record_status_code_and_request_status_code

    view :by_national_serial_number_and_record_status_code_and_request_status_code

    view :by_npid_and_record_status_code_and_request_status_code

    view :by_hospital_of_birth_and_record_status_code_and_request_status_code

    view :by_place_of_birth_and_record_status_code_and_request_status_code

    view :by_birth_village_and_record_status_code_and_request_status_code

    view :by_birth_ta_and_record_status_code_and_request_status_code

    view :by_birth_district_and_record_status_code_and_request_status_code

    view :by_birth_district_and_birth_ta_and_record_status_code_and_request_status_code

    view :by_birth_district_and_birth_ta_and_birth_village_and_record_status_code_and_request_status_code

    view :by_facility_code_and_record_status_code_and_request_status_code

    view :by_district_code_and_record_status_code_and_request_status_code

    view :by_district_code_and_date_registered_and_record_status_code_and_request_status_code

    view :by_district_code_and_facility_code_and_record_status_code_and_request_status_code

    view :by_date_certificate_issued_and_record_status_code_and_request_status_code

    view :by_date_registered_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['date_registered'] != null) {
                      if (doc['date_registered'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['date_registered'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['date_registered'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                            emit([date, doc.record_status_code, doc.request_status_code], 1);
                      } else {
                        emit([doc['date_registered'], doc.record_status_code, doc.request_status_code], 1);
                      }
                  }
                }"

    view :by_date_registered_range_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['date_registered'] != null) {
                      if (doc['date_registered'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['date_registered'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['date_registered'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                            emit([(new Date(date)), doc.record_status_code, doc.request_status_code], 1);
                      } else {
                        emit([(new Date(doc['date_registered'])), doc.record_status_code, doc.request_status_code], 1);
                      }
                  }
                }"

    view :by_date_certificate_issued_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null) {
                    if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                            emit([date, doc.record_status_code, doc.request_status_code], 1);
                    } else if(doc['date_certificate_issued'].trim().length > 10){
                        var date = doc['date_certificate_issued'].trim().substring(0, 10);
                        emit([date, doc.record_status_code, doc.request_status_code], 1);
                    } else {
                      emit([doc['date_certificate_issued'], doc.record_status_code, doc.request_status_code], 1);
                    }
                  }
                }"

    view :by_date_certificate_issued_range_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null) {
                    if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                            emit([(new Date(date)), doc.record_status_code, doc.request_status_code], 1);
                    } else if(doc['date_certificate_issued'].trim().length > 10){
                        var date = doc['date_certificate_issued'].trim().substring(0, 10);
                        emit([(new Date(date)), doc.record_status_code, doc.request_status_code], 1);
                    } else {
                      emit([(new Date(doc['date_certificate_issued'])), doc.record_status_code, doc.request_status_code], 1);
                    }
                  }
                }"

    view :by_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child') {
                    emit([doc['first_name_code'], doc['last_name_code'], doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_district_id_number_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child') {
                    emit([doc['district_id_number'], doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_child_demographics_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child') {
                    emit([doc['first_name_code'], doc['last_name_code'], doc['gender'], doc['birthdate'],
                      doc['mother']['first_name_code'], doc['mother']['last_name_code'], doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_specific_birthdate_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['birthdate'] != null) {
                    var tokens = doc['birthdate'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit([date, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_birthdate_range_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['birthdate'] != null) {
                    var tokens = doc['birthdate'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit([(new Date(date)), doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_mothers_home_district_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.home_district != null) {
                    emit([doc.mother.home_district, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_mothers_home_district_and_ta_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.home_district != null && doc.mother.home_ta != null) {
                    emit([ doc.mother.home_district, doc.mother.home_ta, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_mothers_home_district_ta_and_village_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.home_district != null && doc.mother.home_ta != null && doc.mother.home_village != null) {
                    emit([ doc.mother.home_district, doc.mother.home_ta, doc.mother.home_village, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_fathers_home_district_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.home_district != null) {
                    emit([doc.father.home_district, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_fathers_home_district_and_ta_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.home_district != null && doc.father.home_ta != null) {
                    emit([ doc.father.home_district, doc.father.home_ta, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_fathers_home_district_ta_and_village_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.home_district != null && doc.father.home_ta != null && doc.father.home_village != null) {
                    emit([ doc.father.home_district, doc.father.home_ta, doc.father.home_village, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_mothers_nationality_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.citizenship != null) {
                    emit([doc.mother.citizenship, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_fathers_nationality_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.citizenship != null) {
                    emit([doc.father.citizenship, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_father_last_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.last_name_code != null) {
                    emit([doc.father.last_name_code, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_father_first_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.first_name_code != null) {
                    emit([doc.father.first_name_code, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_father_middle_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.middle_name_code != null) {
                    emit([doc.father.middle_name_code, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_father_last_name_and_first_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.last_name_code != null && doc.father.first_name_code != null) {
                    emit([ doc.father.last_name_code, doc.father.first_name_code, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_father_last_name_first_name_and_middle_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.father.last_name_code != null && doc.father.first_name_code != null ) {
                    emit([ doc.father.last_name_code, doc.father.first_name_code, doc.father.middle_name_code, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_mother_last_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.last_name_code != null) {
                    emit([doc.mother.last_name_code, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_mother_first_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.first_name_code != null) {
                    emit([doc.mother.first_name_code, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_mother_middle_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.middle_name_code != null) {
                    emit([doc.mother.middle_name_code, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_mother_last_name_and_first_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.last_name_code != null && doc.mother.first_name_code != null) {
                    emit([ doc.mother.last_name_code, doc.mother.first_name_code, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_mother_last_name_first_name_and_middle_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.mother.last_name_code != null && doc.mother.first_name_code != null ) {
                    emit([ doc.mother.last_name_code, doc.mother.first_name_code, doc.mother.middle_name_code, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_informant_last_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.last_name_code != null) {
                    emit([doc.informant.last_name_code, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_informant_first_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.first_name_code != null) {
                    emit([doc.informant.first_name_code, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_informant_middle_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.middle_name_code != null) {
                    emit([doc.informant.middle_name_code, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_informant_last_name_and_first_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.last_name_code != null && doc.informant.first_name_code != null) {
                    emit([ doc.informant.last_name_code, doc.informant.first_name_code, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_informant_last_name_first_name_and_middle_name_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.last_name_code != null && doc.informant.first_name_code != null ) {
                    emit([ doc.informant.last_name_code, doc.informant.first_name_code, doc.informant.middle_name_code, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_informants_current_district_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.current_district != null) {
                    emit([doc.informant.current_district, doc.record_status_code, doc.request_status_code], 1);
                  }
                }"

    view :by_informants_current_district_and_ta_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.current_district != null && doc.informant.current_ta != null) {
                    emit([ doc.informant.current_district, doc.informant.current_ta, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_informants_current_district_ta_and_village_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc.informant.current_district != null && doc.informant.current_ta != null && doc.informant.current_village != null) {
                    emit([ doc.informant.current_district, doc.informant.current_ta, doc.informant.current_village, doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_coded_record_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['record_status_code'] != null &&
                        doc['request_status_code'] != null && doc['district_id_number'] != null &&
                        doc['voided'] != true && doc['voided'] != 'true') {
                    emit([doc['record_status_code'], doc.record_status_code, doc.request_status_code ], 1);
                  }
                }"

    view :by_updated_at_and_district_code_and_record_status_code_and_request_status_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['updated_at'] != null) {
                    if (doc['updated_at'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['updated_at'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['updated_at'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                            emit([date, doc.district_code, doc.record_status_code, doc.request_status_code ], 1);
                    } else if(doc['updated_at'].trim().length > 10){
                        var date = doc['updated_at'].trim().substring(0, 10);
                        emit([date, doc.district_code, doc.record_status_code, doc.request_status_code ], 1);
                    } else {
                      emit([doc['updated_at'], doc.district_code, doc.record_status_code, doc.request_status_code ], 1);
                    }
                  }
                }"

    view :by_updated_at_timestamp_and_district_code_with_codes,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['updated_at'] != null) {
                    if (doc['updated_at'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['updated_at'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['updated_at'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = (new Date(tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0])).getTime();
                            emit([ date, doc.district_code, doc.record_status_code, doc.request_status_code ], 1);
                    } else if(doc['updated_at'].trim().length > 10){
                        var date = (new Date(doc['updated_at'].trim().substring(0, 10))).getTime();
                        emit([ date, doc.district_code, doc.record_status_code, doc.request_status_code ], 1);
                    } else {
                      var date = (new Date(doc['updated_at'])).getTime();
                      emit([ date, doc.district_code, doc.record_status_code, doc.request_status_code ], 1);
                    }
                  }
                }"

    view :by_updated_at_timestamp_and_district_code_without_codes,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['updated_at'] != null) {
                    if (doc['updated_at'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['updated_at'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['updated_at'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = (new Date(tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0])).getTime();
                            emit([ date, doc.district_code ], 1);
                    } else if(doc['updated_at'].trim().length > 10){
                        var date = (new Date(doc['updated_at'].trim().substring(0, 10))).getTime();
                        emit([ date, doc.district_code ], 1);
                    } else {
                      var date = (new Date(doc['updated_at'])).getTime();
                      emit([ date, doc.district_code ], 1);
                    }
                  }
                }"

    view :by_reporting_date_and_district_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['acknowledgement_of_receipt_date'] != null && doc['district_code'] != null && doc['approved'] == 'Yes') {
                    if (doc['acknowledgement_of_receipt_date'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['acknowledgement_of_receipt_date'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['acknowledgement_of_receipt_date'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = (new Date(tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0])).getTime();
                            emit([ date, doc.district_code ], 1);
                    } else if(doc['acknowledgement_of_receipt_date'].trim().length > 10){
                        var date = (new Date(doc['acknowledgement_of_receipt_date'].trim().substring(0, 10))).getTime();
                        emit([ date, doc.district_code ], 1);
                    } else {
                      var date = (new Date(doc['acknowledgement_of_receipt_date'])).getTime();
                      emit([ date, doc.district_code ], 1);
                    }
                  }
                }"
                            
    view :by_acknowledgement_of_receipt_date_and_district_code
    
    view :by_reporting_date_and_codes,
         :map => "function(doc) {
                  if (doc['type'] == 'Child' && doc['acknowledgement_of_receipt_date'] != null && doc['district_code'] != null) {
                    if (doc['acknowledgement_of_receipt_date'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['acknowledgement_of_receipt_date'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['acknowledgement_of_receipt_date'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = (new Date(tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0])).getTime();
                            emit([ date, doc.record_status_code, doc.request_status_code ], 1);
                    } else if(doc['acknowledgement_of_receipt_date'].trim().length > 10){
                        var date = (new Date(doc['acknowledgement_of_receipt_date'].trim().substring(0, 10))).getTime();
                        emit([ date, doc.record_status_code, doc.request_status_code ], 1);
                    } else {
                      var date = (new Date(doc['acknowledgement_of_receipt_date'])).getTime();
                      emit([ date, doc.record_status_code, doc.request_status_code ], 1);
                    }
                  }
                }"

    view :by_record_status_code_and_request_status_code

    view :by_record_status_code_and_request_status_code_and_acknowledgement_of_receipt_date

    
    
    # ----------------------------- END VIEW BY STATES -----------------------------------------------------------------
    
    #BALAKA
  view :by_blk_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'BLK' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
 #BLANTYRE
	view :by_bt_date_certificate_issued_range,
		   :map => "function(doc) {
							 	if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'BT' && 
							 		 doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
														      if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #CHIKWAWA
  view :by_ck_date_certificate_issued_range,
		   :map => "function(doc) {
		 					if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'CK' &&
		 						  doc['record_status_code'] == 'P453' && (doc		['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
				                if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #CHITIPA
  view :by_cp_date_certificate_issued_range,
		   :map => "function(doc) {
	 						if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'CP' &&
	 							  doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #CHIRADZULU
	view :by_cz_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'CZ' &&
	 							    doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #DOWA
  view :by_da_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'DA' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #DEDZA
  view :by_dz_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'DZ' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #KARONGA
	view :by_ka_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'KA' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

 
  #NKHOTAKOTA
  view :by_kk_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'KK' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"
		              
  #NKHOTAKOTA
  view :by_ku_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'KU' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #LIKOMA
  view :by_la_date_certificate_issued_range,
		   :map => "function(doc) {
							 if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'LA' && 
							 		 doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #LILONGWE
	view :by_ll_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'LL' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #MNCHINJI
  view :by_mc_date_certificate_issued_range,
		   :map => "function(doc) {
								if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'MC' && 
										doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #MACHINGA
  view :by_mh_date_certificate_issued_range,
		   :map => "function(doc) {
								 if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'MH' && 
								 		 doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #MANGOCHI
	view :by_mhg_date_certificate_issued_range,
		   :map => "function(doc) {
	 						  if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'MHG' && 
	 						      doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #MULANJE
  view :by_mj_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'MJ' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #MWANZA
  view :by_mn_date_certificate_issued_range,
		   :map => "function(doc) {
	 						  if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'MN' && 
	 						  		doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

 
  #MZIMBA
	view :by_mz_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'MZ' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #NKATABAY
  view :by_nb_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'NB' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

 
  #NSANJE
  view :by_ne_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'NE' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #NNENO
	view :by_nn_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'NN' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #NSANJE
  view :by_ns_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'NS' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #NTCHEU
  view :by_nu_date_certificate_issued_range,
		       :map => "function(doc) {
	 									if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'NU' && 
	 											doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #PHALOMBE
	view :by_pe_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'PE' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #RUMPHI
  view :by_ru_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'RU' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #SALIMA
  view :by_sa_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'SA' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #THYOLO
	view :by_to_date_certificate_issued_range,
		   :map => "function(doc) {
	 							if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'TO' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"

  
  #ZOMBA
  view :by_za_date_certificate_issued_range,
		   :map => "function(doc) {
							  if (doc['type'] == 'Child' && doc['date_certificate_issued'] != null && doc['district_code'] == 'ZA' && 
	 									doc['record_status_code'] == 'P453' && (doc['request_status_code'] == 'K463' || doc['request_status_code'] == 'D619')) {
		                  if (doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
		                      doc['date_certificate_issued'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
		                          var tokens = doc['date_certificate_issued'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
		                          var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
		                            'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
		                          var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
		                          emit((new Date(date)), 1);
		                  } else if(doc['date_certificate_issued'].trim().length > 10){
		                      var date = doc['date_certificate_issued'].trim().substring(0, 10);
		                      emit((new Date(date)), 1);
		                  } else {
		                    emit((new Date(doc['date_certificate_issued'])), 1);
		                  }
		                }
		              }"
		              
		view :by_place_of_birth_and_gender,
           :map => "function(doc){
               if(doc['type'] == 'Child' && doc['created_at'] != null){
                  emit(doc.created_at, { birth_place : doc.place_of_birth, sex : doc.gender});
                }
              }"    
              
     
     
 #=====================================================================================#
    
=begin	   
   view :by_hq_open_and_active,
		   :map => "function(doc) {
							  if (doc['type'] == 'Child'  && doc['record_status_code'] == 'H215' && doc['request_status_code'] == 'E231') {
							        emit([doc['created_at'], doc.record_status_code, doc.request_status_code ], 1);
		                  }
		              }"
 
	 view :by_hq_open_and_can_print.(keys).each.count
	 view :by_hq_open_and_approved.(keys).each.count
	 view :by_hq_open_and_request_status.(keys).each.count
	 view :by_hq_open_and_potential_duplicate.(keys).each.count
	 view :by_hq_open_and_incomplete.(keys).each.count
       
    
	  view :by_printed_and_closed.(keys).each.count
	  view :by_printed_and_dispatched.(keys).each.count
	  view :by_voided_and_closed.(keys).each.count
		    
    
    emit([doc['updated_at'], doc.district_code, doc.record_status_code, doc.request_status_code ], 1);
=end
    #=====================================================================================#         
    
    filter :approved_sync, "function(doc,req) {return req.query.approved == doc.approved}"

    filter :facility_sync, "function(doc,req) {return req.query.facility_code == doc.facility_code}"

    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"

  end
  
end
