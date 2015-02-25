unit AnimUnit;
{Interpretador de script de anima‡Æo - Rotinas principais}
{programado por Haroldo de Oliveira Pinheiro}
interface
    uses Graph13h,Lists;
	const
		TextX:integer=10;
		TextY:integer=165;
    var Str2Write:string;
        StrColor:byte;
    procedure LoadAnim(var Anim:AnimPack;FileName:string);
	procedure PlayAnimFrame(var Anim:AnimPack;Frame:longint;Anim2Play:string);
	procedure DrawAnimFrame(var Anim:AnimPack;var Pal:Palette;Frame:longint;Anim2Play:string);
    procedure ResetAnim(var Anim:AnimPack);
implementation
    uses AnimParser,SndDrv;
	procedure InterpolateVector(var Dest:Vector;V1,V2:Vector;I,Max:longint);
		begin
			Dest.X:=((Longint(V1.X)*(Max-I))+(Longint(V2.X)*I)) div Max;
			Dest.Y:=((Longint(V1.Y)*(Max-I))+(Longint(V2.Y)*I)) div Max;
			Dest.Z:=((Longint(V1.Z)*(Max-I))+(Longint(V2.Z)*I)) div Max;
		end;
	procedure LoadAnim(var Anim:AnimPack;FileName:string);
		begin
			ReadAnimScript(Anim,FileName);
		end;
	procedure PlayAnimFrame(var Anim:AnimPack;Frame:longint;Anim2Play:string);
		var Anm:PAnimSlice;
			Spr:PSprite;
			SprSeq:PSpriteSeq;
            Sound:PSoundFX;
			k:longint;
		begin
			Anm:=GetAnim(Anim.Anims,Anim2Play)^.First;
			while Anm <> nil do
				begin
					Spr:=GetSprite(Anim.Sprites,Anm^.SprName);
					SprSeq:=GetSpriteSeq(Anim.SpriteSeqs,Anm^.SprName);
					Sound:=GetSoundEffect(Anim.Sounds,Anm^.SprName);
					with Anm^ do
						begin
							case AType of
								anPlace:
									begin
										if Frame=PlaceTime then
											begin
												if Spr <> nil then
													Spr^.ImgPos:=PlacePos
												else if SprSeq <> nil then
													SprSeq^.ImgPos:=PlacePos;
											end;
									end;
								anPath:
									begin
										if (Frame >= PathStart) and (Frame <= PathEnd) then
											begin
												if PathCount > 1 then
													k:=(PathEnd-PathStart) div Pred(PathCount)
												else
													k:=PathEnd-PathStart;
												if Spr <> nil then
													begin
														InterPolateVector(Spr^.ImgPos,
																		  PathPos[(Frame-PathStart) div k],PathPos[((Frame-PathStart) div k)+1],
																		  (Frame-PathStart) mod k,k+1);
													end
												else if SprSeq <> nil then
													begin
														InterPolateVector(SprSeq^.ImgPos,
																		  PathPos[(Frame-PathStart) div k],PathPos[((Frame-PathStart) div k)+1],
																		  (Frame-PathStart) mod k,k+1);
													end;
											end;
									end;
								anShow:
									begin
										if Frame=ShowTime then
											begin
												if Spr <> nil then
                                                    begin
    													Spr^.Visible:=true;
                                                    end
												else if SprSeq <> nil then
                                                    begin
    													SprSeq^.Visible:=true;
                                                        SprSeq^.Current:=SprSeq^.First;
                                                        SprSeq^.TimeCounter:=0;
                                                    end;
											end;
									end;
								anHide:
									begin
										if Frame=HideTime then
											begin
												if Spr <> nil then
													Spr^.Visible:=false
												else if SprSeq <> nil then
													SprSeq^.Visible:=false;
											end;
									end;
								anWrite:
									begin
										if (Frame >= WriteStart) and (Frame <= WriteEnd) then
											begin
												if (WriteDly <> 0) and (Frame < WriteDly) then
													Str2Write:=Copy(WriteStr^,1,Length(WriteStr^)*(Frame-WriteStart) div WriteDly)
												else
													Str2Write:=WriteStr^;
												StrColor:=WriteColor;
											end;
									end;
								anStar:
									begin
										if (Frame >= StarStart) and (Frame <= StarEnd) then
											begin
												MoveStars(StarKind,StarCount,StarSpeed,StarPos^);
											end;
									end;
                                anBackg:
                                    begin
										if (Frame >= BackgStart) and (Frame <= BackgEnd) then
											begin
                                                Inc(BackgPos.X,BackgSpeed.X);
                                                Inc(BackgPos.Y,BackgSpeed.Y);
                                                Inc(BackgPos.Z,BackgSpeed.Z);
											end;
                                    end;
								anSound:
									begin
										if Frame=SoundTime then
											begin
												if Sound <> nil then
                                                    PlaySoundEffect(Sound^.Sound);
											end;
									end;
							end;
						end;
					Anm:=Anm^.Next;
				end;
			SprSeq:=Anim.SpriteSeqs.First;
            while SprSeq <> nil do
                begin
                    if SprSeq^.Visible then
                        begin
                            Inc(SprSeq^.TimeCounter);
                        end;
                    SprSeq:=SprSeq^.Next;
                end;
		end;
	procedure DrawAnimFrame(var Anim:AnimPack;var Pal:Palette;Frame:longint;Anim2Play:string);
		var Anm:PAnimSlice;
            Spr:PSprite;
            Seq:PSpriteSeq;
            Aux:byte;
        begin
            FillChar(Pal[0],3,0); //Assegura que a cor zero seja a cor preta
			Anm:=GetAnim(Anim.Anims,Anim2Play)^.First;
			while Anm <> nil do
				begin
					with Anm^ do
						begin
							case AType of
								anStar:
									begin
										if (Frame >= StarStart) and (Frame <= StarEnd) then
											begin
												DrawStars(StarKind,StarCount,StarStartColor,StarEndColor,StarPos^);
												Move(StarPal^[StarStartColor],Pal[StarStartColor],(StarEndColor-StarStartColor+1)*3);
											end;
									end;
                                anFlash:
                                    begin
										if (Frame >= FlashStart) and (Frame <= FlashEnd) then
											begin
                                                Aux:=((Frame-FlashStart) div FlashPeriod) mod FlashCount;
												Pal[0,0]:=FlashColor[Aux].X shr 2;
												Pal[0,1]:=FlashColor[Aux].Y shr 2;
												Pal[0,2]:=FlashColor[Aux].Z shr 2;
											end;
                                    end;
                                anBackg:
                                    begin
										if (Frame >= BackgStart) and (Frame <= BackgEnd) then
											begin
                                                Spr:=GetSprite(Anim.Sprites,SprName);
                                                if Spr <> nil then
                                                    begin
                            							TexturizeBackGround(Spr^.ImgOfs.X+(BackgPos.X div 10),
	                            											Spr^.ImgOfs.Y+(BackgPos.Y div 10),
	                            											Spr^.Sprite^);
                            							if Spr^.StartColor+Spr^.Colors <= 256 then
			                            					Move(Spr^.Pal[Spr^.StartColor],Pal[Spr^.StartColor],Spr^.Colors*3);
                                                    end;
                                            end;
                                    end;
							end;
						end;
					Anm:=Anm^.Next;
				end;
			Spr:=Anim.Sprites.First;
			while Spr <> nil do
				begin
					if Spr^.Visible then
						begin
                            if Spr^.ImgPos.Z = 0 then
                                begin
        							DisplayRawImageClip(Spr^.ImgOfs.X+Spr^.ImgPos.X,
	        											Spr^.ImgOfs.Y+Spr^.ImgPos.Y,
	        											Spr^.Sprite^);
                                end
                            else
                                begin
           							DisplayRawImageStretch(160+(Spr^.ImgPos.X+Spr^.ImgOfs.X-160)*(Spr^.ImgPos.Z+255) div 255,
                                                           100+(Spr^.ImgPos.Y+Spr^.ImgOfs.Y-100)*(Spr^.ImgPos.Z+255) div 255,
                                                           160+(Spr^.ImgPos.X+Spr^.ImgOfs.X+Spr^.Sprite^.Width-160)*(Spr^.ImgPos.Z+255) div 255,
                    	                                   100+(Spr^.ImgPos.Y+Spr^.ImgOfs.Y+Spr^.Sprite^.Height-100)*(Spr^.ImgPos.Z+255) div 255,
                                                           Spr^.Sprite^);
                                end;
							if Spr^.StartColor+Spr^.Colors <= 256 then
								Move(Spr^.Pal[Spr^.StartColor],Pal[Spr^.StartColor],Spr^.Colors*3);
						end;
					Spr:=Spr^.Next;
				end;
            Seq:=Anim.SpriteSeqs.First;
            while Seq <> nil do
                begin
					if Seq^.Visible then
						begin
                            Spr:=Seq^.Current^.Sprite;
                            if Seq^.ImgPos.Z = 0 then
                                begin
        							DisplayRawImageClip(Spr^.ImgOfs.X+Seq^.ImgPos.X,
	        											Spr^.ImgOfs.Y+Seq^.ImgPos.Y,
	        											Spr^.Sprite^);
                                end
                            else
                                begin
           							DisplayRawImageStretch(160+(Seq^.ImgPos.X+Spr^.ImgOfs.X-160)*(Seq^.ImgPos.Z+255) div 255,
                                                           100+(Seq^.ImgPos.Y+Spr^.ImgOfs.Y-100)*(Seq^.ImgPos.Z+255) div 255,
                                                           160+(Seq^.ImgPos.X+Spr^.ImgOfs.X+Spr^.Sprite^.Width-160)*(Seq^.ImgPos.Z+255) div 255,
                    	                                   100+(Seq^.ImgPos.Y+Spr^.ImgOfs.Y+Spr^.Sprite^.Height-100)*(Seq^.ImgPos.Z+255) div 255,
                                                           Spr^.Sprite^);
                                end;
							if Spr^.StartColor+Spr^.Colors <= 256 then
								Move(Spr^.Pal[Spr^.StartColor],Pal[Spr^.StartColor],Spr^.Colors*3);
                            if Seq^.TimeCounter > Seq^.Current^.Duration then
                                begin
                                    Seq^.TimeCounter:=0;
                                    Seq^.Current:=Seq^.Current^.Next;
                                    if Seq^.Current = nil then
                                        Seq^.Current:=Seq^.First;
                                end;
						end;
                    Seq:=Seq^.Next;
                end;
			OutTextFmt(TextX,TextY,StrColor,Str2Write);
        end;
    procedure ResetAnim(var Anim:AnimPack);
        var Spr:PSprite;
            Seq:PSpriteSeq;
        begin
            Spr:=Anim.Sprites.First;
            while Spr <> nil do
                begin
                    Spr^.Visible:=false;
                    Spr:=Spr^.Next;
                end;
            Seq:=Anim.SpriteSeqs.First;
            while Seq <> nil do
                begin
                    Seq^.Visible:=false;
                    Seq:=Seq^.Next;
                end;
        end;
End.