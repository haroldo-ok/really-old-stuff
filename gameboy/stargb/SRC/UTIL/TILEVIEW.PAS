program TileView;
	uses Crt,X_Pal,Graph13h,PCXUnit;
	const
{		GBPal:array[0..7,0..3,0..2] of byte=
				(((0,63,0),(0,42,0),(0,21,0),(0,0,0)),
				 ((63,63,0),(42,21,0),(21,0,0),(0,0,0)),
				 ((0,63,63),(0,42,42),(0,21,21),(0,0,0)),
				 ((0,63,0),(0,42,0),(0,21,0),(0,0,0)),
				 ((0,63,0),(0,42,0),(0,21,0),(0,0,0)),
				 ((0,63,0),(0,42,0),(0,21,0),(0,0,0)),
				 ((0,63,0),(0,42,0),(0,21,0),(0,0,0)),
				 ((0,63,0),(0,42,0),(0,21,0),(0,0,0)));}
		ColorArray:array[0..11,0..19] of byte=
							((2,2,2,2,2,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
	type
		GbTile8x8=array[0..7] of word;
		RGB=array[0..3,0..2] of byte;
	var Tile:GbTile8x8;
		F:File;
		TilePos:word;
		Pal,PCXPal:Palette;
		i,j:byte;
		Img:PRawImage;
		QtzPal:array[0..Pred(20*12)] of RGB;
		GBPalette:array[0..3,0..3] of word;
		Junk:byte;
	procedure DisplayGbTile(X,Y:integer;Tile:GbTile8x8);
		var i,j,Color:word;
		begin
			for i:=0 to 7 do
				for j:=0 to 7 do
					begin
						Color:=(Lo(Tile[i]) and $01) or ((Hi(Tile[i]) and $01) shl 1);
						Tile[i]:=Tile[i] shr 1;
						Mem[$A000:((Y+i)*320)+(X+8-j)]:=Color;
					end;
		end;
{	procedure QuantizeGbTile(X,Y:integer;Tile:GbTile8x8;var Pal:RGB);
		var i,j,k,Color:word;
			TmpPal:array[0..3,0..2] of word;
			DivFactors:array[0..3] of byte;
			OrigColor:byte;
		begin
			FillChar(TmpPal,SizeOf(TmpPal),0);
			FillChar(DivFactors,SizeOf(DivFactors),0);
			for i:=0 to 7 do
				for j:=0 to 7 do
					begin
						Color:=(Lo(Tile[i]) and $01) or ((Hi(Tile[i]) and $01) shl 1);
						OrigColor:=Img^.Data[(Y*Img^.Width)+X];
						for k:=0 to 2 do
							Inc(TmpPal[Color,k],PCXPal[OrigColor,k]);
						Inc(DivFactors[Color]);
						Tile[i]:=Tile[i] shr 1;
					end;
			for i:=0 to 3 do
				begin
					if DivFactors[i] <> 0 then
						begin
							for j:=0 to 2 do
								Pal[i,j]:=TmpPal[i,j] div DivFactors[i];
						end
					else
						begin
							for j:=0 to 2 do
								Pal[i,j]:=255; {255 indica "tanto faz"}
{						end;
				end;
		end;}
	procedure QuantizeGbTile(X,Y:integer;Tile:GbTile8x8;var Pal:RGB);
		var i,j,k,Color:word;
			TmpPal:array[0..3,0..2] of word;
			DivFactors:array[0..3] of byte;
			OrigColor:byte;
			Bright,MaxBright:word;
		begin
			FillChar(TmpPal,SizeOf(TmpPal),0);
			FillChar(DivFactors,SizeOf(DivFactors),0);

			MaxBright:=0;
			for i:=0 to 7 do
				for j:=0 to 7 do
					begin
						OrigColor:=Img^.Data[(Y*Img^.Width)+X];
						for k:=0 to 2 do
							Inc(MaxBright,PCXPal[OrigColor,k]);
					end;

			for i:=0 to 7 do
				for j:=0 to 7 do
					begin
{						Color:=(Lo(Tile[i]) and $01) or ((Hi(Tile[i]) and $01) shl 1);}
						OrigColor:=Img^.Data[(Y*Img^.Width)+X];
						Bright:=0;
						for k:=0 to 2 do
							Inc(Bright,PCXPal[OrigColor,k]);
{						Color:=Bright div (3*16);}
						Color:=Longint(Bright)*3 div MaxBright;
						for k:=0 to 2 do
							Inc(TmpPal[Color,k],PCXPal[OrigColor,k]);
						Inc(DivFactors[Color]);
{						Tile[i]:=Tile[i] shr 1;}
					end;
			for i:=0 to 3 do
				begin
					if DivFactors[i] <> 0 then
						begin
							for j:=0 to 2 do
								Pal[(3-i),j]:=TmpPal[i,j] div (DivFactors[i]);
						end
					else
						begin
							for j:=0 to 2 do
								Pal[(3-i),j]:=255; {255 indica "tanto faz"}
						end;
				end;
		end;
	procedure DisplayGbTileColor(X,Y:integer;Tile:GbTile8x8;TColor:byte);
		var i,j,Color:word;
		begin
			for i:=0 to 7 do
				for j:=0 to 7 do
					begin
						Color:=(Lo(Tile[i]) and $01) or ((Hi(Tile[i]) and $01) shl 1);
						Tile[i]:=Tile[i] shr 1;
						Mem[$A000:((Y+i)*320)+(X+8-j)]:=Color+(TColor shl 2);
					end;
		end;
	procedure ApplyTileColor(X,Y:integer;Color:byte);
		var i,j:byte;
		begin
			for i:=0 to 7 do
				for j:=0 to 7 do
					begin
						Mem[$A000:((Y+i)*320)+(X+8-j)]:=Mem[$A000:((Y+i)*320)+(X+8-j)] and $03 or (Color shl 2);
					end;
		end;
	procedure GBPalette2Scr;
		var i,j:word;
		begin
			for i:=0 to 3 do
				for j:=0 to 3 do
					begin
						Pal[(i shl 2) or j,0]:=GBPalette[i,j] shl 1 and $3E;
						Pal[(i shl 2) or j,1]:=GBPalette[i,j] shr 4 and $3E;
						Pal[(i shl 2) or j,2]:=GBPalette[i,j] shl 9 and $3E;
					end;
			X_Put_Pal_Raw(Pal,256,0,false);
		end;
Begin
	InitGraph13h;

	AllocReadPCX(Img,'DREADN.PCX');
	GetPCXPalette(PCXPal,'DREADN.PCX');
	X_Put_Pal_Raw(PCXPal,256,0,false);
	DisplayRawImage(0,0,Img^);
	Readln;

	for i:=0 to 3 do
		for j:=0 to 2 do
			Pal[i,j]:=(3-i) shl 4 + 15;
	X_Put_Pal_Raw(Pal,256,0,false);

	Assign(F,'DREADN.BIN');
	Reset(F,1);
	TilePos:=0;
	while not Eof(F) do
		begin
			BlockRead(F,Tile,SizeOf(Tile));
			DisplayGbTile((TilePos mod 20) shl 3,(TilePos div 20) shl 3,Tile);
			QuantizeGbTile((TilePos mod 20) shl 3,(TilePos div 20) shl 3,Tile,QtzPal[TilePos]);
			Inc(TilePos);
			if TilePos > $1FF then
				begin
					TilePos:=0;
					Readln;
				end;
		end;
	Readln;
	Close(F);

{	Move(GBPal,Pal,SizeOf(Pal));
	X_Put_Pal_Raw(Pal,256,0,false);
	for i:=0 to 19 do
		for j:=0 to 11 do
			ApplyTileColor(i shl 3, j shl 3, ColorArray[j,i]);}
	Assign(F,'DREADN.RAW');
	Reset(F,1);
	TilePos:=0;
	while {not Eof(F)} TilePos < (20*12) do
		begin
			BlockRead(F,Tile,SizeOf(Tile));
			DisplayGbTile((TilePos mod 20) shl 3,(TilePos div 20) shl 3,Tile);
{			QuantizeGbTile((TilePos mod 20) shl 3,(TilePos div 20) shl 3,Tile,QtzPal[TilePos]);}
			Inc(TilePos);
			if TilePos > $1FF then
				begin
					TilePos:=0;
					Readln;
				end;
		end;
	BlockRead(F,ColorArray,SizeOf(ColorArray));
	for i:=0 to 19 do
		for j:=0 to 11 do
			ApplyTileColor(i shl 3, j shl 3, ColorArray[j,i]);
	BlockRead(F,GBPalette,SizeOf(GBPalette));
	GBPalette2Scr;
	Readln;
	Close(F);

{	for i:=0 to 255 do
		for j:=0 to 2 do
			Pal[i,j]:=QtzPal[i shr 2][i and $03,j];
	X_Put_Pal_Raw(Pal,256,0,false);
	Seek(F,0);
	TilePos:=0;
	while not Eof(F) do
		begin
			BlockRead(F,Tile,SizeOf(Tile));
			DisplayGbTileColor((TilePos mod 20) shl 3,(TilePos div 20) shl 3,Tile,TilePos);
			Inc(TilePos);
			if TilePos > $1FF then
				begin
					TilePos:=0;
					Readln;
				end;
		end;
	Junk:=0;
	while ReadKey <> #13 do
		begin
			for i:=0 to 255 do
				for j:=0 to 2 do
					Pal[i,j]:=QtzPal[((i shr 2)+Junk) mod (20*12)][i and $03,j];
			X_Put_Pal_Raw(Pal,256,0,false);
			Inc(Junk,64);
		end;
 }
{	Close(F);}
	CloseGraph13h;
End.