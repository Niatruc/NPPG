require_relative "../protocol/arp_pac.rb"

class ARPP

	# 变量ip为单个Range实例或单个数组或单个整数
	def self.scan_ip(pcap, ip)
		pcap.set_filter("arp")
		a = ARPP.new
		yield(a) if block_given?
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
		pcap.dispatch(timeout:5) do|t, pkt|
			arpp = ARPP.build_arp_pac(pkt.body)
			next if arpp.arph.opcode_decimal != 2 #筛选出arp应答报文
			mac = arpp.arph.get_mac_str(:sender)
			ip = arr_to_dot_dec(arpp.arph.get_addr_arr(:sender))
			puts "#{ip} 		#{mac}"
			# break
		end
		pcap.set_filter(nil)
	end
end