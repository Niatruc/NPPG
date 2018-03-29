LOAD_ALL=true
require_relative 'lib/support/kernel.rb'
require_relative 'config_con_var.rb'
require_relative 'help.rb'

# require 'ffi-pcap'
require 'eventmachine'

if LOAD_ALL==true
	load_lib(File.dirname(__FILE__)+'/lib','rb')
else
	load 'lib/protocol/tcp_pac.rb'
	load 'lib/support/generator.rb'
end