class RecordState

  def initialize(attribute)
    @attribute = attribute
  end

  def before_save(record)

    if (@attribute.strip.downcase == "facility_code" or @attribute.strip.downcase == "district_code")

      facility_code = CONFIG["facility_code"] rescue nil

      district_code = CONFIG["district_code"] # rescue nil

      record.send("#{@attribute}=", (@attribute.match(/facility/) ? facility_code : district_code)) rescue nil if record.send("#{@attribute}").blank?

    else

      record.send("#{@attribute}=", (@attribute.match(/request/) ? "ACTIVE" : "FACILITY OPEN")) rescue nil if record.send("#{@attribute}").blank?

    end

  end

  def after_save(record)

    if (@attribute.strip.downcase == "facility_code" or @attribute.strip.downcase == "district_code")

      facility_code = CONFIG["facility_code"] rescue nil

      district_code = CONFIG["district_code"] # rescue nil

      record.send("#{@attribute}=", (@attribute.match(/facility/) ? facility_code : district_code)) rescue nil if record.send("#{@attribute}").blank?

    else

      record.send("#{@attribute}=", (@attribute.match(/request/) ? "ACTIVE" : "FACILITY OPEN")) rescue nil if record.send("#{@attribute}").blank?

    end

  end

end
