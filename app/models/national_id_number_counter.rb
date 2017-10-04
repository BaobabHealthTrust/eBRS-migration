require 'couchrest_model'
require 'thread'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/rmagick_outputter'
require 'rqrcode'


class NationalIdNumberCounter < CouchRest::Model::Base

  use_database "local"

  property :auto_increment_count, Integer, :default => 0

  timestamps!
  
  @@mutex = nil

  def NationalIdNumberCounter.mutex= (x)

    @@mutex = x

  end

  def NationalIdNumberCounter.mutex

    return @@mutex

  end

  def self.assign_serial_number(child, gender, citizenship_mother = nil, citizenship_father = nil)
  
    return false if (child.class.name.to_s.downcase != "child" rescue true)
  
    return false if gender.blank?

    #return false if (citizenship_mother.blank? and citizenship_father.blank?)

    return false if child.district_id_number.blank?
   
    @@mutex = Mutex.new if @@mutex.blank?

    @@mutex.lock
    
    counter = self.by_auto_increment_count.first

    counter = self.create(:auto_increment_count => 0) if counter.nil?

    next_number = counter.auto_increment_count + 1

    @@mutex.unlock if !child.national_serial_number.blank?

    return false if !child.national_serial_number.blank?
   
    id = "%010d" % next_number

    infix = ""

    if gender.match(/^F/i) 

      infix = "1"

    elsif gender.match(/^M/i) 

      infix = "2"

    end

    nat_serial_num = "#{id[0, 5]}#{infix}#{id[5, 9]}"
      
    if child.npid.blank?
      npid = Npid.by_assigned.keys([false]).first
      update_child = child.update_attributes(:request_status => "CAN PRINT", 
      																			 :npid => npid.national_id,
                                             :national_serial_number => nat_serial_num)
      
      if update_child == true
        
        counter.update_attributes(:auto_increment_count => next_number)
 				
        NationalIdNumber.create(:national_serial_number_value => next_number,
                                :district_id_number => child.district_id_number, 
        												:national_serial_number => nat_serial_num)
        
        								
        npid.update_attributes(:assigned => true , 
        											 :site_code => child.facility_code, 
        											 :child_id => child.id)
        
        p = Process.fork{`bin/generate_barcode #{child.npid} #{child.id} #{CONFIG['barcodes_path']}`}
        Process.detach(p)
      else
        @@mutex.unlock
     
        return false
      end
     
    else
      
      
      update_child = child.update_attributes(:request_status => "CAN PRINT",
                                             :national_serial_number => nat_serial_num)
      
      if update_child == true
        
        counter.update_attributes(:auto_increment_count => next_number)
 				
        NationalIdNumber.create(:national_serial_number_value => next_number, 
        											  :district_id_number => child.district_id_number, 
        											  :national_serial_number => nat_serial_num,
        											  :national_serial_number_value => next_number)
        
             											  
        											  
        p = Process.fork{`bin/generate_barcode #{child.npid} #{child.id} #{CONFIG['barcodes_path']}`}
        Process.detach(p)
        
      else
        @@mutex.unlock
      
        return false
      end
    end

    @@mutex.unlock
  
    return true

  end
  
  def self.create_barcode(child)

    barcode = Barby::Code128B.new(child.npid)
    
    File.open(Rails.root.join("tmp/#{child.id}.png"), "wb") do |f|
      f.write barcode.to_png(:height => 50, :xdim => 2)
    end

  end

  design do
    view :by_auto_increment_count
  end

end
