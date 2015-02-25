unit AnimParser;
{Interpretador de script de animaá∆o - Leitura do arquivo}
{programado por Haroldo de Oliveira Pinheiro}
interface
    {$PACKRECORDS 1}
	uses PCXUnit,Lists;
	var SprList:^SpriteList;
        SprSeqList:^SpriteSeqList;
        SoundList:^SoundEffectList;
		Anims:^AnimList;
	procedure ReadAnimScript(var Anim:AnimPack;FileName:string);
implementation
	uses Graph13h,Utils,Console,SndDrv;
	const
		Alpha=['A'..'Z','a'..'z','_'];
		Number=['0'..'9','-','+'];
		Symbol=['(',',',')'];
    function IntToStr(N:longint):string;
        var S:string;
        begin
            Str(N,S);
            IntToStr:=S;
        end;
	procedure GetVect(var V:Vector;var S:String);
		var Token:string;
			Step:byte;
			Junk:integer;
		begin
			V.X:=0;
			V.Y:=0;
			V.Z:=0;
			Token:=GetToken(S);
			Step:=0;
			while (Token <> ')') and (Token <> '') do
				begin
					if Token[1] in Number then
						begin
							case Step of
								0:Val(Token,V.X,Junk);
								1:Val(Token,V.Y,Junk);
								2:Val(Token,V.Z,Junk);
							end;
							if Junk <> 0 then
								WritelnCon(ANSI_LTRED+'  Erro lendo n£mero: '+Token+' '+IntToStr(Junk))
							else
								Inc(Step);
						end;
					Token:=GetToken(S);
				end;
		end;
	function ReadNumber(S:string):longint;
		var N:Longint;
			Junk:integer;
		begin
			Val(S,N,Junk);
			if Junk <> 0 then
				begin
					WritelnCon(ANSI_LTRED+'  Erro lendo n£mero: '+S+' '+IntToStr(Junk));
				end;
			ReadNumber:=N;
		end;
    var BaseDir:string;
	procedure AddSprite(var T:Text;S:string);
		var Token:string;
			Junk:integer;
			Spr:PSprite;
		begin
			Token:=GetToken(S);
			if Token <> '' then
				begin
					WritelnCon(ANSI_YELLOW+'Sprite: '+Token);
				end
			else
				begin
					WritelnCon(ANSI_LTRED+'Erro: Sprite n∆o possui um nome');
				end;
			Spr:=CreateSprite(SprList^,Token);
			Spr^.ImgOfs.X:=0;
			Spr^.ImgOfs.Y:=0;
			Spr^.ImgOfs.Z:=0;
			Spr^.StartColor:=1;
			Spr^.Colors:=255;
			Spr^.ImgPos.X:=0;
			Spr^.ImgPos.Y:=0;
			Spr^.ImgPos.Z:=0;
			Spr^.Visible:=false;
			Readln(T,S);
			Token:=GetToken(S);
			while (not Eof(T)) and (Token <> '#end') do
				begin
					while Token<>'' do
						begin
							if Token='image' then
								begin
									Token:=GetToken(S);
									if Token[1]='"' then
										begin
											WritelnCon(ANSI_GRAY+'  Arquivo: '+Token);
											AllocReadPCX(Spr^.Sprite,BaseDir+Copy(Token,2,Length(Token)));
											GetPCXPalette(Spr^.Pal,BaseDir+Copy(Token,2,Length(Token)));
										end;
									Token:=GetToken(S);
									if Token='(' then
										GetVect(Spr^.ImgOfs,S);
								end
							else if Token='colors' then
								begin
									Token:=GetToken(S);
									Spr^.Colors:=ReadNumber(Token);
									Token:=GetToken(S);
									if Token <> '' then
										Spr^.StartColor:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
						end;
					Readln(T,S);
					Token:=GetToken(S);
				end;
			ReIndexColors(Spr^.Sprite^,Spr^.Pal,
						  Spr^.Colors,Spr^.StartColor);
		end;
	procedure AddSpriteSeq(var T:Text;S:string);
		var Token:string;
			Junk:integer;
			Spr:PSprite;
            Seq:PSpriteSeq;
            Frame:PSpriteFrame;
		begin
			Token:=GetToken(S);
			if Token <> '' then
				begin
					WritelnCon(ANSI_YELLOW+'SpriteSeq: '+Token);
				end
			else
				begin
					WritelnCon(ANSI_LTRED+'Erro: Sequància n∆o possui um nome');
				end;

            Seq:=CreateSpriteSeq(SprSeqList^,Token);
            Seq^.TimeCounter:=0;
            Seq^.ImgPos.X:=0;
            Seq^.ImgPos.Y:=0;
            Seq^.ImgPos.Z:=0;
            Seq^.Visible:=false;

			Readln(T,S);
			Token:=GetToken(S);
			while (not Eof(T)) and (Token <> '#end') do
				begin
					while Token<>'' do
						begin
							if Token='frame' then
								begin
									Token:=GetToken(S);
									if Token <> '' then
										begin
											WritelnCon(ANSI_GRAY+'  Frame: '+Token);
                                            Spr:=GetSprite(SprList^,Token);
                                            Frame:=AddSpriteToSeq(Seq^,Spr);
										end;
									Token:=GetToken(S);
									if Token <> '' then
                                        Frame^.Duration:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
						end;
					Readln(T,S);
					Token:=GetToken(S);
				end;
		end;
	procedure AddSound(var T:Text;S:string);
		var Token:string;
			SFX:PSoundFX;
		begin
			Token:=GetToken(S);
			if Token <> '' then
				begin
					WritelnCon(ANSI_YELLOW+'Som: '+Token);
				end
			else
				begin
					WritelnCon(ANSI_LTRED+'Erro: Som n∆o possui um nome');
				end;
			SFX:=CreateSoundEffect(SoundList^,Token);
			Readln(T,S);
			Token:=GetToken(S);
			while (not Eof(T)) and (Token <> '#end') do
				begin
					while Token<>'' do
						begin
							if Token='rawsound' then
								begin
									Token:=GetToken(S);
									if Token[1]='"' then
										begin
											WritelnCon(ANSI_GRAY+'  Arquivo: '+Token);
											LoadSoundEffect(SFX^.Sound,BaseDir+Copy(Token,2,Length(Token)));
										end;
								end;
							Token:=GetToken(S);
						end;
					Readln(T,S);
					Token:=GetToken(S);
				end;
		end;
	procedure AddAnim(var T:Text;S:string);
		var Token:string;
			Junk:integer;
			Anim:PAnimSlice;
			List:PAnimSliceList;
		begin
			Token:=GetToken(S);
			if Token <> '' then
				begin
					WritelnCon(ANSI_YELLOW+'Anim: '+Token);
				end
			else
				begin
					WritelnCon(ANSI_LTRED+'Erro: Animaá∆o n∆o possui um nome');
				end;
			List:=CreateAnim(Anims^,Token);
            List^.Duration:=300;
			Token:=GetToken(S);
            if Token <> '' then
                begin
                    WritelnCon(ANSI_GRAY+'  Duraá∆o: '+Token);
                    List^.Duration:=ReadNumber(Token);
                end;
			ReadLn(T,S);
			Token:=GetToken(S);
			while (not Eof(T)) and (Token <> '#end') do
				begin
					if Token = 'place' then
						begin
							Anim:=CreateAnimSlice(List^);
							Anim^.AType:=anPlace;
                            Anim^.PlaceTime:=0;
							Token:=GetToken(S);
							if Token <> '' then
								begin
                                    WriteCon(ANSI_YELLOW+'  ->');
									WritelnCon(ANSI_GRAY+'Place.Sprite: '+Token);
									Anim^.SprName:=Token;
								end
							else
								begin
									WritelnCon(ANSI_LTRED+'  Erro: Sprite n∆o possui um nome');
								end;
							Token:=GetToken(S);
							GetVect(Anim^.PlacePos,S);
							Token:=GetToken(S);
                            if Token <> '' then
                                begin
                                    Anim^.PlaceTime:=ReadNumber(Token);
                                end;
						end
					else if Token = 'path' then
						begin
							Anim:=CreateAnimSlice(List^);
							Anim^.AType:=anPath;
							Anim^.PathCount:=0;
							Token:=GetToken(S);
							if Token <> '' then
								begin
                                    WriteCon(ANSI_YELLOW+'  ->');
									WritelnCon(ANSI_GRAY+'Path.Sprite: '+Token);
									Anim^.SprName:=Token;
								end
							else
								begin
									WritelnCon(ANSI_LTRED+'  Erro: Sprite n∆o possui um nome');
								end;
							Token:=GetToken(S);
							Anim^.PathEnd:=ReadNumber(Token);
							Token:=GetToken(S);
							Anim^.PathStart:=ReadNumber(Token);
							Token:=GetToken(S);
							while S <> '' do
								begin
									if Token='(' then
										begin
											GetVect(Anim^.PathPos[Anim^.PathCount],S);
											Inc(Anim^.PathCount);
										end;
									Token:=GetToken(S);
								end;
						end
					else if Token = 'show' then
						begin
							Anim:=CreateAnimSlice(List^);
							Anim^.AType:=anShow;
							Anim^.ShowTime:=0;
							Token:=GetToken(S);
							if Token <> '' then
								begin
                                    WriteCon(ANSI_YELLOW+'  ->');
									WritelnCon(ANSI_GRAY+'Show.Sprite: '+Token);
									Anim^.SprName:=Token;
								end
							else
								begin
									WritelnCon(ANSI_LTRED+'  Erro: Sprite n∆o possui um nome');
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.ShowTime:=ReadNumber(Token);
								end;
						end
					else if Token = 'hide' then
						begin
							Anim:=CreateAnimSlice(List^);
							Anim^.AType:=anHide;
							Token:=GetToken(S);
							if Token <> '' then
								begin
                                    WriteCon(ANSI_YELLOW+'  ->');
									WritelnCon(ANSI_GRAY+'Hide.Sprite: '+Token);
									Anim^.SprName:=Token;
								end
							else
								begin
									WritelnCon(ANSI_LTRED+'  Erro: Sprite n∆o possui um nome');
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.HideTime:=ReadNumber(Token);
								end;
						end
					else if Token = 'write' then
						begin
							Anim:=CreateAnimSlice(List^);
							Anim^.AType:=anWrite;
							Token:=GetToken(S);
							if Token <> '' then
								begin
                                    WriteCon(ANSI_YELLOW+'  ->');
									WritelnCon(ANSI_GRAY+'Write.Text: '+Token);
									if Token[1]='"' then
										Token:=Copy(Token,2,Length(Token));
									New(Anim^.WriteStr);
									Anim^.WriteStr^:=Token;
								end
							else
								begin
									WritelnCon('Erro: Nada a escrever');
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.WriteColor:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.WriteStart:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.WriteEnd:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.WriteDly:=ReadNumber(Token);
								end;
						end
					else if Token = 'stars' then
						begin
							Anim:=CreateAnimSlice(List^);
							Anim^.AType:=anStar;
							Token:=GetToken(S);
							if Token <> '' then
								begin
                                    WriteCon(ANSI_YELLOW+'  ->');
									WriteLnCon(ANSI_GRAY+'Stars.StarKind: '+Token);
									Anim^.StarKind:=Token;
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.StarStart:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.StarEnd:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.StarStartColor:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									GetVect(Anim^.StarStartRGB,S);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.StarEndColor:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									GetVect(Anim^.StarEndRGB,S);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.StarCount:=ReadNumber(Token);
									GetMem(Anim^.StarPos,Anim^.StarCount*SizeOf(Vector));
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.StarSpeed:=ReadNumber(Token);
								end;
							New(Anim^.StarPal);
							MakeGradPal(Anim^.StarPal^,Anim^.StarStartColor,Anim^.StarStartRGB,
													   Anim^.StarEndColor,Anim^.StarEndRGB);
							InitStars(Anim^.StarKind,Anim^.StarCount,Anim^.StarPos^);
						end
					else if Token = 'flash' then
						begin
							Anim:=CreateAnimSlice(List^);
							Anim^.AType:=anFlash;
							Anim^.FlashCount:=0;
    						Token:=GetToken(S);
							Anim^.FlashEnd:=ReadNumber(Token);
							Token:=GetToken(S);
							Anim^.FlashStart:=ReadNumber(Token);
							Token:=GetToken(S);
							Anim^.FlashPeriod:=ReadNumber(Token);
                            WriteCon(ANSI_YELLOW+'  ->');
							WritelnCon(ANSI_GRAY+'Flash: '+
                                       IntToStr(Anim^.FlashStart)+' '+
                                       IntToStr(Anim^.FlashEnd)+' '+
                                       IntToStr(Anim^.FlashPeriod));
							Token:=GetToken(S);
							while S <> '' do
								begin
									if Token='(' then
										begin
											GetVect(Anim^.FlashColor[Anim^.FlashCount],S);
											Inc(Anim^.FlashCount);
										end;
									Token:=GetToken(S);
								end;
						end
					else if Token = 'background' then
						begin
							Anim:=CreateAnimSlice(List^);
							Anim^.AType:=anBackg;
                            Anim^.BackgStart:=0;
                            Anim^.BackgEnd:=0;
                            Anim^.BackgPos.X:=0;
                            Anim^.BackgPos.Y:=0;
                            Anim^.BackgPos.Z:=0;
                            Anim^.BackgSpeed.X:=0;
                            Anim^.BackgSpeed.Y:=0;
                            Anim^.BackgSpeed.Z:=0;
							Token:=GetToken(S);
							if Token <> '' then
								begin
                                    WriteCon(ANSI_YELLOW+'  ->');
									WritelnCon(ANSI_GRAY+'Background: '+Token);
									Anim^.SprName:=Token;
								end
							else
								begin
									WritelnCon(ANSI_LTRED+'  Erro: Sprite n∆o possui um nome');
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.BackgEnd:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.BackgStart:=ReadNumber(Token);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									GetVect(Anim^.BackgSpeed,S);
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									GetVect(Anim^.BackgPos,S);
                                    Anim^.BackgPos.X:=Anim^.BackgPos.X*10;
                                    Anim^.BackgPos.Y:=Anim^.BackgPos.Y*10;
                                    Anim^.BackgPos.Z:=Anim^.BackgPos.Z*10;
								end;
						end
					else if Token = 'playsound' then
						begin
							Anim:=CreateAnimSlice(List^);
							Anim^.AType:=anSound;
                            Anim^.SoundTime:=0;
							Token:=GetToken(S);
							if Token <> '' then
								begin
                                    WriteCon(ANSI_YELLOW+'  ->');
									WritelnCon(ANSI_GRAY+'Sound: '+Token);
									Anim^.SprName:=Token;
								end
							else
								begin
									WritelnCon(ANSI_LTRED+'  Erro: Som n∆o possui um nome');
								end;
							Token:=GetToken(S);
							if Token <> '' then
								begin
									Anim^.SoundTime:=ReadNumber(Token);
								end;
						end;
					ReadLn(T,S);
					Token:=GetToken(S);
				end;
		end;
	procedure ReadAnimScript(var Anim:AnimPack;FileName:string);
		var T:Text;
			S,Token:String;
		begin
			Assign(T,FileName);
			Reset(T);
            BaseDir:=GetBaseDir(FileName);
			InitSpriteList(Anim.Sprites);
			InitSpriteSeqList(Anim.SpriteSeqs);
			InitSoundEffectList(Anim.Sounds);
			InitAnimList(Anim.Anims);
			SprList:=Addr(Anim.Sprites);
			SprSeqList:=Addr(Anim.SpriteSeqs);
			SoundList:=Addr(Anim.Sounds);
			Anims:=Addr(Anim.Anims);
			while not Eof(T) do
				begin
					Readln(T,S);
					while S <> '' do
						begin
							Token:=GetToken(S);
							if Token='#sprite' then
								AddSprite(T,S);
							if Token='#spriteseq' then
								AddSpriteSeq(T,S);
							if Token='#sound' then
								AddSound(T,S);
							if Token='#anim' then
								AddAnim(T,S);
						end;
				end;
			Close(T);
		end;
End.