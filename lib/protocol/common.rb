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

		# 这个实例变量用来存储协议所有字段名
		c.class_variable_set("@@field_name_sym_set", [])
		
		# 定义报头各字段的getter和setter（hash是键值对：协议字段名-协议字段长度）
		def c.define_field_func(hash, &block)
			i = 0
			field_name_sym_set = self.class_variable_get("@@field_name_sym_set")

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

			 		# 若含有非01的字符，判定为非法字符串
			 		if str =~ /[^01]/
			 			raise "Invalid value!"
			 		end

			 		if str.length > len
			 			puts color_red(" 数值过大或过长")
			 		else
			 			set_field(j, len, '0'*(len-str.length)+str) #j表示此字段在@bit_str中的起始位置，len表示字段长度（有多少个二进制位）	
			 		end
			 	end
			 	i += len

			 	yield(f,len) if block_given?

			 	field_name_sym_set << f.to_sym
			end

			field_name_sym_set.freeze
		end

		# 给某个字段添加以十进制取值的方法(即返回该字段的十进制值)
		def c.decimal_format(f,len)
			define_method(f.to_s+"_decimal") do
				send(f).to_i(2)
			end
		end
	end

	# 将所有字段值以hash的形式返回
	def field_info(field_format_hash = {})
		field_info = {}
		special_field_name_arr = field_format_hash.keys

		self.class.class_variable_get("@@field_name_sym_set").each do |field_name|
			if special_field_name_arr.include?(field_name)
				field_format = field_format_hash[field_name]
				if field_format.class <= Proc
					field_info[field_name] = field_format.call()
				else
					field_info[field_name] = field_format
				end
			else
				field_info[field_name] = send(field_name)
			end
		end
		field_info
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

	# 对01串str进行设置，将index处开始的length个字符替换为str
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
