class NameCodes
  def initialize(attribute, parent=nil)
    @parent  = parent if !parent.blank?

    @attribute = attribute
  end

  def before_save(record)
    if !@parent.blank?
      record[@parent].send("#{@attribute}_code=", to_soundex(record[@parent].send("#{@attribute}"))) rescue nil
    else
      record.send("#{@attribute}_code=", to_soundex(record.send("#{@attribute}"))) rescue nil
    end
  end

  private

  def to_soundex(value)

    value.soundex

  end

end
