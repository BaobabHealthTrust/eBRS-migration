require 'openssl'
require 'base64'

class EncryptionWrapper
  def initialize(attribute, parent=nil)
    @parent = parent if !parent.blank?

    @attribute = attribute
  end

  def before_save(record)

    string_limit = 255

    if !@parent.blank?

      if (record[@parent].send("#{@attribute}").strip.length < string_limit rescue false)

        record[@parent].send("#{@attribute}=", encrypt(record[@parent].send("#{@attribute}"))) rescue nil

      end

    else

      if (record.send("#{@attribute}").strip.length < string_limit rescue false)

        record.send("#{@attribute}=", encrypt(record.send("#{@attribute}")))

      end

    end

  end

  def after_save(record)
    if !@parent.blank?
      record[@parent].send("#{@attribute}=", decrypt(record[@parent].send("#{@attribute}"))) rescue nil
    else
      record.send("#{@attribute}=", decrypt(record.send("#{@attribute}")))
    end
  end

  alias_method :after_initialize, :after_save

  private
  def encrypt(value)

    return value if !File.exists?("#{Rails.root}/config/public.pem")

    public_key_file = "#{Rails.root}/config/public.pem"

    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))

    encrypted_string = Base64.encode64(public_key.public_encrypt(value)) rescue nil

    return encrypted_string

  end

  def decrypt(value)

    return value if !File.exists?("#{Rails.root}/config/private.pem")

    private_key_file = "#{Rails.root}/config/private.pem"

    password = CONFIG["crtkey"] rescue nil

    return value if password.nil?

    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), password)

    string = private_key.private_decrypt(Base64.decode64(value)) rescue nil

    return value if string.nil?

    return string

  end

end
