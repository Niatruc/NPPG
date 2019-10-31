require_relative 'common'

class ARPH
	include Common

	def initialize(bit_num=32*7)
		ini(bit_num)
	end
	define_field_func({hw_type:16, protocol:16,
					   hlen:8, plen:8, opcode:16,
					   sender_mac:48,
					   sender_ip:32,
					   receiver_mac:48,
					   receiver_ip:32}) do |f, len|
					 	case f 
					 	when :hw_type, :protocol, :hlen, :plen, :opcode
					 		decimal_format(f,len)
					 	end
					 end

	def set_addr_by_arr(arr, prefix)
		super(arr, prefix, "_ip")
	end

	def get_addr_arr(prefix)
		super(prefix, "_ip")
	end

	def field_info
		super({
			sender_ip: bit_str_to_dot_dec(sender_ip),
			receiver_ip: bit_str_to_dot_dec(receiver_ip),
			sender_mac: bit_str_to_mac_semi_hex_str(sender_mac),
			receiver_mac: bit_str_to_mac_semi_hex_str(receiver_mac),
		})
	end
end