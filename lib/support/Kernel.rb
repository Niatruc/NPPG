module Kernel
	def get_const(const_name_str_or_sym)
		eval(const_name_str_or_sym.to_s) rescue nil
	end

	def to
		yield self if block_given?
	end

	def d(*v)
		puts "\033[31m\033[47m#{v}\033[0m"
	end

	def error(msg)
		"\033[31m"+"#{msg}"+"\033[0m"
	end

	def puts_errors(*msgs)
		msgs.each do |m|
			puts error(m)
		end
	end

	def load_lib(lib_path, *suffix)
		s = suffix.join('.')
		if File.directory?(lib_path)
			Dir.open(lib_path) do |d|
				d.each do |f|
					if !['.','..'].include?(f)
						f = d.path + '/' + f
						load_lib(f, suffix) 
					end
				end
			end
		else
			print "Loading file: #{lib_path} "
			load lib_path if lib_path =~ /.*\.#{s}(\..+)?/
			puts "(OK)"
		end
	end

	def read_num; readline.to_i end

	def read_nums
		arr = []
		readline.scan(/\d+/) do |m|
			arr<<m.to_i
		end
		arr
	end

	def read_yn
		r = readline
		r.include?('y') ? true : false
	end

	def run(&blk)
		if CONFIG[:iso] # 独立运行
			blk.call
		else # 放在EM中运行
			EM::defer{blk.call}
		end
	end

	def ignore_exception(&blk)
		begin
			blk.call
		rescue Exception => e
			puts e
			ignore_exception(&blk)
		end
	end

	def run_new_process(cmd)
		r = IO.popen(cmd)
		r.set_encoding("utf-8")
		# r.each do |l|
		# 	puts l
		# end
	end

	# 这个表示mark
	def m(context=nil); print color_white_b(color_black("#{context}")),'>> ' end

	def new_process(options, &blk)
		config = get_const(:CONFIG)
		new_proc_readline = get_const(:NewProcessReadline)
		new_proc_readline.candidates = %w{quit show-options show-configs set desc config run}
		new_proc_readline.reset_readline_completion_proc

		vars = {} 
		options[:vars].each do |k, v|
			vars[k] = v[0]
		end

		desc = {} 
		options[:vars].each do |k, v|
			desc[k] = v[1]
		end

		while input = new_proc_readline.read(options[:title] + ">> ", true)
			begin
				case input
				when "quit", "q"
					break

				when "show-options"
					print "name			val			desc\n"
					options[:vars].each do |var, arr|
						val = arr[0]
						if val.class <= String
							val = "\"#{val}\""
						end
						print "#{var}			#{val}			#{arr[1]}\n"
					end

				when "show-configs"
					puts "name			val"
					config.each do |k, v|
						puts "#{k}			#{v}"
					end

				when /^(\w+)\s+(\w+)\s+(.+)/
					md = /^(\w+)\s+(\w+)\s+(.+)/.match(input)

					if nil == options[:vars][md[2].to_sym]
						options[:vars][md[2].to_sym] = []
					end

					case md[1]
					when "set"
						options[:vars][md[2].upcase.to_sym][0] = vars[md[2].upcase.to_sym] = eval(md[3])
					when "desc"
						options[:vars][md[2].upcase.to_sym][1] = desc[md[2].upcase.to_sym] = md[3]
					when "config"
						config[md[2].to_sym] = eval(md[3])
					end

				when "run"
					run {
						blk.call(vars)
					}

				end
			rescue Exception => e
				p e
				puts e.backtrace.join("\n")  
			end
		end
	end

	# 定义方法，它们将要输出的信息转换为字符串，并添加修改颜色属性
	num = 29
	config = get_const(:CONFIG) || {}
	[:white, :black, :red, :green, :yellow, :blue, :purple, :azure,
	 :red_b, :green_b, :yellow_b, :blue_b, :purple_b, :azure_b, :white_b, :black_b].each do |f|
	 	n = num
		define_method("color_"+f.to_s) do |*v|
			format_val = v.reduce("") { |s,i| i.to_s+"\n" }.to{ |s| s.chop }
			if config[:color_switch_on]
				str = "\033[#{n}m" + format_val + "\033[0m"
			else
				str = format_val
			end
		end
		num += f==:azure ? 5:1
	end

