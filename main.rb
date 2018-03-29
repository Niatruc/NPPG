require_relative 'config.rb'

list = $list.sort_by{|k, v| v[1]}	#转成数组

# Dir.open("bin"){|d| d.each{|f| list<<f.sub(/\.rb/,'') if f.include?(".rb")}}

CONFIG[iso] = false

EM::run{
	ignore_exception{
		m
		while opt=readline.delete("\r\n")
			begin
				case opt
				when 'quit'
					break
				when 'help'
					list.each { |i| print color_azure(i[0]),": ",color_green(i[1][1]),"\n" }
				when 'rb','ruby'
					load "#{ThisDir}/bin/repl.rb"
				when 'ni'
					i=0
					puts color_yellow("当前所选网络接口: "), $pcap_info
					puts color_yellow("当前可用网络接口: ")
					P.dump_devices.each_with_index{|ni, i| print i, ". ", ni, "\n" }
					puts color_yellow("选择要使用的网络接口: ")
					ni = readline.to_i

					$pcap_info = P.dump_devices[ni]
					$pcap = L.new(:dev => P.dump_devices[ni][0])
					def $pcap.send_packet(pac)
						pac.renew if pac.class <= FFI::PCap::Packet
						super(pac)
					end
				else
					if !$list[opt.to_sym].nil? and File.exist?("#{ThisDir}/bin/#{$list[opt.to_sym][0]}.rb")
						load "#{ThisDir}/bin/#{$list[opt.to_sym][0]}.rb" 
					end
				end
				m
			rescue Exception => e
				puts color_red("出错！")
				puts e.message  
  				puts e.backtrace
				next
			end
		end
		EM::stop
	}
}
