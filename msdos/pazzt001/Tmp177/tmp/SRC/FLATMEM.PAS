unit FlatMem;
{
 This is a pascal interface to assembler code in FLATMEM.ASM, and
 also contains some code to access XMS in a simpler way than ASM.
 It provides some fast'ish code to read and write the simple data
 types to and from XMS.
 A generic routine, W/DMove, is provided for moving data between XMS
 and DOS. WMove routine moves 16-bits at a time.
 DMove moves it 32-bits at a time.
 Data blocks to be moved may overlap.

 Reading to and from XMS always moves 16 or 32 bits. A single byte
 cannot be transfered without making provision for this. PutByte first
 reads the word at the destination, writes the byte to this word, and
 then write the word to XMS. Needles to say, word-align your data for
 quicker code, and use a word rather than a byte.

 SetStr and GetStr also works at 32-bits per move. The odd
 1 to 3 bytes in PutStr is done as 16-bit transfers.
 A string tipically is allocated more space than it uses - assume nothing
 about this extra space. It is not moved with the data.

 Most of these routines are as effecient as pascal and my knowledge
 allowed me to make them. If however you can do better, please send
 me the result, I would be very grateful, and wiser.
}

INTERFACE
uses BASM32;

   procedure SetGSto4G;
   {Sets the segment register GS, to a descriptor with
    base address at 00000h and Limit/Length = 4G
    Although this procedure is called during initialization,
    and therefore need not be called again, it is provided
    in the interface for when GS ever get trashed.}

   function  getbyte(Ofs:longint):byte;
      INLINE (Use32/$5E/                        {pop ESI}
              GSeg/Index32/_read/_AX+_iSI);   {mov ax, gs:[esi]}

   procedure putbyte(Ofs:longint;b:byte);
      INLINE ($58/                            {pop AX}
              Use32/$5E/                        {pop ESI}
              GSeg/Index32/_read/_DX+_iSI/    {mov dx, gs:[esi]}
              $8A/$E6/                        {mov ah,al}
              GSeg/Index32/_write/_AX+_iSI);  {mov gs:[esi],ax}

   function  getword(Ofs:longint):word;
      INLINE (Use32/$5E/                        {pop ESI}
              GSeg/Index32/_read/_AX+_iSI);   {mov ax, gs:[esi]}

   procedure putword(Ofs:longint;b:word);
      INLINE ($58/                            {pop AX}
              Use32/$5E/                        {pop ESI}
              GSeg/Index32/_write/_AX+_iSI);  {mov gs:[esi],ax}

   function  getint(Ofs:longint):integer;
      INLINE (Use32/$5E/                        {pop ESI}
              GSeg/Index32/_read/_AX+_iSI);   {mov ax, gs:[esi]}

   procedure putint(Ofs:longint;b:integer);
      INLINE ($58/                            {pop AX}
              Use32/$5E/                        {pop ESI}
              GSeg/Index32/_write/_AX+_iSI);  {mov gs:[esi],ax}

   function getlong(Ofs:longint):longint;
      INLINE (Use32/$5E/                            {pop ESI}
              Use32/GSeg/Index32/_read/_AX+_iSI/  {mov eax, gs:[esi]}
              Use32/$0F/$A4/$C2/$10);               {shld EDX,EAX,16}

   procedure putlong(Ofs:longint;b:longint);
      INLINE (Use32/$58/                              {pop EAX}
              Use32/$5E/                              {pop ESI}
              USE32/GSeg/Index32/_write/_AX+_iSI);  {mov gs:[esi],eax}

   function getptr(Ofs:longint):pointer;
      INLINE (Use32/$5E/                              {pop ESI}
              USE32/GSeg/Index32/_read/_AX+_iSI/    {mov eax, gs:[esi]}
              Use32/$0F/$A4/$C2/$10);                 {shld EDX,EAX,16}

   procedure putptr(Ofs:longint;b:pointer);
      INLINE (Use32/$58/                              {pop EAX}
              Use32/$5E/                              {pop ESI}
              USE32/GSeg/Index32/_write/_AX+_iSI);  {mov gs:[esi],eax}

   function getreal(Ofs:longint):real;
      INLINE (Use32/$5E/                                 {pop ESI}
              GSeg/Index32/_read/_AX+_iSI/             {mov ax, gs:[esi]}
              GSeg/Index32/_read/_BX+_iSI+_byte/02/    {mov bx, gs:[esi+2]}
              GSeg/Index32/_read/_DX+_iSI+_byte/04);   {mov dx, gs:[esi+4]}

   procedure putreal(Ofs:longint;b:real);
      INLINE (Use32/$58/                                {pop EAX}
              $5A/                                    {pop DX}
              Use32/$5E/                                {pop ESI}
              USE32/GSeg/Index32/_write/_AX+_iSI/     {mov gs:[esi],eax}
              GSeg/Index32/_write/_DX+_iSI+_byte/04); {mov gs:[esi+4],dx}

