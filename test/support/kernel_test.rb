require 'minitest/autorun'
require_relative '../../lib/support/kernel.rb'

class KernelTest < MiniTest::Unit::TestCase
	def setup
		[:a, :b, :c, :d].each{|v| eval("@#{v}=rand(0..254)")}
		@ip1_arr = [@a,@b,@c,@d]
		@ip2_arr = [@a+1,@b+1,@c+1,@d+1]
		@ip1_str = @ip1_arr.join('.')
		@ip2_str = @ip2_arr.join('.')
		@ip1_int = ((((@a*256)+@b)*256)+@c)*256+@d
		@ip2_int = (((((@a+1)*256)+(@b+1))*256)+(@c+1))*256+(@d+1)
		# @mask = rand(1..32)
		# @ip_cidr_str = "#{ip1_str}/#{mask}"
	end

	def test_ip_str_to_range
		assert(ip_str_to_range("*%-1.1.1.1[aad")==(16843009))
		assert(ip_str_to_range("1.1.1.1 asdl; 1.1.1.2")==(16843009..16843010))
		assert(ip_str_to_range("#{@ip1_str} - #{@ip2_str}")==(@ip1_int..@ip2_int), "bla")
		assert(ip_str_to_range("1.0.0.0/16")==((256**3)..(256**3+256**2-1)), "bla")
	end
end