/****************************************************************************/
/** Serial Communication Routines for Vision-8 GB                          **/
/** by Haroldo de Oliveira Pinheiro                                        **/
/****************************************************************************/

#include <gb.h>
#include <string.h>
#include "chip8.h"
#include "comm.h"

extern char prog_names[7][12];
extern UBYTE chip8_key_conf[8];

static UBYTE comm_counter;
/*static*/ UBYTE comm_status;
static UBYTE comm_end;
static unsigned char comm_buffer[64],temp_buffer[127];

#define _CS_NOTCON 0
#define _CS_SEND   1
#define _CS_RECV   2

#define _ASC_STX   2
#define _ASC_ETX   3
#define _ASC_EOT   4
#define _ASC_ENQ   5
#define _ASC_ACK   6
#define _ASC_NAK   21

/*static*/ void comm_vbl(){
   if(comm_counter){
      comm_counter--;
   }
}

static UWORD checksum;

void init_checksum(){
   checksum = 0x5555;
}

UWORD calc_checksum(UBYTE n){
   if((checksum & 0x8000UL) != 0UL){
      checksum <<= 1;
      checksum |= 0x0001UL;
   }else{
      checksum <<= 1;
   }
   checksum += (UWORD)n;
   return checksum;
}

void init_comm(){
  add_VBL(comm_vbl);
  comm_status = _CS_NOTCON;
}

void negotiate_connect(){
  comm_status = _CS_NOTCON;
  while(1){
     _io_in = 0x00;
     _io_out = 0x80;
     send_byte();
     /* Wait for IO completion... */
     while(_io_status == IO_SENDING);
     if(_io_status == IO_IDLE){
        comm_status = _CS_SEND;
        break;
     }else{
     }
     receive_byte();
     /* Wait for IO completion... */
     comm_counter = 0x10+(rand()&0x0F);
     while((_io_status == IO_RECEIVING) && comm_counter && !(joypad() & 0x3C));
     if(_io_status == IO_IDLE){
        comm_status = _CS_RECV;
        break;
     }else{
     }
  }
  comm_end = TRUE;
}

void close_connect(){
   while(comm_status != _CS_SEND){
      check_io_requests();
   }
   send_package(_PKG_CLOSECON,0,0L,comm_buffer);
   comm_status = _CS_NOTCON;
}

UBYTE request_for_sending(){
   _io_in = 0x00;
   comm_counter = 0x10;
   while((_io_in != _ASC_ACK)&&comm_counter){
      _io_in = 0x00;
      _io_out = _ASC_ENQ;
      send_byte();
      while((_io_status == IO_SENDING)&&comm_counter);
      if(_io_status == IO_IDLE){
         receive_byte();
         /* Wait for IO completion... */
         comm_counter = 0x10+(rand()&0x0F);
         while((_io_status == IO_RECEIVING) && comm_counter);
      }
   }
   return (comm_counter != 0);
}

UBYTE wait_package_confirmation(){
   comm_counter = 0x10;
   while(comm_counter){
      receive_byte();
      /* Wait for IO completion... */
      while((_io_status == IO_RECEIVING) && comm_counter);
      if(_io_status == IO_IDLE){
         if(_io_in == _ASC_ACK){
            return TRUE;
         }else if(_io_in == _ASC_NAK){
            return FALSE;
         }
      }
   }
   return FALSE;
}

