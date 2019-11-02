CONFIG = {
	load_all: true,

	# 是否在运行网络封包相关功能模块时打印封包数据
	display_sended_pac: false,

	# 执行reloadfiles命令时默认重载的文件或目录的路径集
	reload_files_paths: ['/lib/protocol', '/lib/readline'],

	# 是否显示有颜色字体
	color_switch_on: false,

	pcap_count: 1000,
	pcap_timeout: 10,

	# 是否同步运行（若false，则运行子功能模块（即bin目录下的功能模块）时会放在Eventmachine中做异步运行）
	iso: false,

	# 默认选择的网卡接口
	ni_num: 4,

	# 网关mac地址
	gateway_mac: "\xe4\xf3\xf5\xd4\x9a\xac",

	# 本机mac地址
	src_mac: "\xAC\xED\x5C\x15\x18\x32",

	# 受害者mac地址
	victim_mac: "\x84\x3a\x4b\x01\x91\x2a",

	# 目标mac地址
	dst_mac: "\x84\x3a\x4b\x01\x91\x2a",

	# 網段ip
	ip_range: "192.168.1.0/24",

	# 网关ip地址
	gateway_ip: [192, 168, 1, 1],

	# 本机ip地址
	src_ip: [192, 168, 1, 101],

	# 受害者ip地址
	victim_ip: [192, 168, 1, 222],

	# 目标ip地址
	dst_ip: [192, 168, 1, 102],

	# 本机使用的传输层端口
	src_port: 65535,

	# 受害者端口
	victim_port: 4444,

	# 目标端口
	dst_port: 80,

	# 端口范围（端口扫描器会使用该值）
	port_range: 0..5,

	max_rtt: 1,
}