program GenTexData;
var T:text;
	i:integer;
	Step:real;
	B:byte;
	W:word;
Begin
	Assign(T,'..\TEXDATA.INC');
	Rewrite(T);
	Writeln(T,'_scale_table:');
	for i:=1 to 192 do
		begin
			Writeln(T,'; Escala ',i);

{			Step:=(8/i)*128;}
{			Step:=(8/i)*256;}
{			Step:=(16/i)*256;}
			Step:=(16/i)*128;

			if i < 96 then
				B:=0
			else
				B:=Trunc(Step*(i-96)/2);
			Writeln(T,#9,'.db',#9,B,#9,'; Passo inicial');

			if i < 96 then
				B:=0
			else
				B:=Trunc(Step*(i-96)/512);
			if B > 16 then
				B:=16;
			Writeln(T,#9,'.db',#9,B,#9,'; Shift inicial');

			if i < 96 then
				B:=i
			else
				B:=96;
			Writeln(T,#9,'.db',#9,B,#9,'; Altura');

			if Step < 256 then
				B:=Trunc(Step)
			else
				B:=255;
			Writeln(T,#9,'.db',#9,B,#9,'; Passo');

			if	i < 96 then
				B:=48-(i div 2)
			else
				B:=0;
			Writeln(T,#9,'.dw',#9,B*2,#9,'; Offset inicial');

		end;
	Close(T);
End.