require_relative 'ether_pac'
require_relative 'ipv4_head'

class IPv4P < EtherP
	attr_accessor :ipv4h
	def initialize
		super
		@ipv4h = IPv4H.new
			@ipv4h.version = "0100"
			@ipv4h.head_len = "0101"
	 		@ipv4h.tos = "00000000"
	 		# @ipv4h.total_len = ""
		 	@ipv4h.id = rand(0..65535)
	 		@ipv4h.flags = "010"
	 		# @ipv4h.frag_offset = ""
		 	@ipv4h.ttl = "11111111"
	 		@ipv4h.protocol = "00000110" #tcp协议
		 	@ipv4h.set_addr_by_arr(CONFIG[:src_ip], :src)
		 	@ipv4h.set_addr_by_arr(CONFIG[:dst_ip], :dst)
		 	# @ipv4h.opt_padding = "" 
		 	@ipv4h.set_check_sum()
	end

	def pac_info_by_layer
		pac_info = super
		pac_info[:ipv4h] = ipv4h.field_info
		pac_info
	end

	class << self
		def build_pac_from_str(str)
			pac = build_ether_pac(str) #ruby中的类不能用super调用父类的类方法，故只能在父类EtherP中对build_pac_from_str命名别名为build_ether_pac
			ipv4h_len = str[0].unpack("B*")[0][4,4].to_i(2)*4
			pac.ipv4h = IPv4H.from_string(str.slice!(0,ipv4h_len))
			pac
		end
		alias_method :build_ipv4_pac, :build_pac_from_str

		def pac_from_pac(pac, type=nil)
			pac = type==:new ? pac.dup_pac : pac
			yield(pac) if block_given?
			p "ipv4"
			pac.ipv4h.checksum = "0000000000000000"
			pac.ipv4h.set_check_sum
			pac.renew
			pac
		end
	end
end