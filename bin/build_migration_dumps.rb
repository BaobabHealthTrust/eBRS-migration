@dump_files = "#{Rails.root}/app/assets/data/migration_dumps/"
@core_person_counter               = 0
@mother_core_person_counter        = 0
@father_core_person_counter        = 0
@informant_core_person_counter     = 0
@foster_mother_core_person_counter = 0
@foster_father_core_person_counter = 0

@document_tracker = {}
@used_ids         = []

def prepare_dump_files

	core_person ="INSERT INTO core_person (person_id,person_type_id,created_at,updated_at) VALUES "
	person = "INSERT INTO person (person_id, gender, created_at, updated_at) VALUES "
	person_name = "INSERT INTO person_name(person_id, first_name, middle_name, last_name, created_at, updated_at) VALUES "
	person_identifier = "INSERT INTO person_identifier () VALUES "
	person_addresses = "INSERT INTO person_addresses () VALUES ()"
	person_relationship = "INSERT INTO person_relationship (person_a, person_b, person_relationship_type_id, created_at, updated_at) VALUES "
	person_attribute = "INSERT INTO person_attribute () VALUES "
	person_birth_details = "INSERT INTO person_birth_details () VALUES "
	potential_duplicate = "INSERT INTO potential_duplicate () VALUES "
	identifier_allocation_queue = "INSERT INTO identifier_allocation_queue () VALUES "
	person_record_status = "INSERT INTO person_record_status () VALUES "

	`cd #{@dump_files} && [ -f core_person.sql ] && rm core_person.sql && [ -f person_name.sql ] && rm person_name.sql && [ -f person_addresses.sql ] && rm person_addresses.sql && [ -f person_relationship.sql ] && rm person_relationship.sql && [ -f person_attribute.sql ] && rm person_attribute.sql && [ -f identifier_allocation_queue.sql ] && rm identifier_allocation_queue.sql && [ -f person_birth_details.sql ] && rm person_birth_details.sql && [ -f potential_duplicate.sql ] && rm potential_duplicate.sql && [ -f person_record_status.sql ] && rm person_record_status.sql && [ -f person.sql ] && rm person.sql && [ -f person_identifier.sql ] && rm person_identifier.sql`
    `cd #{@dump_files} && touch core_person.sql person.sql person_name.sql person_addresses.sql person_attribute.sql person_identifier.sql person_relationship.sql person_birth_details.sql potential_duplicate.sql identifier_allocation_queue.sql potential_duplicate.sql person_record_status.sql`
    `echo -n '#{core_person}' >> #{@dump_files}core_person.sql`
    `echo -n '#{person}' >> #{@dump_files}person.sql`
    `echo -n '#{person_identifier}' >> #{@dump_files}person_identifier.sql`
    `echo -n '#{person_name}' >> #{@dump_files}person_name.sql`
    `echo -n '#{person_addresses}' >> #{@dump_files}person_addresses.sql`
    `echo -n '#{person_relationship}' >> #{@dump_files}person_relationship.sql`
    `echo -n '#{person_attribute}' >> #{@dump_files}person_attribute.sql`
    `echo -n '#{person_birth_details}' >> #{@dump_files}person_birth_details.sql`
    `echo -n '#{person_record_status}' >> #{@dump_files}person_record_status.sql`
    `echo -n '#{potential_duplicate}' >> #{@dump_files}potential_duplicate.sql`
    `echo -n '#{identifier_allocation_queue}' >> #{@dump_files}identifier_allocation_queue.sql`
end

