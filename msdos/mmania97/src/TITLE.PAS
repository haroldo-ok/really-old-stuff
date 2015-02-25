unit Title;
interface
	uses Crt,X_Main,X_Const,X_Pal,X_Pics,X_Text;
	var TitleReadKey:char;	{Èltima tecla pressionada na tela-t°tulo}
	procedure DrawTitle;	{Desenha a tela t°tulo}
implementation
	const
		NofStars=50;		{N£mero de estrelas na tela}
		Xc=160;				{Centro X}
		Yc=100;				{Centro Y}
		ZFactor=200;		{Fator de divis∆o Z}
	type
		StarRec=record		{Tipo usado para definir as coordenadas das estrelas}
					X,Y,Z : integer;
				end;
		StarPos = array[0..NofStars] of StarRec;	{Tipo usado para definir a posiá∆o de cada estrela}
		StarSpd = array[0..NofStars] of word;		{Tipo usado para definir a velocidade das estrelas}

	var Stars : StarPos;	{Posiá∆o das estrelas}
		Speed : StarSpd;	{Velocidade das estrelas}
{********************************Funá∆o DoWait*******************************}
{	Aguarda pelo n£mero de retraáamentos verticais indicados em Time ou pela }
{press∆o de uma tecla, retornando-a. Se n∆o for pressionada nenhuma tecla, ou}
{for uma tecla especial, retorna #0.										 }
{****************************************************************************}
	function DoWait(Time:word):char;
		var i:word;			{Contador}
			key:char;		{Tecla}
		begin
			if Time<>0 then
				begin
					Key:=#0;
					i:=1;
					while (i<=Time) and not Keypressed do
						begin
							WaitVSyncStart;
							inc(i);
						end;
					if Keypressed then
						begin
							Key:=ReadKey;
							if Key=#0 then	{Se for tecla especial, ent∆o}
								begin
									Key:=ReadKey;	{Limpa o buffer para evitar interferància com outros procedimentos}
									Key:=#0;		{Ver descriá∆o do procedimento}
								end;
						end;
					DoWait:=Key;
				end;
		end;
{****************************************************************************}
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
{****************************************************************************}
	procedure DoStars;
		var X,Y:integer;
			I,Color:byte;
		procedure NewStar(Num : byte);
			var X,Y:integer;
			begin
				X:=Xc+round(Stars[Num].X*Stars[Num].Z/ZFactor);
				Y:=Yc+round(Stars[Num].Y*Stars[Num].Z/ZFactor);
				if (X > 0) and (X < 320) and (Y > 0) and (Y < 200) then
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
					if GetPixel(X,Y)>232 then
						PutPixel(X,Y,0);
					X := Xc+round(Stars[I].X*(Stars[I].Z+Speed[I])/ZFactor);
					Y := Yc+round(Stars[I].Y*(Stars[I].Z+Speed[I])/ZFactor);
					if (X > 0) and (X < 320) and (Y > 0) and (Y < 200) then
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
{****************************Procedimento DrawTitle**************************}
{	Desenha a tela t°tulo do jogo. ê a minha primeira rotina escrita com a   }
{XLib. Os gr†ficos j† devem estar inicializados no modo 320X200, e o texto	 }
{deve ter sido inicializado tambÇm (X_Text_Init).							 }
{****************************************************************************}
	procedure DrawTitle;
		type
			SemiPal=array[32..63] of byte;	{Palheta parcial}
		var Pal:^Palette;					{Palheta}
			i,j:word;						{Vari†veis de controle}
			Aux:array[0..2] of byte;		{Vari†vel tempor†ria}
			Key:char;						{Tecla pressionada}
			TxtYOff:integer;				{Offset vertical do texto}
			TxtCtrl:word;
		begin
			new(Pal);						{Aloca mem¢ria para a palheta}
			X_Set_Black_Pal;				{Carrega palheta escura}
			X_Load_Scr('TITLE1.SCR',Pal^);  {Carrega a 1a imagem na tela}
			X_Put_Pal_Raw(Pal^,256,0,false);{Carrega a palheta da imagem}
			for i:=1 to 100 do              {Durante 100 vezes...}
				WaitVSyncStart;				{Aguarde pela sincronizaá∆o vertical do v°deo (funciona como delay)}
			for i:=0 to 200 do
				X_Set_Visible_Start_Addr(0,i);	{Vai movendo a tela para cima}
			X_Set_Black_Pal;				{Carrega palheta escura}
			X_Load_Scr('TITLE2.SCR',Pal^);  {Carrega a 2a imagem na tela}
			X_Set_Visible_Start_Addr(0,0);	{Coloca a tela de volta Ö posiá∆o correta}
			X_Dark2Pal(Pal^);				{Muda a palheta suavemente do escuro Ö palheta correta}
			Key:=#0;
			Init_Star;
			TxtCtrl:=0;
			X_Set_Font(0);
			while not (Key in [#13,#27]) do	{Enquanto n∆o for pressionado ENTER ou ESC, faáa}
				begin
					if KeyPressed then
						begin
							Key:=ReadKey;
							if Key=#0 then
								ReadKey;
						end;
					WaitVSyncStart;
					DoStars;
					case TxtCtrl of
						500:X_Write(0,190,229,Center(320,'Programmed in Turbo Pascal 7.0'));
						999:for i:=190 to 200 do
								Line(0,i,319,i,0);
						1000:X_Write(0,190,229,Center(320,'by Haroldo de Oliveira Pinheiro'));
						1499:for i:=190 to 200 do
								Line(0,i,319,i,0);
						1500:X_Write(0,190,229,Center(320,'Press ENTER to start'));
						1999:for i:=190 to 200 do
								Line(0,i,319,i,0);
						2000:X_Write(0,190,229,Center(320,'Press ESC to exit to DOS'));
						2499:for i:=190 to 200 do
								Line(0,i,319,i,0);
					end;
					TxtCtrl:=(TxtCtrl+1) mod 3000;
				end;
			X_Pal2Dark(Pal^);								{Escurece a tela lentamente}
			Dispose(Pal);									{Libera a mem¢ria alocada para a palheta}
			TitleReadKey:=Key;								{Retorna a £ltima tecla lida}
		end;
end.