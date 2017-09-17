# 根据所给ip和port从一定数量n的pcap捕获的包中过滤出目的包，扫描过n个包后没发现时则返回nil
def filter_by_ip_port_optimize(pcap, ip_arr, port_num=nil)
	pcap.dispatch(:count=>1) do |this, packet|
		body = packet.body
		src_ip_addr_str = body[14+12, 4]
		src_tcp_port_num = body[14+20, 2].unpack("H*")[0].to_i(16)

		p packet,
		"body:",body.unpack("C*"),
		"src_ip_addr_str",src_ip_addr_str,
		"length",src_ip_addr_str.length,
		"src_ip_addr_str",src_ip_addr_str.unpack("C*")
		if src_ip_addr_str == ip_arr.pack("C*") #&& src_tcp_port_num == port_num
			return packet
		end
		return body
	end
	return nil
end