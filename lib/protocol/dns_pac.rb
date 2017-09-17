require_relative 'dns_head.rb'
require_relative 'udp_pac.rb'

class DNSP<UDPP
	attr_accessor :dnsh

	def initialize
		super
		@udph.dst_port = 53

		@dnsh = DNSH.new
	end
end