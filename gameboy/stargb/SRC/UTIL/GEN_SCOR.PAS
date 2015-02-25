{Programa Gen_Scor: Gera tabela de dezenas/unidades}
{por Haroldo de Oliveira Pinheiro}
program Gen_Scor;
	var T:text;
		i:byte;
Begin
	Assign(T,'scor.h');
	Rewrite(T);
	Writeln(T,'BYTE scor_table[100][2]={');
	for i:=0 to 99 do
		begin
			Write(T, '{', i mod 10, ',', i div 10, '}');
			if i <> 99 then
				Writeln(T,',')
			else
				Writeln(T);
		end;
	Writeln(T,'};');
	Close(T);
End.