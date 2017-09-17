sp = TCPP.syn_pac#{|sp1| sp1.app_data="hello"}
$ap = nil
# $i = 0
TCPP.send_syn($pcap,sp){|p1|
	p $ap = TCPP.ack_for_pac(p1, sp){|p2|
		# p p2.tcph.seq_num = p1.tcph.ack_num_decimal+10
		# $i += 1
		# p2.ipv4h.flags = "001"
		# p2.ipv4h.frag_offset = 1000
	}
	# p 1234
	$pcap.send_packet($ap)
	p $ap.tcph.seq_num_decimal,p1.tcph.seq_num_decimal,$ap.tcph.ack_num_decimal
	break
}

# $ap = TCPP.pac_from_pac($ap){|p1|
# 	p1.set_app_data "blabla"
# }
	# p1.tcph.seq_num  = p1.tcph.seq_num_decimal
# 	p1.tcph.control_flag = "00001000"