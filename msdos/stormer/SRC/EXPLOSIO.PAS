{STORMER - Unidade de manipula‡Æo de explosäes}
{programado por Haroldo de Oliveira Pinheiro}
unit Explosion;
interface
	const
		NofDebris=200;
		ZFactor=400;
		Xc=160;
		Yc:integer=200;
	type
		FragRec=record
					X,Y,Z : integer;
				end;
		FragPos = array[0..NofDebris] of FragRec;
		FragSpd = array[0..NofDebris] of word;
	var
		Fragments:FragPos;
		Speed:FragSpd;
	procedure InitPlyExp;
	procedure HandlePlyExp;
implementation
	uses Player;
	procedure InitPlyExp;
		var A,R:word;
			i:word;
		begin
			Randomize;
			Yc:=(50*Player_Y)+46;
			for i := 0 to NofDebris do
				begin
					A:=Random(256);
					R:=Random(10);
					Fragments[i].X:=Round(R*Cos(PI*A/128));
					Fragments[i].Y:=Round(R*Sin(PI*A/128));
					Fragments[i].Z:=random(900)+200;
					Speed[i]:=0;
				end;
		end;
	procedure HandlePlyExp;
		var i:byte;
		begin
			for i:=0 to NofDebris do
				begin
					inc(Fragments[i].Z,Speed[i]);
					if Fragments[i].Z > 20000 then;
					Speed[i]:=(Fragments[i].Z div 150)*(5-(abs(Fragments[i].X*Fragments[i].Y) div 1000));
				end;
		end;
End.