def build_client_record(current_pge, pge_size)

  data ={}

  records = Child.all.page(current_pge).per(pge_size)
 

  (records || []).each do |r|
     
	  data = { person: {duplicate: "", is_exact_duplicate: "",
					   relationship: r[:relationship],
					   last_name: r[:last_name],
					   first_name: r[:first_name],
					   middle_name: r[:middle_name],
					   birthdate: r[:birthdate],
					   birth_district: r[:birth_district],
					   gender: r[:gender],
					   place_of_birth: r[:place_of_birth],
					   hospital_of_birth: r[:hospital_of_birth],
					   birth_weight: r[:birth_weight],
					   type_of_birth: r[:type_of_birth],
					   parents_married_to_each_other: r[:parents_married_to_each_other],
					   date_of_marriage: r[:date_of_marriage],
					   court_order_attached: r[:court_order_attached],
					   created_at: r[:created_at],
					   created_by: r[:created_by],
					   updated_at: r[:updated_at],
					   parents_signed: "",
					   national_serial_number: r[:national_serial_number],
					   district_id_number: r[:district_id_number],
					   mother:{
					     last_name: r[:mother][:last_name],
					     first_name: r[:mother][:first_name],
					     middle_name: r[:mother][:middle_name],
					     birthdate: r[:mother][:birthdate],
					     birthdate_estimated: r[:mother][:birthdate_estimated],
					     citizenship: r[:mother][:citizenship],
					     residential_country: r[:mother][:residential_country],
					     current_district: r[:mother][:current_district],
					     current_ta: r[:mother][:current_ta],
					     current_village: r[:mother][:current_village],
					     home_district: r[:mother][:home_district],
					     home_ta: r[:mother][:home_ta],
					     home_village: r[:mother][:home_village]
					  },
					   mode_of_delivery: r[:mode_of_delivery],
					   level_of_education: r[:level_of_education],
					   father: {
					     birthdate_estimated: r[:father][:birthdate_estimated],
					     residential_country: r[:father][:residential_country]
					  },
					   informant: {
					     last_name: r[:informant][:last_name],
					     first_name: r[:informant][:first_name],
					     middle_name: r[:informant][:middle_name],
					     relationship_to_person: r[:informant][:relationship_to_child],
					     current_district: r[:informant][:current_district],
					     current_ta: r[:informant][:current_ta],
					     current_village: r[:informant][:current_village],
					     addressline1: r[:informant][:addressline1],
					     addressline2: r[:informant][:addressline2],
					     phone_number: r[:informant][:phone_number]
					  },
					   form_signed: r[:form_signed],
					   acknowledgement_of_receipt_date: r[:acknowledgement_of_receipt_date]
					  },
					   home_address_same_as_physical: "Yes",
					   gestation_at_birth: r[:gestation_at_birth],
					   number_of_prenatal_visits: r[:number_of_prenatal_visits],
					   month_prenatal_care_started: r[:month_prenatal_care_started],
					   number_of_children_born_alive_inclusive: r[:number_of_children_born_alive_inclusive],
					   number_of_children_born_still_alive: r[:number_of_children_born_still_alive],
					   same_address_with_mother: "",
					   informant_same_as_mother: (r[:informant][:relationship_to_child] == "Mother" ? "Yes" : "No"),
					   registration_type: r[:relationship],
					   record_status: r[:record_status],
					   _rev: r[:_rev],
					   _id: r[:_id],
					   request_status: r[:request_status],
					   biological_parents: "",
					   foster_parents: "",
					   parents_details_available: "",
					   copy_mother_name: "No",
					   controller: "person",
					   action: "create"
					  }
            
            #@core_person_counter += 1
            initiate_sql_dump_build(data, r['_id'])
			      #transform_record(data)
			      #pre_migration_check(data)
            puts "....................................... Built: #{(@record_count+=1)} of #{@total_records}"
        end

end

def pre_migration_check(data)

end

def build_core_person_sql(record, person_type = 'Client')
    if person_type == 'Mother'
       person_id = @mother_core_person_counter
    elsif person_type == 'Father'
    	person_id = @father_core_person_counter
    elsif person_type == 'Client'
    	person_id = @document_tracker[record[:_id]][:client_id]
    else
    	person_id = @informant_core_person_counter
    end

	sql = "(#{person_id}, #{PersonType.where(name: "#{person_type}").last.id},"
	sql += "\"#{record[:person][:created_at].to_date}\",\"#{record[:person][:updated_at].to_date}\"),"
    
    `echo -n '#{sql}' >> #{@dump_files}core_person.sql`
end

