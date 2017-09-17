module Kernel
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

	def load_lib(lib_dir, *suffix)
		Dir.open(lib_dir){|d|
			s = suffix.join('.')
			d.each{|f|
				if !['.','..'].include?(f)
					f = d.path+'/'+f
					if File.directory?(f)
						load_lib(f, suffix) 
					else
						puts "\033[35m"+f+"\033[0m"
						load f if f =~ /.*\.#{s}(\..+)?/
					end
				end
			}
		}
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
		if $iso # 独立运行
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

	def m(context=nil); print color_white_b(color_black("#{context}")),'>> ' end

	def repl
		exp=nil
		m("[ruby]")
		while (exp=readline)!="ok\n" #输入ok时退出repl
			begin
				if exp == "ml\n" #多行输入
					str = ""
					while (exp=readline)!="ok\n" #输入ok时退出多行模式
						str << exp
					end
					eval str
				else
					eval "p "+exp
				end
			rescue Exception => e
				puts e
			end
			m("[ruby]")
		end
	end

	# 定义方法，它们将要输出的信息转换为字符串，并添加修改颜色属性
	num = 29
	[:white, :black, :red, :green, :yellow, :blue, :purple, :azure,
	 :red_b, :green_b, :yellow_b, :blue_b, :purple_b, :azure_b, :white_b, :black_b].each do |f|
	 	n = num
		define_method("color_"+f.to_s) do |*v|
			str = "\033[#{n}m" + v.reduce(""){|s,i| i.to_s+"\n"}.to{|s| s.chop} + "\033[0m"
		end
		num += f==:azure ? 5:1
	 end

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
	 	arr.reduce(0){|s,i| s=(s+i)*256}/256
	 end

	 # 将位串按8位分，得到整数数组
	 def bit_str_to_int_arr(bit_str)
	 	bs = bit_str.dup
	 	arr = []
	 	arr<<bs.slice!(0,8).to_i(2) while !bs.empty?
	 	arr
	 end

	 # 将位串转为ASCII字符串
	 def bit_str_to_str(bit_str)
	 	bit_str_to_int_arr(bit_str).pack("C*")
	 end

	 # 将ASCII字符串转为位串
	 def str_to_bit_str(str)
	 	str.unpack("B*")[0]
	 end

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
		 		from = (common+'0'*(32-mask)).to_i(2)
		 		to = (common+'1'*(32-mask)).to_i(2)
		 		return from..to
		 	end
	 	end
	 end

	 # 将字符串形式的mac地址转为分号分隔的十六进制串
	 def mac_to_semi_hex(mac)
	 	mac.unpack("C*").reduce(''){|s,v| s+=v.to_s(16)+':'}.chop
	 end

	 def check_sum(str)
		checksum = "0000000000000000"
		sum = 0
		str = str.dup
		while !str.empty?
			sum = sum.bsum(str.slice!(0,16).to_i(2), 16)
		end
		# np = ~sum<0 ? '1' : '0'
		# sum = [~sum].pack("C*")[0].unpack("B*")[0]
		sum = sum.complement_str
		checksum = sum
	end
end