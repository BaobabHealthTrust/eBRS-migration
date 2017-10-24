#This file is used to sync data birectional from and to all enabled sites
#Kenneth Kapundi@21/Sept/2017

require 'net/ping'
require 'socket'
require 'open3'

class Sync

  def self.up?(host, port=5984)
    a, b, c = Open3.capture3("nc -vw 5 #{host} #{port}")
    b.scan(/succeeded/).length > 0
  end

  def self.local_ip
    self.private_ipv4.ip_address rescue (self.public_ipv4.ip_address rescue nil)
  end

  def self.private_ipv4
    Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
  end

  def self.public_ipv4
    Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
  end
end

