require_relative "../protocol/arp_pac.rb"

class ARPP

	# 变量ip为单个Range实例或单个数组或单个整数
	def self.scan_ip(pcap, options)
		pcap.set_filter("arp")
		a = ARPP.new
		yield(a) if block_given?

		ip = options[:IP] || ""
		replay_time = options[:REPLAY_TIME] || 1
		redo_time = options[:REDO_TIME] || 1
		interval = options[:INTERVAL] || 1
		timeout = options[:TIMEOUT] || 5

		if ip.class == Range
			ip.each do |i|
				a.arph.receiver_ip = i
				pcap.send_packet(a)
			end
		else
			a.arph.receiver_ip = ip
			pcap.send_packet(a)
		end

		puts(color_green("ip地址			mac地址"))
		redo_time.times do
			
			pcap.dispatch(timeout: timeout) do|t, pkt|
				arpp = ARPP.build_arp_pac(pkt.body)
				next if arpp.arph.opcode_decimal != 2 #筛选出arp应答报文
				mac = bit_str_to_mac(arpp.arph.sender_mac)
				ip = bit_str_to_dot_dec(arpp.arph.sender_ip)
				puts "#{ip} 		#{mac}"
				# break
			end

			sleep(interval)
		end
		pcap.set_filter(nil)
	end
end