require "csv"

FILE = Rails.root.join("db","people_all_Aug_2015_Sept_2017.csv")
LOG = Logger.new(Rails.root.join("log","people_all_Aug_2015_Sept_2017.log"))
puts "Quering data" 

def late_registration?(person)	

  days_gone = ((person.acknowledgement_of_receipt_date.to_date rescue Date.today) - (person.birthdate.to_date rescue nil)).to_i rescue 0
  
  if days_gone > 42
    return true
  else
    return false
  end	
  
end

def checknames?(name)
	 
	 if name.length > 20
	   return true
	 end 
	 
	 outcome = false

	 names = name.squish().split(",")
	 if names.length > 1
	   outcome = true
	 elsif names.length == 1
       outcome = false
	 end
	 return outcome
end

def write_file(people)
total_count = people.count
CSV.open( FILE, 'a+' ) do |exporter|
						
  people.each_with_index do |person, index|
    
			if person.district_id_number.blank?
        LOG.debug "#{person.id} : Blank BEN"
        puts "#{person.id} : Blank BEN"
				#next
			elsif person.district_id_number.present? && person.district_id_number.length > 16
        LOG.debug "#{person.id} : Long BEN"
        puts "#{person.id} : Long BEN"
				#next
			elsif person.national_serial_number.present? && person.national_serial_number.length > 11
        LOG.debug "#{person.id} : Long BRN"
        puts "#{person.id} : Long BRN"
				#next								
			end

    begin 
        exporter << [
            (person.relationship.squish rescue nil),
            (person.last_name.squish().titleize rescue ""),
            (person.middle_name.squish().titleize rescue ""),
            (person.first_name.squish().titleize rescue ""),
            (Date.parse(person.birthdate).strftime("%Y-%m-%d") rescue person.birthdate),
             person.gender,
             person.place_of_birth,
             person.birth_district,
             person.birth_ta,
             person.birth_village, 
             person.hospital_of_birth,
             person.birth_address,
             person.other_birth_place_details,
             person.birth_weight,
             person.type_of_birth,
             person.other_type_of_birth,
             (person.multiple_birth_id rescue ""),
             person.parents_married_to_each_other,
             (Date.parse(person.date_of_marriage).strftime("%Y-%m-%d") rescue ""),
             person.court_order_attached,
             person.parents_signed,
             person.created_at.strftime("%Y-%m-%d"),
             "XXXXX",
             "XXXXX",
             person.national_serial_number,
             person.district_id_number,
             person.gestation_at_birth,
             person.number_of_prenatal_visits,
             person.month_prenatal_care_started,
             person.mode_of_delivery,
             person.number_of_children_born_alive_inclusive,
             person.number_of_children_born_still_alive,
             (person.mother.last_name.squish().titleize rescue ""),
             (person.mother.first_name.squish().titleize rescue ""),
             (person.mother.middle_name.squish().titleize rescue ""),
             (Date.parse(person.mother.birthdate).strftime("%Y-%m-%d") rescue ""),
             (person.birthdate_estimated rescue ""),
             person.mother.citizenship,
             (person.mother.residential_country rescue ""),
             person.mother.current_district,
             person.mother.current_ta,
             person.mother.current_village,
             person.mother.home_country,
             person.mother.home_district,
             person.mother.home_ta,
             person.mother.home_village,
             (person.mother.foreigner_current_district rescue ""),
             (person.mother.foreigner_current_village rescue ""),
             (person.mother.foreigner_current_ta rescue ""),
             (person.mother.foreigner_home_district rescue ""),
             (person.mother.foreigner_home_village rescue ""),
             (person.mother.foreigner_home_ta rescue ""),
             person.level_of_education,
             (person.father.last_name.squish().titleize rescue ""),
             (person.father.first_name.squish() rescue "").titleize,
             (person.father.middle_name.squish().titleize rescue ""),
             (Date.parse(person.father.birthdate).strftime("%Y-%m-%d") rescue ""),
             (person.father.birthdate_estimated rescue ""), 
             person.father.citizenship,
             (person.father.residential_country rescue ""),
             person.father.current_district,
             person.father.current_ta,
             person.father.current_village,
             person.father.home_district,
             person.father.home_country,
             person.father.home_ta,
             person.father.home_village,
             (person.father.foreigner_current_district rescue ""),
             (person.father.foreigner_current_village rescue ""),
             (person.father.foreigner_current_ta rescue ""),
             (person.father.foreigner_home_district rescue ""),
             (person.father.foreigner_home_village rescue ""),
             (person.father.foreigner_home_ta rescue ""),            
             (person.informant.last_name.squish().titleize rescue ""),
             (person.informant.first_name.squish().titleize rescue ""),
             (person.informant.middle_name.squish().titleize rescue ""),
             person.informant.relationship_to_child,
             person.informant.current_district,
             person.informant.current_ta, 
             person.informant.current_village,
             person.informant.addressline1, 
             person.informant.addressline2,
             person.informant.phone_number,
             (person.foster_mother.id_number rescue ""),
             (person.foster_mother.first_name  rescue ""),
             (person.foster_mother.middle_name  rescue ""),
             (person.foster_mother.last_name  rescue ""), 
             (person.foster_mother.birthdate  rescue ""),
             (person.foster_mother.birthdate_estimated  rescue ""),
             (person.foster_mother.current_village  rescue ""),
             (person.foster_mother.current_ta  rescue ""),
             (person.foster_mother.current_district  rescue ""),
             (person.foster_mother.home_village  rescue ""),
             (person.foster_mother.home_ta  rescue ""),
             (person.foster_mother.home_district  rescue ""),
             (person.foster_mother.home_country  rescue ""),
             (person.foster_mother.citizenship  rescue ""), 
             (person.foster_mother.residential_country  rescue ""),
             (person.foster_mother.foreigner_current_district  rescue ""),
             (person.foster_mother.foreigner_current_village  rescue ""),
             (person.foster_mother.foreigner_current_ta  rescue ""),
             (person.foster_mother.foreigner_home_district  rescue ""),
             (person.foster_mother.oreigner_home_village  rescue ""),
             (person.foster_mother.foreigner_home_ta  rescue ""),
             (person.foster_father.id_number  rescue ""),
             (person.foster_father.first_name  rescue ""),
             (person.foster_father.middle_name  rescue ""),
             (person.foster_father.last_name  rescue ""),
             (person.foster_father.birthdate  rescue ""),
             (person.foster_father.birthdate_estimated  rescue ""),
             (person.foster_father.current_village  rescue ""),
             (person.foster_father.current_ta  rescue ""),
             (person.foster_father.current_district  rescue ""),
             (person.foster_father.home_village  rescue ""),
             (person.foster_father.home_ta  rescue ""),
             (person.foster_father.home_district  rescue ""),
             (person.foster_father.home_country  rescue ""),
             (person.foster_father.citizenship  rescue ""),
             (person.foster_father.residential_country  rescue ""),
             (person.foster_father.foreigner_current_district  rescue ""),
             (person.foster_father.foreigner_current_village  rescue ""),
             (person.foster_father.foreigner_current_ta  rescue ""),
             (person.foster_father.foreigner_home_district  rescue ""),
             (person.foster_father.foreigner_home_village  rescue ""),
             (person.foster_father.foreigner_home_ta  rescue ""),
             person.form_signed,
             (person.acknowledgement_of_receipt_date.strftime("%Y-%m-%d") rescue ""),
             person.record_status,
             person.rev,
             person.id,
             person.request_status,
             (person.approved_at.strftime("%Y-%m-%d") rescue ""),
             person.district_code,
             (person.facility_code rescue ''),
            (person.date_certificate_issued.to_date.strftime("%Y-%m-%d") rescue ""),
            ((person.dispatched_date.to_date.strftime("%Y-%m-%d") rescue person.dispatched_at.strftime("%Y-%m-%d")) rescue "")].to_csv

	 puts "ID: #{person.id} Exported #{index + 1} of #{total_count}"

	 
	 rescue => e 
    LOG.debug "#{person.id} #{e.message} : #{e.backtrace.inspect}"
	    puts "ID: #{person.id} Exported #{index + 1} of #{total_count}"
	 end							 
  end
