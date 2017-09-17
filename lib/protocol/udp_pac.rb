require_relative 'ipv4_pac'
require_relative 'udp_head'

class UDPP<IPv4P
	attr_accessor :udph
	def initialize
		super
		@app_data = ""
		@udph = UDPH.new
			@udph.src_port = $src_port
			@udph.dst_port = $dst_port
			@udph.length = 4*2 + @app_data.length/8
			@udph.set_check_sum

			@ipv4h.protocol = "00010001"
		 	sum=0
		 	@ipv4h.total_len = [@ipv4h.head_len_decimal*4, @udph.length_decimal].reduce(sum,&:+)
		 	@ipv4h.set_check_sum()
	end

	def bogus_head
		@ipv4h.src_addr +
		@ipv4h.dst_addr +
		"00000000" +
		@ipv4h.protocol +
		(@udph.length_decimal).to{|x| x=x.to_s(2); '0'*(16-x.length)+x}
	end

	def set_check_sum_udp(ad = @app_data.unpack("B*")[0])
		@udph.checksum = "0"
		@udph.set_check_sum(self.bogus_head+@udph.bit_str+ad)
	end

	def set_app_data(data)
		data = data.force_encoding("ASCII-8BIT")
		@app_data = data.length%2==0 ? data : data+"\x00" #确保报文长度为偶数个字节

		@udph.length = 2*4 + @app_data.length #更新udp首部中的报文长度字段
		set_check_sum_udp

		@ipv4h.total_len = @ipv4h.head_len_decimal*4 + 2*4 + @app_data.length #更新ip首部中的总长度字段
		@ipv4h.set_check_sum
		self.renew
	end

	def renew
		self.body = @etherh.pack +
					  @ipv4h.pack +
					  @udph.pack +
					  @app_data
	end

	class << self
		def build_pac_from_str(str, pac_class=self)
			pac = build_ipv4_pac(str)
			udph_len = str[4,2].unpack("S*")[0]
			pac.udph = TCPH.from_string(str.slice!(0,tcph_len))
			pac
		end
		alias_method :build_udp_pac, :build_pac_from_str
	end
end