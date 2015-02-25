{STORMER - Menu principal}
{programado por Haroldo de Oliveira Pinheiro}
unit Menu;
{$V-}
interface
	type
		MenuType=array[0..6] of String[80];
	Const
		Main_Menu:MenuType=(
					'®15¯S®10¯tart new game',
					'',
					'®15¯I®10¯nstructions',
					'',
					'®15¯C®10¯redits',
					'',
					'®10¯E®15¯x®10¯it to DOS');
		Menu_Instructions1:MenuType=(
					'®10¯Your objective in this game',
					'®10¯is very simple:',
					'®10¯Destroy everithing in your sight',
					'®10¯and Don''t let anything hit you.',
					'®10¯You move your ship with the mouse,',
					'®10¯and fire with any mouse button',
					'®15¯(Continued...)');
		Menu_Instructions2:MenuType=(
					'®10¯You can use the ®15¯+®10¯ and ®15¯-®10¯ keys',
					'®10¯to increase/decrease vertical mouse',
					'®10¯sensibility, and the ®15¯[®10¯ and ®15¯]®10¯ keys to',
					'®10¯adjust horizontal sensiblity.',
					'®10¯During game, you can hit ®15¯P®10¯ to pause',
					'®10¯the game, and ®15¯ESC®10¯ to return to main menu.',
					'®10¯Now, stop reading and start shooting!');
		Menu_Credits1:MenuType=(
					'®10¯This program was created in two months',
					'®10¯by Haroldo de Oliveira Pinheiro,',
					'®10¯during his spare time, using',
					'®10¯Turbo Pascal 7.0(TM).',
					'®10¯It uses the XLib graphics lybrary',
					'®10¯to handle the graphics, and',
					'®15¯(Continued...)');
		Menu_Credits2:MenuType=(
					'®10¯Digital Sound Interface Kit',
					'®10¯for the sounds.',
					'®10¯The movement of the player and enemies',
					'®10¯are handled by the timer interrupt,',
					'®10¯while the graphics routines, which are',
					'®10¯the most processor demanding part,',
					'®15¯(Continued...)');
		Menu_Credits3:MenuType=(
					'®10¯are handled by the main program loop.',
					'®10¯This way, the enemies'' position',
					'®10¯are updated even if the drawing process',
					'®10¯haven''t been completed, thus assuring',
					'®10¯that the game runs in the same speed',
					'®10¯in every computer, just with a little',
					'®15¯(Continued...)');
		Menu_Credits4:MenuType=(
					'®10¯loss of image quality in slower PC''s.',
					'®10¯',
					'®10¯Well, maybe you''re not understanding',
					'®10¯all this technical information, but',
					'®10¯this does not prevents you from having',
					'®10¯fun with this game, right?',
					'®10¯Now, stop reading and get STORMING!');
	var MenuOption:byte;
		MenuImg:pointer;
	procedure InitMenu;
	procedure HandleMenu;
	procedure DrawMenu;
	procedure DoneMenu;
