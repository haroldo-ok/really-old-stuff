program MakeSinTable;
var
	T : Text;
	i : Integer;
Begin
	Assign(T, 'sintable.c');
	Rewrite(T);

	Writeln(T);
	Writeln(T, 'unsigned char sin_table[] = {');
	for i := 0 to 89 do
		begin
			Write(T, Trunc(Sin(i*PI/180)*256), ', ');
			if (i mod 10) = 9 then
				Writeln(T);
		end;
	Writeln(T, '};');

	Close(T);
End.