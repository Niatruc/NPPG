require_relative '../../protocol/tcp_pac.rb'

class TCPP
	def self.tcp_listen_plus(pcap, port)
		pcap.setfilter("tcp and dst host #{arr_to_dot_dec($src_ip)} and dst port #{port}")

		syn_pac = nil
		ini_port = 0 #对端原先使用的端口
		probe_port = 0
		pcap.loop do |this, pkt|
			syn_pac = TCPP.build_tcp_pac(pkt.body)

			probe_pac = TCPP.pac_from_pac(pac, :new){|p1|
				p1.ipv4h.src_addr = pac.ipv4h.dst_addr
				p1.ipv4h.dst_addr = pac.ipv4h.src_addr
				p1.tcph.src_port = pac.tcph.dst_port
				ini_port = p1.tcph.src_port_decimal #对端原先使用的端口
				p1.tcph.dst_port = probe_port = (ini_port+1)%65536 #使用另外的端口号
				p1.tcph.control_flag = "00000010"
			} #构造一个试探性的包

			pcap.send_packet(probe_pac)
			break
		end

		dst_ip = arr_to_dot_dec(bit_str_to_int_arr(syn_pac.tcph.src_addr))  #得到请求连接者的IP的点分十进制字符串
		dst_port = syn_pac.tcph.src_port_decimal  #得到请求连接者使用的端口号
		pcap.set_filter("tcp
						 and dst host #{arr_to_dot_dec($src_ip)} and dst port #{port}
						 and src host #{dst_ip} and src port #{probe_port}")

		sleep($max_rtt)

		pcap.dispatch do |this, pkt|
			ack_pac = TCPP.pac_from_pac(probe_pac){|p2|
				p2.tcph.dst_port = ini_port
				p2.tcph.seq_num = rand(0..2**32)
				p2.tcph.ack_num = syn_pac.tcph.seq_num_decimal+1
				p2.tcph.control_flag = "00010010"
			}
			pcap.send_packet(ack_pac) #发送握手包
		end

		pcap.set_filter("")
	end
end