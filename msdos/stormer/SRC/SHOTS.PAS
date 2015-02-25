{STORMER - Unidade de manipula‡Æo de tiros}
{programado por Haroldo de Oliveira Pinheiro}
unit Shots;
interface
	type
		Shot=record
				Pos:integer;
				Dir:ShortInt;
				IsHere:boolean;
			 end;
	var ShotPos:array[0..6] of Shot;
		ShotImage:array[0..1] of Pointer;
	procedure InitShots;
	procedure HandleShots;
	procedure Shoot;
	procedure DoneShots;
implementation
	uses X_FileIO,Player,Sounds,Other;
	var MoveControl:boolean;
	procedure InitShots;
		var F:file;
			i:byte;
		begin
			{Limpa as vari veis}
			for i:=0 to 6 do
				ShotPos[i].IsHere:=False;
			{Carrega as imagens}
			GetMem(ShotImage[0],F_Size('SHOT_L.PBM'));
			F_Open_Read(F,'SHOT_L.PBM');
			BlockRead(F,ShotImage[0]^,F_Size('SHOT_L.PBM'));
			Close(F);
			GetMem(ShotImage[1],F_Size('SHOT_R.PBM'));
			F_Open_Read(F,'SHOT_R.PBM');
			BlockRead(F,ShotImage[1]^,F_Size('SHOT_R.PBM'));
			Close(F);
		end;
	procedure HandleShots;
		var i:byte;
		begin
			if MoveControl then
				begin
					for i:=0 to 6 do
						begin
							if (ShotPos[i].IsHere) and (ShotPos[i].Pos>-15) and (ShotPos[i].Pos<326) then
								begin
									Inc(ShotPos[i].Pos,ShotPos[i].Dir);
								end
							else
								begin
									ShotPos[i].IsHere:=False;
								end;
						end;
				end;
			MoveControl:=not MoveControl;
		end;
	procedure Shoot;
		begin
			if not ShotPos[Player_Y].IsHere then
				begin
					if not Facing_R then
						begin
							ShotPos[Player_Y].Pos:=140;
							ShotPos[Player_Y].Dir:=-1;
							ShotPos[Player_Y].IsHere:=True;
							if not DemoMode then
								PlaySound(PlyShotSnd,0,52,64);
						end
					else
						begin
							ShotPos[Player_Y].Pos:=160;
							ShotPos[Player_Y].Dir:=1;
							ShotPos[Player_Y].IsHere:=True;
							if not DemoMode then
								PlaySound(PlyShotSnd,0,74,64);
						end;
				end;
		end;
	procedure DoneShots;
		begin
			FreeMem(ShotImage[0],F_Size('SHOT_L.PBM'));
			FreeMem(ShotImage[1],F_Size('SHOT_R.PBM'));
		end;
End.