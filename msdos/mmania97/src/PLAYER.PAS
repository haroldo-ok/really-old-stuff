{Mega Mania 97: Rotinas de manipulaá∆o do jogador}
unit Player;
interface
	uses Mouse,X_Bitmap,Keybd;
	type
		PointType = record					{Simplesmente um par de coordenadas X e Y}
						X,
						Y:integer;
					end;

	var PlyShot:PointType;					{Posiá∆o do tiro do jogador}
		PlyShotInScreen:boolean;			{O tiro est† na tela? (S¢ pode haver um tiro do jogador na tela por vez)}
		PlySprite:Pointer;					{Sprite do jogador}
		PlyLife:byte;						{N£mero de vidas do jogador	(Ser† que alguÇm consegue mais do que 255?)}
		Score:Longint;						{Como pode ver, Ç o score.}
		PlyDead:boolean;					{O jogador morreu?}
		PlySize:PointType;					{Tamanho do jogador, usado para checagem de colis∆o.}
		PlyXCenter:integer;					{Centro horizontal do jogador, usado para manipulaá∆o de tiros.}
		PlyXCoord:integer;					{Coordenada horizontal do jogador}
		PlyYCoord:integer;					{Coordenada vertical do jogador}
		Energy:integer;						{Energia do jogador}
		Level:byte;							{Fase atual}
		SoundStatus:boolean;				{O som est† ativado?}
		FollowMode:boolean;					{Est† em modo teleguiado?}
		MouseRatio:integer;					{Sensibilidade do mouse}
		UseKeyboard:boolean;				{Usa o teclado ou o mouse?}

	procedure LoadPbm(Name:String;var Pbm:Pointer);	{Carrega um arquivo PBM}
	procedure DrawShot(X,Y:integer;Color:byte);		{Desenha um tiro na tela}
	procedure DrawStBar;							{Desenha a barra de status}
	procedure PlayerInit;							{Inicializa o jogador}
	procedure HandlePlayer;							{Procedimento que controla o jogador}
	procedure PlayerDone;							{Desfaz o que foi feito por PlayerInit}