implementation
	uses Crt,X_BitMap,X_FileIO,X_Text,Sounds,HiScores,Other;
	procedure InitMenu;
		var F:file;
		begin
			MenuOption:=0;
			{Carrega a tela-t¡tulo}
			GetMem(MenuImg,F_Size('TITLEPIC.PBM'));
			F_Open_Read(F,'TITLEPIC.PBM');
			BlockRead(F,MenuImg^,F_Size('TITLEPIC.PBM'));
			Close(F);
		end;
	procedure HandleMenu;
		var Key:Char;
		begin
			if KeyPressed then
				begin
					Key:=UpCase(ReadKey);
					if MenuOption=0 then
						begin
							Case Key of
								'S':begin
										MenuOption:=0;
										MusicNum:=0;
										PlaySound(Bleep1,2,64,64);
										Level:=1;
										Lives:=5;
										Score:=0;
										InitLevelCtrl:=LevInitDuration;
										DemoMode:=False;
									end;
								'I':begin
										PlaySound(Bleep2,1,64,64);
										MenuOption:=2;
									end;
								'C':begin
										PlaySound(Bleep3,1,64,64);
										MenuOption:=3;
									end;
								'X':begin
										MenuOption:=4;
									end;
								#00:begin
										Key:=ReadKey;
									end;
							end;
						end
					else
						begin
							if Key=#0 then
								ReadKey;
							case MenuOption of
								002:begin
										MenuOption:=5;
										PlaySound(Bleep2,1,64,64);
									end;
								003:begin
										MenuOption:=6;
										PlaySound(Bleep3,1,64,64);
									end;
								005:begin
										MenuOption:=0;
										PlaySound(Bleep2,1,64,64);
									end;
								006:begin
										MenuOption:=7;
										PlaySound(Bleep3,1,64,64);
									end;
								007:begin
										MenuOption:=8;
										PlaySound(Bleep3,1,64,64);
									end;
								008:begin
										MenuOption:=0;
										PlaySound(Bleep3,1,64,64);
                                	end;
								009:begin
										if not ReadingHiScores then
											begin
												MenuOption:=0;
												PlaySound(Bleep1,1,64,64);
											end
										else
											begin
												Case Key of
													'0'..'9','A'..'Z',' ':
														begin
															if Length(HiScore[HiScoreNum].Name) < HSNameLength then
																Insert(Key,HiScore[HiScoreNum].Name,Length(HiScore[HiScoreNum].Name)+1);
														end;
													#08:begin
															if Length(HiScore[HiScoreNum].Name) > 0 then
																Delete(HiScore[HiScoreNum].Name,Length(HiScore[HiScoreNum].Name),1);
														end;
													#13:begin
															if HiScore[HiScoreNum].Name='' then
																HiScore[HiScoreNum].Name:='???';
															MenuOption:=0;
															PlaySound(Bleep1,1,64,64);
														end;
												end;
											end;
									end;
							end;
						end;
				end;
		end;
	procedure DrawMenu;
		var i:byte;
		begin
			X_Put_Masked_Pbm(80,60,MenuImg^);
			case MenuOption of
				000:begin
						for i:=0 to 6 do
							E_WriteColor(0,i*20+150,0,0,Center(320,Main_Menu[i]));
					end;
				002:begin
						for i:=0 to 6 do
							E_WriteColor(0,i*20+150,0,0,Center(320,Menu_Instructions1[i]));
					end;
				003:begin
						for i:=0 to 6 do
							E_WriteColor(0,i*20+150,0,0,Center(320,Menu_Credits1[i]));
					end;
				005:begin
						for i:=0 to 6 do
							E_WriteColor(0,i*20+150,0,0,Center(320,Menu_Instructions2[i]));
					end;
				006:begin
						for i:=0 to 6 do
							E_WriteColor(0,i*20+150,0,0,Center(320,Menu_Credits2[i]));
					end;
				007:begin
						for i:=0 to 6 do
							E_WriteColor(0,i*20+150,0,0,Center(320,Menu_Credits3[i]));
					end;
				008:begin
						for i:=0 to 6 do
							E_WriteColor(0,i*20+150,0,0,Center(320,Menu_Credits4[i]));
					end;
				009:begin
						E_Write(0,150,15,0,Center(320,'High Scores'));
						if ReadingHiScores then
							begin
								E_Write(0,170,15-((MusCtrl div 300) mod 2),0,Center(320,'Type in your name'));
							end;
						for i:=1 to 5 do
							begin
								E_WriteColor(0,i*20+170,10,0,Center(320,Str(HiScore[i].Score)+
											' ®15¯-®10¯ Level '+Str(HiScore[i].Level)+' ®15¯-®10¯ '+HiScore[i].Name));
							end;
					end;
			end;
		end;
	procedure DoneMenu;
		begin
			FreeMem(MenuImg,F_Size('TITLEPIC.PBM'));
		end;
End.