{Programa Gen_Sqrt: Gera tabela de ra¡zes quadradas (0 a 255, 8.8 p.fx.)}
{por Haroldo de Oliveira Pinheiro}
program Gen_Sqrt;
	const
		NUM_ROOT = 256;       {0 a 255}
		MUL_FACTOR = 256;     {8.8 ponto fixo}
	var T:text;
		i:byte;
Begin
	Assign(T,'sqrt.h');
	Rewrite(T);
	Writeln(T,'WORD sqrt_table[]={');
	for i:=0 to Pred(NUM_ROOT) do
		begin
			Write(T,Round(MUL_FACTOR*Sqrt(i)));
			if i <> Pred(NUM_ROOT) then
				Writeln(T,',')
			else
				Writeln(T);
		end;
	Writeln(T,'};');
	Writeln(T);
	Writeln(T,'#define _SQRT(x) sqrt_table[x]');
	Close(T);
End.