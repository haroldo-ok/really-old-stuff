Unit H_File;
interface
	type
		HighScoreRec=record
						Name:String[8];			{Nome do jogador}
						Score:Longint;			{Score do jogador}
					 end;
		HighScoreVec=array[1..10] of HighScoreRec;{Tipo usado para registrar os high scores}
		HighScoreFile=file of HighScoreVec;
	procedure FileClose(Var f:HighScoreFile);
implementation
	procedure FileClose(Var f:HighScoreFile);
		begin
			Close(f);
		end;
end.