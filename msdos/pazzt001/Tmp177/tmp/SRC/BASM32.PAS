unit BASM32;
{ Here are some constants I use to get at 32-bit assembler.
  It's not that simple - so make sure your code actually does
  what you wanted it to. The easiest is to use Turbo Debug, to check the
  assembler it generates from the opcodes you specified. In fact, I beleive
  that it is MUCH easier to make use of TASM assembled EXTERNAL routines.
  But it a lot quicker this way, once you got the hang of it.

  If anybody can do this in a better way, I will bestow on him/her
  the Pascal Programming Prize...

  Note: The order in which each constant is used, is definitly important.
    ...again, see the examples.

  (By Harry Marx.)
}

INTERFACE
const
   USE32       =$66;
   GSEG        =$65;
   INDEX32     =$67;

   _read       =$8B;  {like in MOV reg, mem }
   _write      =$89;  {        MOV mem, reg }
   _add2reg    =$03;  {        ADD reg, mem }
   _add2mem    =$01;  {        ADD mem, reg }
   _sub2reg    =$2B;  {        SUB reg, mem }
   _sub2mem    =$29;  {        SUB mem, reg }

   _AX         =$00;
   _BX         =$18;
   _CX         =$08;
   _DX         =$10;

   _iBX        =$03;
   _iDI        =$07;
   _iSI        =$06;

   _byte       =$40;
   _dword      =$80;

   _pair       =$04;
   iBX_iDI     =$3B;
   iBX_iSI     =$33;
(*
Key used:
::= means: "is defined as"                                                  .
Anything in "[]" is optional.                                               .
Anything in {posible1 / posible2 ...} lists the posible values. Use only one.
                                                                            .
Useage:                                                                     .
-------                                                                     .
statement1::=                                                               .
   db [Use32,] [GSeg,] [Index32,] COMMAND, REG + INDEX                      .
                                                                            .
statement2::=                                                               .
   db [Use32,] [GSeg,] [Index32,] COMMAND, REG + INDEX + _byte, $00         .
                                                                            .
statement3::=                                                               .
   db [Use32,] [GSeg,] [Index32,] COMMAND, REG + INDEX + _dword             .
   dd $00000000                                                             .
                                                                            .
statement4::=                                                               .
   db [Use32,] [GSeg,] [Index32,] COMMAND, REG + _pair, PAIR                .
                                                                            .
   COMMAND  ::= {_read / _write /_add2reg / _add2mem /_sub2reg / _sub2mem } .
                                                                            .
   REG      ::= {_AX / _BX / _CX / _DX }                                    .
                                                                            .
   INDEX    ::= {_EBX / _EDI / _ESI }                                       .
                                                                            .
   PAIR     ::= { EBX_EDI / EBX_ESI }                                       .
                                                                            .
   $00      ::= a byte                                                      .
   $00000000::= a 32-bit unsigned offset                                    .
                                                                            .
Examples:
--------- *)
IMPLEMENTATION
procedure Example;{!!!!Don't call this procedure - it's only an example!!!!}
   var
      X:longint;{ A physical address returned by LockXMS,
                  or computed using AbsAddr }
   begin
     asm
         {Wanted:  mov EDI, X }
      db USE32; mov DI, word ptr X  {Note: A lot of instructions can be
            extended this way to be 32bit}

         {Wanted:  add EDI, 10000h }
      db USE32; add DI,0000h; dw 0001h

         {Wanted:  mov AX, GS:[EDI] }
      db GSEG, INDEX32, _read, _AX + _iDI

         {Wanted:  mov EAX, GS:[EDI] }
      db USE32, GSEG, INDEX32, _read, _AX + _iDI

         {Wanted:  mov GS:[EDI], BX }
      db GSEG, INDEX32, _write, _iDI + _BX

         {Wanted:  add EAX, GS:[EBX+$100] }
      db USE32, GSEG, INDEX32, _add2reg, _AX + _iBX + _dword; dd $00000100

         {Wanted:  add GS:[EBX+EDI+2],CX }
      db GSEG, INDEX32, _add2mem, _CX + _pair + _byte, iBX_iDI, $02
     end;
   end;
end.


