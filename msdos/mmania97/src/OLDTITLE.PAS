unit Title;
interface
	uses Crt,X_Main,X_Const,X_Pal,X_Pics,X_Text;
	var TitleReadKey:char;	{Èltima tecla pressionada na tela-t°tulo}
	procedure DrawTitle;	{Desenha a tela t°tulo}
implementation
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
			while not (Key in [#13,#27]) do	{Enquanto n∆o for pressionado ENTER ou ESC, faáa}
				begin
					Key:=DoWait(300);				{Espera um tempo ou a press∆o de uma tecla}
					X_Load_Scr('TITLE3.SCR',Pal^);  {Carrega a 3a imagem na tela}
					X_Put_Pal_Raw(Pal^,256,0,false);{Carrega a palheta da imagem}
					TxtYOff:=(200 - (X_Font_Height*2)) div 2;	{Calcula offset vertical do texto}
					X_Write(0,TxtYOff,254,center(320,'Programmed by'));{Escreve texto}
					X_Write(0,TxtYOff+X_Font_Height,255,center(320,'Haroldo de Oliveira Pinheiro'));{Escreve texto}
					if	not (Key in [#13,#27]) then
						begin
							Key:=DoWait(150);				{Espera um tempo ou a press∆o de uma tecla}
							X_Load_Scr('TITLE3.SCR',Pal^);  {Carrega a 3a imagem na tela}
							X_Write(0,TxtYOff,254,center(320,'Graphics by'));{Escreve texto}
							X_Write(0,TxtYOff+X_Font_Height,255,center(320,'Haroldo de Oliveira Pinheiro'));{Escreve texto}
						end;
					if	not (Key in [#13,#27]) then
						begin
							Key:=DoWait(150);				{Espera um tempo ou a press∆o de uma tecla}
							X_Load_Scr('TITLE3.SCR',Pal^);  {Carrega a 3a imagem na tela}
							X_Write(0,TxtYOff,254,center(320,'Sound by'));{Escreve texto}
							X_Write(0,TxtYOff+X_Font_Height,255,center(320,'Haroldo de Oliveira Pinheiro'));{Escreve texto}
						end;
					if	not (Key in [#13,#27]) then
						begin
							Key:=DoWait(150);				{Espera um tempo ou a press∆o de uma tecla}
							X_Load_Scr('TITLE3.SCR',Pal^);  {Carrega a 3a imagem na tela}
							X_Write(0,TxtYOff,254,center(320,'Game design by'));{Escreve texto}
							X_Write(0,TxtYOff+X_Font_Height,255,center(320,'Haroldo de Oliveira Pinheiro'));{Escreve texto}
						end;
					if	not (Key in [#13,#27]) then
						begin
							Key:=DoWait(150);				{Espera um tempo ou a press∆o de uma tecla}
							X_Set_Black_Pal;				{Escurece a palheta antes de carregar a pr¢xima imagem, evitando piscamento}
							X_Load_Scr('TITLE2.SCR',Pal^);  {Carrega a 2a imagem na tela}
							X_Put_Pal_Raw(Pal^,256,0,false);{Carrega a palheta da imagem}
						end;
				end;
			X_Pal2Dark(Pal^);								{Escurece a tela lentamente}
			Dispose(Pal);									{Libera a mem¢ria alocada para a palheta}
			TitleReadKey:=Key;								{Retorna a £ltima tecla lida}
		end;
end.