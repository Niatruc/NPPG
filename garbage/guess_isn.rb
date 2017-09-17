require_relative '../../protocol/ether_pac.rb'
class TCPP
	def self.guess_isn(pcap, t_ip, t_port)
		packet = MyPacket.my_new_packet
		packet.ipv4h.set_addr_by_arr(src_ip, :src)
		
		a = Time.now
		
		packet_from_T = nil
		get_T_packet = proc do
			pcap.send_packet(packet)
			until packet_from_T
				packet_from_T = filter_by_ip_port(pcap, t_ip, T_port)
			end	
		end
		
		get_T_packet.call
		b = packet_from_T.time
		seq_a = packet_from_T.body[14+20+4, 14+20+4+4].unpack("H*")[0].to_i(16)
		rtt1 = b-a

		packet_from_T = nil
		get_T_packet.call
		d = packet_from_T.time
		seq_b = packet_from_T.body[14+20+4, 14+20+4+4].unpack("H*")[0].to_i(16)
		rtt2 = d-c

		t = (rtt1/2) + (c-b) + (rtt2/2)
		inc = (seq_b-seq_a)/t

		e = Time.now
		rtt = (rtt1+rtt2)/2
		return seq_b + inc*(rtt2+rtt/2+e-d)
	end
end