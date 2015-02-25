program ExpTest;
	uses X_Const,X_Main,X_Pal;
	var Pal:Palette;
		i:word;
	const
		NofDebris=200;
		ZFactor=400;
		Xc=160;
		Yc:integer=200;
	type
		FragRec=record
					X,Y,Z : integer;
				end;
		FragPos = array[0..NofDebris] of FragRec;
		FragSpd = array[0..NofDebris] of word;
	var
		Fragments:FragPos;
		Speed:FragSpd;
	procedure Init_Debris;
		var
			A,R:word;
			I,X,Y:byte;
		begin
			randomize;                        { Initialize stars }
			for I := 0 to NofDebris do
				begin
					A:=Random(256);
					R:=Random(10);
					Fragments[I].X := Round(R*Cos(PI*A/128));
					Fragments[I].Y := Round(R*Sin(PI*A/128));
					Fragments[I].Z := random(900)+200;
					Speed[I] := 0;
				end;
		end;
	procedure DoDebris;
		var X,Y : integer;
			I,Color : byte;
		begin
			for I := 0 to NofDebris do
				begin{ Stars }
					X:=Xc+round(Fragments[I].X*(Fragments[I].Z+Speed[I])/ZFactor);
					Y:=Yc+2*round(Fragments[I].Y*(Fragments[I].Z+Speed[I])/ZFactor);
					if (X > 0) and (X < 320) and (Y > 0) and (Y < 400) then
						begin
							Color:=8+(Fragments[I].Z div 150);
							if Color > 31 then
								Color := 31;
							PutPixel(X,Y,Color);
						end;
					inc(Fragments[I].Z,Speed[I]);
					if Fragments[I].Z > 20000 then;
					Speed[I] := (Fragments[I].Z div 150)*(5-(abs(Fragments[I].X*Fragments[I].Y) div 1000));
				end;
		end;
	procedure Init;
		var F:file of Palette;
		begin
			{Inicializa o modo gr fico}
			X_Set_Mode(X_Mode_320x400,320);
			{Carrega a palheta do disco}
			Assign(F,'PALETTE.DAT');
			Reset(F);
			Read(F,Pal);
			Close(F);
			{Ajusta a palheta}
			X_Put_Pal_Raw(Pal,256,0,False);
		end;
	procedure Done;
		begin
			X_Text_Mode;
		end;
	procedure DrawExp(Step:word);
		var i:word;
		begin
			X_ClearAll;
			DoDebris;
		end;
Begin
	Init;
	Init_Debris;
	for i:=0 to 100 do
		DrawExp(i);
	Readln;
	Done;
End.