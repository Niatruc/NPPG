require_relative 'common'
class UDPH
	include Common
	def initialize(bit_num=32*2)
		ini(bit_num)
	end

	define_field_func({src_port:16, dst_port:16, 
						length:16, checksum:16})do |f, len|
					 	case f 
					 	when :src_port,:dst_port,:length
					 		decimal_format(f,len)
					 	end
					 end

end