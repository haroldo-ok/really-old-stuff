all-after:
	copy rdt_sms.sms stub.sms
	map2sym rdt_sms.map rdt_sms.sym
	tools\applygfs rdt_sms.sms 32768 data.mfs
