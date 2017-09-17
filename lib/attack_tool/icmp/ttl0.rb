require_relative '../../protocol/icmp_pac.rb'

class ICMPP
	def self.send_ttl0_pacs(pcap, ttl=0, count=1)
		pac = ICMPP.new
		pac = ICMPP.pac_from_pac(pac){|p1|
			p1.ipv4h.ttl = ttl
			p1.icmp_data = "\0"*100
			p1.icmp_data = yield if block_given?
			p1.ipv4h.instance_eval do
				self.total_len = head_len_decimal*4 + 8 + p1.icmp_data.length
			end
		}
		count.times do
			pcap.send_packet(pac)
		end
	end
end