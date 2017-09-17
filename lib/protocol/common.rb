require_relative '../support/integer'
require_relative '../support/kernel'
module Common
	attr_accessor :bit_str
	def initialize(bit_num=0)
		# @bit_str = ""
		@bit_str = '0'*bit_num
	end
	alias_method :ini, :initialize

	def self.included(c)
		# 包含Common模块会得到这些方法（作为c的类方法）

		# 用于使用（由Packet#body方法获取的）字符串构造各协议头对应的实例
		def c.from_string(data)
			h = self.new
			h.bit_str = data.unpack("B*")[0]
			h
		end
		
		# 定义报头各字段的getter和setter（hash是键值对：协议字段名-协议字段长度）
		def c.define_field_func(hash, &block)
			i = 0
			hash.each do |f,len| #len指字段的二进制位数
		 		j = i
			 	define_method(f) do
			 		@bit_str.slice(j,len)
			 	end
			 	define_method( f.to_s+"=" ) do|str|
			 		if str.class <= Integer 	#若参数是整数而非字符串
			 			str = str.to_s(2)
			 		elsif str.class <= Array
			 			str = (str.reduce(0){|s,i| s=(s+i)*256}/256).to_s(2)	#按字节将数组str合并成一个整数
			 		end
			 		if str.length > len
			 			puts color_red(" 数值过大或过长")
			 		else
			 			set_field(j, len, '0'*(len-str.length)+str) #j表示此字段在@bit_str中的起始位置，len表示字段长度（有多少个二进制位）	
			 		end
			 	end
			 	i += len

			 	yield(f,len) if block_given?
			end
		end

		# 给某个字段添加以十进制取值的方法(即返回该字段的十进制值)
		def c.decimal_format(f,len)
			define_method(f.to_s+"_decimal") do
				send(f).to_i(2)
			end
		end
	end

	# 将01串@bit_str按每8位分割成数组，然后将数组打包成ascii串
	def pack
		str = @bit_str.dup
		arr = []
		while !str.empty?
			arr << str.slice!(0,8).to_i(2)
		end
		arr.pack("C*")#.force_encoding("UTF-8")
	end

	#对01串str进行设置，将index处开始的length个字符替换为str
	def set_field(index, length, str)
		return false if length!=str.length
		@bit_str.sub!(/(?<=^.{#{index}}).{#{length}}/, str)
	end

	# 使用数组设置IP地址字段(现在可以不用该方法，直接给地址字段以数组赋值了)
	def set_addr_by_arr(arr, prefix, suffix="_addr")
		a = prefix.to_s+suffix+'='
	 	addr = arr.pack("C*").unpack("B*")[0]
	 	send(a, addr)
	end

	# 以数组的形式获取ip地址字段
	def get_addr_arr(prefix, suffix="_addr")
		addr = nil
		eval "addr = self.#{prefix.to_s+suffix}" #获取IP地址字段的01串

      	arr = []
	 	4.times do|i|
			arr<<addr.slice!(0,8)
			arr[i] = arr[i].to_i(2) #将01串转为10进制数
		end
		arr
	end

	# 用ascii字符串设置mac地址
	def set_mac_by_str(str, prefix, suffix="_mac")
		mac = str.unpack("B*")[0]
 		eval("self.#{prefix.to_s+suffix} = mac")
	end

	# 获取十六进制形式的mac地址,每个字节间用分号隔开
	def get_mac_str(prefix, suffix="_mac")
		arr = []
		eval("#{prefix.to_s+suffix}.dup.to{|s| arr<<s.slice!(0,8).to_i(2) while !s.empty?; arr}.reduce(''){|s,v| s+=v.to_s(16)+':'}.chop")
	end

	def set_check_sum(str=self.bit_str)
		self.checksum = "0000000000000000"
		sum = 0
		str = str.dup
		while !str.empty?
			sum = sum.bsum(str.slice!(0,16).to_i(2), 16)
		end
		np = ~sum<0 ? '1' : '0'
		# sum = [~sum].pack("C*")[0].unpack("B*")[0]
		sum = sum.complement_str
		self.checksum = sum
	end
		
	def dup_head
		h = self.dup
		h.bit_str = h.bit_str.dup
		h
	end
end

"\x46\xff\x00\x00\x00\x00\x00\x00\xff\x06\x00\x00\xc0\xa8\x01\x6b\xc0\xa8\x01\x66\x00\x00\x00\x00"
# 0000   46 ff 00 00 00 00 00 00 ff 06 ff 3c c0 a8 01 6b
# 0010   c0 a8 01 66 00 00 00 00