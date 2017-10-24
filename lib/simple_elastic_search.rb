require "rails"
require "yaml"
class SimpleElasticSearch
  SETTING = YAML.load_file("#{Rails.root}/config/elasticsearchsetting.yml")['elasticsearch']
  def self.format_content(person)
     
     search_content = ""
      if person["middle_name"].present?
         search_content = self.escape_single_quotes(person["middle_name"]) + ", "
      end 

      birthdate_formatted = person["birthdate"].to_date.strftime("%Y-%m-%d")
      search_content = search_content + birthdate_formatted + " "
      search_content = search_content + person["gender"].upcase + " "

  
      search_content = search_content + person["district"] + " " 
         

      if person["mother_first_name"].present?
        search_content = search_content + person["mother_first_name"] + " " 
      end

      if person["mother_middle_name"].present?
         search_content = search_content + person["mother_middle_name"] + " "
      end   

      if person["mother_last_name"].present?
        search_content = search_content + person["mother_last_name"] + " "
      end

      if person["father_first_name"].present?
         search_content = search_content + person["father_first_name"] + " "
      end 

      if person["father_middle_name"].present?
         search_content = search_content + person["father_middle_name"] + " "
      end 

      if person["father_last_name"].present?
         search_content = search_content + person["father_last_name"]
      end 

      return search_content.squish

  end

  def self.format_coded_content(person)
     
     search_content = ""
      if person["middle_name"].present?
         search_content = self.escape_single_quotes(person["middle_name"]).soundex + ", "
      end 

      birthdate_formatted = person["birthdate"].to_date.strftime("%Y-%m-%d")
      search_content = search_content + birthdate_formatted + " "
      search_content = search_content + person["gender"].upcase + " "

  
      search_content = search_content + person["district"] + " " 
         

      if person["mother_first_name"].present?
        search_content = search_content + person["mother_first_name"].soundex + " " 
      end

      if person["mother_middle_name"].present?
         search_content = search_content + person["mother_middle_name"].soundex + " "
      end   

      if person["mother_last_name"].present?
        search_content = search_content + person["mother_last_name"].soundex + " "
      end

      if person["father_first_name"].present?
         search_content = search_content + person["father_first_name"].soundex + " "
      end 

      if person["father_middle_name"].present?
         search_content = search_content + person["father_middle_name"].soundex + " "
      end 

      if person["father_last_name"].present?
         search_content = search_content + person["father_last_name"].soundex
      end 

      return search_content.squish

  end

  def self.escape_single_quotes(string)
    if string.present?
        string = string.gsub("'", "'\\\\''")
    end
    return string
  end

  def self.elastic_format(person)
     content =  self.format_content(person)
    
     registration_district = person["district"]

     coded_content = "#{person["first_name"].soundex} #{person["last_name"].soundex} #{self.format_coded_content(person)}"

     elastic_search_index = "curl -XPUT 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{person["id"]}'  -d '
              {
                \"first_name\": \"#{self.escape_single_quotes(person["first_name"])}\",
                \"last_name\": \"#{self.escape_single_quotes(person["last_name"])}\",
                \"middle_name\": \"#{self.escape_single_quotes(person["middle_name"]) rescue ''}\",
                \"gender\": \"#{person["gender"]}\",
                \"birthdate\": \"#{person["birthdate"].to_date.strftime("%Y-%m-%d")}\",
                \"place_of_death_district\": \"#{registration_district}\",
                \"mother_first_name\": \"#{self.escape_single_quotes(person["mother_first_name"])}\",
                \"mother_last_name\": \"#{self.escape_single_quotes(person["mother_last_name"])}\",
                \"father_first_name\": \"#{self.escape_single_quotes(person["father_first_name"])}\",
                \"father_last_name\": \"#{self.escape_single_quotes(person["father_last_name"])}\",
                \"coded_content\" :\"#{coded_content}\",
                \"content\" : \"#{self.escape_single_quotes(person["first_name"])} #{self.escape_single_quotes(person["last_name"])} #{escape_single_quotes(content)}\"
              }'"

      return elastic_search_index
  end

  def self.add_back(person)
    #puts self.elastic_format(person)
   puts `#{self.elastic_format(person)}`
  end

  def self.query(field,query_content,precision,size,from)
    if precision.blank?
      precision = SETTING['precision']
    end
    start_time = Time.now
    query = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?size=#{size rescue 10}&from=#{from rescue 0}&pretty=true' -H 'Content-Type: application/json' -d'
            {
              \"query\": {
                  \"match\": {
                    \"#{field}\":{
                          \"query\":\"#{self.escape_single_quotes(query_content)}\",
                          \"minimum_should_match\": \"#{precision}%\"
                    }
                  }
                }
              }'"
      
      data = JSON.parse(`#{query}`)

      end_time = Time.now

      if data["error"].blank?
         return {"time" => (end_time-start_time), "data" => data["hits"]["hits"]}
      else
         return {"time" => (end_time-start_time), "data" => []}
      end
     
  end

  def self.query_duplicate(person,precision)
      content =  self.format_content(person)
      query_string = "#{person["first_name"]} #{person["last_name"]} #{content}"

      potential_duplicates = []
      hits = self.query("content",query_string,precision,10,0)["data"]

      hits.each do |hit|
        potential_duplicates << hit if hit["_id"] !=(person.person_id rescue nil)
      end

      return potential_duplicates
  end

  def self.query_duplicate_coded(person,precision)
      content =  self.format_coded_content(person)
      query_string = "#{person["first_name"].soundex} #{person["last_name"].soundex} #{content}"

      potential_duplicates = []
      hits = self.query("coded_content",query_string,precision,10,0)["data"]
      
      #hits.each do |hit|
        #potential_duplicates << hit if hit["_id"].squish !=(person["person_id"].squish rescue nil)
      #end
      potential_duplicates = SimpleElasticSearch.white_similarity(person,hits,precision)

      return potential_duplicates
  end
  def self.white_similarity(person, hits,precision)
    potential_duplicates = []
    content =  "#{person["first_name"]} #{person["last_name"]} #{self.format_content(person)}"
    hits.each do |hit|
      next if hit["_id"].to_s.squish ==(person["id"].to_s.squish rescue nil)
      hit_content = hit["_source"]["content"]
      potential_duplicates <<  hit if WhiteSimilarity.similarity(content, hit_content) >= (precision/100)
    end
    return potential_duplicates
  end

  def self.add(person)
    content =  self.format_content(person)
    
    registration_district = person["district"]

    coded_content = "#{person["first_name"].soundex} #{person["last_name"].soundex} #{self.format_coded_content(person)}"
    person["content"] = "#{self.escape_single_quotes(person["first_name"])} #{self.escape_single_quotes(person["last_name"])} #{content}"
    person["coded_content"] = coded_content
    create_string = self.escape_single_quotes(person.as_json.to_json)
    create_query = "curl -s -XPUT 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{person['id']}'  -d '
                #{create_string}'"
    `#{create_query}`             
    return self.find(person["id"])
  end

  #Retriving record from elastic research
  def self.find(id)
    find_query = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{id}' "
    begin
      record = JSON.parse(`#{find_query}`)
      return record["_source"].merge({"id" => record["_id"]}) 
    rescue Exception => e
      return {}
    end
  end
  
  def self.all(type="")
    find_all = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{type.present? ? type : SETTING['type']}/_search?pretty=true'"
    return JSON.parse(`#{find_all}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}
  end

  def self.must_match_by(params)
    params_keys = params.keys rescue nil
    if params_keys.present?

      match = []
      params_keys.each do |key|
        match << {:match => { key => params[key]}}
      end
      query = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'  -d '
              {
                \"query\": {
                  \"bool\": {
                    \"must\":#{self.escape_single_quotes(match.to_json.to_s)}
                    }
                  }
                }
              }'"
            return JSON.parse(`#{query}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}
    else
      return "parameter bad format"
    end
  end

  def self.should_match_by(params)
    params_keys = params.keys rescue nil
    if params_keys.present?

      match = []
      params_keys.each do |key|
        match << {:match => { key => params[key]}}
      end
      query = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'  -d '
              {
                \"query\": {
                  \"bool\": {
                    \"should\":#{self.escape_single_quotes(match.to_json.to_s)}
                    }
                  }
                }
              }'"
            return JSON.parse(`#{query}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}
    else
      return "parameter bad format"
    end
  end

  def self.match_all(query_string)
    query = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'  -d '
              {
                \"query\": {
                  \"match\": {
                    \"_all\":\"#{query_string}\"
                    }
                  }
                }
        }'"
        return JSON.parse(`#{query}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}
  end

  def self.match_by_query(query)
    query = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'  -d '
              #{query.to_json.to_s}'"
        puts query
        return JSON.parse(`#{query}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}   
  end

  #Delete a document from elastic search
  def self.delete(id)
    delete_query = "curl -XDELETE 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{id}'"
    return JSON.parse(`#{delete_query}`)["found"]
  end

  #Update to elastic search
  def self.update(id,updates)
    document = self.find(id)
    if document.blank?
      puts "Document doesn't exist"
      return false
    else
      content = document
      content = content.merge(updates)
      update_query = "curl -XPUT 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{id}'  -d '
                #{content}'"
      return JSON.parse(`#{self.elastic_format(content)}`)["result"] == "updated" ? self.find(id) : false
    end
  end

  def self.count
    query = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'"
    data = JSON.parse(`#{query}`)["hits"]
    return data["total"]
  end

  def self.connect?
    if self.query_connection.blank? && self.query_connection["name"].blank?
      return false 
    else
      return true
    end
  end

  def self.query_connection
    begin
      connection = "curl http://#{SETTING['host']}:#{SETTING['port']}"
      return JSON.parse(`#{connection}`)
    rescue Exception => e
      return {}
    end

  end
end