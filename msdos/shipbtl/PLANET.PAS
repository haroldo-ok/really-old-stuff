program Planet;
	uses Crt,X_Const,X_Pal,Screen;
	const Radius=32;
	type
		Texel=record
				X,Y:byte;
			  end;
		ColorMapType=array[0..31,0..255] of byte;
	var Texture:array[0..63,0..127] of byte;
		Rot:byte;
		Light:array[0..2*Radius,0..2*Radius] of byte;
		TexCoord:array[0..2*Radius,0..2*Radius] of Texel;
		ColorMap:ColorMapType;
		sYTable:array[0..2*Radius] of Integer;
	procedure MakePal;
		var F:file;
			Pal:palette;
		begin
			Assign(F,'PALETTE.DAT');
			Reset(F,1);
			BlockRead(F,Pal,SizeOf(Pal));
			X_Put_Pal_Raw(Pal,256,0,false);
			Close(F);
			Assign(F,'COLORMAP.DAT');
			Reset(F,1);
			BlockRead(F,ColorMap,SizeOf(ColorMap));
			Close(F);
		end;
	function Angle(X,Y:real):real;
		var Ang:real;
		begin
			{Tan=Sin/Cos}
			if X = 0 then
				begin
					if Y < 0 then
						Ang:=-PI/2
					else
						Ang:=PI/2;
				end
			else
				begin
					Ang:=Abs(ArcTan(Y/X));
					if X < 0 then
						begin
							if Y < 0 then
								Ang:=PI+Ang
							else
								Ang:=PI-Ang;
						end
					else
						begin
							if Y < 0 then
								Ang:=-Ang
						end;
				end;
			Angle:=Ang;
		end;
	function QuarterAngle(X,Y:real):real;
		begin
			{Tan=Sin/Cos}
			if X = 0 then
				QuarterAngle:=PI/2
			else
				QuarterAngle:=Abs(ArcTan(Y/X));
		end;
	procedure PrepareSphere;
		const
			YRatio=200/240;
		var i,j,k:longint;
			X,Y:longint;
			aX,aY,aZ:real;
			Rho:real;
			sX,sY,Color:integer;
			tX,tY:integer;
		begin
			for i:=-Radius to Radius do
				for j:=-Radius to Radius do
					begin
						X:=i;
						Y:=j;
						if  Sqr(X) + Sqr(Y) <= Sqr(Radius) then
							begin
								aZ:=Sqrt(Sqr(Radius)-Sqr(X)-Sqr(Y));
								aX:=64*Angle(aZ,X)/PI;
								tX:=Round(64*(aX+Radius)/(2*Radius));
								tX:=tX and $7F;
								tY:=64*(Y+Radius) div (2*Radius);
								tY:=tY and $3F;
								TexCoord[Y+Radius,X+Radius].X:=tX;
								TexCoord[Y+Radius,X+Radius].Y:=tY;
								Light[Y+Radius,X+Radius]:=Round(31*aZ/Radius);
								sYTable[Y+Radius]:=((5*Y)+3) div 6+80;
							end
						else
							begin
								Light[Y+Radius,X+Radius]:=32;
							end;
					end;
		end;
	procedure DrawSphere;
		var i,j,k:longint;
			X,Y:integer;
			aX,aY,aZ:real;
			Rho:real;
			sX,sY,Color:integer;
			tX,tY:integer;
			ScrSeg:word;
			TexAddr:word;
		begin
			ScrSeg:=Seg(ScrBuf^);
			for i:=-Radius to Radius do
				for j:=-Radius to Radius do
					begin
						X:=i;
						Y:=j;
						if  Light[Y+Radius,X+Radius] <> 32 then
							begin
								sX:=X+128;
								sY:=sYTable[Y+Radius];
								asm
									push ds;
									{C lculo do endere‡o dos dados nas tabelas}
									mov ax, Y;
									add ax, Radius;
									mov bx, 2*Radius+1;
									mul bx;
									mov bx, X;
									add bx, Radius;
									add bx, ax;
									{Segmento e offset das tabelas de coordenadas de textura e ilumina‡Æo}
									mov ax, seg TexCoord;
									mov ds, ax;
									mov ax, offset TexCoord;
									mov si, ax;
									mov ax, seg Light;
									mov es, ax;
									mov ax, offset Light;
									mov di, ax;
									{Lˆ a tabela de ilumina‡Æo}
									mov dl, es:[di+bx];
									{Lˆ tabela de coordenadas de textura}
									shl bx, 1;
									mov bx, ds:[si+bx];
									add bl, rot;
									mov cx, bx;
									shl bl, 1;
									shr bx, 1;
									{Segmento e offset das tabelas de textura e mapa de cores}
									mov ax, seg Texture;
									mov ds, ax;
									mov ax, offset Texture;
									mov si, ax;
									mov ax, seg ColorMap;
									mov es, ax;
									mov ax, offset ColorMap;
									mov di, ax;
									{Lˆ textura}
									mov bl, ds:[si+bx];
									{Lˆ mapa de cores}
									mov bh, dl;
									mov dl, es:[di+bx];
									{Plota o pixel na tela (UUUUUUFAAAAAAAaaaa!)}
									{Planeta}
									mov ds, ScrSeg;
									mov bl, byte ptr sX;
									mov bh, byte ptr sY;
									mov ds:[bx], dl;
									{Mapa}
									and cl, $7F;
									add cl, 64;
									add ch, 120;
									mov bx, cx;
									mov ds:[bx], dl;
								  @SkipPixel:
									pop ds;
								end;
							end;
					end;
		end;
	procedure LoadTexture;
		var F:file;
			i,j,k:integer;
			W:word;
		begin
			Assign(F,'PLASMA.RAW');
			Reset(F,1);
			BlockRead(F,Texture,SizeOf(Texture));
			Close(F);
		end;
	procedure DrawFrame;
		var i:word;
		begin
			FillChar(Mem[$A000:$0000],320*200,7);
			FillChar(Mem[$A000:320*199],320,0);
			for i:=0 to 319 do
				begin
					Mem[$A000:i]:=15;
					Mem[$A000:(320*198)+i]:=8;
				end;
			for i:=0 to 256 do
				begin
					Mem[$A000:(320*2)+3+i]:=8;
					Mem[$A000:(320*196)+2+i]:=15;
				end;
			for i:=0 to 193 do
				begin
					Mem[$A000:(320*(2+i))+2]:=8;
					Mem[$A000:(320*(3+i))+256+3]:=15;
					Mem[$A000:(320*(2+i))+256+3+2]:=8;
					Mem[$A000:(320*(2+i))+256+3+3]:=15;
					Mem[$A000:(320*(3+i))+320-3]:=15;
					Mem[$A000:(320*(3+i))+320-4]:=8;
				end;
			for i:=0 to 55 do
				begin
					Mem[$A000:(320*2)+256+3+3+i]:=8;
					Mem[$A000:(320*196)+256+3+3+i]:=15;
				end;
			for i:=0 to 53 do
				begin
					Mem[$A000:(320*3)+256+4+3+i]:=15;
					Mem[$A000:(320*195)+256+3+3+i]:=8;
				end;
			for i:=0 to 198 do
				begin
					Mem[$A000:(320*i)]:=15;
					Mem[$A000:(320*(i+1))+319]:=8;
				end;
		end;
Begin
	InitScreen;
	ClearBuffer;
	MakePal;
	LoadTexture;
	PrepareSphere;
	DrawFrame;
	while not Keypressed do
		begin
			DrawSphere;
			WaitVSyncStart;
			Buffer2Screen;
			Inc(Rot);
		end;
	DoneScreen;
End.