def build_person_sql(record, type = 'Client')
   doc_id = record[:_id]
   if type == 'Client'
    person_id = @document_tracker[doc_id][:client_id]
   elsif type == 'Father'
    person_id = @document_tracker[doc_id][:father_id]
   elsif type == 'Mother'
    person_id = @document_tracker[doc_id][:mother_id]
   elsif type == 'Informant'
    person_id = @document_tracker[doc_id][:informant_id]
   end



   if type == 'Client'
    sql = "(#{person_id},\"#{record[:person][:gender]}\",\"#{record[:person][:birthdate].to_date}\","
    sql += "\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
   elsif type == 'Mother'
     if record[:person][:mother][:birthdate_estimated].blank?
       record[:person][:mother][:birthdate] = '1900-01-01'
       record[:person][:mother][:birthdate_estimated] = 1
     end

    sql = "(#{person_id},\"#{'Female'}\",\"#{record[:person][:mother][:birthdate].to_date}\","
    sql += "\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
   elsif type == 'Father'
     if record[:person][:father][:birthdate_estimated].blank?
       record[:person][:father][:birthdate] = '1900-01-01'
       record[:person][:father][:birthdate_estimated] = 1
     end

      sql = "(#{person_id},\"#{'Male'}\",\"#{record[:person][:father][:birthdate].to_date}\","
      sql += "\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
   elsif type == 'Adoptive-Mother'
     if record[:person][:foster_mother][:birthdate_estimated].blank?
       record[:person][:foster_mother][:birthdate] = '1900-01-01'
       record[:person][:foster_mother][:birthdate_estimated] = 1
     end

    sql = "(#{person_id},\"#{'Female'}\",\"#{record[:person][:foster_mother][:birthdate].to_date}\","
    sql += "\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
   elsif type == 'Adoptive-Father'
     if record[:person][:foster_father][:birthdate_estimated].blank?
       record[:person][:foster_father][:birthdate] = '1900-01-01'
       record[:person][:foster_father][:birthdate_estimated] = 1
     end

    sql = "(#{person_id},\"#{'Male'}\",\"#{record[:person][:foster_father][:birthdate].to_date}\","
    sql += "\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
   elsif type == 'Informant'
     if record[:person][:informant][:birthdate_estimated].blank?
       record[:person][:informant][:birthdate] = '1900-01-01'
       record[:person][:informant][:birthdate_estimated] = 1
     end

    sql = "(#{person_id},\"#{record[:person][:informant][:gender]}\",\"#{record[:person][:informant][:birthdate].to_date}\","
    sql += "\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
   end
  
   `echo -n '#{sql}' >> #{@dump_files}person.sql`
end

  def build_person_name_sql(record, person_type = 'Client')
     doc_id = record[:_id]
     if person_type == 'Client'
      person_id = @document_tracker[doc_id][:client_id]
     elsif person_type == 'Father'
      person_id = @document_tracker[doc_id][:father_id]
     elsif person_type == 'Mother'
      person_id = @document_tracker[doc_id][:mother_id]
     elsif person_type == 'Informant'
      person_id = @document_tracker[doc_id][:informant_id]
     end


    if person_type == 'Client'
       sql = "(#{person_id},\"#{record[:person][:first_name]}\",\"#{record[:person][:middle_name]}\","
       sql += "\"#{record[:person][:last_name]}\",\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
    elsif person_type == 'Mother'
    	sql = "(#{person_id},\"#{record[:person][:mother][:first_name]}\",\"#{record[:person][:mother][:middle_name]}\","
      sql += "\"#{record[:person][:mother][:last_name]}\",\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
    elsif person_type == 'Father'
    	sql = "(#{person_id},\"#{record[:person][:father][:first_name]}\",\"#{record[:person][:father][:middle_name]}\","
      sql += "\"#{record[:person][:father][:last_name]}\",\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
    elsif person_type == 'Adoptive-Mother'
    	sql = "(#{person_id},\"#{record[:person][:foster_mother][:first_name]}\",\"#{record[:person][:foster_mother][:middle_name]}\","
      sql += "\"#{record[:person][:foster_mother][:last_name]}\",\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
    elsif person_type == 'Adoptive-Father'
    	sql = "(#{person_id},\"#{record[:person][:foster_father][:first_name]}\",\"#{record[:person][:foster_father][:middle_name]}\","
      sql += "\"#{record[:person][:foster_father][:last_name]}\",\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
    else 
    	sql = "(#{person_id},\"#{record[:person][:informant][:first_name]}\",\"#{record[:person][:informant][:middle_name]}\","
      sql += "\"#{record[:person][:informant][:last_name]}\",\"#{record[:person][:created_at]}\",\"#{record[:person][:updated_at]}\"),"
    end

    begin
      `echo -n '#{sql}' >> #{@dump_files}person_name.sql`
    rescue
    end
