$: << "E:/Ruby22/test/pcap/IP_deceive"
require 'C.rb'
require 'minitest/autorun'

class CTest < MiniTest::Test

	def setup
		@c = C.new(1.3,2)
	end

	def test_plus
		assert(@c.plus==3.3, "method 'plus': wrong\n")
	end

	def test_p0
		refute(@c.p0==0, "hahahaha")
	end
end