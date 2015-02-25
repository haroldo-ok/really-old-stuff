program AnimScript;
	uses Crt,TimerUnit,Graph13h,PCXUnit,Lists,Parser;
	const
		TextX:integer=10;
		TextY:integer=165;
	var Spr:PSprite;
		Pal:Palette;
		i,j,k:word;
		Anm:PAnimSlice;
       	Anim:AnimPack;
    	Anim2Play:string;
		Str2Write:string;
        AnimLength:longint;
		StrColor:byte;
	procedure InterpolateVector(var Dest:Vector;V1,V2:Vector;I,Max:longint);
		begin
			Dest.X:=((Longint(V1.X)*(Max-I))+(Longint(V2.X)*I)) div Max;
			Dest.Y:=((Longint(V1.Y)*(Max-I))+(Longint(V2.Y)*I)) div Max;
			Dest.Z:=((Longint(V1.Z)*(Max-I))+(Longint(V2.Z)*I)) div Max;
		end;
	procedure PlayAnimFrame(Frame:longint);
		var Anm:PAnimSlice;
            k:longint;
		begin
			Anm:=GetAnim(Anim.Anims,Anim2Play)^.First;
			while Anm <> nil do
				begin
					Spr:=GetSprite(SprList^,Anm^.SprName);
					with Anm^ do
						begin
							case AType of
								anPlace:
									begin
										if Frame=PlaceTime then
											Spr^.ImgPos:=PlacePos;
									end;
								anPath:
									begin
										if (Frame >= PathStart) and (Frame <= PathEnd) then
											begin
												if PathCount > 1 then
													k:=(PathEnd-PathStart) div Pred(PathCount)
												else
													k:=PathEnd-PathStart;
												InterPolateVector(Spr^.ImgPos,
																  PathPos[(Frame-PathStart) div k],PathPos[((Frame-PathStart) div k)+1],
																  (Frame-PathStart) mod k,k+1);
											end;
									end;
								anShow:
									begin
										if Frame=ShowTime then
											Spr^.Visible:=true;
									end;
								anHide:
									begin
										if Frame=HideTime then
											Spr^.Visible:=false;
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
							end;
						end;
					Anm:=Anm^.Next;
				end;
		end;
Begin
	ClrScr;
	ReadAnimScript(Anim,'TEST.ANS');
	Readln;
	InitGraph13h;
	LoadFont('FONT.BIN');
	i:=0;
	j:=0;
	Anim2Play:='Main';
    SetTimer(100);
	MaxY:=160;
    AnimLength:=GetAnim(Anim.Anims,Anim2Play)^.Duration;
	while i < AnimLength do
		begin
            i:=Timers[0];
			while j < i do
				begin
					PlayAnimFrame(j);
					Inc(j);
				end;
			ClearBuffer(ScrBuf^);
			Anm:=GetAnim(Anim.Anims,Anim2Play)^.First;
			while Anm <> nil do
				begin
					with Anm^ do
						begin
							case AType of
								anStar:
									begin
										if (j >= StarStart) and (j <= StarEnd) then
											begin
												DrawStars(StarKind,StarCount,StarStartColor,StarEndColor,StarPos^);
												Move(StarPal^[StarStartColor],Pal[StarStartColor],(StarEndColor-StarStartColor+1)*3);
											end;
									end;
							end;
						end;
					Anm:=Anm^.Next;
				end;
			Spr:=SprList^.First;
			while Spr <> nil do
				begin
					if Spr^.Visible then
						begin
							DisplayRawImageClip(Spr^.ImgOfs.X+Spr^.ImgPos.X,
												Spr^.ImgOfs.Y+Spr^.ImgPos.Y,
												Spr^.Sprite^);
							if Spr^.StartColor+Spr^.Colors <= 256 then
								Move(Spr^.Pal[Spr^.StartColor],Pal[Spr^.StartColor],Spr^.Colors*3);
						end;
					Spr:=Spr^.Next;
				end;
			OutTextFmt(TextX,TextY,StrColor,Str2Write);
			WaitVSyncStart;
			Buffer2Screen(ScrBuf^);
			PutPal(Pal);
		end;
	Readln;
    CleanUpTimer;
	CloseGraph13h;
End.
