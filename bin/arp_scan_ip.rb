require_relative '../config.rb'
load ThisDir+'/lib/scanner/arp_scan_ip.rb'

new_process({
	title: "arp_scan_ip",
	vars: {
		IP: [CONFIG[:ip_range], "要扫描的IP地址段或地址(点分十进制或CIDR地址)"],
		REPLAY_TIME: [1, "重放次数"],
		REDO_TIME: [1, "重复执行dispatch的次数（适当增加该值以提高捕获率）"],
		INTERVAL: [1, "每次执行dispatch的时间间隔"],
		TIMEOUT: [5, "dispatch的timeout选项"],
	},
}) do |vars|
	ip_range = ip_str_to_range(vars[:IP]) # 先将点分十进制的ip字符串转成整数或整数范围值
	ARPP.scan_ip(
		$pcap,
		vars.merge({
			IP: ip_range
		})
	)
end