require_relative '../config_con_var.rb'
require_relative '../lib/support/kernel.rb'

puts color_azure("输入攻击次数: ")
redo_time = read_num
puts color_azure("输入每次攻击发送包数目: ")
scale = read_num

run_new_process("ruby #{ThisDir}/bin/arp_deceive.rb #{redo_time} #{scale}")