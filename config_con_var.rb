
############################################################################################################################################

# $pcap_info = P.dump_devices[0]
# $pcap = L.new(:dev => P.dump_devices[4][0])
# $pcap_count = 1000
# $pcap_timeout = 10

# # 是否为单独运行的程序，否则程序会被main.rb引入
# $iso = true

# # 选择的网卡的序号
# $ni_num = 1

# $gateway_mac = "\xe4\xf3\xf5\xd4\x9a\xac"
# # $src_mac = "\xb8\x76\x3f\x14\x5e\x33"
# $src_mac = "\xAC\xED\x5C\x15\x18\x32"
# $victim_mac = "\x84\x3a\x4b\x01\x91\x2a"
# $dst_mac = "\x84\x3a\x4b\x01\x91\x2a"

# $gateway_ip = [192,168,1,1]
# $src_ip = [192,168,1,102]
# $victim_ip = [192,168,1,222]
# $dst_ip = [192,168,1,101]

# $src_port = 65535
# $victim_port = 4444
# $dst_port = 80
# $port_range = 0..65535

# # "\xe0\xdb\x55\x9c\x13\xf4"
# # "\x60\x08\x10\x29\x39\x5b"
# $max_rtt = 1


CONFIG = {
	load_all: true,
	display_sended_pac: true,
	color_switch_on: false,
	pcap_count: 1000,
	pcap_timeout: 10,
	iso: true,
	ni_num: 1,
	gateway_mac: "\xe4\xf3\xf5\xd4\x9a\xac",
	src_mac: "\xAC\xED\x5C\x15\x18\x32",
	victim_mac: "\x84\x3a\x4b\x01\x91\x2a",
	dst_mac: "\x84\x3a\x4b\x01\x91\x2a",
	gateway_ip: [192,168,1,1],
	src_ip: [192,168,1,102],
	victim_ip: [192,168,1,222],
	dst_ip: [192,168,1,101],
	src_port: 65535,
	victim_port: 4444,
	dst_port: 80,
	port_range: 0..65535,
	max_rtt: 1,
}