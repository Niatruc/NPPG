require_relative '../protocol/tcp_pac.rb'
class Packet_Analysis < TCPP
	def initialize(packet)
		body = packet.body.dup
		@etherh = EtherH.from_string(body.slice!(0,14))

		if @etherh.protocol == "\x08\x00"	#是ip包
			if body.unpack("B*")[0].slice(0,4)=="0100"	#是ipv4
				ipv4h_len = body.unpack("B*")[0].slice(4,4).to_i(2)
				@ipv4h = IPv4H.from_string(body.slice!(0,ipv4h_len*4))
				if ipv4h.protocol=="00000110"
					tcph_len = body.unpack("B*")[0].slice(32*3,4).to_i(2)
					@tcph = TCPH.from_string(body.slice!(0,tcph_len*4))
				end
			end
		end
	end
end