require_relative '../protocol/tcp_pac.rb'
require_relative '../support/kernel.rb'

class TCPP
	# TCP端口扫描
	def self.tcp_port_scan(pcap, port_range=(0..1024))
		dst_ip = arr_to_dot_dec($victim_ip)
		pcap.set_filter("src host #{dst_ip} and tcp")

		sp = TCPP.syn_pac{|pac|
			pac.ipv4h.set_addr_by_arr($victim_ip, :dst)
		}

		print color_blue("开始对"), dst_ip, color_blue("进行TCP端口扫描"), "\n"
		port_range.each do |port|
			sp = TCPP.pac_from_pac(sp){|pac| pac.tcph.dst_port = port}
			pcap.send_packet(sp)

			pcap.loop(count:1) do |this, pkt|
				pac = TCPP.build_tcp_pac(pkt.body)
				if pac.tcph.control_flag[5]=='1' #收到了RST报文
					break
				elsif pac.tcph.src_port_decimal != port #若为上一个端口的重发报文
					break
				else
					print color_purple("开通了"), port, color_purple("端口"), "\n"
					rp = TCPP.ack_for_pac(pac, sp, "00000100")
					pcap.send_packet(rp)
				end
			end
		end

		pcap.set_filter("")
	end
end