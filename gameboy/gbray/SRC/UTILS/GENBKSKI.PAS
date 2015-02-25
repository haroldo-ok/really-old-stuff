program GenBkSkin;
	var F:file;
		T:text;
		Map:array[0..31,0..31] of byte;
		Til:array[0..255,0..15] of byte;
		i,j,k:byte;
	function HexByte(B:byte):string;
		const
			HexNibble:array[$0..$F] of char=('0','1','2','3',
											 '4','5','6','7',
											 '8','9','A','B',
											 'C','D','E','F');
		begin
			HexByte:=HexNibble[B shr 4]+HexNibble[B and $0F];
		end;
Begin
	{Lˆ os caracteres}
	Assign(F,'BKSKNTIL');
	Reset(F,1);
	BlockRead(F,Til,FileSize(F));
	Close(F);

	{Lˆ o mapa}
	Assign(F,'BKSKNMAP');
	Reset(F,1);
	BlockRead(F,Map,FileSize(F));
	Close(F);

	Assign(T,'..\BKGSKIN.H');
	Rewrite(T);

	{blocos}
	for k:=0 to 15 do
		begin
			Writeln(T,'unsigned char skin_tiles_',k,'[]={');
			for i:=0 to 3 do
				begin
					if i <> 0 then
						Writeln(T,',');
					for j:=0 to 15 do
						begin
							if j <> 0 then
								Write(T,',');
							Write(T,'0x',HexByte( Til[(i shl 4)+k][j] ));
						end;
				end;
			Writeln(T);
			Writeln(T,'};');
			Writeln(T);
		end;

	{mapa}
	Writeln(T,'unsigned char skin_map[]={');
	for i:=0 to 17 do
		begin
			if i <> 0 then
				Writeln(T,',');
			for j:=0 to 19 do
				begin
					if j <> 0 then
						Write(T,',');
					k:=Map[i][j];
					k:=((k shr 4)+$0C)+(k shl 4);
					Write(T,'0x',HexByte(k));
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T);

	{atributos}
	Writeln(T,'unsigned char skin_attrs[]={');
	for i:=0 to 17 do
		begin
			if i <> 0 then
				Writeln(T,',');
			for j:=0 to 19 do
				begin
					if j <> 0 then
						Write(T,',');
					case Map[i][j] of
						0: k:=0;
						1..31: k:=1;
						32..59: k:=2;
						60..63: k:=3;
					end;
					Write(T,'0x',HexByte(k));
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T);

	Close(T);
End.