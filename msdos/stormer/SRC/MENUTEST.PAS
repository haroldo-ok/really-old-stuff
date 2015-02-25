program MenuTest;
	uses X_Const,X_Main,X_Pal,X_Text,Menu,Graphics;
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
			{Inicializa o gerador de caracteres}
			X_Text_Init;
			X_Set_Font(1);
		end;
	procedure Done;
		begin
			X_Text_Mode;
		end;
	procedure Do_Menu;
		begin
			InitMenu;
			while MenuOption<>4 do
				begin
					HandleMenu;
					DrawMenu;
					SwapPages;
				end;
			DoneMenu;
		end;
Begin
	Init;
	Do_Menu;
	Done;
End.