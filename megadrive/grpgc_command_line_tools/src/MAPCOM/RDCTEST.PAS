program Teste;
	uses RDCUnit;
	var F, F2: file;
		Size: longint;
		Buf1, Buf2: ^Byte;
begin
    {Testa em mem¢ria}
	Assign(F, 'genesis.c');
	Reset(F, 1);
	Size := FileSize(F);
	GetMem(Buf1, Size);
	BlockRead(F, Buf1^, Size);
	Close(F);

	GetMem(Buf2, 65528);
	Size := Comp_BufferToBuffer(Buf1^, Size, Buf2^);
	Assign(F, 'TEST2.RDC');
	Rewrite(F,1);
	BlockWrite(F, Buf2^, Size);
	Close(F);

	{Testa em arquivo}
	Assign(F, 'genesis.c');
	Reset(F, 1);
	Assign(F2, 'TEST1.RDC');
	Rewrite(F2,1);
	Comp_FileToFile(F, F2);
	Close(F);
	Close(F2);
end.