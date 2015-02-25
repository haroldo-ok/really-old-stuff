program TestEffect;
	uses Crt,X_Const,X_Pal,Graph13h,Lists;
	var Pal:Palette;
		i,j,k:word;
		Stars:array[0..255] of Vector;
		V1,V2:Vector;
		StColor,EdColor:integer;
	procedure HLine(X,Y:integer;Len:integer;Color:byte);
		begin
			if (Y >= MinY) and (Y <= MaxY) and (X <= MaxX) then
				begin
					if X < MinX then
						begin
							Dec(Len,MinX-X);
							X:=MinX;
						end;
					if (Len <> 0) and (X+Len > MaxX) then
						begin
							Len:=MaxX-X+1;
						end;
					if Len <> 0 then
						begin
							asm
								les di, [ScrBuf]
								mov ax, Y
								shl ax, 6
								add di, ax
								shl ax, 2
								add di, ax
								add di, X
								mov cx, Len
								mov al, Color
								rep stosb
							end;
						end;
				end;
		end;
	procedure VLine(X,Y:integer;Len:integer;Color:byte);
		begin
			if (X >= MinX) and (X <= MaxX) and (Y <= MaxY) then
				begin
					if Y < MinY then
						begin
							Dec(Len,MinY-Y);
							Y:=MinY;
						end;
					if (Len <> 0) and (Y+Len > MaxY) then
						begin
							Len:=MaxY-Y+1;
						end;
					if Len <> 0 then
						begin
							asm
								les di, [ScrBuf]
								mov ax, Y
								shl ax, 6
								add di, ax
								shl ax, 2
								add di, ax
								add di, X
								mov cx, Len
								mov al, Color
							  @RowLoop:
								mov es:[di], al
								add di, 320
								loop @RowLoop
							end;
						end;
				end;
		end;
	procedure InterpolateVector(var Dest:Vector;V1,V2:Vector;I,Max:longint);
		begin
			Dest.X:=((Longint(V1.X)*(Max-I))+(Longint(V2.X)*I)) div Max;
			Dest.Y:=((Longint(V1.Y)*(Max-I))+(Longint(V2.Y)*I)) div Max;
			Dest.Z:=((Longint(V1.Z)*(Max-I))+(Longint(V2.Z)*I)) div Max;
		end;
	procedure MakeGradPal(var Pal:Palette;StartColor:byte;StartRGB:Vector;EndColor:byte;EndRGB:Vector);
		var i:byte;
			NewRGB:Vector;
		begin
			for i:=0 to (EndColor-StartColor) do
				begin
					InterPolateVector(NewRGB,StartRGB,EndRGB,i,EndColor-StartColor);
					Pal[i+StartColor,0]:=NewRGB.X shr 2;
					Pal[i+StartColor,1]:=NewRGB.Y shr 2;
					Pal[i+StartColor,2]:=NewRGB.Z shr 2;
				end;
		end;
	procedure InitStars(Mode:string;StarCount:byte);
		var i:byte;
			CountX,CountY:integer;
		begin
			CountX:=MaxX-MinX+1;
			CountY:=MaxY-MinY+1;
			if Pos('x',Mode) <> 0 then
				begin
					for i:=0 to Pred(StarCount) do
						begin
							Stars[i].Z:=Random(255)+1;
							Stars[i].X:=Longint(Random(CountX))*Stars[i].Z div 256;
							Stars[i].Y:=Longint(Random(CountY))*Stars[i].Z div 256;
						end;
				end
			else if Pos('y',Mode) <> 0 then
				begin
					for i:=0 to Pred(StarCount) do
						begin
							Stars[i].Z:=Random(255)+1;
							Stars[i].X:=Longint(Random(CountX))*Stars[i].Z div 256;
							Stars[i].Y:=Longint(Random(CountY))*Stars[i].Z div 256;
						end;
				end
			else if Pos('z',Mode) <> 0 then
				begin
					for i:=0 to Pred(StarCount) do
						begin
							Stars[i].Z:=Random(255)+1;
							Stars[i].X:=Longint(Random(CountX)-160)*Stars[i].Z div 64;
							Stars[i].Y:=Longint(Random(CountY)-100)*Stars[i].Z div 64;
						end;
				end;
		end;
	procedure MoveStars(Mode:string;StarCount:byte;Speed:integer);
		var i:byte;
			ModeCod:byte;
			CountX,CountY:integer;
			nX,nY:integer;
		begin
			CountX:=MaxX-MinX+1;
			CountY:=MaxY-MinY+1;
			if Pos('x',Mode) <> 0 then
				ModeCod:=0
			else if Pos('y',Mode) <> 0 then
				ModeCod:=1
			else if Pos('z',Mode) <> 0 then
				ModeCod:=2;
			for i:=0 to 255 do
				begin
					with Stars[i] do
						begin
							case ModeCod of
								0:X:=X+Speed;
								1:Y:=Y+Speed;
								2:Z:=Z+Speed;
							end;
							if Z <> 0 then
								begin
									nX:=(Longint(X)*256) div Z;
									nY:=(Longint(Y)*256) div Z;
								end;
							if (ModeCod <> 2) and (nX >= MinX) and (nX <= MaxX) and (nY >= MinX) and (nY <= MaxX) then
								begin
								end
							else if (ModeCod = 2) and (Z > 0) and (Z < 256) then
								begin
								end
							else
								begin
									case ModeCod of
										0:begin
											Z:=Random(255)+1;
											if Speed < 0 then
												X:=Longint(Random(20)+MaxX-20)*Z div 256
											else
												X:=Longint(Random(20))*Z div 256;
											Y:=Random(200);
										  end;
										1:begin
											Z:=Random(255)+1;
											X:=Random(320);
											if Speed < 0 then
												Y:=Longint(Random(20)+MaxY-20)*Z div 256
											else
												Y:=Longint(Random(20))*Z div 256;
										  end;
										2:begin
											if Speed < 0 then
												Z:=255
											else
												Z:=0;
											X:=Random(CountX)-160;
											Y:=Random(CountX)-100;
										  end;
									end;
								end;
						end;
			end;
		end;
	procedure DrawStars(Mode:string;StarCount:byte;StartColor,EndColor:byte);
		var i:byte;
			ModeCod:byte;
			DirCod:byte;
			nX,nY:integer;
			Color,ColorCount:byte;
		begin
			if Pos('n',Mode) <> 0 then
				ModeCod:=0
			else if Pos('h',Mode) <> 0 then
				ModeCod:=1
			else if Pos('v',Mode) <> 0 then
				ModeCod:=2;
			DirCod:=0;
			if Pos('z',Mode) <> 0 then
				DirCod:=2;
			ColorCount:=EndColor-StartColor;
			for i:=0 to 255 do
				begin
					with Stars[i] do
						begin
							if Z <> 0 then
								begin
									if DirCod = 0 then
										begin
											nX:=(Longint(X)*256) div Z + MinX;
											nY:=(Longint(Y)*256) div Z + MinX;
										end
									else
										begin
											nX:=(Longint(X)*256) div Z+((MinX+MaxX) shr 1);
											nY:=(Longint(Y)*256) div Z+((MinY+MaxY) shr 1);
										end;
								end;
							if (nX >= MinX) and (nX <= MaxX) and (nY >= MinY) and (nY < MaxY) then
								begin
									Color:=EndColor-(Longint(Z)*ColorCount div 255);
									case ModeCod of
										0:ScrBuf^[nY,nX]:=Color;
										1:HLine(nX,nY,16,Color);
										2:VLine(nX,nY,16,Color);
									end;
								end;
						end;
			end;
		end;
