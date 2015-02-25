program MakeDat;
	uses Utils;
	const
		Signature:string[8]='PATCHDAT';
		Version=$0100;
		BinSig:string[4]='BIN_';
	type
		FileHeader= record
						Sig:array[0..7] of char;
						Version:longint;
						Reserved:array[0..19] of byte;
					end;
		DataHeader= record
						Sig:Array[0..3] of char;
						Offset:longint;
						Len:longint;
						Reserved:array[0..19] of byte;
					end;

		BPP1Tile=array[0..7] of byte;
		SMSTile=array[0..7,0..3] of byte;
		GenTile=array[0..7,0..3] of byte;
		RawTile=array[0..7,0..7] of byte;
	var T:text;
		OutFile:file;
		Include:Text;
		S:string;
		FHeader:FileHeader;
		CurrHeader:DataHeader;
		CurrHeaderPos:longint;
		CurrFilePos:longint;
		CurrDataAddr:longint;
		CurrOffset:longint;
	function HexByte(B:byte):string;
		const
			HexChar:array[$00..$0F] of char=('0','1','2','3',
											 '4','5','6','7',
											 '8','9','A','B',
											 'C','D','E','F');
		begin
			HexByte:=HexChar[B shr 4]+HexChar[B and $0F];
		end;
	function HexWord(W:word):string;
		begin
			HexWord:=HexByte((W shr 8) and $FF)+HexByte(W and $FF);
		end;
	function HexLong(L:longint):string;
		begin
			HexLong:=HexWord((L shr 16) and $FFFF)+HexWord(L and $FFFF);
		end;
	function FName2Iden(S:string):string;
		var i:byte;
		begin
			while Pos('\',S) <> 0 do
				Delete(S,1,Pos('\',S));
			for i:=1 to Length(S) do
				begin
					case S[i] of
						'.':S[i]:='_';
					else
						S[i]:=UpCase(S[i]);
					end;
				end;
			FName2Iden:=S;
		end;
	procedure Chr2Raw(var Src:BPP1Tile;var Dst:RawTile);
		var i,j:byte;
			Aux:byte;
		begin
			for i:=0 to 7 do
				begin
					Aux:=Src[i];
					for j:=0 to 7 do
						begin
							if Aux and $80 <> 0 then
								Dst[i,j]:=$FF
							else
								Dst[i,j]:=$00;
							Aux:=Aux shl 1;
						end;
				end;
		end;
	procedure RChr2Raw(var Src:BPP1Tile;var Dst:RawTile);
		var i,j:byte;
			Aux:byte;
		begin
			for i:=0 to 7 do
				begin
					Aux:=Src[i];
					for j:=0 to 7 do
						begin
							if Aux and $01 <> 0 then
								Dst[i,j]:=$FF
							else
								Dst[i,j]:=$00;
							Aux:=Aux shr 1;
						end;
				end;
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
	procedure Raw2Gen(var Src:RawTile;var Dst:GenTile);
		var i,j,k:byte;
		begin
			for i:=0 to 7 do
				for j:=0 to 3 do
					begin
						Dst[i,j]:=Src[i,(j*2)] and $0F;
						Dst[i,j]:=Dst[i,j] shl 4;
						Dst[i,j]:=Dst[i,j] or Src[i,(j*2)+1] and $0F;
					end;
		end;
	function CopyBinToOutFile(BinFile:string):longint;
		var F:file;
			Buf:array[0..2047] of byte;
			NumRead:word;
		begin
			Assign(F,BinFile);
			Reset(F,1);

			CopyBinToOutFile:=FileSize(F);

			while not Eof(F) do
				begin
					BlockRead(F,Buf,SizeOf(Buf),NumRead);
					BlockWrite(OutFile,Buf,NumRead);
				end;

			Close(F);
		end;
	procedure AddBinFile(BinFile:string);
		begin
			Writeln('Adding binary file: ',BinFile);

			CurrHeaderPos:=FilePos(OutFile);
			FillChar(CurrHeader,SizeOf(CurrHeader),0);
			Move(BinSig[1],CurrHeader.Sig,4);
			CurrHeader.Offset:=CurrOffset;

			Writeln(Include,'#define ',FName2Iden(BinFile),#09,'0x',HexLong(CurrDataAddr),'UL');

			BlockWrite(OutFile,CurrHeader,SizeOf(CurrHeader));
			CurrHeader.Len:=CopyBinToOutFile(S);

			CurrFilePos:=FilePos(OutFile);
			Seek(OutFile,CurrHeaderPos);
			BlockWrite(OutFile,CurrHeader,SizeOf(CurrHeader));
			Seek(OutFile,CurrFilePos);

			Inc(CurrOffset,CurrHeader.Len);
			Inc(CurrDataAddr,CurrHeader.Len);
			Writeln(Include,'#define ',FName2Iden(BinFile),'_END',#09,'0x',HexLong(CurrDataAddr),'UL');
			Writeln(Include);
		end;
	procedure AddChr2Gen(TileCount:longint;FileName:string);
		var Chr:BPP1Tile;
			Raw:RawTile;
			Gen:GenTile;
			NumRead:word;
			i:longint;
			F:file;
		begin
			Writeln('Converting 1bpp chr to Genesis chr: ',FileName);

			CurrHeaderPos:=FilePos(OutFile);
			FillChar(CurrHeader,SizeOf(CurrHeader),0);
			Move(BinSig[1],CurrHeader.Sig,4);
			CurrHeader.Offset:=CurrOffset;

			Writeln(Include,'#define ',FName2Iden(FileName),#09,'0x',HexLong(CurrDataAddr),'UL');

			BlockWrite(OutFile,CurrHeader,SizeOf(CurrHeader));
			CurrHeader.Len:=TileCount*SizeOf(Gen);

			Assign(F,FileName);
			Reset(F,1);
			for i:=0 to Pred(TileCount) do
				begin
					BlockRead(F,Chr,SizeOf(Chr),NumRead);
					if NumRead = SizeOf(Chr) then
						begin
							Chr2Raw(Chr,Raw);
							Raw2Gen(Raw,Gen);
						end
					else
						begin
							FillChar(Gen,SizeOf(Gen),0);
						end;
					BlockWrite(OutFile,Gen,SizeOf(Gen));
				end;
			Close(F);

			CurrFilePos:=FilePos(OutFile);
			Seek(OutFile,CurrHeaderPos);
			BlockWrite(OutFile,CurrHeader,SizeOf(CurrHeader));
			Seek(OutFile,CurrFilePos);

			Inc(CurrOffset,CurrHeader.Len);
			Inc(CurrDataAddr,CurrHeader.Len);
			Writeln(Include,'#define ',FName2Iden(FileName),'_END',#09,'0x',HexLong(CurrDataAddr),'UL');
			Writeln(Include);
		end;
	procedure AddRChr2Gen(TileCount:longint;FileName:string);
		var Chr:BPP1Tile;
			Raw:RawTile;
			Gen:GenTile;
			NumRead:word;
			i:longint;
			F:file;
		begin
			Writeln('Converting 1bpp reflected chr to Genesis chr: ',FileName);

			CurrHeaderPos:=FilePos(OutFile);
			FillChar(CurrHeader,SizeOf(CurrHeader),0);
			Move(BinSig[1],CurrHeader.Sig,4);
			CurrHeader.Offset:=CurrOffset;

			Writeln(Include,'#define ',FName2Iden(FileName),#09,'0x',HexLong(CurrDataAddr),'UL');

			BlockWrite(OutFile,CurrHeader,SizeOf(CurrHeader));
			CurrHeader.Len:=TileCount*SizeOf(Gen);

			Assign(F,FileName);
			Reset(F,1);
			for i:=0 to Pred(TileCount) do
				begin
					BlockRead(F,Chr,SizeOf(Chr),NumRead);
					if NumRead = SizeOf(Chr) then
						begin
							RChr2Raw(Chr,Raw);
							Raw2Gen(Raw,Gen);
						end
					else
						begin
							FillChar(Gen,SizeOf(Gen),0);
						end;
					BlockWrite(OutFile,Gen,SizeOf(Gen));
				end;
			Close(F);

			CurrFilePos:=FilePos(OutFile);
			Seek(OutFile,CurrHeaderPos);
			BlockWrite(OutFile,CurrHeader,SizeOf(CurrHeader));
			Seek(OutFile,CurrFilePos);

			Inc(CurrOffset,CurrHeader.Len);
			Inc(CurrDataAddr,CurrHeader.Len);
			Writeln(Include,'#define ',FName2Iden(FileName),'_END',#09,'0x',HexLong(CurrDataAddr),'UL');
			Writeln(Include);
		end;
	procedure AddSMS2Gen(TileCount:longint;FileName:string);
		var SMS:SMSTile;
			Raw:RawTile;
			Gen:GenTile;
			NumRead:word;
			i:longint;
			F:file;
		begin
			Writeln('Converting SMS chr to Genesis chr: ',FileName);

			CurrHeaderPos:=FilePos(OutFile);
			FillChar(CurrHeader,SizeOf(CurrHeader),0);
			Move(BinSig[1],CurrHeader.Sig,4);
			CurrHeader.Offset:=CurrOffset;

			Writeln(Include,'#define ',FName2Iden(FileName),#09,'0x',HexLong(CurrDataAddr),'UL');

			BlockWrite(OutFile,CurrHeader,SizeOf(CurrHeader));
			CurrHeader.Len:=TileCount*SizeOf(Gen);

			Assign(F,FileName);
			Reset(F,1);
			for i:=0 to Pred(TileCount) do
				begin
					BlockRead(F,SMS,SizeOf(SMS),NumRead);
					if NumRead = SizeOf(SMS) then
						begin
							SMS2Raw(SMS,Raw);
							Raw2Gen(Raw,Gen);
						end
					else
						begin
							FillChar(Gen,SizeOf(Gen),0);
						end;
					BlockWrite(OutFile,Gen,SizeOf(Gen));
				end;
			Close(F);

			CurrFilePos:=FilePos(OutFile);
			Seek(OutFile,CurrHeaderPos);
			BlockWrite(OutFile,CurrHeader,SizeOf(CurrHeader));
			Seek(OutFile,CurrFilePos);

			Inc(CurrOffset,CurrHeader.Len);
			Inc(CurrDataAddr,CurrHeader.Len);
			Writeln(Include,'#define ',FName2Iden(FileName),'_END',#09,'0x',HexLong(CurrDataAddr),'UL');
			Writeln(Include);
		end;
	procedure ParseCommand(Cmd:string);
		var Token:string;
			Junk:integer;
		begin
			Token:=GetToken(Cmd);
			if Token = '#org' then
				begin
					Cmd:=RemoveBlanks(Cmd);
					Token:=RemoveBlanks(Copy(Cmd,1,Pos(' ',Cmd)));
					Delete(Cmd,1,Pos(' ',Cmd));
					Val(Token,CurrOffset,Junk);

					Cmd:=RemoveBlanks(Cmd);
					Token:=RemoveBlanks(Copy(Cmd,1,Pos(' ',Cmd)));
					Delete(Cmd,1,Pos(' ',Cmd));
					Val(Token,CurrDataAddr,Junk);
					if Junk <> 0 then
						CurrDataAddr:=CurrOffset;

					Writeln('New origin: 0x',HexLong(CurrOffSet),' 0x',HexLong(CurrDataAddr));
				end;
		end;
	procedure ParseConversion(S:string);
		var Token:string;
		begin
			Delete(S,1,1);
			Token:=GetToken(S);
			if Token = 'chr2gen' then {converte 1bpp, normal, para genesis}
				begin
					AddChr2Gen(ReadNumber(GetToken(S)),RemoveBlanks(S));
				end
			else if Token = 'rchr2gen' then {converte 1bpp, refletido, para genesis}
				begin
					AddRChr2Gen(ReadNumber(GetToken(S)),RemoveBlanks(S));
				end
			else if Token = 'sms2gen' then {converte sega master system para genesis}
				begin
					AddSMS2Gen(ReadNumber(GetToken(S)),RemoveBlanks(S));
				end;
		end;
Begin
	if ParamCount < 2 then
		begin
			Writeln('MAKEDAT v1.1 by Haroldo de Oliveira Pinheiro');
			Writeln('Usage: MAKEDAT <script> <datafile>');
			Halt(1);
		end;
	Assign(T,ParamStr(1));
	Reset(T);

	Assign(OutFile,ParamStr(2));
	Rewrite(OutFile,1);

	Assign(Include,ChangeExt(ParamStr(2),'H'));
	Rewrite(Include);

	{Escreve o cabe‡alho do arquivo de dados}
	FillChar(FHeader,SizeOf(FHeader),$66);
	Move(Signature[1],FHeader.Sig,8);
	FHeader.Version:=Version;
	BlockWrite(OutFile,FHeader,SizeOf(FHeader));

	{Escreve o cabe‡alho do include}
	S:=FName2Iden(ParamStr(2));
	Writeln(Include,'/* Generated by MAKEDAT 1.1 */');
	Writeln(Include);
	Writeln(Include,'#ifndef ',S);
	Writeln(Include,'#define ',S);
	Writeln(Include);

	{"Apresenta-se" ao usu rio}
	Writeln;
	Writeln('MAKEDAT v1.1 by Haroldo de Oliveira Pinheiro');
	Writeln;

	CurrDataAddr:=0;
	CurrOffset:=0;

	while not Eof(T) do
		begin
			Readln(T,S);
			if S <> '' then
				begin
					case S[1] of
						'#':begin
								ParseCommand(S);
							end;
						'.':begin
								ParseConversion(S);
							end;
					else
						AddBinFile(S);
					end;
				end;
		end;

	Writeln(Include,'#endif /* ',FName2Iden(ParamStr(2)),' */');
	Writeln(Include);

	Close(Include);
	Close(OutFile);
	Close(T);

	Writeln('Done.');
End.