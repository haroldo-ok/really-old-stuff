program GridTest;
	uses Crt,X_Const,X_Main,X_Pal,X_Text;
	var Pal:Palette;
	procedure Init;
		var i:byte;
		begin
			{Inicializa o modo gr fico}
			X_Set_Mode(X_Mode_320x400,320);
			X_Text_Init;
			X_Set_Font(1);
			{Cria a palheta}
			FillChar(Pal,SizeOf(Pal),0);
			for i:=0 to 63 do
				begin
					Pal[i,2]:=i;
					Pal[64+i,2]:=63-i;
				end;
			Pal[255,0]:=63;
			Pal[255,1]:=63;
			Pal[255,2]:=63;
			{Ajusta a palheta}
			X_Put_Pal_Raw(Pal,256,0,False);
		end;
	procedure Done;
		begin
			X_Text_Mode;
		end;
	procedure DrawScreen;
		var i,j:word;
		begin
			for i:=0 to 399 do
				begin
					Line(0,i,50,i,i and 127);
					Line(269,i,319,i,i and 127);
				end;
			for i:=51 to 268 do
				begin
					Line(i,340,i,399,(i * 3) and 127);
					Line(i,0,i,59,((269-i) * 3) and 127);
				end;
			for i:=60 to 339 do
				begin
					Line(51,i,81,i,(339-i) and 127);
					Line(238,i,268,i,(339-i) and 127);
				end;
			for i:=82 to 237 do
				if (i div 10) and 1 = 0 then
					begin
						for j:=60 to 102 do
							begin
								PutPixel(i,j,(j shl 1) and 127);
								PutPixel(i,399-j,(j shl 1) and 127);
							end;
					end
				else
					begin
						for j:=60 to 102 do
							begin
								PutPixel(i,j,((101-j) shl 1) and 127);
								PutPixel(i,399-j,((101-j) shl 1) and 127);
							end;
					end;
			for i:=103 to 296 do
				if (i div 30) and 1 = 0 then
					begin
						for j:=82 to 102 do
							begin
								PutPixel(j,i,(j shl 1) and 127);
								PutPixel(319-j,i,(j shl 1) and 127);
							end;
					end
				else
					begin
						for j:=82 to 102 do
							begin
								PutPixel(j,i,((102-j) shl 1) and 127);
								PutPixel(319-j,i,((102-j) shl 1) and 127);
							end;
					end;
			for i:=103 to 296 do
				begin
					Line(103,i,123,i,i and 127);
					Line(196,i,216,i,i and 127);
				end;
			for i:=124 to 195 do
				begin
					Line(i,103,i,153,(i * 3) and 127);
					Line(i,295,i,245,((269-i) * 3) and 127);
				end;
			for i:=154 to 244 do
				begin
					Line(124,i,139,i,(244-(i shl 1)) and 127);
					Line(195,i,180,i,(i shl 1) and 127);
				end;
			for i:=140 to 179 do
				begin
					Line(i,154,i,170,(179-(i shl 2)) and 127);
					Line(i,244,i,228,(i shl 2) and 127);
				end;
			for i:=170 to 228 do
				begin
					Line(140,i,150,i,(i shl 1) and 127);
					Line(179,i,169,i,(244-(i shl 1)) and 127);
				end;
			for i:=140 to 179 do
				begin
					Line(i,170,i,180,(179-(i shl 2)) and 127);
					Line(i,228,i,218,(i shl 2) and 127);
				end;
			E_WriteInt(156,192,255,63,1);
		end;
	procedure RotPal;
		var Tmp:Palette;
		begin
			Move(Pal[1],Tmp[0],254*3);
			Move(Pal[0],Tmp[127],3);
			Move(Tmp[0],Pal[0],255*3);
			X_Put_Pal_Raw(Pal,256,0,false);
			Delay(5);
		end;
Begin
	Init;
	DrawScreen;
	while not KeyPressed do
		RotPal;
	while KeyPressed do
		ReadKey;
	Done;
End.