program Rotate;
	uses Crt,X_Const,X_Pal,X_Bitmap,Keybd,RotateDraw,Screen,SoundSystem,Ships;
	const
		YRatio1:real=200/240;
		YRatio2:real=240/200;
		MultFactor=$7F;
		MinX=-950;
		MaxX=950;
		MinY=-950;
		MaxY=950;
		Accel=1;
		MaxSpd=32;
	type
		Buffer=record
					X,Y:byte;
					Pic:array[0..64000] of byte;
			   end;
		ShipRec=record
					X,Y:real;
					XSpd,YSpd:real;
					Rot:byte;
				end;
	var Pal:Palette;
		i,j:longint;
		Color:integer;
		Ship:array[0..1] of ShipRec;
{		X,Y:real;
		X2,Y2:real;
		XSpd,YSpd:real;
		XSpd2,YSpd2:real;
		Rot,Rot2:byte;}
		ShotX,ShotY:array[0..5] of real;
		SXSpd,SYSpd:array[0..5] of real;
		SRot:array[0..5] of byte;
		ShotOn:array[0..5] of word;
		ShotNum:byte;
		ShotDelay:byte;
		Zoom:real;
		Key:char;
	procedure LoadPal;
		var F:file;
			i,j:byte;
		begin
			Assign(F,'PALETTE.DAT');
			Reset(F,1);
			BlockRead(F,Pal,SizeOf(Pal));
			Close(F);
		end;
	function RecenterX(X:real):real;
		begin
			X:=X-MaxX;
			if X < MinX then
				X:=MaxX+(X-MinX);
			RecenterX:=X;
		end;
	function RecenterY(Y:real):real;
		begin
			Y:=Y-MaxY;
			if Y < MinY then
				Y:=MaxY+(Y-MinY);
			RecenterY:=Y;
		end;
	procedure Recenter;
		var rX,rY,rX2,rY2:real;
			rSX,rSY:array[0..5] of real;
			i:word;
		begin
			rX:=RecenterX(Ship[0].X);
			rY:=RecenterY(Ship[0].Y);
			rX2:=RecenterX(Ship[1].X);
			rY2:=RecenterY(Ship[1].Y);
			for i:=0 to 5 do
				begin
					rSX[i]:=RecenterX(ShotX[i]);
					rSY[i]:=RecenterY(ShotY[i]);
				end;
			if Abs(Ship[0].X-Ship[1].X) > Abs(rX-rX2) then
				begin
					Ship[0].X:=rX;
					Ship[1].X:=rX2;
					for i:=0 to 5 do
						ShotX[i]:=rSX[i];
				end;
			if Abs(Ship[0].Y-Ship[1].Y) > Abs(rY-rY2) then
				begin
					Ship[0].Y:=rY;
					Ship[1].Y:=rY2;
					for i:=0 to 5 do
						ShotY[i]:=rSY[i];
				end;
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
	procedure ControlShip(Num:byte);
		begin
			if Sqr(Ship[Num].XSpd)+Sqr(Ship[Num].YSpd) > Sqr(MaxSpd) then
				begin
					if Ship[Num].XSpd > 0 then
						Ship[Num].XSpd:=Sqrt(Sqr(Ship[Num].XSpd*MaxSpd)/(Sqr(Ship[Num].XSpd)+Sqr(Ship[Num].YSpd)))
					else
						Ship[Num].XSpd:=-Sqrt(Sqr(Ship[Num].XSpd*MaxSpd)/(Sqr(Ship[Num].XSpd)+Sqr(Ship[Num].YSpd)));
					if Ship[Num].YSpd > 0 then
						Ship[Num].YSpd:=Sqrt(Sqr(Ship[Num].YSpd*MaxSpd)/(Sqr(Ship[Num].XSpd)+Sqr(Ship[Num].YSpd)))
					else
						Ship[Num].YSpd:=-Sqrt(Sqr(Ship[Num].YSpd*MaxSpd)/(Sqr(Ship[Num].XSpd)+Sqr(Ship[Num].YSpd)));
				end;
			Ship[Num].X:=Ship[Num].X+Ship[Num].XSpd;
			Ship[Num].Y:=Ship[Num].Y+Ship[Num].YSpd;
			if Ship[Num].X < MinX then
				Ship[Num].X:=MaxX+(Ship[Num].X-MinX);
			if Ship[Num].X > MaxX then
				Ship[Num].X:=MinX+(Ship[Num].X-MaxX);
			if Ship[Num].Y < MinY then
				Ship[Num].Y:=MaxY+(Ship[Num].Y-MinY);
			if Ship[Num].Y > MaxY then
				Ship[Num].Y:=MinY+(Ship[Num].Y-MaxY);
		end;
