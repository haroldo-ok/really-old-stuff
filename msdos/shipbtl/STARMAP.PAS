program TestStarMap;
	uses Crt,X_Const,X_Pal,X_Bitmap,Keybd,Screen;
	const
		YRatio=200/240;
	type
		XYZ=record
				X,Y,Z:integer;
				Color:byte;
			end;
		ColorMapType=array[0..31,0..255] of byte;
	var Pal:Palette;
		RotX,RotY,RotZ:byte;
		i:byte;
		Stars:array[0..255] of XYZ;
		X,Y,Z:longint;
		tX,tY,tZ:longint;
		R,T:real;
		Depht:integer;
		ColorMap:ColorMapType;
	procedure LoadPal;
		var F:file;
		begin
			Assign(F,'PALETTE.DAT');
			Reset(F,1);
			BlockRead(F,Pal,SizeOf(Pal));
			X_Put_Pal_Raw(Pal,256,0,false);
			Close(F);
			Assign(F,'COLORMAP.DAT');
			Reset(F,1);
			BlockRead(F,ColorMap,SizeOf(ColorMap));
			Close(F);
		end;
	procedure Rot2D(var X,Y:longint;Rot:real);
		var SinRot,CosRot:real;                         {Seno e cosseno da rota‡Æo}
			Tx,Ty:longint;								{Vari veis tempor rias}
		begin
			SinRot:=Sin(Rot);
			CosRot:=Cos(Rot);
			Tx:=X;
			Ty:=Y;
			X:=Round(( Tx * CosRot ) + ( Ty * SinRot ));
			Y:=Round((-Tx * SinRot ) + ( Ty * CosRot ));
		end;
	procedure DrawFrame;
		var i:word;
		begin
			FillChar(Mem[$A000:$0000],320*200,7);
			FillChar(Mem[$A000:320*199],320,0);
			for i:=0 to 319 do
				begin
					Mem[$A000:i]:=15;
					Mem[$A000:(320*198)+i]:=8;
				end;
			for i:=0 to 256 do
				begin
					Mem[$A000:(320*2)+3+i]:=8;
					Mem[$A000:(320*196)+2+i]:=15;
				end;
			for i:=0 to 193 do
				begin
					Mem[$A000:(320*(2+i))+2]:=8;
					Mem[$A000:(320*(3+i))+256+3]:=15;
					Mem[$A000:(320*(2+i))+256+3+2]:=8;
					Mem[$A000:(320*(2+i))+256+3+3]:=15;
					Mem[$A000:(320*(3+i))+320-3]:=15;
					Mem[$A000:(320*(3+i))+320-4]:=8;
				end;
			for i:=0 to 55 do
				begin
					Mem[$A000:(320*2)+256+3+3+i]:=8;
					Mem[$A000:(320*196)+256+3+3+i]:=15;
				end;
			for i:=0 to 53 do
				begin
					Mem[$A000:(320*3)+256+4+3+i]:=15;
					Mem[$A000:(320*195)+256+3+3+i]:=8;
				end;
			for i:=0 to 198 do
				begin
					Mem[$A000:(320*i)]:=15;
					Mem[$A000:(320*(i+1))+319]:=8;
				end;
		end;
Begin
	InitKeyboard;
	InitScreen;
	LoadPal;
	CleanBuf:=True;
	RotX:=0;
	RotY:=0;
	RotZ:=0;
	Z:=100;
	Randomize;
	for i:=0 to 255 do
		begin
			Stars[i].X:=Random(100)-50;
			Stars[i].Y:=Random(100)-50;
			Stars[i].Z:=Random(100)-50;
			Stars[i].Color:=Random(256);
		end;
	DrawFrame;
	while not Keys[scEsc] do
		begin
			ClearBuffer;
			for i:=0 to 255 do
				begin
					tX:=Stars[i].X;
					tY:=Stars[i].Y;
					tZ:=Stars[i].Z;
					Rot2D(tX,tY,RotZ*PI/128);
					Rot2D(tX,tZ,RotY*PI/128);
					Rot2D(tY,tZ,RotX*PI/128);
					tZ:=tZ+Z;
					if tZ > 0 then
						begin
							X:=Round(255*tX/tZ);
							Y:=Round(255*YRatio*tY/tZ);
						end
					else
						begin
							X:=Round(255*tX*(1-tZ));
							Y:=Round(255*YRatio*tY*(1-tZ));
						end;
					Depht:=Round(16-((tZ-100)/10));
					if Depht > 31 then
						Depht:=31;
					if Depht < 0 then
						Depht:=0;
					Inc(X,128);
					Inc(Y,97);
					if (X >= 0) and (X < 256) and (Y >= 0) and (Y < 194) then
						ScrBuf^[Y,X]:=ColorMap[Depht,Stars[i].Color];
				end;
			if Keys[scUp] then
				RotX:=RotX+1;
			if Keys[scDown] then
				RotX:=RotX-1;
			if Keys[scLeft] then
				RotY:=RotY-1;
			if Keys[scRight] then
				RotY:=RotY+1;
			if Keys[scZ] then
				RotZ:=RotZ-1;
			if Keys[scX] then
				RotZ:=RotZ+1;
			if Keys[scQ] then
				Inc(Z);
			if Keys[scA] then
				Dec(Z);
			WaitVSyncStart;
			Buffer2Screen;
		end;
	DoneScreen;
	DoneKeyboard;
End.