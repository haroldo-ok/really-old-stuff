program TestTitle;
	uses X_Main,X_Text,Title;
begin
	X_Set_Mode(0,320);
	X_Text_Init;
	X_Set_Font(1);
	DrawTitle;
	X_Text_Mode;
end.