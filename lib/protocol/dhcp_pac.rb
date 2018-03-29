require_relative 'udp_pac'
require_relative 'dhcp_head'
class DHCPP<UDPP
	attr_accessor :dhcph

	def initialize
		super
		@dhcph = DHCPH.new
			@dhcph.op = 1
			@dhcph.htype = 1
			@dhcph.hlen = 6
			@dhcph.hops = "00000000"
			@dhcph.xid =  rand(0..2**32)
			@dhcph.flag = "1000000000000000"
			@dhcph.magic_cookie = [99,130,83,99].pack("C*").unpack("B*")[0]
			@dhcph.set_chaddr_by_str(CONFIG[:src_mac])
			@dhcph.trans_to_dhcp_request

		@udph.src_port = 68
		@udph.dst_port = 67

		@ipv4h.set_addr_by_arr([0,0,0,0], :src)
		@ipv4h.set_addr_by_arr([255,255,255,255], :dst)

		@etherh.dst_mac = "\xff\xff\xff\xff\xff\xff"

		renew
	end

	def self.dhcp_request_unicast(pcap)
		pac = DHCPP.new
			# pac.etherh.src_mac = CONFIG[:src_mac]
			# pac.etherh.dst_mac = CONFIG[:gateway_mac]
			# pac.ipv4h.set_addr_by_arr([0,0,0,0], :src)
			# pac.ipv4h.set_addr_by_arr([255,255,255,255], :dst)
			# pac.dhcph.flag = "0000000000000000"
			pac.dhcph.trans_to_dhcp_request

		pac.set_app_data(pac.dhcph.pack)
		pcap.send_packet(pac)
	end
end