Begin
	StColor:=0;
	EdColor:=255;
	FillChar(Pal,SizeOf(Pal),0);
	V1.X:=0;
	V1.Y:=0;
	V1.Z:=0;
	V2.X:=255;
	V2.Y:=255;
	V2.Z:=255;
	MakeGradPal(Pal,StColor,V1,EdColor,V2);

	Randomize;
	InitGraph13h;
	X_Put_Pal_Raw(Pal,256,0,False);

	InitStars('xn',255);
	repeat
		ClearBuffer(ScrBuf^);
		MoveStars('xn',255,-8);
		DrawStars('xn',255,StColor,EdColor);
		WaitVSyncStart;
		Buffer2Screen(ScrBuf^);
	until KeyPressed;
	Readln;

	InitStars('xh',255);
	repeat
		ClearBuffer(ScrBuf^);
		MoveStars('xh',255,-8);
		DrawStars('xh',255,StColor,EdColor);
		WaitVSyncStart;
		Buffer2Screen(ScrBuf^);
	until KeyPressed;
	Readln;

	InitStars('zn',255);
	repeat
		ClearBuffer(ScrBuf^);
		MoveStars('zn',255,-8);
		DrawStars('zn',255,StColor,EdColor);
		WaitVSyncStart;
		Buffer2Screen(ScrBuf^);
	until KeyPressed;
	Readln;

	InitStars('yv',255);
	repeat
		ClearBuffer(ScrBuf^);
		MoveStars('yv',255,8);
		DrawStars('yv',255,StColor,EdColor);
		WaitVSyncStart;
		Buffer2Screen(ScrBuf^);
	until KeyPressed;
	Readln;

	InitStars('yv',255);
	repeat
		ClearBuffer(ScrBuf^);
		MoveStars('yv',255,-8);
		DrawStars('yv',255,StColor,EdColor);
		WaitVSyncStart;
		Buffer2Screen(ScrBuf^);
	until KeyPressed;
	Readln;

	InitStars('zn',255);
	repeat
		ClearBuffer(ScrBuf^);
		MoveStars('zn',255,8);
		DrawStars('zn',255,StColor,EdColor);
		WaitVSyncStart;
		Buffer2Screen(ScrBuf^);
	until KeyPressed;
	Readln;

	InitStars('xh',255);
	repeat
		ClearBuffer(ScrBuf^);
		MoveStars('xh',255,8);
		DrawStars('xh',255,StColor,EdColor);
		WaitVSyncStart;
		Buffer2Screen(ScrBuf^);
	until KeyPressed;
	Readln;

	CloseGraph13h;
End.