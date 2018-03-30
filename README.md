# NPPG

## Network Protocol Packet Generator
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
And as for EtherP class, it inherites `FFI::PCap::Packet` class. Before sending a packet, pcap will reset `body`, the member of pac1, and so the data of this packet is stored in `pac1.body`. Then as `ffi/pcap` library can do that, a packet will be put on the network after executing the code `pcap1.send_packet(pac1)`. (pcap1 is an instance of `FFI::PCap::Live` class)

* You can transform a network packet into a ruby class. You can destruct the packet by protocol layer, on the premiss that you have define a method as is showed below.
```ruby
class << ARPP
	def build_pac_from_str(str)
		pac = build_ether_pac(str)
		pac.arph = ARPH.from_string(str.slice!(0,4*7))
		pac
	end
	alias_method :build_arp_pac, :build_pac_from_str
end
```
If you execute the code `ARPP.build_pac_from_str(pkt.body)` (`pkt.body` means the acsii format data of a network packet), the instance of ARPP class (for example, pac1) will be created, and then you could get the fields' value of each protocol by accessing the member of pac1:
```ruby
pac1 = ARPP.build_pac_from_str(pkt.body)

pac1.arph.sender_ip
```

## What Can NPPG Be Uesd For?
* Build some network scanners. (To scan ip address of the machines in a LAN, to scan opening TCP port of a computer, etc.)
* Build some attack tools. (Like arp deception, flooding attack, etc.)
* Anything else that you might come up with.

## Getting Started
1. Install ruby interpreter. Click to redirect to [Ruby's official website](http://www.ruby-lang.org/en/downloads/).
2. Install required ruby gems.
`gem install ffi-pcap`