end 
end


def write_header
  CSV.open( FILE, 'w' ) do |exporter|
    exporter << [
             "relationship",
             "last_name",
             "first_name",
             "middle_name",
             "birthdate",
             "gender",
             "place_of_birth",
             "birth_district",
             "birth_ta",
             "birth_village",
             "hospital_of_birth",
             "birth_address",
             "other_birth_place_details",
             "birth_weight",
             "type_of_birth",
             "other_type_of_birth",
             "multiple_birth_id",
             "parents_married_to_each_other",
             "date_of_marriage",
             "court_order_attached",
             "parents_signed",
             "created_at",
             "created_by",
             "updated_at",
             "national_serial_number",
             "district_id_number",
             "gestation_at_birth",
             "number_of_prenatal_visits",
             "month_prenatal_care_started",
             "number_of_children_born_alive_inclusive",
             "number_of_children_born_still_alive",
             "mode_of_delivery",
             "mother_last_name" ,
             "mother_first_name",
             "mother_middle_name",
             "mother_birthdate",
             "mother_birthdate_estimated",
             "mother_citizenship",
             "mother_residential_country",
             "mother_current_district",
             "mother_current_ta",
             "mother_current_village",
             "mother_home_country",
             "mother_home_district",
             "mother_home_ta",
             "mother_home_village",
             "mother_foreigner_current_district",
             "mother_foreigner_current_village",
             "mother_foreigner_current_ta",
             "mother_foreigner_home_district",
             "mother_foreigner_home_village",
             "mother_foreigner_home_ta",
             "level_of_education",
             "father_last_name",
             "father_first_name",
             "father_middle_name",
             "father_birthdate",
             "father_birthdate_estimated", 
             "father_citizenship",
             "father_residential_country",
             "father_current_district",
             "father_current_ta",
             "father_current_village",
             "father_home_country",
             "father_home_district",
             "father_home_ta",
             "father_home_village", 
             "father_foreigner_current_district",
             "father_foreigner_current_village",
             "father_foreigner_current_ta",
             "father_foreigner_home_district",
             "father_foreigner_home_village",
             "mother_foreigner_home_ta",           
             "informant_last_name",
             "informant_first_name",
             "informant_middle_name",
             "informant_relationship_to_child",
             "informant_current_district",
             "informant_current_ta", 
             "informant_current_village",
             "informant_addressline", 
             "informant_addressline2", 
             "informant_phone_number",
             "foster_mother_id_number",
             "foster_mother_first_name",
             "foster_mother_middle_name",
             "foster_mother_last_name", 
             "foster_mother_birthdate",
             "foster_mother_birthdate_estimated",
             "foster_mother_current_village",
             "foster_mother_current_ta",
             "foster_mother_current_district",
             "foster_mother_home_village",
             "foster_mother_home_ta",
             "foster_mother_home_district",
             "foster_mother_home_country",
             "foster_mother_citizenship", 
             "foster_mother_residential_country",
             "foster_mother_foreigner_current_district",
             "foster_mother_foreigner_current_village",
             "foster_mother_foreigner_current_ta",
             "foster_mother_foreigner_home_district",
             "foster_mother_foreigner_home_village",
             "foster_mother_foreigner_home_ta",
             "foster_father_id_number",
             "foster_father_first_name",
             "foster_father_middle_name",
             "foster_father_last_name",
             "foster_father_birthdate",
             "foster_father_birthdate_estimated",
             "foster_father_current_village",
             "foster_father_current_ta",
             "foster_father_current_district",
             "foster_father_home_village",
             "foster_father_home_ta",
             "foster_father_home_district",
             "foster_father_home_country",
             "foster_father_citizenship",
             "foster_father_residential_country",
             "foster_father_foreigner_current_district",
             "foster_father_foreigner_current_village",
             "foster_father_foreigner_current_ta",
             "foster_father_foreigner_home_district",
             "foster_father_foreigner_home_village",
             "foster_father_foreigner_home_ta",
             "form_signed",
             "acknowledgement_of_receipt_date",
             "record_status",
             "_rev",
             "_id",
             "request_status",
             "approved_at",
             "district_code",
             "facility_code",
             "date_certificate_issued",
             "date_dispatched"
          ]
  end
