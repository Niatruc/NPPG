class Integer
	# bit_num:二进制加法中
	def bsum(b, bit_num)
		a = self
		c = (a+b).to_s(2)
		carry = c.length>bit_num ? (begin c.slice!(0);1 end):0 #循环加：若高位溢出，将进位加到最低位
		c.to_i(2)+carry
	end

	# 将01串按位取反
	def complement_str(bit_num=16)
		str = self.to_s(2)
		str.length.times do |i|
			str[i] = str[i]=='1'? '0' : '1'
		end

		padding = ""
		(bit_num-str.length).times do
			padding<<'1'
		end
		padding+str
	end

	def to_asc_str
		arr=[]
		str=""
		if self==0
			str<<0
		else
			v = self.abs
			while v>0
				arr.unshift(v%256)
				v /= 256
			end
			arr.reduce(str){|s,v| s<<v.chr}
		end
	end
end


# arr=
# [
# 0b1001100100010011,
# 0b0000100001101000,
# 0b1010101100000011,
# 0b0000111000001011,
# 0b0000000000010001,
# 0b0000000000001111,
# 0b0000010000111111,
# 0b0000000000001101,
# 0b0000000000001111,
# 0b0000000000000000,
# 0b0101010001000101,
# 0b0101001101010100,
# 0b0100100101001110,
# 0b0100011100000000
# ]

# a=0
# arr.each do |v|
# 	a = v.bsum(a,16)
# end
# a.to_s(2)

# # "1001011011101101"