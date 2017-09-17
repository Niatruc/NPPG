require_relative 'arp_head'
require_relative 'ether_pac'

class ARPP<EtherP
	attr_accessor :arph

	def initialize
		super
		@arph = ARPH.new
			@arph.hw_type = 1
			@arph.protocol = 0x0800
			@arph.hlen = 6
			@arph.plen = 4
			@arph.opcode = 1
			@arph.set_mac_by_str($src_mac, :sender)
			@arph.set_addr_by_arr($src_ip, :sender)
			@arph.set_mac_by_str("\x00\x00\x00\x00\x00\x00", :receiver)
			@arph.set_addr_by_arr($dst_ip, :receiver)

		@etherh.dst_mac = "\xff\xff\xff\xff\xff\xff"
		@etherh.protocol = "\x08\x06"
	end

	class << self
		def build_pac_from_str(str)
			pac = build_ether_pac(str)
			pac.arph = ARPH.from_string(str.slice!(0,4*7))
			pac
		end
		alias_method :build_arp_pac, :build_pac_from_str
	end
end