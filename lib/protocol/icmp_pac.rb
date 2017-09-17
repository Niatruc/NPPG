require_relative 'icmp_head.rb'
require_relative 'ipv4_pac.rb'

class ICMPP<IPv4P
	attr_accessor :icmph, :icmp_data
	def initialize
		super
		@ipv4h.protocol = 1 #icmp协议

		@icmph = ICMPH.new
		@icmph.type = 8
		@icmph.code = 0
		@icmp_data = ""
		set_check_sum_icmp

		@ipv4h.total_len = @ipv4h.head_len_decimal*4 + @icmph.bit_str.length/8
		@ipv4h.set_check_sum
	end

	def self.icmp_reply
		pac = ICMPP.new.instance_eval{ 
			@icmph = ICMPH.new(8*4);
			undef :id, :id=, :id_decimal, :seq_num, :seq_num=, :seq_num_decimal
		}
	end

	def set_check_sum_icmp
		@icmph.checksum = "0"
		@icmph.set_check_sum(@icmph.bit_str + str_to_bit_str(@icmp_data))
	end

	def renew
		self.body = super + @icmp_data
	end

	class << self
		def pac_from_pac(pac, type=nil)
			super(pac, type) do |pac2|
				yield(pac2) if block_given?
				pac2.set_check_sum_icmp
			end
		end
	end
end