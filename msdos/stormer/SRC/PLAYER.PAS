{STORMER - Unidade de manipula‡Æo do jogador}
{programado por Haroldo de Oliveira Pinheiro}
unit Player;
interface
	uses Mouse,Other;
	var Player_Y:word;
		Facing_R:boolean;
		PlayerImg:array[0..1] of Pointer;
		PlyExplos:Word;
	procedure InitPlayer;
	procedure HandlePlayer;
	procedure DonePlayer;
implementation
	uses Crt,X_FileIO,Enemies,Shots,Explosion,Sounds,Menu,HiScores;
	var Last_X:integer;
		Last_Y:word;
		PlyMoveDir:ShortInt;
		PlyMoveCtrl:Word;
	procedure InitPlayer;
		var F:file;
		begin
			Player_Y:=0;
			PlyExplos:=0;
			GetMem(PlayerImg[0],F_Size('PLAYER_L.PBM'));
			F_Open_Read(F,'PLAYER_L.PBM');
			BlockRead(F,PlayerImg[0]^,F_Size('PLAYER_L.PBM'));
			Close(F);
			GetMem(PlayerImg[1],F_Size('PLAYER_R.PBM'));
			F_Open_Read(F,'PLAYER_R.PBM');
			BlockRead(F,PlayerImg[1]^,F_Size('PLAYER_R.PBM'));
			Close(F);
		end;
	procedure HandlePlayer;
			var MouseLoc:LocRec;
				i,j:byte;
				Key:char;
		begin
			if DemoMode then
				begin{Demonstra‡Æo do jogo}
					if (PlyMoveDir<>-1) and (PlyMoveDir<>1) then
						begin
							If Random(2)=1 then
								PlyMoveDir:=1
							else
								PlyMoveDir:=-1;
						end;
					if PlyMoveCtrl=0 then
						begin
							if PlyMoveDir=-1 then
								begin
									if Player_Y>0 then
										Dec(Player_Y)
									else
										PlyMoveDir:=1;
								end
							else
								begin
									if Player_Y<6 then
										Inc(Player_Y)
									else
										PlyMoveDir:=-1;
								end;
							if Random(30)=15 then
								PlyMoveDir:=-PlyMoveDir;
							if Random(10)=5 then
								Facing_R:=not Facing_R;
						end;
					PlyMoveCtrl:=(PlyMoveCtrl+1) mod 30;
					Shoot;
				end
			else
				begin{Jogo real}
					if PlyExplos=0 then
						begin
							if KeyPressed then
								begin
									Key:=UpCase(ReadKey);
									case Key of
										'P':begin
												if Paused then
													begin
														MusicNum:=1;
														MusCtrl:=0;
													end
												else
													begin
														MusicNum:=0;
													end;
												PlaySound(Bleep3,2,64,64);
												Paused:=not Paused;
											end;
										'-','_':
											begin
												if MRange_Y<230 then
													Inc(MRange_Y,10);
												MRowRange(0,MRange_Y);
											end;
										'=','+':
											begin
												if MRange_Y>10 then
													Dec(MRange_Y,10);
												MRowRange(0,MRange_Y);
											end;
										'}',']':
											begin
												if HSense>1 then
													Dec(HSense);
											end;
										'{','[':
											begin
												if HSense<15 then
													Inc(HSense);
											end;
										#27:begin
												PlyExplos:=1;
												Lives:=0;
											end;
										#00:begin
												Key:=UpCase(ReadKey);
											end;
									end;
								end;
							MPos(MouseLoc);
							Last_Y:=Player_Y;
							Player_Y:=(MouseLoc.Row*7) div MRange_Y;
							if Player_Y > 6 then
								Player_Y:=6;
							if Last_X<>(MouseLoc.Column div HSense) then
								begin
									Facing_R:=Last_X < (MouseLoc.Column div HSense);
									Last_X:=MouseLoc.Column div HSense;
								end;
							if MouseLoc.ButtonStatus<>0 then
								Shoot;
							if Abs(EnemyInfo[0][Player_Y].Pos-160) < 15 then{ColisÆo}
								begin
									PlyExplos:=2000;
									InitPlyExp;
									PlaySound(PlyExpSnd,0,64,64);
									if (not DemoMode) and (Lives>0) then
										Dec(Lives);
								end;
						end
					else if PlyExplos=1 then
						begin
							Dec(PlyExplos);
							if (not DemoMode) and (Lives=0) then
								begin
									MusicNum:=2;
									MusCtrl:=0;
									MenuOption:=9;
									Paused:=false;
									UpdateHiScores;
									DemoMode:=true;
								end;
							for i:=0 to 2 do
								for j:=0 to 6 do
									EnemyInfo[i][j].Pos:=326;
						end
					else if PlyExplos > 1000 then
						begin
							Dec(PlyExplos);
							if PlyExplos mod 7 = 0 then
								HandlePlyExp;
						end
					else
						begin
							Dec(PlyExplos);
						end;
				end;
		end;
	procedure DonePlayer;
		begin
			FreeMem(PlayerImg[0],F_Size('PLAYER_L.PBM'));
			FreeMem(PlayerImg[1],F_Size('PLAYER_R.PBM'));
		end;
End.