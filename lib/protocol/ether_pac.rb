require 'ffi/pcap'
require_relative 'ether_head'
require_relative 'common_pac'

class EtherP < FFI::PCap::Packet
	include CommonPac
	attr_accessor :etherh, :app_data
	
	def initialize
		packet = super(nil,"")
		@etherh = EtherH.new
			@etherh.src_mac = CONFIG[:src_mac]
			@etherh.dst_mac = CONFIG[:dst_mac]
			@etherh.protocol = "\x08\x00" #ipv4

		@app_data = ""
	end

	def pac_info_by_layer
		{etherh: etherh.field_info}
	end

	# 根据所给报文字符串建立Packet实例
	class << self
		def build_pac_from_str(str)
			# p self
			pac = self.new
			pac.etherh = EtherH.from_string(str.slice!(0,14))
			pac
		end
		alias_method :build_ether_pac, :build_pac_from_str
	end
end