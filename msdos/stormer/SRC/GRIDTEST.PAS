program GridTest;
	uses X_Const,X_Main,X_Pal;
	var Pal:Palette;
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
Begin
	Init;
	DrawGrid;
	Readln;
	Done;
End.