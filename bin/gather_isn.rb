require_relative '../lib/attack_tool/tcp/syn_and_ack.rb'
require_relative '../lib/attack_tool/tcp/ip_deceive.rb'
require_relative '../config_con_var.rb'

ratio,rtts,last_time,last_num = TCPP.syn_and_ack($pcap)

puts "请输入序号选择参考的序列号样本\n"
opts = read_nums
s=0; opts.each{|opt| s+=ratio[opt]}
p increment = s / (opts.length)

puts "请输入序号选择参考的往返时间样本\n"
opts = read_nums
s=0; opts.each{|opt| s+=rtts[opt]}
p rtt_average = s / (opts.length)

open("#{ThisDir}/data/isn_msg", "w") do |f|
	Marshal.dump([ratio,rtts,last_time,last_num])
end