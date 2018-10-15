module Generator
	class << Generator
		def generate_mac(scale, mac_model:"\xb8\x76\x3f\x14\x5e\x33")
			i=1

			# 根据需要的假mac地址数scale算出mac_model中有几个字节需要动态变化
			while scale>=256
				scale /= 256
				i += 1
			end
			remainder = scale%256

			mac_const = mac_model[0,6-i].force_encoding("ASCII-8BIT")

			f = ->(l, n, str="".force_encoding("ASCII-8BIT")){
				str<<"#"	# 仅仅是一个填充字符
				n.times { |i| 
					str.slice!(-1,1)	# 删去str末尾字符
					str<<i
					if l==1 
						yield((mac_const+str).force_encoding("UTF-8")) if block_given?
					else
						f.call(l-1, 255, str.dup)
					end
				}
			}
			f.call(i, remainder)
		end


	end
end