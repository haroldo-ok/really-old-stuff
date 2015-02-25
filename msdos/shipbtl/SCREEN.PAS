unit Screen;
interface
	type
		ScreenBuffer=array[0..193,0..255] of byte;
	var ScrBuf:^ScreenBuffer;
	procedure InitScreen;
	procedure DoneScreen;
	procedure ClearBuffer;
	procedure Buffer2Screen;
implementation
	var ScrPtr:pointer;
	procedure InitScreen;
		begin
			asm
				mov ax, 13h;
				int 10h;
			end;
			GetMem(ScrPtr,SizeOf(ScreenBuffer)+16);
			ScrBuf:=Ptr(Seg(ScrPtr^)+1,0);
		end;
	procedure DoneScreen;
		begin
			FreeMem(ScrPtr,SizeOf(ScreenBuffer)+16);
			asm
				mov ax, 3;
				int 10h;
			end;
		end;
	procedure ClearBuffer;
		const LoopCount= SizeOf(ScreenBuffer) div 4;
		var BufSeg:word;
		begin
			BufSeg:=Seg(ScrBuf^);
			asm
				mov es, BufSeg;
				xor di,di;
				db $66;xor ax,ax;{xor eax, eax}
				cld;
				mov cx, LoopCount;
				db $66;rep stosw;{rep stosd}
			end;
		end;
	procedure Buffer2Screen;
		const
			BufX=3;
			BufY=3;
			BufStart=(BufY*320)+BufX;
			BufInc=320-256;
			BufLines=193;
		var BufSeg:word;
		begin
			BufSeg:=Seg(ScrBuf^);
			asm
				push ds;
				mov ds, BufSeg;
				xor si,si;
				mov ax, 0A000h;
				mov es, ax;
				mov ax, BufStart;
				mov di, ax;
				cld;
				mov cx, BufLines;
			  @lineloop:
				mov bx, cx;
				mov cx, 64;
				db $66;rep movsw;{rep movsd}
				add di, BufInc;
				mov cx, bx;
				loop @lineloop;
				pop ds;
			end;
		end;
End.