require_relative 'ntp_head'
require_relative 'udp_pac'

class NTPP < UDPP
	attr_accessor :ntph

	def initialize()
		@ntph = NTPH.new
			@ntph.li = '11'
			@ntph.vn = 3
			@ntph.mode = 3
			@ntph.vn = 3
			@ntph.vn = 3
	end
end