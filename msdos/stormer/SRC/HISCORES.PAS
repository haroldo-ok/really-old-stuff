{STORMER - Unidade de High Scores}
{programado por Haroldo de Oliveira Pinheiro}
unit HiScores;
interface
	const
		HSNameLength=15;
	type
		HiscRec=record
					Score:longint;
					Level:byte;
					Name:String[8];
				end;
		HiscVec=array[1..5] of HiscRec;
	var ReadingHiscores:boolean;
		HiScoreNum:byte;
		HiScore:HiscVec;
	procedure InitHiScores;
	procedure UpdateHiScores;
	procedure DoneHiScores;
implementation
	uses Other;
	procedure InitHiscores;
		var F:file of HiscVec;
			i:byte;
		begin
			ReadingHiscores:=false;
			HiScoreNum:=0;
			{$I-}
			Assign(F,'HISCORES.DAT');
			Reset(F);
			if IOResult<>0 then
				begin
					for i:=1 to 5 do
						begin
							HiScore[i].Name:='???';
							HiScore[i].Score:=0;
							HiScore[i].Level:=1;
						end;
				end
			else
				begin
					Read(F,HiScore);
					Close(F);
				end;
		end;
	procedure UpdateHiscores;
		var i,j:byte;
		begin
			i:=1;
			ReadingHiscores:=false;
			while (HiScore[i].Score>=Score) and (i<6) do
				Inc(i);
			if i<6 then
				begin
					HiScoreNum:=i;
					for j:=4 downto i do
						HiScore[i+1]:=HiScore[i];
					HiScore[i].Name:='';
					HiScore[i].Score:=Score;
					HiScore[i].Level:=Level;
					ReadingHiscores:=true;
				end
			else
				begin
					ReadingHiScores:=false;
				end;
		end;
	procedure DoneHiScores;
		var F:file of HiscVec;
		begin
			{$I-}
			Assign(F,'HISCORES.DAT');
			Rewrite(F);
			Write(F,HiScore);
		end;
End.