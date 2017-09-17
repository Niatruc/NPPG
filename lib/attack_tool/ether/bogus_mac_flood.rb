require_relative "../../protocol/ether_pac.rb"

class EtherP
	def self.bogus_mac_flood(pcap, bogus_mac:"\x00\x00\x00\x00\x00\x00", scale:100)
		pac = EtherP.new
		pac.etherh.instance_eval do
			@dst_mac = bogus_mac
			@protocol = "\x00\x00"
		end
		if block_given?
			data = yield 
		else
			data = '0'*100
		end
		pac.body = pac.etherh.pack + data
		scale.times{pcap.send_packet(pac)}
	end
end