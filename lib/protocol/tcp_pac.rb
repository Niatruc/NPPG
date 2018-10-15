require_relative 'ipv4_pac'
require_relative 'tcp_head'

class TCPP < IPv4P
	attr_accessor :tcph
	def initialize
		super
		@app_data = ""
		@tcph = TCPH.new
		 		@tcph.src_port = rand(1..65535)
		 		@tcph.dst_port = CONFIG[:dst_port]
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
		 		# @tcph.urgent_pointer = "0"*16
		 		set_check_sum_tcp

		 	sum=0
		 	@ipv4h.total_len = [@ipv4h.head_len_decimal*4, @tcph.data_offset_decimal*4, @app_data.length].reduce(sum,&:+)
		 	@ipv4h.set_check_sum()
	end

	# 重新设置tcp首部的校验和字段
	def set_check_sum_tcp
		@tcph.checksum = "0" #很必要的一步，先把校验和字段重置为全0，因为下面那一步根本没做到这点！
		@tcph.set_check_sum(self.bogus_head+@tcph.bit_str+@app_data.unpack("B*")[0])
	end

	# 向tcp包末尾添加数据,同时重新计算各校验和字段
	def set_app_data(data)
		data = data.force_encoding("ASCII-8BIT")
		@app_data = data.length%2==0 ? data : data+"\n"

		set_check_sum_tcp

		@ipv4h.total_len = self.ipv4h.head_len_decimal*4 + self.tcph.data_offset_decimal*4 + @app_data.length
		@ipv4h.set_check_sum
		self.renew
	end

	# 伪首部
	def bogus_head
		@ipv4h.src_addr +
		@ipv4h.dst_addr +
		"00000000" +
		@ipv4h.protocol +
		(@tcph.data_offset_decimal*4+@app_data.length).to{|x| x=x.to_s(2); '0'*(16-x.length)+x}
	end

	def renew
		self.body = @etherh.pack +
					  @ipv4h.pack +
					  @tcph.pack +
					  @app_data
	end

	def self.syn_pac
		syn_pac = pac_from_pac(TCPP.new) do|sp|
			yield(sp) if block_given?
		end
	end

	# 建立tcp连接：发送syn包sp，并接收对方syn/ack包，并回送ack
	def self.establish_conn(pcap, sp, count=1)
		count.times{pcap.send_packet(sp)}
		ip1 = arr_to_dot_dec(sp.ipv4h.get_addr_arr("src"))
		port1 = sp.tcph.src_port_decimal
		ip2 = arr_to_dot_dec(sp.ipv4h.get_addr_arr("dst"))
		port2 = sp.tcph.dst_port_decimal

		pcap.set_filter("tcp 
			and src host #{ip2}
			and src port #{port2}")

		ack_pac = nil
		pcap.loop{|t,pkt|
			ack_pac = TCPP.ack_for_pac(TCPP.build_tcp_pac(pkt.body), sp)
			pcap.send_packet(ack_pac)
			puts color_yellow("new connection builded:"), "#{ip1}:#{port1} -> #{ip2}:#{port2}\n"
			break
		}
		pcap.set_filter(nil)
		ack_pac
	end

	# 根据本机上一次发出的包来构造这一次要发送的包,data是将要发送的上层数据
	def self.send_pac(pcap, last_sended_pac, data)
		np = pac_from_pac(last_sended_pac, :new) do |pac|
			pac.instance_eval do
				@tcph.seq_num = last_sended_pac.instance_eval{tcph.seq_num_decimal + app_data.length}#(ipv4h.total_len_decimal-ipv4h.head_len_decimal-tcph.data_offset_decimal)
				# @ipv4h.total_len = last_sended_pac.instance_eval{ipv4h.total_len_decimal - app_data.length}
				set_app_data(data)
			end
		end
		pcap.send_packet(np)
		np
	end

	# recv_pac为从连接的对端发来的包(如，syn握手包)，last_sended_pac为本地上次发出的syn包，在这里拿来改造用
	def self.ack_for_pac(recv_pac, last_sended_pac, cf="00010000")
		pac_from_pac(last_sended_pac, :new) do |new_pac|
			new_pac.instance_eval do
				tcph.seq_num = recv_pac.tcph.ack_num_decimal
				tcph.ack_num = recv_pac.tcph.seq_num_decimal + 1
				tcph.control_flag = cf
				yield(new_pac) if block_given?
			end
		end
	end

	def pac_info_by_layer
		pac_info = super
		pac_info[:tcph] = tcph.field_info
		pac_info
	end

	class << self
		def build_pac_from_str(str)
			pac = build_ipv4_pac(str)
			tcph_len = str[12].unpack("B*")[0][0,4].to_i(2)*4
			pac.tcph = TCPH.from_string(str.slice!(0,tcph_len))
			pac
		end
		alias_method :build_tcp_pac, :build_pac_from_str

		# 若new变量值为:new,则拷贝pac并修改，返回新的包；否则直接修改pac并返回
		def pac_from_pac(pac, type=nil)
			super(pac, type) do |pac2|
				yield(pac2) if block_given?
				pac2.set_check_sum_tcp
			end
		end
	end
end