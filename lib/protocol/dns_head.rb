require_relative 'common.rb'

class DNSH
	def initialize(bit_num=8*12)
		ini(bit_num)
	end

	define_field_func({
		id:16, qr:1, opcode:4, atra:4, zero:3, rcode:4,
		ques:16, ans_rrs:16,
		auth_rrs:16, addi_rrs:16
	})
end