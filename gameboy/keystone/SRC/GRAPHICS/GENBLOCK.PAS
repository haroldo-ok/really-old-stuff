program GenBlock;
	var F:file;
		Map:array[0..31,0..39] of byte;
		i,j,k,l:byte;
		T:text;
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
	if ParamCount < 2 then
		begin
			Writeln('GenBlock v1.0 by Haroldo de Oliveira Pinheiro');
			Writeln('Usage: GENBLOCK mapfile blockfile.h');
			Halt(1);
		end;
	{}
	Assign(F,ParamStr(1));
	Reset(F,1);
	BlockRead(F,Map,SizeOf(Map));
	Close(F);
	{}
	Assign(T,ParamStr(2));
	Rewrite(T);
	{Blocos de fundo}
	Writeln(T,'unsigned char block_raw_map[]={');
	for k:=0 to 10 do
		begin
			if k <> 0 then
				Writeln(T,',');
			Writeln(T,'// ** bloco ',k,' **');
			for l:=0 to 4 do
				begin
					if l <> 0 then
						Writeln(T,',');
					Writeln(T,'//  * sub-bloco ',l,' *');
					for i:=0 to 4 do
						begin
							if i <> 0 then
								Writeln(T,',');
							for j:=0 to 3 do
								begin
									if j <> 0 then
										Write(T,',');
									Write(T,ToHex(Map[i+((k mod 6)*5),j+(l*4)+((k div 6)*20)]));
								end;
						end;
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T,'unsigned char *block_map[][5]={');
	for k:=0 to 10 do
		begin
			if k <> 0 then
				Writeln(T,'},');
			Write(T,'{');
			for l:=0 to 4 do
				begin
					if l <> 0 then
						Write(T,',');
					Write(T,'block_raw_map+',(k*5*20)+(l*5*4));
				end;
		end;
	Writeln(T,'}');
	Writeln(T,'};');
	{Escadas rolantes}
	Writeln(T);
	Writeln(T);
	Writeln(T,'// Observe que as escadas s∆o mapeadas por coluna/linha');
	Writeln(T,'unsigned char lstair_raw_map[]={');
	for k:=0 to 2 do
		begin
			if k <> 0 then
				Writeln(T,',');
			Writeln(T,'// quadro ',k);
			for i:=0 to 5 do
				begin
					if i <> 0 then
						Writeln(T,',');
					for j:=0 to 4 do
						begin
							if j <> 0 then
								Write(T,',');
							Write(T,ToHex(Map[j+27,i+40-18+(k*6)]));
						end;
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T,'unsigned char *lstair_map[3]={');
	for k:=0 to 2 do
		begin
			if k <> 0 then
				Writeln(T,',');
			Write(T,'lstair_raw_map+',k*5*6);
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T,'unsigned char rstair_map[]={');
	for i:=0 to 5 do
		begin
			if i <> 0 then
				Writeln(T,',');
			for j:=0 to 4 do
				begin
					if j <> 0 then
						Write(T,',');
					Write(T,ToHex(Map[j+22,i+40-18]));
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T,'unsigned char lstair_top[]={');
	for i:=0 to 3 do
		begin
			if i <> 0 then
				Writeln(T,',');
			for j:=0 to 1 do
				begin
					if j <> 0 then
						Write(T,',');
					Write(T,ToHex(Map[j+30,i+20-8]));
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T,'unsigned char rstair_top[]={');
	for i:=0 to 3 do
		begin
			if i <> 0 then
				Writeln(T,',');
			for j:=0 to 1 do
				begin
					if j <> 0 then
						Write(T,',');
					Write(T,ToHex(Map[j+30,i+20-4]));
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	{Parede}
	Writeln(T);
	Writeln(T);
	Writeln(T,'unsigned char wall_map[]={');
	for i:=0 to 4 do
		begin
			if i <> 0 then
				Writeln(T,',');
			Write(T,ToHex(Map[i+20,20]));
		end;
	Writeln(T);
	Writeln(T,'};');
	{Elevador}
	Writeln(T);
	Writeln(T);
	Writeln(T,'unsigned char elevator_raw_map[]={');
	for k:=0 to 6 do
		begin
			if k <> 0 then
				Writeln(T,',');
			Writeln(T,'// quadro ',k);
			for i:=0 to 1 do
				begin
					if i <> 0 then
						Writeln(T,',');
					for j:=0 to 1 do
						begin
							if j <> 0 then
								Write(T,',');
							Write(T,ToHex(Map[i+20,(k*2)+j+21]));
						end;
				end;
		end;
	Writeln(T);
	Writeln(T,'};');
	Writeln(T,'unsigned char *elevator_map[]={');
	for k:=0 to 6 do
		begin
			if k <> 0 then
				Writeln(T,',');
			Write(T,'elevator_raw_map+',k*4);
		end;
	Writeln(T);
	Writeln(T,'};');
	{}
	Close(T);
End.