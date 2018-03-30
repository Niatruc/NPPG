# NPPG

## Network Protocol Package Generator
I have tried to develop it to a framework. 
* You can simply define a ruby class for a network protocol and pass something like `{field1: field1_length}` to a method(as the example below shows) to define the data format of this protocol's head, then NPPG will generate the class for this protocol's head, which contains powerful getter and setter for each field. 
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

# initialize the instance of this class, and get or set one of its field
ih = IPv4H.new

# set value by decimal
ih.version = 4 

# by '01' like str which represents a binary value
ih.flags = "010"

# by an array which elements are all decimal smaller than 256 (it means that each decimal represents a byte value)
ih.src_addr = [192,168,1,1]

# get field's value by decimal format
puts ih.decimal_head_len
```
* A network packet can be represented with a ruby instance. Ruby class inheritance is used to represent the hierarchy of the network protocol.
```ruby
class IPv4P < EtherP
	attr_accessor :ipv4h
	def initialize
		super
		@ipv4h = IPv4H.new
			@ipv4h.version = 4
	end
end

pac1 = IPv4P.new
```

## Getting Started
1. Install ruby interpreter.[Ruby's official website](http://www.ruby-lang.org/en/downloads/)
