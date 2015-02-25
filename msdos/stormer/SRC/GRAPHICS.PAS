{STORMER - Unidade de manipula‡Æo de gr ficos}
{programado por Haroldo de Oliveira Pinheiro}
{utiliza a ferrementa XLIB, por Themie Gouthas e Christian Harms}
unit Graphics;
interface
	uses X_Const;
	var Pal:Palette;
	procedure LoadNormPal;
	procedure SwapPages;
	procedure LevelInitScreen_Draw;
	procedure LevelInitScreen_Rotate;
	procedure DrawGrid;
	procedure Draw_All;
implementation
	uses Crt,X_Main,X_Pal,X_Text,X_Bitmap,Enemies,Player,Shots,Explosion,Sounds,Other;
	procedure LoadNormPal;
		var F:file of Palette;
		begin
			{Carrega a palheta do disco}
			Assign(F,'PALETTE.DAT');
			Reset(F);
			Read(F,Pal);
			Close(F);
			{Ajusta a palheta}
			X_Put_Pal_Raw(Pal,256,0,False);
		end;
	procedure SwapPages;
		begin
			if Page then
				begin
					X_Set_Visible_Start_Addr(0,0);	{Seleciona a p gina visual}
					X_Set_Activ_Start_Addr(0,400);	{Seleciona a p gina ativa}
					ClearScreen(400,800,0);			{Limpa a p gina ativa}
				end
			else
				begin
					X_Set_Visible_Start_Addr(0,400);{Seleciona a p gina visual}
					X_Set_Activ_Start_Addr(0,0);	{Seleciona a p gina ativa}
					ClearScreen(0,399,0); 	 		{Limpa a p gina ativa}
				end;
			Page:=not Page;							{Inverte a vari vel}
		end;
	procedure LevelInitScreen_Draw;
		var i,j:word;
		begin
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
			{Desenha o fundo}
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
			E_WriteInt(156,192,255,63,Level);
		end;
	procedure LevelInitScreen_Rotate;
		var Tmp:Palette;
		begin
			Move(Pal[5],Tmp[0],250*3);
			Move(Pal[0],Tmp[123],5*3);
			Move(Tmp[0],Pal[0],255*3);
			X_Put_Pal_Raw(Pal,256,0,true);
		end;
	procedure DrawGrid;
		procedure DrawLine(Y:Integer);
			begin
				{Lado direito}
				Line(172,Y,312,Y,185);
				Line(172,Y+1,313,Y+1,187);
				Line(172,Y+2,313,Y+2,189);
				Line(172,Y+3,313,Y+3,187);
				Line(172,Y+4,312,Y+4,185);
				{Lado esquerdo}
				Line(7,Y,147,Y,185);
				Line(6,Y+1,147,Y+1,187);
				Line(6,Y+2,147,Y+2,189);
				Line(6,Y+3,147,Y+3,187);
				Line(7,Y+4,147,Y+4,185);
			end;
		begin
			{Borda externa}
			Rectangle(5,20,314,370,185);
			Line(6,21,313,21,187);
			Rectangle(6,22,313,368,189);
			Line(6,23,313,23,187);
			Line(6,367,313,367,187);
			Rectangle(7,24,312,366,185);
			Line(6,369,313,369,187);
			{Linhas centrais}
			DrawLine(70);
			DrawLine(120);
			DrawLine(170);
			DrawLine(220);
			DrawLine(270);
			DrawLine(320);
		end;
	procedure Draw_All;
		var i:byte;
			X,Y:integer;
			Color:byte;
		begin
			X_Set_Clip_Rect(8,24,311,366);
			{Desenha os tiros}
			for i:=0 to 6 do
				if ShotPos[i].IsHere then
					begin
						if ShotPos[i].Dir=-1 then
							X_Put_Masked_Pbm_ClipX(ShotPos[i].Pos,(50*i)+26,ShotImage[0]^)
						else
							X_Put_Masked_Pbm_ClipX(ShotPos[i].Pos,(50*i)+26,ShotImage[1]^);
					end;
			{Desenha os inimigos}
			for i:=0 to 6 do
				begin
					if EnemyInfo[0][i].Dir=-1 then
						X_Put_Masked_Pbm_ClipX(EnemyInfo[0][i].Pos,(50*i)+26,EnemyImg[EnemyInfo[0][i].ImgNum,0]^)
					else
						X_Put_Masked_Pbm_ClipX(EnemyInfo[0][i].Pos,(50*i)+26,EnemyImg[EnemyInfo[0][i].ImgNum,1]^);
				end;
			{Desenha o jogador}
			if PlyExplos=0 then
				begin
					if not Facing_R then
						X_Put_Masked_Pbm(150,(50*Player_Y)+26,PlayerImg[0]^)
					else
						X_Put_Masked_Pbm(150,(50*Player_Y)+26,PlayerImg[1]^);
				end
			else if PlyExplos > 1000 then
				begin
					for i:=0 to NofDebris do
						begin
							X:=Xc+round(Fragments[i].X*(Fragments[i].Z+Speed[i])/ZFactor);
							Y:=Yc+2*round(Fragments[i].Y*(Fragments[i].Z+Speed[i])/ZFactor);
							if (X > 5) and (X < 314) and (Y > 20) and (Y < 370) then
								begin
									Color:=8+(Fragments[I].Z div 150);
									if Color > 31 then
										Color := 31;
									PutPixel(X,Y,Color);
								end;
						end;
				end;
			{Escreve o n£mero de vidas ou informa pausa}
			if Paused then
				X_Write(0,380,14+((MusCtrl div 300) mod 2),Center(320,'P A U S E D'))
			else if DemoMode or (Lives=0) then
				X_Write(0,380,14+((MusCtrl div 300) mod 2),Center(320,'G A M E   O V E R'))
			else
				E_WriteColor(0,380,10,6,Center(320,'®15¯LIVES: ®10¯'+Str(Lives)+'®15¯  SCORE: ®10¯'+Str(Score)));
		end;
End.