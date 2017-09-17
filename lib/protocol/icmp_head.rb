require_relative 'common.rb'

class ICMPH
	include Common

	def initialize(bit_num=8*8)
		ini(bit_num)
	end

	define_field_func({
		type:8, code:8, checksum:16,
		id:16, seq_num:16
	})do |f, len|
		case f
		when :type, :code, :id, :seq_num
			decimal_format(f, len)
		end
	end
end