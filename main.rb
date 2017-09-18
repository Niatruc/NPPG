load 'config.rb'
# i=0
# P.dump_devices.each{|it| puts i,it; i+=1}
# puts "选择要使用的网络接口"
# if = readline.to_i

# $pcap = L.new(:dev => P.dump_devices[if][0])

list = $list.sort_by{|k, v| v[1]}	#转成数组
# Dir.open("bin"){|d| d.each{|f| list<<f.sub(/\.rb/,'') if f.include?(".rb")}}

$iso = false

EM::run{
	ignore_exception{
		m
		while opt=readline.delete("\r\n")
			begin
				case opt
				when 'quit'
					break
				when 'help'
					list.each{|i| print color_azure(i[0]),": ",color_green(i[1][1]),"\n"}
				when 'rb','ruby'
					load "#{ThisDir}/bin/repl.rb"
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
