require_relative 'common'
class IPv4H
	include Common
	def initialize(bit_num=32*5)
		ini(bit_num)
	end

	define_field_func({version:4, head_len:4, tos:8, total_len:16,
						id:16, flags:3, frag_offset:13,
						ttl:8, protocol:8, checksum:16,
						src_addr:32,
						dst_addr:32,
						opt_padding:32}) do |f, len|
					 	case f 
					 	when :head_len,:total_len,:frag_offset
					 		decimal_format(f,len)
					 	end
					 end

	def field_info
		super({
			src_addr: bit_str_to_int_arr(self.src_addr),
			dst_addr: bit_str_to_int_arr(self.dst_addr),
		})
	end
end