{$IFDEF CPU87}  {only if compile for FPU }
   function getext(Ofs:longint):extended;
      INLINE (Use32/$5E/   {pop ESI}
              $65/$67/$DB/$2E); { fld tbyte ptr GS:[ESI] }

   procedure putext(Ofs:longint;b:extended);
      INLINE ($8B/$DC/              { mov bx,sp }
              $36/$DB/$2F/          { fld tbyte ptr ss:[bx] }
              $66/$36/$8B/$77/$0A/  { mov ESI,ss:[bx+$0A]       }
              $65/$67/$DB/$3E/      { fstp tbyte ptr GS:[ESI] }
              $83/$C4/$0E);         { add SP,0E }
{$ENDIF}

   function  getstr(Source:longint):string;

   procedure putstr(S:string;Dest:longint);

   function  absaddr(X:pointer):longint;    { 13 cycles...}
      INLINE ($66/$58/                      { pop  EAX :4}
              $66/$0F/$A4/$C2/$14/          { shld EDX,EAX,20 :2}
              $66/$81/$E2/$F0/$FF/$0F/$00/  { and  EDX,$000FFFF0 :2}
              $66/$25/$FF/$FF/$00/$00/      { and  EAX,$0000FFFF :2}
              $66/$03/$C2/                  { add  EAX,EDX :1}
              $66/$0F/$A4/$C2/$10);         { shld EDX,EAX,16 :2}

   procedure wmove(Source,Dest,Len:longint);
   procedure dmove(Source,Dest,Len:longint);

IMPLEMENTATION

{$L FLATMEM.OBJ}

{$F+}
   function  InitFlatMem:boolean;EXTERNAL;
{This is a private procedure which sets up the Local Descriptor Table}

   procedure SetGSto4G;EXTERNAL;
{$F-}

procedure wmove(Source,Dest,Len:longint);assembler;
   asm
      db USE32; mov SI,word ptr Source
      db USE32; mov DI,word ptr Dest
      db USE32; mov CX,word ptr Len
      db USE32; inc CX {to round up CX to nearest even}
      db USE32; cmp SI,DI
      jl @fromtop
      db USE32; shr CX,1
      @A:
         db GSeg,Index32,_read, _AX +_iSI
         db GSeg,Index32,_write,_iDI +_AX
         db USE32; add SI,2
         db USE32; add DI,2
      db USE32; loop @A
      jmp @end
      @fromtop:
         db USE32; add SI,CX
         db USE32; add DI,CX
         db USE32; shr CX,1
         @B:
            db USE32; sub SI,2
            db USE32; sub DI,2
            db GSeg, Index32, _read, _AX +_iSI
            db GSeg, Index32, _write,_iDI+_AX
         db USE32; loop @B
      @end:
   end;

procedure dmove(Source,Dest,Len:longint);assembler;
   asm
      db USE32; mov SI,word ptr Source
      db USE32; mov DI,word ptr Dest
      db USE32; mov CX,word ptr Len
      db USE32; add CX,3 {to round up CX to nearest 4}
      db USE32; cmp SI,DI
      jl @fromtop
      db USE32; shr CX,2
      @A:
         db USE32, GSeg, Index32, _read, _AX +_iSI
         db USE32, GSeg, Index32, _write,_iDI +_AX
         db USE32; add SI,4
         db USE32; add DI,4
      db USE32; loop @A
      jmp @end
      @fromtop:
         db USE32; add SI,CX
         db USE32; add DI,CX
         db USE32; shr CX,2
         @B:
            db USE32; sub SI,4
            db USE32; sub DI,4
            db USE32, GSeg, Index32, _read, _AX +_iSI
            db USE32, GSeg, Index32, _write,_iDI+_AX
         db USE32; loop @B
      @end:
   end;

function getstr(Source:longint):string;assembler;
   asm
      les di,@result
      db USE32; mov si,word ptr Source
      db GSEG, INDEX32, _read, _AX+_iSI
      mov cl,al
      xor ch,ch
      inc cx
      @A:
         db USE32, GSEG, INDEX32, _read, _AX+_iSI
         db USE32; mov es:[di],ax
         add di,4
         db USE32; add si,4
         sub cx,4
      jg @A
   end;

procedure putstr(S:string;Dest:longint);assembler;
   asm
      db USE32; mov SI,word ptr Dest
      les di,S
      mov AX,es:[di]
      db GSEG, INDEX32, _write, _iSI+_AX {length byte}
      mov cl,al
      xor ch,ch
      mov dx,cx
      shr cx,2
      jz @MoveTail
      @DoDWords:
         db USE32; mov AX,es:[di]
         db USE32, GSEG, INDEX32, _write, _iSI+_AX
         add DI,4
         db USE32; add SI,4
      loop @DoDWords
      @MoveTail:  {This way uneven length strings trash only one byte}
      mov cx,dx
      and cx,3
      jz @done
      @DoBytes:
         mov AX,es:[di]
         db GSEG, INDEX32, _write, _iSI+_AX
         add DI,2
         db USE32; add SI,2
         sub cx,2
      jg @DoBytes
      @Done:
   end;

{Initialization}
begin
   if not InitFlatMem then begin
      writeln('Error: FlatMem could not initialize.');
      writeln('This is beacuase the CPU are in a V86 mode.');
      writeln('To use this program, boot with ONLY himem.sys,');
      writeln('and no additional memory managers (EMM386, QEMM, Windows)');
      Halt;
   end;
   SetGSto4G;
end.

