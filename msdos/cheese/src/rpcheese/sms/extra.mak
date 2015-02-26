all-after:
	copy rprun.sms stub.sms
	map2sym rprun.map rprun.sym
	tools\applygfs rprun.sms 32768 data.mfs
