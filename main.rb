require_relative 'config.rb'
require 'readline'
require_relative 'lib/readline/main_readline.rb'

list = $list.sort_by{|k, v| v[1]}	#转成数组
MainReadline.candidates = $list.keys.collect(&:to_s)


EM::run{
	ignore_exception{
		while opt = MainReadline.read(">> ", true)
			args = nil

			begin
				case opt
				when 'quit', 'q'
					break

				when 'help', 'h'
					list.each { |i| print color_azure(i[0]),": ",color_green(i[1][1]),"\n" }

				when 'ruby','rb'
					load "#{ThisDir}/bin/repl.rb"
					MainReadline.reset_readline_completion

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

					# rl命令，重新加载指定目录下的rb文件
					elsif /^(rl|reloadfiles)(?<args>(?:\s+).*)*/ =~ opt
						args && args.split(/\s+/).each do |arg|
							load_lib("#{ThisDir}/#{arg}") if !arg.empty?
						end ||
						CONFIG[:reload_files_paths].each do |path|
							load_lib("#{ThisDir}/#{path}")
						end
					end

					MainReadline.reset_readline_completion
				end
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
