#ifndef __INC_Z80__
#define __INC_Z80__ 1

#define MVST_FM		unsigned char *
#define MVST_DAC	unsigned char *
#define MVST_PSG	unsigned char *



void Z80_LoadDriver( );
void Z80_Pause( );
void Z80_Release( );

void Z80_PlayFM( MVST_FM *Music );
void Z80_TempoFM( char newTempo );
void Z80_StopFM( );

void Z80_PlayDAC( MVST_DAC *Sound, unsigned short size );
void Z80_StopDAC( );

void Z80_PlayPSG( MVST_PSG *Sound );
void Z80_EnablePSG( char chan );
void Z80_DisablePSG( char chan );
void Z80_StopPSG( );


#endif
