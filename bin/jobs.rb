#This file is used to sync data birectional from and to all enabled sites
#Kenneth Kapundi@21/Sept/2017

require 'open3'
def is_up?(host)
  host, port = host.split(':')
  a, b, c = Open3.capture3("nc -vw 5 #{host} #{port}")
  b.scan(/succeeded/).length > 0
end


district_tag_id = LocationTag.where(name: "District").last.id
LocationTagMap.where(location_tag_id: district_tag_id).map(&:location_id).each do |loc_id|
  if !File.exist?("#{Dir.pwd}/public/sites/#{loc_id}.yml")
    File.open("#{Dir.pwd}/public/sites/#{loc_id}.yml","w") do |file|
      data = {loc_id =>
        {
          online: false
        }
      }
      file.write data.to_yaml
      file.close
    end
  end
end

files = Dir.glob( File.join("#{Rails.root}/public/sites", '**', '*.yml')).to_a
(files || []).each do |f|
  data = YAML.load_file(f) rescue {}
  (data || []).each do |site_id, d|
    next if d.blank?
    up = false
    (d['ip_addresses'] || []).each do |adr|
      if is_up?(adr)
        up = true
        data[site_id]['online'] = true
        data[site_id]['last_seen'] = "#{Time.now}"
        next
      end

      if up == true
        data[site_id]['online'] = true
        data[site_id]['last_seen'] = "#{Time.now}"
      else
        data[site_id]['online'] = false
      end
    end

    File.open("#{Rails.root}/public/sites/#{site_id}.yml","w") do |file|
      file.write data.to_yaml
    end
  end

end

FileUtils.touch("#{Rails.root}/public/ping_sentinel")

