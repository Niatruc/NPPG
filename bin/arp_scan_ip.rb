require_relative '../config_con_var.rb'
load ThisDir+'/lib/scanner/arp_scan_ip.rb'

new_process({
	title: "arp_scan_ip",
	vars: {
		IP: ["192.168.1.1/24", "要扫描的IP地址段或地址(点分十进制)"],
		REDO_TIME: [1, "重复执行dispatch的次数（适当增加该值以提高捕获率）"],
		INTERVAL: [1, "每次执行dispatch的时间间隔"],
		TIMEOUT: [5, "dispatch的timeout选项"],
	},
}) do |vars|
	puts(color_green("请输入想扫描的网址或网段"))
	ip_range = ip_str_to_range(vars[:IP])
	ARPP.scan_ip(
		$pcap,
		vars.merge({
			IP: ip_range
		})
	)
end