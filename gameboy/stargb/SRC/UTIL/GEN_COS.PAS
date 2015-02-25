{Programa Gen_Cos: Gera tabela de cossenos (16 dire‡äes, 8.8 p.fx.)}
{por Haroldo de Oliveira Pinheiro}
program Gen_Cos;
	const
		NUM_DIR = 16;         {16 dire‡äes}
		MUL_FACTOR = 256;     {8.8 ponto fixo}
		DIR_MASK = ' & 0x0F'; {16 dire‡äes}
	var T:text;
		i:byte;
Begin
	Assign(T,'cosin.h');
	Rewrite(T);
	Writeln(T,'WORD cos_table[]={');
	for i:=0 to Pred(NUM_DIR) do
		begin
			Write(T,Round(MUL_FACTOR*Cos(2*PI*i/NUM_DIR)));
			if i <> Pred(NUM_DIR) then
				Writeln(T,',')
			else
				Writeln(T);
		end;
	Writeln(T,'};');
	Writeln(T);
	Writeln(T,'#define _COS(x) cos_table[x',DIR_MASK,']');
	Writeln(T,'#define _SIN(x) cos_table[x+',NUM_DIR div 4,DIR_MASK,']');
	Close(T);
End.