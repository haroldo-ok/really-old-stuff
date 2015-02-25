program Test;
	var T:text;
	function HexByte(B:byte):string;
		const
			HexChar:array[$0..$F] of char=( '0','1','2','3',
											'4','5','6','7',
											'8','9','A','B',
											'C','D','E','F');
		begin
			HexByte:=HexChar[B shr 4]+HexChar[B and $0F];
		end;
	var i,j:byte;
Begin
	Assign(T,'TABLE.TXT');
	Rewrite(T);
	for i:=0 to 7 do
		begin
			for j:=0 to 15 do
				Write(T,'0x',HexByte((j*8)+i),',');
			Writeln(T);
		end;
	Close(T);
End.