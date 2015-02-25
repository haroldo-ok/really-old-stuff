{STORMER - Programa principal}
{programado por Haroldo de Oliveira Pinheiro}
program TestGame;
	uses Crt,X_Const,X_Main,X_Text,X_FileIO,X_Pal,Ts,Mouse,Player,Enemies,Shots,Graphics,Sounds,Intro,Menu,HiScores,Other;
	var Rst:ResetRec;
		ReloadPal:boolean;
		i,j:byte;
	procedure MyTimerProc;far;
		begin
			if InitLevelCtrl=0 then
				begin
					if not Paused then
						begin
							HandleEnemy;
							HandlePlayer;
							HandleShots;
						end
					else if KeyPressed then
						begin
							MusicNum:=1;
							MusCtrl:=0;
							Paused:=false;
							if ReadKey=#0 then
								ReadKey;
							PlaySound(Bleep3,1,64,64);
						end;
					if DemoMode then
						HandleMenu;
				end
			else if InitLevelCtrl=1 then
				begin
					ReloadPal:=true;
				end
			else if InitLevelCtrl<>LevInitDuration then
				begin
					Dec(InitLevelCtrl);
				end;
			HandleSounds;
		end;
Begin
	Init_MasterFile('STORMER.DAT');
	InitSounds;
	ShowIntro;
	X_ClearAll;
	SwapPages;
	MReset(Rst);
	MRowRange(0,230);
	MRange_Y:=230;
	HSense:=2;
	X_Set_Mode(X_Mode_320x400,320);
	X_Text_Init;
	X_Set_Font(1);
	LoadNormPal;
	Level:=4;
	DemoMode:=true;
	Paused:=false;
	InitMenu;
	InitEnemy;
	InitPlayer;
	InitShots;
	InitHiScores;
	MusicNum:=2;
	InitLevelCtrl:=0;
	TSInit;
	TSSetRate(1000);
	TSSetRoutine(MyTimerProc);
	while MenuOption<>4 do
		begin
			if InitLevelCtrl=0 then
				begin
					DrawGrid;
					Draw_All;
					if DemoMode then
						DrawMenu;
					SwapPages;
				end
			else if InitLevelCtrl=1 then
				begin
					X_Pal2Dark(Pal);
					X_ClearAll;
					LoadNormPal;
					for i:=0 to 2 do
						for j:=0 to 6 do
							EnemyInfo[i][j].Pos:=326;
					for i:=0 to 6 do
						ShotPos[i].IsHere:=False;
					MusicNum:=1;
					MusCtrl:=0;
					InitLevelCtrl:=0;
				end
			else if InitLevelCtrl=LevInitDuration then
				begin
					MusicNum:=0;
					X_Pal2Dark(Pal);
					X_ClearAll;
					LevelInitScreen_Draw;
					SwapPages;
					PlaySound(Intro2Music,2,64,64);
					EnemyLeft:=200+(Level*100);
					Dec(InitLevelCtrl);
				end
			else
				begin
					LevelInitScreen_Rotate;
				end;
		end;
	MusicNum:=0;
	PlaySound(Bleep2,2,64,64);
	X_Pal2Dark(Pal);
	while KeyPressed do
		ReadKey;
	TSDone;
	TSRestoreTime;
	DoneMenu;
	DoneEnemy;
	DonePlayer;
	DoneShots;
	DoneSounds;
	DoneHiScores;
	Close_MasterFile;
	X_Text_Mode;
	Writeln('Thank you for playing STORMER!');
End.
