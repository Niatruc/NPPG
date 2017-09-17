require_relative '../../protocol/ipv4_pac.rb'

class IPv4P
	def self.send_ttl0_pacs(pcap, count=1)
		pac = IPv4P.new
		pac.ipv4h.ttl = 0
		count.times do
			pcap.send_packet(pac)
		end
	end
end