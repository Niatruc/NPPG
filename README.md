# NPPG
Network Protocol Package Generator. I have tried to develop it to a framework. 
* You can simply define a ruby class for a network protocol and pass something like `{field1: field1_length}` to a method(as the example belows shows) to define the data format of this protocol's head, then NPPG will generate the class for this protocol's head, which contains powerful getter and setter for each field. 
```ruby
# example: define a class for IPv4 protocol's head
require_relative 'common'
class IPv4H
	include Common
	def initialize(bit_num=32*5)
		ini(bit_num)
	end

	define_field_func({version:4, head_len:4, tos:8, total_len:16,
						id:16, flags:3, frag_offset:13,
						ttl:8, protocol:8, checksum:16,
						src_addr:32,
						dst_addr:32,
						opt_padding:32}) do |f, len|
					 	case f 
					 	when :head_len,:total_len,:frag_offset
					 		decimal_format(f,len)
					 	end
					 end

end
```
