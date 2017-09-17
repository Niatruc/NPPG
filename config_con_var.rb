require 'ffi-pcap'
P = FFI::PCap
L = P::Live
Packet = P::Packet
ThisDir = __FILE__.sub(/\/[^\/]*$/, '')	#当前所在文件夹之绝对路径，最后不带斜杠

$pcap = L.new(:dev => P.dump_devices[1][0])
def $pcap.send_packet(pac)
	pac.renew if pac.class <= FFI::PCap::Packet
	super(pac)
end
$pcap_count = 1000
$pcap_timeout = 10

# 是否为单独运行的程序，否则程序会被main.rb引入
$iso = true

# 选择的网卡的序号
$if_num = 1

# def gateway_mac; "\x50\xbd\x5f\x30\xad\x70" end
$gateway_mac = "\xe4\xf3\xf5\xd4\x9a\xac"
# def src_mac; "\xe0\xdb\x55\x9c\x13\xf4" end
$src_mac = "\xb8\x76\x3f\x14\x5e\x33"
$victim_mac = "\x84\x3a\x4b\x01\x91\x2a"
$dst_mac = "\x84\x3a\x4b\x01\x91\x2a"

$gateway_ip = [192,168,1,1]
$src_ip = [192,168,1,100]
$victim_ip = [192,168,1,222]
$dst_ip = [192,168,1,101]

$src_port = 65535
$victim_port = 4444
$dst_port = 80
$port_range = 0..65535

# "\xe0\xdb\x55\x9c\x13\xf4"
# "\x60\x08\x10\x29\x39\x5b"
$max_rtt = 1