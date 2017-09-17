$: << "E:/Ruby22/test/pcap/IP_deceive"
load 'lib/support/kernel.rb'

require 'ffi-pcap'
require 'eventmachine'

P = FFI::PCap
L = P::Live
Packet = P::Packet

EM::run{
	while (p 'while';opt=readline)!="quit\n"
		case opt.delete("\n\r")
		when '1'
			EM::defer{loop {p 'hahahaha';sleep(2);}}
		when '2'
			EM::defer{loop{puts readline}}
		when '3'
			EM::defer{p 'here is 3';puts readline;p 'here is 3 after'}
		else
			EM::defer{puts 'else'}
		end
	end
}