{STORMER - Tela de introdu‡Æo}
{programado por Haroldo de Oliveira Pinheiro}
unit Intro;
interface
	procedure ShowIntro;
implementation
	uses Crt,X_Const,X_Main,X_Pal,X_Pics,Ts,Sounds;
	const
		NofStars=50;		{N£mero de estrelas na tela}
		Xc=160;				{Centro X}
		Yc=120;				{Centro Y}
		ZFactor=200;		{Fator de divisÆo Z}
	type
		StarRec=record		{Tipo usado para definir as coordenadas das estrelas}
					X,Y,Z : integer;
				end;
		StarPos = array[0..NofStars] of StarRec;	{Tipo usado para definir a posi‡Æo de cada estrela}
		StarSpd = array[0..NofStars] of word;		{Tipo usado para definir a velocidade das estrelas}
	var Stars : StarPos;	{Posi‡Æo das estrelas}
		Speed : StarSpd;	{Velocidade das estrelas}
	procedure Init_Star;
		var	i:byte;
		begin
			randomize;
			for I := 0 to NofStars do
				begin
					Stars[I].X:=random(100)-50;
					Stars[I].Y:=random(100)-50;
					Stars[I].Z:=random(900)+200;
					Speed[I]:=0;
				end;
			for i:=0 to 22 do
				X_Set_Rgb(i+233,(i*2)+19,(i*2)+19,(i*2)+19);
		end;
	procedure DoStars;
		var X,Y:integer;
			I,Color:byte;
		procedure NewStar(Num : byte);
			var X,Y:integer;
			begin
				X:=Xc+round(Stars[Num].X*Stars[Num].Z/ZFactor);
				Y:=Yc+round(Stars[Num].Y*Stars[Num].Z/ZFactor);
				if (X > 0) and (X < 320) and (Y > 0) and (Y < 240) then
					PutPixel(X,Y,0);
				Stars[Num].X := random(100)-50;
				Stars[Num].Y := random(100)-50;
				Stars[Num].Z := random(100)+200;
			end;
		begin
			for I := 0 to NofStars do
				begin
					X := Xc+round(Stars[I].X*Stars[I].Z/ZFactor);
					Y := Yc+round(Stars[I].Y*Stars[I].Z/ZFactor);
					if GetPixel(X,Y)>200 then
						PutPixel(X,Y,0);
					X := Xc+round(Stars[I].X*(Stars[I].Z+Speed[I])/ZFactor);
					Y := Yc+round(Stars[I].Y*(Stars[I].Z+Speed[I])/ZFactor);
					if (X > 0) and (X < 320) and (Y > 0) and (Y < 240) then
						begin
							Color := Stars[I].Z div 300;
							if Color > 22 then
								Color := 22;
							if GetPixel(X,Y)=0 then
								PutPixel(X,Y,233+Color);
						end
					else
						NewStar(I);
					inc(Stars[I].Z,Speed[I]);
					if Stars[I].Z > 20000 then
						NewStar(I);
					Speed[I]:=(Stars[I].Z div 150)*(5-(abs(Stars[I].X*Stars[I].Y) div 500));
				end;
		end;
	const
		DivFactor=11000 div 1000;
		SecondMusicPart:longint=(36252 div DivFactor);
		MusLength:longint=(32992 div DivFactor)+(36252 div DivFactor);
	var SndCtrl:longint;
	procedure IntroTimer;far;
		begin
			if SndCtrl=MusLength then
				PlaySound(Intro1Music,0,64,64)
			else if SndCtrl=SecondMusicPart then
				PlaySound(Intro2Music,0,64,64);
			if SndCtrl>0 then
				Dec(SndCtrl);
			HandleSounds;
		end;
	procedure ShowIntro;
		var Pal:Palette;
		begin
			X_Set_Mode(X_Mode_320x240,320);
			X_Set_Black_Pal;				{Carrega palheta escura}
			X_Load_Scr('INTRO.SCR',Pal);  	{Carrega a 1a imagem na tela}
			X_Put_Pal_Raw(Pal,256,0,false);	{Carrega a palheta da imagem}
			Init_Star;
			MusicNum:=0;
			SndCtrl:=MusLength;
			TSInit;
			TSSetRate(1000);
			TSSetRoutine(IntroTimer);
			while SndCtrl>0 do
				begin
					WaitVSyncStart;
					DoStars;
				end;
			X_Pal2Dark(Pal);				{Escurece a tela lentamente}
			TSDone;
			TSRestoreTime;
		end;
End.