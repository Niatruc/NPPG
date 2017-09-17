require_relative '../config_con_var.rb'
require_relative '../lib/scanner/arp_scan_ip.rb'

puts(color_green("请输入想扫描的网址或网段"))

ip = ""
while (ip_range = ip_str_to_range(ip))==nil
	ip = readline
end
ARPP.scan_ip($pcap, ip_range)