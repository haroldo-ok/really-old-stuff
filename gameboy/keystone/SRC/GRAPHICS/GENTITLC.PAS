program GenTitlC;
	type
		GIQImage=record
					TileSet1:array[0..255,0..15] of byte;
					TileSet2:array[0..103,0..15] of byte;
					BkgAttrs:array[0..17,0..19] of byte;
					Palette:array[0..7,0..3] of word;
				 end;
	var F:file;
		T:text;
		Img:GIQImage;
		i,j:byte;
	function ToHex(N:byte):string;
		const HexChars:array[0..15] of char=(
							'0','1','2','3',
							'4','5','6','7',
							'8','9','A','B',
							'C','D','E','F');
		begin
			ToHex:='0x'+HexChars[N shr 4]+HexChars[N and $0F];
		end;
Begin
	Writeln(SizeOf(GIQImage));

	Assign(F,'TITLEC.RAW');
	Reset(F,1);
	BlockRead(F,Img,SizeOf(Img));
	Close(F);

	Assign(T,'..\TITLCDAT.H');
	Rewrite(T);

	Writeln(T,'unsigned char titl_cgb_tiles1[]={');
	for i:=0 to 255 do
		begin
			if i <> 0 then
				Writeln(T,',');
			for j:=0 to 15 do
				begin
					if j <> 0 then
						Write(T,',');
					Write(T,ToHex(Img.TileSet1[i,j]));
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T);

	Writeln(T,'unsigned char titl_cgb_tiles2[]={');
	for i:=0 to 103 do
		begin
			if i <> 0 then
				Writeln(T,',');
			for j:=0 to 15 do
				begin
					if j <> 0 then
						Write(T,',');
					Write(T,ToHex(Img.TileSet2[i,j]));
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T);

	Writeln(T,'unsigned char titl_cgb_map[]={');
	for i:=0 to 17 do
		begin
			if i <> 0 then
				Writeln(T,',');
			for j:=0 to 19 do
				begin
					if j <> 0 then
						Write(T,',');
					Write(T,ToHex((i*20)+j));
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T);

	Writeln(T,'unsigned char titl_cgb_attrs[]={');
	for i:=0 to 17 do
		begin
			if i <> 0 then
				Writeln(T,',');
			for j:=0 to 19 do
				begin
					if j <> 0 then
						Write(T,',');
					Write(T,ToHex(Img.BkgAttrs[i,j]));
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T);

	Writeln(T,'UWORD titl_cgb_pal[][4]={');
	for i:=0 to 7 do
		begin
			if i <> 0 then
				Writeln(T,',');
			Write(T,'{');
			for j:=0 to 3 do
				begin
					if j <> 0 then
						Write(T,',');
					Write(T,Img.Palette[i][j]);
				end;
			Write(T,'}');
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T);

	Close(T);
End.