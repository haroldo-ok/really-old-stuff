unit RotateDraw;
interface
	const
		Num64x64Tiles=2;
		Num16x16Tiles=8;
		YRatio1:real=200/240;
		YRatio2:real=240/200;
		MultFactor=$7F;
	type
		Pix64=array[0..63,0..63] of byte;
		Pix64Buffer=array[0..Pred(Num64x64Tiles)] of Pix64;
		Pix16=array[0..15,0..15] of byte;
		Pix16Buffer=array[0..Pred(Num16x16Tiles)] of Pix16;
	var Pic64:^Pix64Buffer;
		Pic16:^Pix16Buffer;
	procedure InitRotationEngine;
	procedure DoneRotationEngine;
	procedure LoadPix(Num:byte;FileName:string);
	procedure LoadPix16(Num:byte;FileName:string);
	procedure RotPix(X,Y,Rot:byte;Zoom:real;PixNum:byte);
	procedure RotPix16(X,Y,Rot:byte;Zoom:real;PixNum:byte);
implementation
	uses X_BitMap,X_FileIO,Screen;
	var PixPtr1,PixPtr2:pointer;
	procedure InitRotationEngine;
		begin
			GetMem(PixPtr1,SizeOf(Pix64Buffer)+16);
			Pic64:=Ptr(Seg(PixPtr1^)+1,0);
			GetMem(PixPtr2,SizeOf(Pix16Buffer)+16);
			Pic16:=Ptr(Seg(PixPtr2^)+1,0);
		end;
	procedure DoneRotationEngine;
		begin
			FreeMem(PixPtr1,SizeOf(Pix64Buffer)+16);
			FreeMem(PixPtr2,SizeOf(Pix64Buffer)+16);
		end;
	procedure LoadPix(Num:byte;FileName:string);
		var Buf:record
					X,Y:byte;
					Pic:array[0..8192] of byte;
				end;
			i,j:byte;
		begin
			X_Load_PCX_as_LBM(FileName,Buf);
			for i:=0 to 63 do
				for j:=0 to 63 do
					Pic64^[Num][i,j]:=Buf.Pic[(i*Buf.X)+j];
			for i:=0 to 63 do
				Pic64^[Num][63,i]:=0;
		end;
	procedure LoadPix16(Num:byte;FileName:string);
		var Buf:record
					X,Y:byte;
					Pic:array[0..8192] of byte;
				end;
			i,j:byte;
		begin
			X_Load_PCX_as_LBM(FileName,Buf);
			for i:=0 to 15 do
				for j:=0 to 15 do
					Pic16^[Num][i,j]:=Buf.Pic[(i*Buf.X)+j];
			for i:=0 to 15 do
				Pic16^[Num][15,i]:=0;
		end;
	procedure RotPix(X,Y,Rot:byte;Zoom:real;PixNum:byte);
		var i,j:integer;
			nX,nY:word;
			iX,iY:word;
			XInc1,YInc1,XInc2,YInc2:integer;
			ScrSeg,PixSeg:word;
		begin
			ScrSeg:=Seg(ScrBuf^);
			PixSeg:=Seg(Pic64^)+(PixNum*(64*64 div 16));
			XInc1:=Round(Zoom*MultFactor*Cos(PI*Rot/128));
			YInc1:=Round(Zoom*MultFactor*YRatio1*Sin(PI*Rot/128));
			XInc2:=Round(-Zoom*MultFactor*YRatio2*Sin(PI*Rot/128));
			YInc2:=Round(Zoom*MultFactor*Cos(PI*Rot/128));
			iX:=Word(X) shl 8;
			iY:=Word(Y) shl 8;
			Dec(iX,XInc1*64+XInc2*64);
			Dec(iY,YInc1*64+YInc2*64);
			for i:=0 to 127 do
				begin
					asm
						push ds;
						mov ds, PixSeg;
						mov si, i;
						shl si, 6;
						and si,1111110000000b;
						mov dx, iX;
						mov bx, iY;
						mov ax, XInc1;
						mov di, YInc1;
						mov es, ScrSeg;
						mov cx, 127;
					  @colloop:
						push si;
						shr si, 1;
						mov ch, ds:[si];
						pop si;
						inc si;
						xchg dh, bl;
						or  ch, ch;
						jz  @skippixel;
						mov es:[bx], ch;
					  @skippixel:
						xchg dh, bl;
						add dx, ax;
						add bx, di;
						xor ch, ch;{S¢ cl est  realmente sendo usado como contador}
						loop @colloop;
						pop ds;
					end;
					Inc(iX,XInc2);
					Inc(iY,YInc2);
				end;
		end;
	procedure RotPix16(X,Y,Rot:byte;Zoom:real;PixNum:byte);
		var i,j:integer;
			nX,nY:word;
			iX,iY:word;
			XInc1,YInc1,XInc2,YInc2:integer;
			ScrSeg,PixSeg:word;
		begin
			ScrSeg:=Seg(ScrBuf^);
			PixSeg:=Seg(Pic16^)+(PixNum*(16*16 div 16));
			XInc1:=Round(Zoom*MultFactor*Cos(PI*Rot/128));
			YInc1:=Round(Zoom*MultFactor*YRatio1*Sin(PI*Rot/128));
			XInc2:=Round(-Zoom*MultFactor*YRatio2*Sin(PI*Rot/128));
			YInc2:=Round(Zoom*MultFactor*Cos(PI*Rot/128));
			iX:=Word(X) shl 8;
			iY:=Word(Y) shl 8;
			Dec(iX,XInc1*16+XInc2*16);
			Dec(iY,YInc1*16+YInc2*16);
			for i:=0 to 31 do
				begin
					asm
						push ds;
						mov ds, PixSeg;
						mov si, i;
						shl si, 4;
						and si, 111100000b;
						mov dx, iX;
						mov bx, iY;
						mov ax, XInc1;
						mov di, YInc1;
						mov es, ScrSeg;
						mov cx, 31;
					  @colloop:
						push si;
						shr si, 1;
						mov ch, ds:[si];
						pop si;
						inc si;
						xchg dh, bl;
						or  ch, ch;
						jz  @skippixel;
						mov es:[bx], ch;
					  @skippixel:
						xchg dh, bl;
						add dx, ax;
						add bx, di;
						xor ch, ch;{S¢ cl est  realmente sendo usado como contador}
						loop @colloop;
						pop ds;
					end;
					Inc(iX,XInc2);
					Inc(iY,YInc2);
				end;
		end;
End.