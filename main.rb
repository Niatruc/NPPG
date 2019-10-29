require_relative 'config.rb'

list = $list.sort_by{|k, v| v[1]}	#转成数组

# Dir.open("bin"){|d| d.each{|f| list<<f.sub(/\.rb/,'') if f.include?(".rb")}}

$reset_pcap.call(0)

EM::run{
	ignore_exception{
		m
		while opt=readline.delete("\r\n")
			args = nil

			begin
				case opt
				when 'quit', 'q'
					break

				when 'help', 'h'
					list.each { |i| print color_azure(i[0]),": ",color_green(i[1][1]),"\n" }

				when 'ruby','rb'
					load "#{ThisDir}/bin/repl.rb"

				when 'ni'
					puts color_yellow("当前所选网络接口: "), $pcap_info
					puts color_yellow("当前可用网络接口: ")
					P.dump_devices.each_with_index {|ni, i| print i, ". ", ni, "\n" }
					puts color_yellow("选择要使用的网络接口: ")
					ni = readline.to_i

					$reset_pcap.call(ni)

				else
					# 如果是直接输入bin目录下的文件（路径）名，则直接执行对应的ruby文件
					if !$list[opt.to_sym].nil? and File.exist?("#{ThisDir}/bin/#{$list[opt.to_sym][0]}.rb")
						load "#{ThisDir}/bin/#{$list[opt.to_sym][0]}.rb" 
					elsif /^(rl|reloadfiles)(?<args>(?:\s+).*)*/ =~ opt
						args && args.split(/\s+/).each do |arg|
							load_lib("#{ThisDir}/#{arg}") if !arg.empty?
						end || load_lib("#{ThisDir}/lib")
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
