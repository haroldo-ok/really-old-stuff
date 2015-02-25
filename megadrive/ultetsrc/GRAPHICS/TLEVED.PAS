program Tetris_Level_Editor;
	uses Crt,X_Const,X_Pal,Graph13h,Mouse,Utils;
	const
		Yes_No:array[boolean] of string = ('No','Yes');

		DefaultMouseCursor:array[0..67] of byte=(8,0,8,0,
												 $8,$8,$0,$0,$0,$0,$0,$0,
												 $8,$F,$8,$0,$0,$0,$0,$0,
												 $8,$F,$F,$8,$0,$0,$0,$0,
												 $8,$F,$F,$F,$8,$0,$0,$0,
												 $8,$F,$F,$F,$F,$8,$0,$0,
												 $8,$F,$F,$F,$F,$F,$8,$0,
												 $8,$8,$8,$F,$8,$8,$8,$8,
												 $0,$0,$8,$8,$8,$8,$0,$0);

		MIN_W = 6;
		MAX_W = 14;

		MIN_H = 20;
		MAX_H = 30;

		LEVMAP_X = 8;
		LEVMAP_Y = 8;

		STPAN_X = 128;
		STPAN_Y = 8;

		BLOCKPAL_X = 128;
		BLOCKPAL_Y = 184;
	type
		LevelHeader=record
						W,H:byte;
						Bombs_On,Extended_Mode:boolean;
						CountDown:byte;
						Special_Blocks:boolean;
						Meta:array[0..3] of byte;
						Initial_Speed,Preview_Count:byte;
					end;
		LevelRec=record
					Header:LevelHeader;
					Map:array[0..30,0..14] of byte;
				 end;

		SMSTile=array[0..7,0..3] of byte;
		GenTile=array[0..7,0..3] of byte;
		RawTile=array[0..7,0..7] of byte;

		TilRec= record
					Width,Height:word;
					Tile:RawTile;
				end;
	var Mouse_X,Mouse_Y:integer;
		Mouse_B:byte;
		Pal:Palette;
		Key:char;
		TileImgs:array[0..16] of TilRec;
		Levels:array[0..99] of LevelRec;
		CurrLevel,LevelCount:byte;
		LevelPtr:^LevelRec;
		SelectedBlock:byte;
	procedure InitMouse;
		var Rst:ResetRec;
		begin
			MReset(Rst);
			if not Rst.Exists then
				begin
					CloseGraph13h;
					Writeln('Error: No mouse driver found.');
					Halt(1);
				end;
			MColRange(0,319);
			MRowRange(0,199);
		end;
	procedure ReadMouse;
		var Loc:LocRec;
		begin
			MPos(Loc);
			Mouse_X:=Loc.Column;
			Mouse_Y:=Loc.Row;
			Mouse_B:=Loc.ButtonStatus;
		end;
	procedure DrawMouseCursor;
		var Img:PRawImage;
		begin
			Img:=Addr(DefaultMouseCursor);
			DisplayRawImageClip(Mouse_X,Mouse_Y,Img^);
		end;
	procedure InitPalette;
		var i,j:byte;
		begin
{			Pal[ 0,0]:=$00; Pal[ 0,1]:=$00; Pal[ 0,2]:=$00;
			Pal[ 1,0]:=$00; Pal[ 1,1]:=$00; Pal[ 1,2]:=$2F;
			Pal[ 2,0]:=$00; Pal[ 2,1]:=$2F; Pal[ 2,2]:=$00;
			Pal[ 3,0]:=$00; Pal[ 3,1]:=$2F; Pal[ 3,2]:=$2F;
			Pal[ 4,0]:=$2F; Pal[ 4,1]:=$00; Pal[ 4,2]:=$00;
			Pal[ 5,0]:=$2F; Pal[ 5,1]:=$00; Pal[ 5,2]:=$2F;
			Pal[ 6,0]:=$2F; Pal[ 6,1]:=$2F; Pal[ 6,2]:=$00;
			Pal[ 7,0]:=$2F; Pal[ 7,1]:=$2F; Pal[ 7,2]:=$2F;
			Pal[ 8,0]:=$0F; Pal[ 8,1]:=$0F; Pal[ 8,2]:=$0F;
			Pal[ 9,0]:=$0F; Pal[ 9,1]:=$0F; Pal[ 9,2]:=$3F;
			Pal[10,0]:=$0F; Pal[10,1]:=$3F; Pal[10,2]:=$0F;
			Pal[11,0]:=$0F; Pal[11,1]:=$3F; Pal[11,2]:=$3F;
			Pal[12,0]:=$3F; Pal[12,1]:=$0F; Pal[12,2]:=$0F;
			Pal[13,0]:=$3F; Pal[13,1]:=$0F; Pal[13,2]:=$3F;
			Pal[14,0]:=$3F; Pal[14,1]:=$3F; Pal[14,2]:=$0F;
			Pal[15,0]:=$3F; Pal[15,1]:=$3F; Pal[15,2]:=$3F; }

			Pal[ 0,0]:=$00; Pal[ 0,1]:=$00; Pal[ 0,2]:=$00;

			Pal[ 1,0]:=$0F; Pal[ 1,1]:=$0F; Pal[ 1,2]:=$0F;
			Pal[ 2,0]:=$1F; Pal[ 2,1]:=$1F; Pal[ 2,2]:=$1F;
			Pal[ 3,0]:=$3F; Pal[ 3,1]:=$3F; Pal[ 3,2]:=$3F;

			Pal[ 4,0]:=$0F; Pal[ 4,1]:=$00; Pal[ 4,2]:=$00;
			Pal[ 5,0]:=$1F; Pal[ 5,1]:=$00; Pal[ 5,2]:=$00;
			Pal[ 6,0]:=$3F; Pal[ 6,1]:=$00; Pal[ 6,2]:=$00;

			Pal[ 7,0]:=$00; Pal[ 7,1]:=$0F; Pal[ 7,2]:=$00;
			Pal[ 8,0]:=$00; Pal[ 8,1]:=$1F; Pal[ 8,2]:=$00;
			Pal[ 9,0]:=$00; Pal[ 9,1]:=$3F; Pal[ 9,2]:=$00;

			Pal[10,0]:=$00; Pal[10,1]:=$00; Pal[10,2]:=$0F;
			Pal[11,0]:=$00; Pal[11,1]:=$00; Pal[11,2]:=$1F;
			Pal[12,0]:=$00; Pal[12,1]:=$00; Pal[12,2]:=$3F;

			Pal[13,0]:=$0F; Pal[13,1]:=$0F; Pal[13,2]:=$00;
			Pal[14,0]:=$1F; Pal[14,1]:=$1F; Pal[14,2]:=$00;
			Pal[15,0]:=$3F; Pal[15,1]:=$3F; Pal[15,2]:=$00;

			X_Put_Pal_Raw(Pal,256,0,false);
		end;

	procedure SMS2Raw(var Src:SMSTile;var Dst:RawTile);
		var i,j,k:byte;
		begin
			for i:=0 to 7 do
				for j:=0 to 7 do
					Dst[i,j]:=$00;
			for i:=0 to 7 do
				for j:=0 to 7 do
					for k:=3 downto 0 do
						begin
							Dst[i,j]:=Dst[i,j] shl 1;
							Dst[i,j]:=Dst[i,j] or (((Src[i,k] shl j) shr 7) and $01);
						end;
		end;
	procedure LoadTiles;
		var F:file;
			SMS:SMSTile;
			i:byte;
		begin
			TileImgs[0].Width:=8;
			TileImgs[0].Height:=8;
			FillChar(TileImgs[0].Tile,SizeOf(TileImgs[0].Tile),0);

			Assign(F,'BLOCKS.BIN');
			Reset(F,1);

			for i:=1 to 16 do
				begin
					TileImgs[i].Width:=8;
					TileImgs[i].Height:=8;
					BlockRead(F,SMS,SizeOf(SMS));
					SMS2Raw(SMS,TileImgs[i].Tile);
				end;

			Close(F);
		end;

	procedure InitLevels;
		var i:byte;
		begin
			for i:=0 to 99 do
				begin
					Levels[i].Header.W:=10;
					Levels[i].Header.H:=22;
					Levels[i].Header.Bombs_On:=false;
					Levels[i].Header.Extended_Mode:=false;
					Levels[i].Header.CountDown:=0;
					Levels[i].Header.Special_Blocks:=false;
					Levels[i].Header.Meta[0]:=0;
					Levels[i].Header.Meta[1]:=0;
					Levels[i].Header.Meta[2]:=0;
					Levels[i].Header.Meta[3]:=0;
					Levels[i].Header.Initial_Speed:=1;
					Levels[i].Header.Preview_Count:=2;
					FillChar(Levels[i].Map,SizeOf(Levels[i].Map),0);
				end;
			CurrLevel:=0;
			LevelCount:=1;
			LevelPtr:=Addr(Levels[CurrLevel]);
			SelectedBlock:=1;
		end;

	procedure LoadMainFile;
		var i,j,k:byte;
			Buf:array[0..14*30] of byte;
			F:file;
		begin
			if not FileExists('MISSION.TET') then
				exit;

			CurrLevel:=0;
			LevelCount:=0;

			Assign(F,'MISSION.TET');
			Reset(F,1);

			while not Eof(F) do
				begin
					with Levels[LevelCount] do
						begin
							BlockRead(F,Header,SizeOf(Header));
							Inc(LevelCount);

							BlockRead(F,Buf,Header.W*Header.H);
							for i:=0 to Pred(Header.H) do
								for j:=0 to Pred(Header.W) do
									Map[i,j]:=Buf[(Word(i)*Header.W)+j];
						end;
				end;

			Close(F);
		end;
	function CheckForSpecialBlocks(var Level:LevelRec):boolean;
		var HasAny:boolean;
			i,j:byte;
		begin
			HasAny:=false;
			for i:=0 to Pred(Level.Header.H) do
				for j:=0 to Pred(Level.Header.W) do
					if Level.Map[i,j] = 6 then
						HasAny:=true;
			CheckForSpecialBlocks:=HasAny;
		end;
	procedure SaveMainFile;
		var i,j,k:byte;
			Buf:array[0..14*30] of byte;
			F:file;
		begin
			Assign(F,'MISSION.TET');
			Rewrite(F,1);

			for k:=0 to Pred(LevelCount) do
				with Levels[k] do
					begin
						Header.Special_Blocks:=CheckForSpecialBlocks(Levels[k]);
						BlockWrite(F,Header,SizeOf(Header));

						for i:=0 to Pred(Header.H) do
							for j:=0 to Pred(Header.W) do
								Buf[(Word(i)*Header.W)+j]:=Map[i,j];
						BlockWrite(F,Buf,Header.W*Header.H);
					end;

			Close(F);
		end;

	procedure DrawLevel(var Level:LevelRec);
		var i,j:byte;
		begin
			HLine(LEVMAP_X-2,LEVMAP_Y-2,(Level.Header.W*8)+4,3);
			HLine(LEVMAP_X-2,LEVMAP_Y+(Level.Header.H*8)+2,(Level.Header.W*8)+4,3);
			VLine(LEVMAP_X-2,LEVMAP_Y-2,(Level.Header.H*8)+4,3);
			VLine(LEVMAP_X+(Level.Header.W*8)+2,LEVMAP_Y-2,(Level.Header.H*8)+4,3);

			for i:=0 to Pred(Level.Header.H) do
				for j:=0 to Pred(Level.Header.W) do
					begin
						DisplayRawImageClip(LEVMAP_X+(j*8),
											LEVMAP_Y+(i*8),
											PRAWImage(Addr(TileImgs[Level.Map[i,j]]))^);
					end;

			OutText(STPAN_X,STPAN_Y,3,  'Width(Q,W)  : '+IntToStr(Level.Header.W));
			OutText(STPAN_X,STPAN_Y+8,3,'Height(A,S) : '+IntToStr(Level.Header.H));

			OutText(STPAN_X,STPAN_Y+24,3,'Bombs(B)    : '+Yes_No[Level.Header.Bombs_On]);
			OutText(STPAN_X,STPAN_Y+32,3,'Extended(X) : '+Yes_No[Level.Header.Extended_Mode]);

			OutText(STPAN_X,STPAN_Y+48,3,'Countdown(+,-) : '+IntToStr(Level.Header.CountDown));

			OutText(STPAN_X,STPAN_Y+64,3,'Single(E,R) : '+IntToStr(Level.Header.Meta[0]));
			OutText(STPAN_X,STPAN_Y+72,3,'Double(D,F) : '+IntToStr(Level.Header.Meta[1]));
			OutText(STPAN_X,STPAN_Y+80,3,'Triple(C,V) : '+IntToStr(Level.Header.Meta[2]));
			OutText(STPAN_X,STPAN_Y+88,3,'Tetris(T,Y) : '+IntToStr(Level.Header.Meta[3]));

			OutText(STPAN_X,STPAN_Y+104,3,'Speed(O,P)   : '+IntToStr(Level.Header.Initial_Speed));
			OutText(STPAN_X,STPAN_Y+112,3,'Preview(K,L) : '+IntToStr(Level.Header.Preview_Count));

			OutText(STPAN_X,STPAN_Y+128,3,'Level(<,>) : '+IntToStr(CurrLevel));
			OutText(STPAN_X,STPAN_Y+136,3,'Lev. Cnt.([,]) : '+IntToStr(LevelCount));

			OutText(STPAN_X,STPAN_Y+152,3,'Z = Save');

			for i:=1 to 16 do
				begin
					DisplayRawImageClip(BLOCKPAL_X+((i-1)*8),
										BLOCKPAL_Y,
										PRAWImage(Addr(TileImgs[i]))^);
				end;
			HLine(BLOCKPAL_X+((SelectedBlock-1)*8),BLOCKPAL_Y-2,8,3);
		end;
	procedure DrawEverything;
		begin
			DrawLevel(LevelPtr^);
			DrawMouseCursor;
			WaitVSyncStart;
			Buffer2Screen(ScrBuf^);
			ClearBuffer(ScrBuf^);
		end;

	function IsInside(X,Y,X1,Y1,X2,Y2:longint):boolean;
		begin
			IsInside:= (X >= X1) and (X <= X2) and (Y >= Y1) and (Y <= Y2);
		end;
	procedure HandleMouse;
		var i,j:byte;
		begin
			ReadMouse;

			if IsInside(Mouse_X,Mouse_Y,
						LEVMAP_X,LEVMAP_Y,
						LEVMAP_X+(8*LevelPtr^.Header.W)-1,
						LEVMAP_Y+(8*LevelPtr^.Header.H)-1) then
				begin
					i:=(Mouse_Y - LEVMAP_Y) div 8;
					j:=(Mouse_X - LEVMAP_X) div 8;
					if (Mouse_B and $01) <> 0 then
						begin
							LevelPtr^.Map[i,j]:=SelectedBlock;
						end
					else if (Mouse_B and $02) <> 0 then
						begin
							LevelPtr^.Map[i,j]:=0;
						end;
				end;
			if IsInside(Mouse_X,Mouse_Y,
						BLOCKPAL_X,BLOCKPAL_Y,
						BLOCKPAL_X+(16*8)-1,BLOCKPAL_Y+8) then
				begin
					if Mouse_B <> 0 then
						begin
							SelectedBlock:=(Mouse_X - BLOCKPAL_X) div 8 + 1;
						end;
				end;
		end;
	procedure HandleKeyPresses;
		begin
			if KeyPressed then
				begin
					Key:=ReadKey;
					case Key of
						'Q','q':
							begin
								if LevelPtr^.Header.W > MIN_W then
									Dec(LevelPtr^.Header.W);
							end;
						'W','w':
							begin
								if LevelPtr^.Header.W < MAX_W then
									Inc(LevelPtr^.Header.W);
							end;

						'A','a':
							begin
								if LevelPtr^.Header.H > MIN_H then
									Dec(LevelPtr^.Header.H);
							end;
						'S','s':
							begin
								if LevelPtr^.Header.H < MAX_H then
									Inc(LevelPtr^.Header.H);
							end;

						'B','b':
							begin
								LevelPtr^.Header.Bombs_On:=not LevelPtr^.Header.Bombs_On;
							end;
						'X','x':
							begin
								LevelPtr^.Header.Extended_Mode:=not LevelPtr^.Header.Extended_Mode;
							end;

						'-':begin
								Dec(LevelPtr^.Header.CountDown);
							end;
						'+':begin
								Inc(LevelPtr^.Header.CountDown);
							end;

						'E','e':
							begin
								Dec(LevelPtr^.Header.Meta[0]);
							end;
						'R','r':
							begin
								Inc(LevelPtr^.Header.Meta[0]);
							end;
						'D','d':
							begin
								Dec(LevelPtr^.Header.Meta[1]);
							end;
						'F','f':
							begin
								Inc(LevelPtr^.Header.Meta[1]);
							end;
						'C','c':
							begin
								Dec(LevelPtr^.Header.Meta[2]);
							end;
						'V','v':
							begin
								Inc(LevelPtr^.Header.Meta[2]);
							end;
						'T','t':
							begin
								Dec(LevelPtr^.Header.Meta[3]);
							end;
						'Y','y':
							begin
								Inc(LevelPtr^.Header.Meta[3]);
							end;

						'<',',':
							begin
								if CurrLevel <> 0 then
									Dec(CurrLevel)
								else
									CurrLevel:=LevelCount-1;
								LevelPtr:=Addr(Levels[CurrLevel]);
							end;
						'>','.':
							begin
								if CurrLevel < Pred(LevelCount) then
									Inc(CurrLevel)
								else
									CurrLevel:=0;
								LevelPtr:=Addr(Levels[CurrLevel]);
							end;

						'[','{':
							begin
								if LevelCount > 1 then
									Dec(LevelCount);
								if CurrLevel >= LevelCount then
									CurrLevel:=LevelCount-1;
								LevelPtr:=Addr(Levels[CurrLevel]);
							end;
						']','}':
							begin
								if LevelCount < 100 then
									Inc(LevelCount);
							end;

						'O','o':
							begin
								if LevelPtr^.Header.Initial_Speed > 1 then
									Dec(LevelPtr^.Header.Initial_Speed);
							end;
						'P','p':
							begin
								if LevelPtr^.Header.Initial_Speed < 9 then
									Inc(LevelPtr^.Header.Initial_Speed);
							end;

						'K','k':
							begin
								if LevelPtr^.Header.Preview_Count > 0 then
									Dec(LevelPtr^.Header.Preview_Count);
							end;
						'L','l':
							begin
								if LevelPtr^.Header.Preview_Count < 4 then
									Inc(LevelPtr^.Header.Preview_Count);
							end;

						'Z','z':
							begin
								SaveMainFile;
							end;
					end;
				end;
		end;
Begin
	InitGraph13h;
	InitPalette;
	InitMouse;
	LoadTiles;
	InitLevels;
	LoadMainFile;

	Key:=#0;
	while Key <> #27 do
		begin
			DrawEverything;
			HandleMouse;
			HandleKeyPresses;
		end;

	CloseGraph13h;
End.