end

def build_person_address_sql(record, type)
   doc_id = record[:_id]
   if type == 'Client'
    person_id = @document_tracker[doc_id][:client_id]
   elsif type == 'Father'
    person_id = @document_tracker[doc_id][:father_id]
   elsif type == 'Mother'
    person_id = @document_tracker[doc_id][:mother_id]
   elsif type == 'Informant'
    person_id = @document_tracker[doc_id][:informant_id]
   end

  cur_district_id         = Location.locate_id_by_tag(record[:current_district], 'District')
  cur_ta_id               = Location.locate_id(record[:current_ta], 'Traditional Authority', cur_district_id)
  cur_village_id          = Location.locate_id(record[:current_village], 'Village', cur_ta_id)

  home_district_id        = Location.locate_id_by_tag(record[:home_district], 'District')
  home_ta_id              = Location.locate_id(record[:home_ta], 'Traditional Authority', home_district_id)
  home_village_id         = Location.locate_id(record[:home_village], 'Village', home_ta_id)

  citizenship            = Location.where(country: record[:citizenship]).last.id
  residential_country    = Location.locate_id_by_tag(record[:residential_country], 'Country')
  address_line_1         = (record[:informant_same_as_mother].present? && record[:informant_same_as_mother] == "Yes" ? record[:person][:informant][:addressline1] : nil)
  address_line_2         = (record[:informant_same_as_mother].present? && record[:informant_same_as_mother] == "Yes" ? record[:person][:informant][:addressline2] : nil)

  created_at         = record[:person][:created_at].to_date
  updated_at         = record[:person][:updated_at].to_date


  sql = "(#{person_id},#{cur_district_id},#{cur_ta_id},#{cur_village_id},#{home_district_id},"
  sql += "#{home_ta_id},#{home_village_id},\"#{record[:person][:mother][:foreigner_home_district]}\","
  sql += "\"#{record[:person][:mother][:foreigner_current_ta]}\",\"#{record[:person][:mother][:foreigner_current_village]}\","
  sql += "\"#{record[:person][:mother][:foreigner_home_district]}\",\"#{record[:person][:mother][:foreigner_home_ta]}\","
  sql += "\"#{record[:person][:mother][:foreigner_home_village]}\",#{citizenship},#{residential_country},"
  sql += "\"#{address_line_1}\",\"#{address_line_2}\",\"#{created_at}\",\"#{updated_at}\"),"

  `echo -n '#{sql}' >> #{@dump_files}person_addresses.sql`
end

def build_person_relationship_sql(record, person_type)
 person_type_id = PersonRelationType.where(name: person_type).last.id
   if person_type == 'Mother'
    person_b = @mother_core_person_counter
   elsif person_type == 'Father'
    person_b = @father_core_person_counter
   else
    person_b = @informant_core_person_counter
   end

  doc_id = record[:_id]
  person_a = @document_tracker[doc_id][:client_id]
   
  sql = "(#{person_a},#{person_b},#{person_type_id},"
  sql += "\"#{record[:person][:created_at].to_date}\",\"#{record[:person][:updated_at].to_date}\"),"

 `echo -n '#{sql}' >> #{@dump_files}person_relationship.sql`
end

def build_informant_relationship(record, person_type)
   person_type_id = PersonRelationType.where(name: 'Informant').last.id
   doc_id = record[:_id]

   if person_type == 'Mother'
    person_b = @document_tracker[doc_id][:mother_id]
   elsif person_type == 'Father'
    person_b = @document_tracker[doc_id][:father_id]
   else
    person_b = @document_tracker[doc_id][:informant_id]
    puts "########################################### #{person_b}"
   end

  person_a = @document_tracker[doc_id][:client_id]
  sql = "(#{person_a},#{person_b},#{person_type_id},"
  sql += "\"#{record[:person][:created_at].to_date}\",\"#{record[:person][:updated_at].to_date}\"),"

 `echo -n '#{sql}' >> #{@dump_files}person_relationship.sql`
end

