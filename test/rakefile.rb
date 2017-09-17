$: << "E:/Ruby22/test/pcap/IP_deceive"
require 'rake/testtask'

Rake::TestTask.new do|t|
	t.test_files = FileList['testC.rb']
	# t.warning = true
end