implementation
	uses Crt,X_Main,X_Text,X_FileIO,Enemy;
{*****************************Procedimento LoadPbm***************************}
{	Carrega um arquivo PBM do disco, alocando mem¢ria automaticamente.		 }
{*************************************************************************** }
	procedure LoadPbm(Name:String;var Pbm:Pointer);
		var F:file;
		begin
			if F_Open_Read(F,Name) then				{O arquivo pìde ser aberto?}
				begin								{Sim.}
					GetMem(Pbm,F_Size(Name));		{Aloca mem¢ria para a vari†vel}
					X_Load_Pbm(Name,Pbm^);			{Carrega o arquivo}
				end
			else									{Sen∆o}
				Pbm:=nil;							{Retorna nil}
		end;
{*****************************Procedimento DrawShot**************************}
{	Desenha um tiro na tela, nas coordenadas X e Y e na cor especificada.	 }
{****************************************************************************}
	procedure DrawShot(X,Y:integer;Color:byte);
		begin
			if Y > -5 then
				Line(X,Y,X,Y+5,Color);
		end;
{*****************************Procedimento DrawStBar*************************}
{	Desenha a barra de status. ê necess†rio usar a fonte HAROLDO.FNT para que}
{funcione corretamente.														 }
{****************************************************************************}
	procedure DrawStBar;
		var i:byte;									{Vari†vel de controle}
			TmpStr:String[40];						{Vari†vel tempor†ria}
		procedure DrawEnergyBar;					{Desenha a barra de energia}
			begin
				Line(0,184,Energy,184,22);			{Desenha a parte de cima}
				Line(0,185,Energy,185,24);			{Desenha a parte central}
				Line(0,186,Energy,186,22);			{Desenha a parte de baixo}
			end;
		begin
			case PlyLife of						{Calcula quantas naves ser∆o desenhadas na barra de status}
				0:TmpStr:='';
				1:TmpStr:='#';
				2:TmpStr:='##';
				3:TmpStr:='###';
				4:TmpStr:='####';
				5:TmpStr:='#####';
				6:TmpStr:='######';
				7:TmpStr:='#######';
				8:TmpStr:='########';
				9:TmpStr:='#########';
				10:TmpStr:='##########'
			else
				TmpStr:='###########';
			end;
			Line(0,173,319,173,12);				{Desenha a parte de cima da barra de status}
			Line(0,174,319,174,14);				{Idem}
			Line(0,175,319,175,12);				{Idem}
			Line(0,197,319,197,12);				{Desenha a parte de baixo da barra de status}
			Line(0,198,319,198,14);				{Idem}
			Line(0,199,319,199,12);				{Idem}
			X_Write(0,177,40,Center(320,TmpStr));{Desenha as vidas}
			DrawEnergyBar;						{Desenha a barra de energia}
			X_Write(0,177,255,Center(320,Str(Score)));{Desenha o score}
		end;
{***************************Procedimento PlayerInit**************************}
{	Inicializa os dados referentes ao jogador.								 }
{****************************************************************************}
	procedure PlayerInit;
		var FileName:String;						{Nome do arquivo a ser lido}
			X,Y:Word;								{Vari†veis tempor†rias (X_Get_Pbm_SizeXY n∆o aceita inteiros normais)}
		begin
			FileName:='PLAYER.PBM';
			LoadPbm(FileName,PlySprite);			{Carrega o arquivo contendo o sprite como PBM}
			X_Get_Pbm_SizeXY(X,Y,PlySprite^);		{Calcula o tamanho do Sprite}
			PlySize.X:=X;							{Transfere X para seu destino}
			PlySize.Y:=Y;							{Transfere Y para seu destino}
			PlyXCenter:=PlySize.X div 2;			{Calcula o centro do jogador}
			PlyXCoord:=160;							{Calcula a posiá∆o horizontal do jogador}
			PlyYCoord:=(200 - 26) - PlySize.Y;		{Calcula a coordenada vertical do jogador}
			PlyLife:=5;								{O jogador comeáa com 5 vidas}
			PlyDead:=false;							{Vocà n∆o quer que o jogador comece morto, quer?}
			PlyShotInScreen:=false;					{N∆o h† nenhum tiro na tela... ainda.}
			Score:=0;								{Inicializa o score}
			MColRange(0,320-PlySize.X);				{Limita o movimento do mouse}
		end;
{**************************Procedimento HandlePlayer*************************}
{	Controla o jogador, desenha-o na tela, manipula os tiros, etc.			 }
{****************************************************************************}
	procedure HandlePlayer;
		var MouseInfo:LocRec;						{Informaá‰es sobre o mouse}
		begin
			MPos(MouseInfo);						{Pega as informaá‰es sobre o mouse}
			if UseKeyboard then						{Se deve usar o teclado, ent∆o}
				begin
					if (Keys[scLeft]) and (PlyXCoord>0) then{Se apertou para a esquerda, ent∆o}
						Dec(PlyXCoord,5);
					if (Keys[scRight]) and (PlyXCoord<320-PlySize.X) then{Se apertou para a direita, ent∆o}
						Inc(PlyXCoord,5);
				end
			else
				PlyXCoord:=MouseInfo.Column;		{Verifica a posiá∆o horizontal do jogador atravÇs do mouse}
			X_Put_Masked_Pbm_ClipXY(PlyXCoord,PlyYCoord,PlySprite^);{Desenha o jogador na tela}
			if PlyShotInScreen then					{Se o tiro do jogador estiver na tela}
				begin
					if FollowMode then       		{Se o modo teleguiado estiver ativado, ent∆o}
						PlyShot.X:=PlyXCoord+PlyXCenter;{O tiro acompanha o jogador}
					Dec(PlyShot.Y,9);				{Move o tiro do jogador}
					DrawShot(PlyShot.X,PlyShot.Y,10);{Desenha o tiro}
					if PlyShot.Y > 50 then			{Se o tiro estiver abaixo do 1o quarto da tela}
						begin
							if SoundStatus then		{Se o som estiver habilitado, ent∆o}
								Sound(PlyShot.Y+60)	{Produz um som}
							else
								NoSound;
						end
					else
						NoSound;
					if PlyShot.Y<-5 then			{Se o tiro sair da tela, ent∆o}
						begin
							PlyShotInScreen:=false; {"Destr¢i" o tiro do jogador}
							NoSound;				{P†ra o som do tiro}
						end;
				end
			else									{Se o tiro do jogador n∆o estiver na tela}
				begin
					if (MouseInfo.ButtonStatus<>0) or (Keys[scCtrl]) then{Se o mouse foi clicado ou Ctrl pressionado, ent∆o}
						begin
							PlyShotInScreen:=true;				{Preparar...}
							PlyShot.X:=PlyXCoord+PlyXCenter;	{Apontar...}
							PlyShot.Y:=PlyYCoord;
							DrawShot(PlyShot.X,PlyShot.Y,10);   {FOGO!}
							SoundCtrl:=0;						{Para qualquer som que estiver tocando}
						end
					else
						begin
							PlyShot.X:=PlyXCoord+PlyXCenter;
							PlyShot.Y:=PlyYCoord+2;
						end;
				end;
		end;
{***************************Procedimento PlayerDone**************************}
{	Usado apenas quando o jogador perde todas as suas vidas. 				 }
{****************************************************************************}
	procedure PlayerDone;
		begin
			FreeMem(PlySprite,X_SizeOf_Pbm(PlySprite^));
		end;
{*************************Procedimento ResetTheMouse************************}
{	Como vocà deve ter sacado, esta funá∆o reseta o mouse, e,  caso n∆o 	}
{exista, aborta o programa e avisa o jogador.								}
{***************************************************************************}
	procedure ResetTheMouse;
		var M_ResetInfo:ResetRec;		{Informaá∆o necess†ria ao resetamento do mouse}
		begin
			MReset(M_ResetInfo);		{Reseta o mouse}
			if not M_ResetInfo.Exists then	{Se n∆o existir um mouse, ent∆o}
				begin
					ClrScr;
					writeln;
					writeln('ERROR: You need a mouse in order to run this game.');
					writeln;
					writeln('ERRO:  Vocà precisa de um mouse para rodar este jogo.');
					Halt(255);		{P†ra o programa incondicionalmente, com errorlevel 255}
				end;
			MouseRatio:=5;				{Define a sensibilidade inicial do mouse}
			MRatio(MouseRatio,10);		{Ajusta a sensibilidade do mouse}
		end;
Begin
	ResetTheMouse;					{Bastante Auto-explicativo, n∆o acha?}
	SoundStatus:=true;				{Som ativado}
	FollowMode:=false;				{Modo teleguiado desativado}
	UseKeyboard:=false;
End.