#########################################################################################
# 点分十进制字符串转其他类型

	# 点分十进制的正则对应的字符串
	def dot_dec_regexp_str(num=4)
		within255="(?:25[0-5]|2[0-4]\\d|1?\\d{1,2})"
		regexp_str = "((?:#{within255}\\.){#{num-1}}#{within255})"
	end
	alias_method :ddrs, :dot_dec_regexp_str

	# 点分十进制转数组
	def dot_dec_to_arr(str)
		str.split(".").reduce([]){|arr,i| arr<<i.to_i}
	end

	# 将形如"192.168.1.1 - 192.168.1.255"的由两个隔开的点分十进制IP地址
	# 或形如"192.168.1.0/24"的CIDR网络地址
	# 转成整数范围，以表示IP地址范围;
	# 也可将单个点分十进制IP地址字符串转成整数返回
	def ip_str_to_range(str)
		arr = []
		str.scan(/#{ddrs}(?!\/)/) do |m|
			arr<<dot_dec_to_arr(m[0])
		end

		if !arr[0].nil? and !arr[1].nil?
			return arr_to_int(arr[0])..arr_to_int(arr[1])
		elsif !arr[0].nil?
			return arr_to_int(arr[0])
		else
			addr, mask = str.scan(/#{ddrs}\/(\d+)/)[0]
			if !addr.nil?
		 		addr = dot_dec_to_arr(addr)
		 		addr_str = arr_to_bit_str(addr)
		 		mask = mask.to_i

		 		common = addr_str[0, mask]
		 		from = (common + '0'*(32-mask)).to_i(2)
		 		to = (common + '1'*(32-mask)).to_i(2)
		 		return from..to
		 	end
		end
	end

#########################################################################################
# MAC地址字符串转其他类型
	
	# MAC地址转字符串
	def mac_to_str(mac)
		mac.split(/[-:]/).collect { |i| i.to_i(16) }.pack("C*")
	end

#########################################################################################
# 数组转其他类型

	# 数组转点分十进制
	def arr_to_dot_dec(arr)
		arr.join('.')
	end

	# 将数组每个元素按字节转换为01串
	def arr_to_bit_str(arr)
		arr.pack("C*").unpack("B*")[0]
	end

	# 将整个整数数组每个元素看成一个256进制数的一位的十进制表示，然后将这个256进制数转换为一个十进制整数
	def arr_to_int(arr)
		(arr.reduce(0) { |s,i| s = (s + i) * 256 }) / 256
	end

#########################################################################################
# 01字符串转其他类型

	# 将位串按8位分，得到整数数组
	def bit_str_to_int_arr(bit_str)
		bs = bit_str.dup
		arr = []
		arr << bs.slice!(0,8).to_i(2) while !bs.empty?
		arr
	end

	# 01串转为点分十进制字符串
	def bit_str_to_dot_dec(bit_str)
		bit_str_to_int_arr(bit_str).join(".")
	end

	# 将位串转为MAC地址字符串
	def bit_str_to_mac_semi_hex_str(bit_str)
		str = bit_str_to_int_arr(bit_str).reduce("") { |semi_hex_str, num| "#{semi_hex_str}:#{num.to_s(16)}"}
		str[1, str.size]
	end

	# 将位串转为ASCII字符串
	def bit_str_to_str(bit_str)
		bit_str_to_int_arr(bit_str).pack("C*")
	end

#########################################################################################
# ASCII字符串数据（也即pcap捕获的原生数据格式）转其他类型

	# 将ASCII字符串转为位串
	def str_to_bit_str(str)
		str.unpack("B*")[0]
	end

	# 将ASCII字符串形式的mac地址转为分号分隔的十六进制串
	def str_to_mac_semi_hex_str(mac)
		mac.unpack('C*').collect { |i| 
			i = i.to_s(16).upcase
			i.length < 2 ? ('0'+i) : i
		}.join(':')
	end

#########################################################################################

end
