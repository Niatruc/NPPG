require_relative 'config_con_var.rb'
require_relative 'lib/support/Kernel.rb'
require_relative 'help.rb'
require 'ffi-pcap'
require 'eventmachine'

P = FFI::PCap
L = P::Live
Packet = P::Packet
ThisDir = __FILE__.sub(/\/[^\/]*$/, '')	#当前所在文件夹之绝对路径，最后不带斜杠

$reset_pcap = ->(ni) {
	$pcap_info = P.dump_devices[ni]
	$pcap = L.new(:dev => P.dump_devices[ni][0])
	def $pcap.send_packet(pac)
		pac.renew if pac.class <= FFI::PCap::Packet
		if CONFIG[:display_sended_pac] and pac.respond_to?(:pac_info)
			puts pac.pac_info
		end
		super(pac)
	end
}

if CONFIG[:load_all] == true
	load_lib(File.dirname(__FILE__)+'/lib','rb')
else
	load 'lib/protocol/tcp_pac.rb'
	load 'lib/support/generator.rb'
end