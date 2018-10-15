require_relative 'common'
class EtherH
	# 各字段直接用ascii串表示
	include Common
	attr_accessor :src_mac, :dst_mac, :protocol
	self.class_variable_set("@@field_name_sym_set", [:src_mac, :dst_mac, :protocol])

	def self.from_string(str)
		etherh = self.new(14*8)
		etherh.src_mac = str.slice!(0,6)
		etherh.dst_mac = str.slice!(0,6)
		etherh.protocol = str.slice!(0,2)
		etherh
	end

	# 将字符串用ASCII-8BIT编码后再赋给mac字段
	[:src_mac=, :dst_mac=].each do |m|
		define_method(m) do |mac|
			eval("@#{m.to_s} mac.force_encoding('ASCII-8BIT')")
		end
	end

	def pack
		(@dst_mac + @src_mac + @protocol).force_encoding("ASCII-8BIT")
	end

	def dup_head
		h = EtherH.new
		["src_mac", "dst_mac", "protocol"].each do |v|
			eval "h.#{v} = self.#{v}.dup"
		end
		h
	end

end