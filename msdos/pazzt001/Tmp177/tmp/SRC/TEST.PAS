program Test;
	uses HVMM;
	var Handle : word;
		Buf, Buf2: array[0..3911] of byte; {O tamanho n∆o pode ser potància de 2, a fim de testar o tratamento de offsets}
		F, F2: file;
		Size: longint;
		NumRead: word;
		Position: longint;
		i : word;
Begin
	InitHVMM;

	Handle := GetMemHVMM($FFFFF);

	TestXMS;

	Writeln('Lendo TOWN.ZZT');
	Assign(F,'TOWN.ZZT');
	Reset(F,1);
	Size := FileSize(F);
	Position := 0;
	while not Eof(F) do
		begin
			BlockRead(F,Buf,SizeOf(Buf),NumRead);
			if WriteHVMM(Handle,Buf,Position,NumRead) <> NumRead then
				Writeln('Erro!');
			Inc(Position,NumRead);
		end;
	Close(F);

	Writeln('Gravando TEST.ZZT');
	Assign(F,'TEST.ZZT');
	Rewrite(F,1);
	Position := 0;
	while Position < Size do
		begin
			if Size - Position > SizeOf(Buf) then
				NumRead := SizeOf(Buf)
			else
				NumRead := Size - Position;
			if ReadHVMM(Handle,Buf,Position,NumRead) <> NumRead then
				Writeln('Erro!');
			BlockWrite(F,Buf,NumRead);
			Inc(Position,NumRead);
		end;
	Close(F);

	Writeln('Comparando arquivos');

	Assign(F,'TOWN.ZZT');
	Reset(F,1);
	Assign(F2,'TEST.ZZT');
	Reset(F2,1);
	while not Eof(F) and not Eof(F2) do
		begin
			Position := FilePos(F);

			BlockRead(F,Buf,SizeOf(Buf),NumRead);
			BlockRead(F2,Buf2,SizeOf(Buf2),NumRead);

			i := 0;
			while (i <> 3911) and
				  (Buf[i] = Buf2[i]) do
				Inc(i);

			if Buf[i] <> Buf2[i] then
				Writeln('Diferenáa encontrada em ', Position + i);
		end;
	Close(F);
	Close(F2);

	Writeln;
	Writeln;

	FreeMemHVMM(Handle);

	DoneHVMM;
End.