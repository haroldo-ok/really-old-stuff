program PatchDat;
	uses Utils;
	const
		Signature:string[8]='PATCHDAT';
		PatchDatVersion=$0100;
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
	var BinFile,PatchFile:file;
		S:string;
		FHeader:FileHeader;
		CurrHeader:DataHeader;
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
	function MemCmp(var A,B;Count:word):boolean;
		var PA,PB:^Byte;
		begin
			PA:=Addr(A);
			PB:=Addr(B);
			while (PA^ = PB^) and (Count <> 0) do
				begin
					Inc(PA);
					Inc(PB);
					Dec(Count);
				end;
			MemCmp:=(Count = 0);
		end;
	procedure PadFile(Len:longint);
		var Buf:array[0..2047] of byte;
		begin
			if Len > FileSize(BinFile) then
				begin
					FillChar(Buf,SizeOf(Buf),0);
					Seek(BinFile,FileSize(BinFile));
					Dec(Len,FileSize(BinFile));
					Writeln('Padding ',Len,'bytes');
					while Len > 0 do
						begin
							if Len > SizeOf(Buf) then
								BlockWrite(BinFile,Buf,SizeOf(Buf))
							else
								BlockWrite(BinFile,Buf,Len);
							Dec(Len,SizeOf(Buf));
						end;
				end;
		end;
	procedure DoBinaryPatch;
		var Remaining:longint;
			Buf:array[0..2047] of byte;
			ToCopy:word;
		begin
			PadFile(CurrHeader.Offset);
			Seek(BinFile,CurrHeader.Offset);

			Writeln('Patching from 0x',HexLong(CurrHeader.Offset),
					' to 0x',HexLong(CurrHeader.Offset+CurrHeader.Len-1),
					' (',CurrHeader.Len,'bytes)');

			Remaining:=CurrHeader.Len;
			while Remaining > 0 do
				begin
					if Remaining > SizeOf(Buf) then
						ToCopy:=SizeOf(Buf)
					else
						ToCopy:=Remaining;
					BlockRead(PatchFile,Buf,ToCopy);
					BlockWrite(BinFile,Buf,ToCopy);
					Dec(Remaining,SizeOf(Buf));
				end;
		end;
Begin
	if ParamCount < 2 then
		begin
			Writeln('PATCHDAT v1.0 by Haroldo de Oliveira Pinheiro');
			Writeln('Usage: MAKEDAT <binfile> <patchfile>');
			Halt(1);
		end;
	{$I-}
	Assign(BinFile,ParamStr(1));
	Reset(BinFile,1);
	if IOResult <> 0 then
		begin
			Writeln('Error opening ',ParamStr(1));
			Halt(2);
		end;
	{$I+}

	{$I-}
	Assign(PatchFile,ParamStr(2));
	Reset(PatchFile,1);
	if IOResult <> 0 then
		begin
			Writeln('Error opening ',ParamStr(2));
			Halt(2);
		end;
	{$I+}

	BlockRead(PatchFile,FHeader,SizeOf(FHeader));
	if not MemCmp(FHeader,Signature[1],8) then
		begin
			Writeln(ParamStr(2),' is not a PATCHDAT patch file.');
			Halt(3);
		end;
	if FHeader.Version > PatchDatVersion then
		begin
			Writeln('Patch file is from a newer version.');
			Halt(4);
		end;

	Writeln;
	Writeln('PATCHDAT v1.0 by Haroldo de Oliveira Pinheiro');
	Writeln;
	Writeln('Patching ',ParamStr(1));

	while not Eof(PatchFile) do
		begin
			BlockRead(PatchFile,CurrHeader,SizeOf(CurrHeader));
			if MemCmp(CurrHeader.Sig,BinSig[1],4) then
				begin
					DoBinaryPatch;
				end
			else
				begin
					Writeln('Unknown data format. Patch file may be corrupted.');
					Halt(5);
				end;
		end;

	Close(PatchFile);
	Close(BinFile);
End.