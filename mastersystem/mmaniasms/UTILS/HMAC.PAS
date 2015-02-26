program HMac;
	uses Utils;
	var InFile,OutFile:text;
		S,S2,Token:string;
	procedure IncBin(FileName:string);
		var F:file;
			Buf:array[0..15] of byte;
			NumRead:word;
			S:string;
			i:byte;
		begin
			Writeln('INCBIN ',FileName);
			Assign(F,FileName);
			Reset(F,1);
			Writeln(OutFile,'; INCBIN "',FileName,'"');
			while not Eof(F) do
				begin
					S:='    .byte ';
					BlockRead(F,Buf,16,NumRead);
					for i:=0 to Pred(NumRead) do
						begin
							S:=S+IntToStr(Buf[i]);
							if i < Pred(NumRead) then
								S:=S+',';
						end;
					Writeln(OutFile,S);
				end;
			Close(F);
		end;
Begin
	If ParamCount < 2 then
		begin
			Writeln('HMAC v1.0 by Haroldo O. Pinheiro');
			Writeln('Usage: HMAC outfile infile');
			Halt(1);
		end;

	Assign(OutFile,ParamStr(1));
	Rewrite(OutFile);

	Assign(InFile,ParamStr(2));
	Reset(InFile);

	Writeln('Processing ',ParamStr(2));

	while not Eof(InFile) do
		begin
			Readln(InFile,S);
			S2:=S;
			Token:=GetToken(S2);
			if Token = 'INCBIN' then
				begin
					Token:=RemoveQuotes(GetToken(S2));
					IncBin(Token);
				end
			else
				begin
					Writeln(OutFile,S);
				end;
		end;

	Close(OutFile);
	Close(InFile);

	Writeln('Finished.');
End.