UBYTE send_package(UBYTE kind, UBYTE len, UWORD ofs, unsigned char *data){
   UBYTE i, ok, retries;
   fixed *fix;

   while(comm_status != _CS_SEND){
      check_io_requests();
   }

   ok = FALSE;
   retries = 0;
   while(!ok){
      if(!request_for_sending()) continue;

      comm_counter = 0x40;

      init_checksum();

      _io_out = kind;
      do{
         send_byte();
         while(_io_status == IO_SENDING);
      }while((_io_status != IO_IDLE)&&comm_counter);
      calc_checksum(kind);
   
      _io_out = len;
      do{
         send_byte();
         while(_io_status == IO_SENDING);
      }while((_io_status != IO_IDLE)&&comm_counter);
      calc_checksum(len);

      fix = (fixed *)&ofs;
      _io_out = fix->b.l;
      do{
         send_byte();
         while(_io_status == IO_SENDING);
      }while((_io_status != IO_IDLE)&&comm_counter);
      calc_checksum(fix->b.l);

      _io_out = fix->b.h;
      do{
         send_byte();
         while(_io_status == IO_SENDING);
      }while((_io_status != IO_IDLE)&&comm_counter);
      calc_checksum(fix->b.h);

      for(i = 0; i != len; i++){
         _io_out = *data;
         do{
            send_byte();
            while(_io_status == IO_SENDING);
         }while((_io_status != IO_IDLE)&&comm_counter);
         calc_checksum(*data);
         data++;
      }

      fix = (fixed *)&checksum;
      _io_out = fix->b.l;
      do{
         send_byte();
         while(_io_status == IO_SENDING);
      }while((_io_status != IO_IDLE)&&comm_counter);

      _io_out = fix->b.h;
      do{
         send_byte();
         while(_io_status == IO_SENDING);
      }while((_io_status != IO_IDLE)&&comm_counter);

      ok = wait_package_confirmation();

      if(!ok){
         retries++;
         if(retries > 5){
            return FALSE;
         }
      }
   }

   return TRUE;
}

UBYTE receive_package(UBYTE *kind, UBYTE *len, UWORD *ofs, unsigned char *data){
   UBYTE i, ok, retries;
   fixed *fix;
   UWORD chk;

   ok = FALSE;
   retries = 0;
   while(!ok){
      comm_counter = 0x40;

      init_checksum();

      receive_byte();
      while((_io_status == IO_RECEIVING)&&comm_counter);
      *kind = _io_in;
      calc_checksum(_io_in);
   
      receive_byte();
      while((_io_status == IO_RECEIVING)&&comm_counter);
      *len = _io_in;
      calc_checksum(_io_in);

      fix = (fixed *)ofs;
      receive_byte();
      while((_io_status == IO_RECEIVING)&&comm_counter);
      fix->b.l = _io_in;
      calc_checksum(_io_in);

      receive_byte();
      while((_io_status == IO_RECEIVING)&&comm_counter);
      fix->b.h = _io_in;
      calc_checksum(_io_in);

      for(i = 0; i != *len; i++){
         receive_byte();
         while((_io_status == IO_RECEIVING)&&comm_counter);
         *data = _io_in;
         calc_checksum(_io_in);
         data++;
      }

      fix = (fixed *)&chk;
      receive_byte();
      while((_io_status == IO_RECEIVING)&&comm_counter);
      fix->b.l = _io_in;

      receive_byte();
      while((_io_status == IO_RECEIVING)&&comm_counter);
      fix->b.h = _io_in;

      if(comm_counter&&(checksum == chk)){
         ok = TRUE;
      }else{
         _io_in = 0x00;
         _io_out = _ASC_NAK;
         send_byte();
         while(_io_status == IO_SENDING);
         retries++;
         if(retries > 5){
            return FALSE;
         }
      }
   }
   while(_io_status != IO_IDLE);
   _io_in = 0x00;
   _io_out = _ASC_ACK;
   send_byte();
   while(_io_status == IO_SENDING);

   return TRUE;
}

void upload_program(UWORD size){
   unsigned char *p;
   UWORD ofs;

   p = (unsigned char *)(chip8_mem[0]+0x200);
   ofs = 0UL;

   while(ofs < size){
      send_package(_PKG_SEND_PROG,64,ofs,p);
      p+=64UL;
      ofs+=64UL;
   }

   memcpy(comm_buffer,&size,2L);
   send_package(_PKG_END,2,size,comm_buffer);
}