end

def write_header_back
  CSV.open( FILE, 'w' ) do |exporter|
    exporter << ["first_name","middle_name","last_name","gender","birthdate",
    "place_of_birth","hospital_of_birth","birth_address",
    "birth_village","birth_ta","birth_district","other_birth_place_details",
    "birth_weight","type_of_birth","other_type_of_birth","parents_married_to_each_other",
    "date_of_marriage","gestation_at_birth","number_of_prenatal_visits","month_prenatal_care_started",
    "mode_of_delivery","number_of_children_born_alive_inclusive","number_of_children_born_still_alive",
    "level_of_education","birth_entry_number","date_registered","facility_registered","district_registered",
    "registration_number","court_order_attached","parents_signed","form_signed","acknowledgement_of_receipt_date",
    "mother_first_name","mother_middle_name","mother_last_name","mother_birthdate","mother_current_village",
    "mother_current_ta","mother_current_district","mother_home_village","mother_home_ta","mother_home_district",
    "mother_home_country","mother_citizenship","father_first_name","father_middle_name","father_last_name",
    "father_birthdate","father_current_village","father_current_ta","father_current_district","father_home_village",
    "father_home_ta","father_home_district","father_home_country","father_citizenship","informant_first_name",
    "informant_middle_name","informant_last_name","informant_relationship_to_child","informant_current_village",
    "informant_current_ta","informant_current_district","informant_addressline1","informant_addressline2",
    "informant_phone_number","late_registration","record_status","request_status","date_created", "date_printed", "date_dispatched"]
  end
end
START = Time.now
 def init
  counter = 0
  total_count = Child.count
  pages = total_count / 100
  write_header
  
  (0..pages).each do |page|
    counter += 1
    children = Child.by__id.page(page).per(100).each
    write_file(children)
    puts "Started at : #{START.strftime("%H:%M:%S")} ###### Exported #{counter*100} of #{total_count} #####"
  end 

 end

init
end_time = Time.now
puts "Started at #{START.strftime("%Y-%m-%d %H:%M:%S")} and finished at #{end_time.strftime("%Y-%m-%d %H:%M:%S")}"
