#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "options.h"
#include "ultrdat.h"
#include "gamebkg.h"
#include "psgsound.h"
#include "language.h"
#include "battle.h"

void btl_stone_enm_pieces(plf)
playfield *plf;
{
	playfield *enm;
	register uint i,j,k;

	enm = (playfield *)(plf->enemy);

	for(k = 0; k != 2; k++){
		for(i = 0; i != 4; i++){
			for(j = 0; j != 4; j++){
				if(enm->piece_preview[k][i][j]){
					enm->piece_preview[k][i][j] = _BLK_SOLID;
				}
			}
		}
	}
}
