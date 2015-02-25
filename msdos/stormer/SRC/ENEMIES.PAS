{STORMER - Unidade de manipulaá∆o de inimigos}
{programado por Haroldo de Oliveira Pinheiro}
unit Enemies;
interface
	Const
		MaxEnemyImg=12;
		EnemyDelay:array[0..Pred(MaxEnemyImg)] of word=(27,25,23,20,18,15,12,
														9,7,5,3,0);
	type
		Enemy = record
					ImgNum:byte;
					Pos:integer;
					MoveDly:word;
					MoveCtrl:word;
					Dir:ShortInt;
				end;
		EnemyPos=array[0..6] of Enemy;
	var EnemyInfo:array[0..2] of EnemyPos;	{0=Posiá∆o atual 1,2:Èltima posiá∆o nas p†ginas 1 e 2}
		EnemyImg:array[0..Pred(MaxEnemyImg),0..1] of Pointer;
		EnemyLeft:longint;
	Procedure InitEnemy;
	Procedure HandleEnemy;
	Procedure DoneEnemy;
implementation
	uses Crt,X_Main,X_Bitmap,X_FileIO,Player,Shots,Sounds,Other;
	function IntToStr(I:Longint):String;
		var S:string[11];
		begin
			Str(I,S);
			IntToStr:=S;
		end;
	Procedure InitEnemy;
		var i,j:byte;
			F:file;
		begin
			{Carrega as imagens}
			for i:=0 to Pred(MaxEnemyImg) do
				begin
					GetMem(EnemyImg[i,0],F_Size('ENM'+IntToStr(i+1)+'_L.PBM'));
					F_Open_Read(F,'ENM'+IntToStr(i+1)+'_L.PBM');
					BlockRead(F,EnemyImg[i,0]^,F_Size('ENM'+IntToStr(i+1)+'_L.PBM'));
					Close(F);
					GetMem(EnemyImg[i,1],F_Size('ENM'+IntToStr(i+1)+'_R.PBM'));
					F_Open_Read(F,'ENM'+IntToStr(i+1)+'_R.PBM');
					BlockRead(F,EnemyImg[i,1]^,F_Size('ENM'+IntToStr(i+1)+'_R.PBM'));
					Close(F);
				end;
			{Reseta as posiá‰es}
			for i:=0 to 2 do
				for j:=0 to 6 do
					EnemyInfo[i][j].Pos:=326;
		end;
	Procedure HandleEnemy;
		var i:byte;
		begin
			{Observaá∆o: o inimigo Ç desenhado numa rotina separada, manipulada pelo loop de jogo,
			 enquanto que estas rotinas s∆o manipuladas pela interrupá∆o de timer}
			for i:=0 to 6 do
				begin
					{Checa se o inimigo foi atingido}
					if ShotPos[i].IsHere and (Abs(EnemyInfo[0][i].Pos-ShotPos[i].Pos)<21) then
						begin
							if not DemoMode then
								begin
									if (EnemyInfo[0][i].Pos+10>-1) and (EnemyInfo[0][i].Pos+10<320) then
										PlaySound(EnmExpSnd,1,28 + ((EnemyInfo[0][i].Pos+20) * 108 div 320),64)
									else if EnemyInfo[0][i].Pos < -9 then
										PlaySound(EnmExpSnd,1,26,64)
									else if EnemyInfo[0][i].Pos > 319 then
										PlaySound(EnmExpSnd,1,110,64)
								end;
							EnemyInfo[0][i].Pos:=329;
							ShotPos[i].IsHere:=false;
							Inc(Score,(EnemyDelay[0]-EnemyDelay[EnemyInfo[0][i].ImgNum]) * 17);
							if EnemyLeft>0 then
								Dec(EnemyLeft)
							else if not DemoMode then
								begin
									if Level < LastLevel then
										Inc(Level);
									InitLevelCtrl:=LevInitDuration;
								end;
						end;
					{Move os inimigos}
					if (EnemyInfo[0][i].Pos<-16) or (EnemyInfo[0][i].Pos>325) then
						begin
							if Random(2)=0 then
								begin
									EnemyInfo[0][i].Pos:=-16;
									EnemyInfo[0][i].Dir:=1;
								end
							else
								begin
									EnemyInfo[0][i].Pos:=325;
									EnemyInfo[0][i].Dir:=-1;
								end;
							EnemyInfo[0][i].ImgNum:=Random(MaxEnemyImg-(LastLevel-Level));
							EnemyInfo[0][i].MoveDly:=(EnemyDelay[EnemyInfo[0][i].ImgNum] * (Succ(LastLevel)-Level)) div LastLevel;
						end
					else
						begin
							if EnemyInfo[0][i].MoveCtrl=0 then
								begin
									EnemyInfo[0][i].MoveCtrl:=EnemyInfo[0][i].MoveDly;
									Inc(EnemyInfo[0][i].Pos,EnemyInfo[0][i].Dir);
								end
							else
								begin
									Dec(EnemyInfo[0][i].MoveCtrl);
								end;
						end;
				end;
		end;
	Procedure DoneEnemy;
		var i:byte;
		begin
			for i:=0 to Pred(MaxEnemyImg) do
				begin
					FreeMem(EnemyImg[i,0],F_Size('ENM'+IntToStr(i+1)+'_L.PBM'));
					FreeMem(EnemyImg[i,1],F_Size('ENM'+IntToStr(i+1)+'_R.PBM'));
				end;
		end;
End.