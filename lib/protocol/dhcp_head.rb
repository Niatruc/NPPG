require_relative 'common'

class DHCPH
	include Common
	attr_accessor :opts, :opts_str

	def initialize(bit_num=32*11+64*8+128*8+32)
		ini(bit_num)
		@opts = []
		@opts_str = ""
	end

	define_field_func({op:8, htype:8, hlen:8, hops:8,
					 	xid:32,
						secs:16, flag:16,
						ciaddr:32,
						yiaddr:32,
						siaddr:32,
						giaddr:32,
						chaddr:128,
						sname:64*8,
						file:128*8,
						magic_cookie:32}) do|f, len|
						 	case f 
						 	when :op,:htype,:hlen,:hops,:xid
						 		decimal_format(f,len)
						 	end
						end

	def add_opt(opt)
		if opt[:type]==nil or opt[:len]==nil
			puts_errors("error while adding opt: lacks type or length")
		elsif opt[:len] != (str = opt_to_str(opt)).length-2
			puts_errors("error while adding opt: opt's content has #{str.length-2} bytes('#{str}') rather than exactly #{opt[:len]} bytes")
		else
			@opts<<opt
			@opts_str<<str
		end
	end

	def opt_to_str(opt)
		str=""
		opt.each do |k,v|
			c = v.class
			if c<=Integer
				str<<v.to_asc_str
			elsif c<=Array
				str<<v.pack("C*") #这里假设数组所有元素都是255以内正整数
			else
				str<<v.force_encoding("ASCII-8BIT")
			end
		end
		str
	end

	def set_addr_by_arr(arr, whose)
	 	super(arr, whose, "iaddr")
	end

	def set_chaddr_by_str(mac)
		mac = mac.unpack("B*")[0]
		mac = mac + '0'*(128-mac.length)
		self.chaddr = mac
	end

	def pack
		super+@opts_str.to{|s| s.empty? ? s:s+"\xff".force_encoding("ASCII-8BIT")}
	end

	def trans_to_dhcp_discover
		@opts=[]
		@opts_str=""
		[{type:53, len:1, dhcp_msg_type:1},
		 {type:57, len:2, dhcp_msg_size:1500},
		 {type:60, len:13, vender_class:"dhcpcd 4.0.15"},
		 {type:12, len:6, host_name:"blabla"},
		 {type:55, len:11, param_request_list:[1,121,33,3,6,15,28,51,58,59,119]},
		].each { |h| add_opt(h) }
	end

	def trans_to_dhcp_request
		@opts=[]
		@opts_str=""
		[{type:53, len:1, dhcp_msg_type:3},
		 {type:61, len:7, hw_type:0x01,client_mac:CONFIG[:src_mac]},
		 {type:50, len:4, requested_ip:CONFIG[:src_ip]},
		 {type:12, len:25, host_name:"zhangbohanPC-20130902QBLV"},
		 {type:81, len:28, flags:0x00, a_rr:0, ptr_rr:0, client_name:"zhangbohanPC-20130902QBLV"},
		 {type:60, len:8, vender_class:"MSFT 5.0"},
		 {type:55, len:12, param_request_list:[1,15,3,6,44,46,47,31,33,121,249,43]},
		].each { |h| add_opt(h) }
	end
end