program MakeSav;
	uses Dos;
	type
		GameHeader= record
						Name:array[0..11] of char;
						Size:word;
					end;
	var F:file;
		Buf:array[$0000..$7FFF] of byte;
		i:byte;
	procedure WriteHeader;
		const Sig:string[16]='Vision-8 GB'+#0;
		begin
			Move(Sig[1],Buf[0],16);
		end;
	procedure AddFile(N:byte);
		var F:file;
			Head:GameHeader;
			S:string;
		function GetFName(FName:string):string;
			var Dir,Name,Ext:string;
			begin
				FSplit(FName,Dir,Name,Ext);
				GetFName:=Name;
			end;
		begin
			if N > 7 then
				Exit;

			Writeln('Adding ',ParamStr(N));
			Assign(F,ParamStr(N));
			Reset(F,1);

			FillChar(Head,SizeOf(Head),0);
			S:=GetFName(ParamStr(N));
			Move(S[1],Head.Name,Length(S));
			Head.Size:=FileSize(F);
			Move(Head,Buf[128*N],SizeOf(Head));

			BlockRead(F,Buf[4096*N],FileSize(F));
		end;
Begin
	Writeln('MAKESAV v1.0 by Haroldo de Oliveira Pinheiro');
	Writeln('Builds a cartridge RAM image for GBC8');
	if ParamCount = 0 then
		begin
			Writeln('Usage: MAKESAV <file1> [<file2>] [<file3>] ...');
			Writeln('Up to seven files can be included.');
			Halt(1);
		end;

	Writeln('Building image...');
	FillChar(Buf,SizeOf(Buf),0);
	WriteHeader;
	for i:=1 to ParamCount do
		AddFile(i);

	Writeln('Saving GBC8.SAV...');
	Assign(F,'GBC8.SAV');
	Rewrite(F,1);
	BlockWrite(F,Buf,SizeOf(Buf));
	Close(F);

	Writeln('Done.');
End.