#include "genesis.h"
#include "utils.h"
#include "interr.h"

uint frame_ctrl;

void init_interr(){
}

void poll_interr(){
	frame_ctrl++;
}
