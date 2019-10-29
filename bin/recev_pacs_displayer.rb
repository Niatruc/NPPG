require_relative '../config.rb'

ni = CONFIG[:ni_num]
if ARGV[0]
	ni = ARGV[0]
else
	puts color_yellow("当前所选网络接口: "), $pcap_info
	puts color_yellow("当前可用网络接口: ")
	P.dump_devices.each_with_index {|ni, i| print i, ". ", ni, "\n" }
	puts color_yellow("选择要使用的网络接口: ")
	ni = readline.to_i
end
$pcap = L.new(:dev => P.dump_devices[ni.to_i][0])


$pcap.loop do |this,pkt|
	p this, pkt 
end