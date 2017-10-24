class ActionMatrix

  def self.read_actions(role, states = [])
		states = states.collect{|s| s.strip.upcase}
		role = role.strip.upcase

    csv = CSV.read("#{Rails.root}/app/assets/data/action_matrix.csv").entries
		roles = csv.first.collect{|c| c.strip.upcase rescue nil}
		role_index = roles.index(role)

		results = []
		csv.each_with_index do |row, i|
			next if i == 0 
			state = row[0]
			next if state.blank?
			break if state.strip.upcase == "END"

			if states.include?(state.strip.upcase) 
				row.each_with_index do |data, j|
					next if role_index != j || data.blank?
					results << data.split(",")
				end
			end
		end		
	
		results = results.flatten.collect{|i| i.to_i}.sort.collect{|i| self.decode(i)}		
		results
  end

	def self.decode(n)		

    csv = CSV.read("#{Rails.root}/app/assets/data/action_matrix.csv").entries
		csv.each_with_index do |row, i|
			next if i == 0 
			code = row[0]
			next if code.blank?
			break if code.strip.upcase == "END CODES"

			if n.to_s == code.to_s 
				return {
					"code" => n,
					"desc" => row[1],
					"button_name" => row[2]
				}
			end
		end		
  end

  def self.read_folders(role)
    csv = CSV.read("#{Rails.root}/app/assets/data/action_matrix.csv").entries
    found = false
    folders = []
    index = -1

    csv.each_with_index do |row, i|
      
      if row[0] == "Root Folder Privileges"
        found = true
        next
      end

      if found && row[0] == "Folder/Role"
        roles = row.collect{|r| r.upcase.strip}
        index = roles.index(role.upcase.strip)
      end
  
      if found && SETTINGS['enable_role_privileges'].to_s == 'false' && !row[0].blank? && Rails.env.to_s == 'development'
        folders << row[0]
      elsif index > -1 && !row[index].blank? && row[index].to_s == 'Y'
        folders << row[0]
      end

      break if row[0] && row[0].strip.upcase == "END ROOT FOLDER PRIVILEGES"
    end

    (folders - ["Folder/Role", "END ROOT FOLDER PRIVILEGES"])
  end

end