def mother_record(record, mother_type, doc_id)
  document = Child.find(doc_id)

  mother_first_name = document.mother.first_name rescue nil
  return if mother_first_name.blank?
  type = 'Mother'

  @mother_core_person_counter = @used_ids.sort.last + 1
  @used_ids << @mother_core_person_counter
  @document_tracker[doc_id][:mother_id] = @mother_core_person_counter

  build_core_person_sql(record, type)
  build_person_sql(record, type)
  build_person_name_sql(record, type)
  build_person_address_sql(record, type)
  build_person_relationship_sql(record, type)
end

def father_record(record, father_type, doc_id)
  document = Child.find(doc_id)

  father_first_name = document.father.first_name rescue nil
  return if father_first_name.blank?

  @father_core_person_counter = @used_ids.sort.last + 1
  @used_ids << @father_core_person_counter
  @document_tracker[doc_id][:father_id] = @father_core_person_counter

  build_core_person_sql(record, 'Father')
  build_person_sql(record, 'Father')
  build_person_name_sql(record,"Father")
  build_person_address_sql(record, 'Father')
  build_person_relationship_sql(record, 'Father')
end



def informant_record(record, doc_id)
  document = Child.find(doc_id)

  relationship_to_child = document.informant.relationship_to_child rescue nil
  return if relationship_to_child.blank?

  if relationship_to_child.match(/Adoptive/i)
    if relationship_to_child.match(/Mother/i)
      build_informant_relationship(record, 'Adoptive-Mother')
      return
    elsif relationship_to_child.match(/Father/i)
      build_informant_relationship(record, 'Adoptive-Father')
      return
    end
  elsif relationship_to_child.match(/Mother/i)
    build_informant_relationship(record, 'Mother')
    return
  elsif relationship_to_child.match(/Father/i)
    build_informant_relationship(record, 'Father')
    return
  end

  relationship_to_child = 'Informant' if relationship_to_child.match(/Other/i)
  @informant_core_person_counter = @used_ids.sort.last + 1
  @used_ids << @informant_core_person_counter
  @document_tracker[doc_id][:informant_id] = @informant_core_person_counter

  build_core_person_sql(record, relationship_to_child)
  build_person_sql(record, relationship_to_child)
  build_person_name_sql(record, relationship_to_child)
  build_person_address_sql(record, relationship_to_child)
  build_informant_relationship(record, 'Informant')
end

def initiate_sql_dump_build(record, doc_id)
  client = Child.find(doc_id)

  @document_tracker[doc_id] = {
    client_id: ((@used_ids.sort.last + 1) rescue 1),
    mother_id: nil,
    father_id: nil,
    informant_id: nil
  }

  @used_ids << @document_tracker[doc_id][:client_id]

  registration_type  = record[:person][:relationship]
  build_core_person_sql(record)
  build_person_sql(record)
  build_person_name_sql(record)


  case registration_type
    when "normal"
      unless client.mother.blank?
        mother_record(record,"Mother", doc_id)
      end

      unless client.father.blank?
        father_record(record,"Father", doc_id)
      end

      unless client.informant.blank?
        informant_record(record, doc_id)
      end

    when "orphaned"
      informant_record(record, doc_id)
    when "adopted" || "abandoned"
      if record[:biological_parents] == "Both" || record[:biological_parents] =="Mother"
        mother_record(person, 'Mother')
      end
      
      if record[:biological_parents] == "Both" || record[:biological_parents] =="Father"
        father_record(record, 'Father')
      end
      
      if params[:foster_parents] == "Both"
        mother_record(person, 'Adoptive-Mother')
        father_record(record, 'Adoptive-Father')
      end

      if params[:foster_parents] =="Mother"
        mother_record(person, 'Adoptive-Mother')
      end
      
      if params[:foster_parents] =="Father"
        mother_record(person, 'Adoptive-Father')
      end
        
      informant_record(record, doc_id)

  else
  end

end

def start

  prepare_dump_files
  total_records = Child.count
  page_size = 1000
  @total_records = total_records
  total_pages = (total_records / page_size) + (total_records % page_size)
  current_page = 0

  while (current_page < total_pages) do
    build_client_record(current_page, page_size)
    current_page = current_page + 1
    break
  end

   puts "\n"
   puts "Completed migration of 1 of 3 batch of records! Please review the log files to verify.."
   puts "\n"
end

@total_records = 0
@record_count = 0
start