void check_io_requests(){
   UBYTE kind, len;
   UWORD ofs, size;

   if(comm_status == _CS_NOTCON) return;

   if(comm_status == _CS_RECV){
      receive_byte();
      /* Wait for IO completion... */
      comm_counter = 0x10+(rand()&0x0F);
      while((_io_status == IO_RECEIVING) && comm_counter && !joypad());
      if(_io_status == IO_IDLE){
         if(_io_in == _ASC_ENQ){
            _io_in = 0x00;
            _io_out = _ASC_ACK;
            send_byte();
            while(_io_status == IO_SENDING);

            if(receive_package(&kind,&len,&ofs,comm_buffer)){
               switch(kind){
                  case _PKG_SWITCH:
                     wait_vbl_done();
                     comm_status = _CS_SEND;
                  break;
                  case _PKG_REQ_PROG:
                     wait_vbl_done();
                     comm_status = _CS_SEND;
                     load_chip8_prog((UBYTE)ofs);
                     get_chip8_progsize((UBYTE)ofs,&size);
                     upload_program(size);
                  break;
                  case _PKG_SEND_PROG:
                     ofs+=0x0200UL;
                     memcpy(chip8_mem[0]+ofs,comm_buffer,(UWORD)len);
                  break;
                  case _PKG_REQ_KEYCONF:
                     wait_vbl_done();
                     comm_status = _CS_SEND;
                     memcpy(temp_buffer,chip8_key_conf,sizeof(chip8_key_conf));
                     load_save_chip8_keys((UBYTE)ofs,FALSE);
                     send_package(_PKG_SEND_KEYCONF,sizeof(chip8_key_conf),0L,(unsigned char *)chip8_key_conf);
                     send_package(_PKG_END,0,0L,comm_buffer);
                     memcpy(chip8_key_conf,temp_buffer,sizeof(chip8_key_conf));
                  break;
                  case _PKG_SEND_KEYCONF:
                     memcpy(chip8_key_conf,comm_buffer,(UWORD)len);
                  break;
                  case _PKG_REQ_LIST:
                     wait_vbl_done();
                     comm_status = _CS_SEND;
                     memcpy(temp_buffer,prog_names[0],96UL);
                     preload_headers();
                     send_package(_PKG_SEND_LIST,48,0L,(unsigned char *)prog_names[0]);
                     send_package(_PKG_SEND_LIST,48,4L,(unsigned char *)prog_names[4]);
                     send_package(_PKG_END,0,0L,comm_buffer);
                     memcpy(prog_names[0],temp_buffer,96UL);
                  break;
                  case _PKG_SEND_LIST:
                     memcpy(prog_names[ofs],comm_buffer,(UWORD)len);
                  break;
                  case _PKG_END:
                     comm_end = TRUE;
                  break;
				  case _PKG_CLOSECON:
                     comm_status = _CS_NOTCON;
                  break;
               }
            }else{
            }
         }
      }
   }else if(comm_status == _CS_SEND){
      if(!(rand()&0x3F)){
         send_package(_PKG_SWITCH,0,0L,comm_buffer);
         comm_status = _CS_RECV;
      }
   }
}

void request_remote_list(){
   comm_end = FALSE;
   send_package(_PKG_REQ_LIST,0,0L,comm_buffer);
   comm_status = _CS_RECV;
   while(!comm_end){
      check_io_requests();
   }
}

void request_remote_program(UBYTE num, UWORD *size){
   comm_end = FALSE;
   send_package(_PKG_REQ_PROG,0,(UWORD)num,comm_buffer);
   comm_status = _CS_RECV;
   while(!comm_end){
      check_io_requests();
   }
   memcpy(size,comm_buffer,2L);

   comm_end = FALSE;
   send_package(_PKG_REQ_KEYCONF,0,(UWORD)num,comm_buffer);
   comm_status = _CS_RECV;
   while(!comm_end){
      check_io_requests();
   }
}
