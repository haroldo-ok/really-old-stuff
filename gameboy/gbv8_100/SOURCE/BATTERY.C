/****************************************************************************/
/** Battery-Backed RAM Routines for Vision-8 GB                            **/
/** by Haroldo de Oliveira Pinheiro                                        **/
/****************************************************************************/

#include "CHIP8.h"

#include <gb.h>
#include <string.h>
#include <drawing.h>

#define MBC1_MODE(b) \
  *(unsigned char *)0x6000 = (b)

typedef struct _prog_header{
   char name[12];
   UWORD size;
   UWORD filler1;
   UBYTE key_conf[8];
}prog_header;

typedef struct _system_header{
   char signature[16];
   UBYTE filler[8];
   UBYTE bkg_num;
}system_header;

char *signature = "Vision-8 GB";

char prog_names[7][12];
UBYTE background_number;

int check_signature(){
   UBYTE i;

   MBC1_MODE(1);
   SWITCH_RAM_MBC1(0);
   ENABLE_RAM_MBC1;
   i = strcmp(signature,(char *)0xA000U);
   DISABLE_RAM_MBC1;

   return !i;
}

void preload_headers(){
   UBYTE i;
   char *phead;

   MBC1_MODE(1);
   SWITCH_RAM_MBC1(0);

   phead = (char *)0xA000U+128UL;
   for(i = 0; i != 7; i++){
      ENABLE_RAM_MBC1;
      strcpy(prog_names[i],((prog_header *)phead)->name);
      DISABLE_RAM_MBC1;
      phead +=128;
   }
}

void load_save_sysconf(UBYTE save){
   UBYTE i;
   system_header *phead;

   MBC1_MODE(1);
   SWITCH_RAM_MBC1(0);

   phead = (system_header *)0xA000U;

   if(save){
      ENABLE_RAM_MBC1;
      phead->bkg_num = background_number;
      DISABLE_RAM_MBC1;
   }else{
      ENABLE_RAM_MBC1;
      background_number = phead->bkg_num;
      DISABLE_RAM_MBC1;
   }
}

extern UBYTE chip8_key_conf[8];

void load_save_chip8_keys(UBYTE num, UBYTE save){
   UBYTE i;
   char *phead;
   prog_header *proghead;

   MBC1_MODE(1);
   SWITCH_RAM_MBC1(0);

   phead = (char *)0xA000U;
   for(i = 0; i != num; i++){
      phead +=128;
   }

   ENABLE_RAM_MBC1;
   proghead = (prog_header *)phead;
   if(save){
      memcpy(proghead->key_conf,chip8_key_conf,8UL);
   }else{
      memcpy(chip8_key_conf,proghead->key_conf,8UL);
   }
   DISABLE_RAM_MBC1;
}

void save_chip8_name(UBYTE num, char *name){
   char *phead;

   MBC1_MODE(1);
   SWITCH_RAM_MBC1(0);

   phead = (char *)0xA000U+128UL;
   num--;
   while(num){
      phead+=128;
      num--;
   }

   ENABLE_RAM_MBC1;
   strcpy(((prog_header *)phead)->name,name);
   DISABLE_RAM_MBC1;
}

void load_chip8_prog(UBYTE num){
   UWORD addr;

   MBC1_MODE(1);
   SWITCH_RAM_MBC1(num >> 1);

   addr = 0L;
   if(num&0x01){
      addr = 4096; 
   }
   addr += 0xA000U;

   ENABLE_RAM_MBC1;
   memcpy(chip8_mem[0]+0x200,(void *)addr,(4096-0x200));
   DISABLE_RAM_MBC1;

   load_save_chip8_keys(num,FALSE);
}

void get_chip8_progsize(UBYTE num, UWORD *size){
   char *phead;

   MBC1_MODE(1);
   SWITCH_RAM_MBC1(0);

   phead = (char *)0xA000U+128UL;
   num--;
   while(num){
      phead+=128;
      num--;
   }

   ENABLE_RAM_MBC1;
   *size = ((prog_header *)phead)->size;
   DISABLE_RAM_MBC1;
}

void save_chip8_progsize(UBYTE num, UWORD size){
   char *phead;

   MBC1_MODE(1);
   SWITCH_RAM_MBC1(0);

   phead = (char *)0xA000U+128UL;
   num--;
   while(num){
      phead+=128;
      num--;
   }

   ENABLE_RAM_MBC1;
   ((prog_header *)phead)->size = size;
   DISABLE_RAM_MBC1;
}

void save_chip8_prog(UBYTE num, UWORD size, char *name){
   UWORD addr;
   char *phead;

   MBC1_MODE(1);
   SWITCH_RAM_MBC1(num >> 1);

   addr = 0L;
   if(num&0x01){
      addr = 4096; 
   }
   addr += 0xA000U;

   ENABLE_RAM_MBC1;
   memcpy((void *)addr,chip8_mem[0]+0x200,(4096-0x200));
   DISABLE_RAM_MBC1;

   load_save_chip8_keys(num,TRUE);
   save_chip8_progsize(num,size);
   save_chip8_name(num,name);
}
