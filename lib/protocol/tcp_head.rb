require_relative 'common'
class TCPH
	include Common

	def initialize(bit_num=32*5)
		ini(bit_num)
	end

	define_field_func({src_port:16, dst_port:16, 
					 seq_num:32,
					 ack_num:32,
					 data_offset:4, reserved:4, control_flag:8, win_size:16,
					 checksum:16, urgent_pointer:16, 
					 opt_padding:32}) do |f, len|
					 	case f 
					 	when :src_port,:dst_port,:seq_num,:ack_num,:data_offset,:win_size
					 		decimal_format(f,len)
					 	end
					 end

	def add_opts(*opts)
		opt_len = 0
		opts.each do |opt|
			self.bit_str += opt.pack("C*").unpack("B*")[0]
			opt_len += opt.length
		end
		self.data_offset = self.data_offset_decimal+opt_len/4
	end

end