Begin
	InitScreen;
	InitSoundSystem;
	InitRotationEngine;
	LoadPal;
	X_Put_Pal_Raw(Pal,256,0,false);
	LoadPix(0,'UR_QUAN.PCX');
	LoadPix(1,'ARILOU.PCX');
	LoadPix16(0,'URQ_SHOT.PCX');
	InitStars;
	DrawFrame;
	Key:=#0;
	Ship[0].Rot:=0;
	Ship[1].Rot:=0;
	Zoom:=1;
	Module:=NewModule('BATTLE.S3M');
	InitKeyboard;
	CleanBuf:=true;
	Ship[0].X:=-64;
	Ship[0].Y:=0;
	Ship[1].X:=64;
	Ship[1].Y:=0;
	Ship[0].XSpd:=0;
	Ship[0].YSpd:=0;
	Ship[1].XSpd:=0;
	Ship[1].YSpd:=0;
	for i:=0 to 5 do
		ShotOn[i]:=0;
	ShotNum:=0;
	ShotDelay:=0;
	while not Keys[scEsc] do
		begin
			ClearBuffer;
			Xc:=(Ship[0].X+Ship[1].X)/2;
			Yc:=(Ship[0].Y+Ship[1].Y)/2;
			DrawStars(Zoom);
			for i:=0 to 5 do
				begin
					if ShotOn[i] > 0 then
						begin
							DrawShot(ShotX[i],ShotY[i],SRot[i],Zoom,0);
						end;
				end;
			DrawShip(Ship[0].X,Ship[0].Y,Ship[0].Rot,Zoom,0);
			DrawShip(Ship[1].X,Ship[1].Y,Ship[1].Rot,Zoom,1);
			WaitVSyncStart;
			Buffer2Screen;
			Zoom:=Sqrt(Sqr(Ship[0].X-Ship[1].X)+Sqr(Ship[0].Y-Ship[1].Y));
			if Zoom=0 then
				Zoom:=MinZoom
			else
				begin
					Zoom:=96/Zoom;
					if Zoom > MaxZoom then
						Zoom:=MaxZoom;
					if Zoom < MinZoom then
						Zoom:=MinZoom;
				end;
			{Nave 1}
			if Keys[scLeft] then
				Dec(Ship[0].Rot,3);
			if Keys[scRight] then
				Inc(Ship[0].Rot,3);
			if Keys[scUp] then
				begin
					Ship[0].XSpd:=Ship[0].XSpd+(Accel*Sin(PI*Ship[0].Rot/128));
					Ship[0].YSpd:=Ship[0].YSpd-(Accel*Cos(PI*Ship[0].Rot/128));
				end;
			if Keys[scAlt] and (ShotDelay=0) then
				begin
					i:=0;
					while (i < 6) and (ShotOn[i] > 0) do
						Inc(i);
					if i < 6 then
						begin
							SRot[i]:=Ship[0].Rot;
							ShotX[i]:=Ship[0].X+16*Sin(PI*Ship[0].Rot/128);
							ShotY[i]:=Ship[0].Y-16*Cos(PI*Ship[0].Rot/128);
							SXSpd[i]:=34*Sin(PI*Ship[0].Rot/128)+Ship[0].XSpd;
							SYSpd[i]:=-34*Cos(PI*Ship[0].Rot/128)+Ship[0].YSpd;
							ShotOn[i]:=30;
							ShotDelay:=3;
						end;
				end;
			ControlShip(0);
			{Nave 2}
			if Keys[scH] then
				Dec(Ship[1].Rot);
			if Keys[scK] then
				Inc(Ship[1].Rot);
			if Keys[scU] then
				begin
					Ship[1].XSpd:=Ship[1].XSpd+(Accel*Sin(PI*Ship[1].Rot/128));
					Ship[1].YSpd:=Ship[1].YSpd-(Accel*Cos(PI*Ship[1].Rot/128));
				end;
			ControlShip(1);
			for i:=0 to 5 do
				begin
					if ShotOn[i] > 0 then
						begin
							ShotX[i]:=ShotX[i]+SXSpd[i];
							ShotY[i]:=ShotY[i]+SYSpd[i];
							Dec(ShotOn[i]);
						end;
				end;
			if ShotDelay > 0 then
				Dec(ShotDelay);
			Recenter;
		end;
	DoneKeyboard;
	StopModule(Module);
	DoneRotationEngine;
	DoneSoundSystem;
	DoneScreen;
End.