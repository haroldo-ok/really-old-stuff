{***************************Programa Mega Mania 97***************************}
{						Por Haroldo de Oliveira Pinheiro					 }
{	Este Ç o m¢dulo principal do jogo Mega Mania 97. Para us†-lo, alÇm das   }
{units inclu°das com a Xlib, vocà tambÇm precisar† das units Title, Player e }
{Enemy, que contÇm as funá‰es necess†rias ao funcionamento do jogo. Lembre-se}
{tambÇm de ativar a sintaxe estendida (extended sintax).					 }
{	Vocà pode distribuir este jogo e seu source code livremente, desde que 	 }
{estes n∆o sejam modificados de forma alguma. Se vocà desenvolver qualquer 	 }
{tipo de programa baseado neste algor°tmo, n∆o se esqueáa de me dar os devi- }
{dos crÇditos.																 }
{	Lembre-se: este jogo Ç ditribu°do como est†, sem qualquer tipo de garan- }
{tia. O autor n∆o se responsabilizar† por quaisquer danos, de qualquer natu- }
{reza, causados direta ou indiretamente pelo uso deste programa ou seu source}
{code. Em outras palavras: se essa coisa fritar seu computador, n∆o venha 	 }
{chorar no meu ouvido, OK?													 }
{****************************************************************************}
program Mega_Mania_97;
	uses Crt,H_File,X_Main,X_Const,X_Text,X_Pics,X_FileIO,X_Pal,X_Keys,Title,Player,Enemy,Levels,SpkVoice,Mouse,Keybd,AudioTPU;
	{$I HAROLDO.INC}{Inclui a nova fonte}
	{$I DIGITAL.INC}{Inclui a nova fonte}
	{$V-}
	{$I-}
	{$F-}
	{$R-}
	{$B-}
	var Swapped:boolean;							{True se a p†gina ativa for a 1a e False se for a 2a}
		GamePal:Pointer;							{Ponteiro para a palheta usada durante o jogo}
		AnimCtrl:byte;								{Controle de animaá∆o}
		EnergyCtrl:byte;							{Vari†vel auxiliar de controle de energia}
		StarCoord:array[0..255] of PointType;		{Coordenadas das estrelas do fundo}
		InDebugMode:boolean;						{Est† em modo debug?}
		PauseMode:byte;								{Modo de pausa. 0 = nenhum, 1 = pausa, 2 = delay}
		UsedDebug:boolean;							{Usou o modo debug?}
		StarsEnabled:boolean;						{Usa estrelas no fundo?}
		VoiceOn:boolean;							{Usa sons digitalizados?}
		InTurboMode:boolean;						{Est† em modo turbo?}
		CDPlaying:boolean;							{O CD est† tocando?}
		CDMusic:byte;								{N£mero da musica do CD}
{****************************Procedimento PlaySound**************************}
{	Produz efeitos sonoros.													 }
{****************************************************************************}
	procedure PlaySound;
		begin
			if (SoundType<>0) and SoundStatus then	{Se houver algum som a ser tocado, e PUDER ser tocado...}
				case SoundType of					{Caso o tipo de som seja}
					001:begin						{Morte do inimigo}
							case SoundCtrl of
								8:Sound(800);
								9:Sound(750);
								10:Sound(700);
								7:SoundCtrl:=2;
								1:Nosound
							else
								SoundType:=0;
							end;
						end;
				end;
			if SoundCtrl<>0 then
				dec(SoundCtrl);						{Atualiza a vari†vel}
		end;
{*****************************Procedimento PlayRaw***************************}
{	Toca o arquivo RAW especificado em FileName.							 }
{****************************************************************************}
	procedure PlayRaw(FileName:String);
		var Snd:SpkSound;
		begin
			if VoiceOn then									{Se o som digitalizado est† habilitado, ent∆o}
				begin
					LoadSpkSound(FileName,Snd);				{Carrega o arquivo para a mem¢ria}
					PlaySpkSound(Snd);						{Toca o arquivo}
					UnLoadSpkSound(Snd);					{Libera a mem¢ria alocada}
				end;
		end;
{*****************************Procedimento DrawStars*************************}
{	Desenha as estrelas no fundo.											 }
{****************************************************************************}
	procedure DrawStars;
		var i:byte;									{Indexador}
		begin
			if StarsEnabled then					{Se as estrelas estiverem habilitadas, ent∆o}
				for i:=0 to 255 do
					begin
						if StarCoord[i].Y < 200 then{Se a estrela n∆o tiver sa°do pela parte de baixo...}
							begin
								PutPixel(StarCoord[i].X,StarCoord[i].Y,(i mod 3)+10);{Desenha-a}
								inc(StarCoord[i].Y,(i mod 3) + 1);{Atualiza a posiá∆o}
							end
						else if Random(30) = 0 then	{Sen∆o, coloca uma nova estrela (ou n∆o!).}
							begin
								StarCoord[i].X:=Random(320);
								StarCoord[i].Y:=0;
							end;
					end;
		end;
{*******************************Funá∆o LoadPal*******************************}
{	Carrega o arquivo especificado por FileName, retornando a palheta.		 }
{****************************************************************************}
	function LoadPal(FileName:String):Pointer;
		var Pal:^Palette;							{A palheta}
		begin
			new(Pal);								{Aloca mem¢ria para a palheta}
			X_Load_Scr(FileName,Pal^);				{Abre o arquivo e carrega a palheta}
			LoadPal:=Pal;							{Retorna o resultado}
		end;
{*****************************Procedimento SwapPages*************************}
{	Troca as p†ginas de v°deo e limpa a p†gina ativa.						 }
{****************************************************************************}
	procedure SwapPages;
		begin
			if Swapped then
				begin
					X_Set_Visible_Start_Addr(0,20);	{Seleciona a p†gina visual}
					X_Set_Activ_Start_Addr(0,360);	{Seleciona a p†gina ativa}
					ClearScreen(360,360+320,0);		{Limpa a p†gina ativa}
				end
			else
				begin
					X_Set_Visible_Start_Addr(0,360);{Seleciona a p†gina visual}
					X_Set_Activ_Start_Addr(0,20);	{Seleciona a p†gina ativa}
					ClearScreen(20,20+320,0);  		{Limpa a p†gina ativa}
				end;
			X_Set_Clip_Rect(0,0,319,199);
			Swapped:=not Swapped;					{Inverte a vari†vel}
		end;
{****************************Procedimento LevelStart*************************}
{	Animaá∆o do in°cio da fase.												 }
{****************************************************************************}
	procedure LevelStart;
		var i:byte;									{Vari†vel de controle}
		begin
			CleanBuf:=True;							{MantÇm o buffer de teclado limpo}
			for i:=0 to 255 do
				StarCoord[i].Y:=200;				{Reseta as estrelas}
			SwapPages;								{Troca as p†ginas de v°deo}
			for i:=0 to 64 do
				begin
					Energy:=i*5;					{Calcula a energia}
					DrawStars;						{Desenha as estrelas do fundo}
					HandlePlayer;					{Desenha o jogador,etc.}
					DrawStBar;						{Desenha a barra de status}
					if SoundStatus then				{Se o som estiver habilitado, ent∆o}
						Sound(100+i);				{Produz o som}
					SwapPages;						{Troca as p†ginas de v°deo}
					WaitVSyncStart;					{Espera um tempo}
				end;
			NoSound;								{P†ra o som}
			CleanBuf:=False;						{Retorna o buffer de teclado ao normal}
		end;
{******************************Procedure LevelEnd****************************}
{	Animaá∆o do final da fase.												 }
{****************************************************************************}
	procedure LevelEnd;
		var i:integer;									{Vari†vel de controle}
		begin
			CleanBuf:=True;							{MantÇm o buffer de teclado limpo}
			for i:=(Energy div 3) downto 0 do
				begin
					DrawStars;						{Desenha as estrelas do fundo}
					HandlePlayer;					{Desenha o jogador,etc.}
					DrawStBar;						{Desenha a barra de status}
					if SoundStatus then				{Se o som estiver habilitado, ent∆o}
						Sound(trunc(Cos(i/3)*30)+100);{Produz o som}
					inc(Score,Level div 2+1);		{Aumenta o score}
					Energy:=i*3;					{Atualiza a energia}
					SwapPages;						{Troca as p†ginas de v°deo}
					WaitVSyncStart;					{Espera um tempo}
				end;
			NoSound;								{P†ra o som}
			CleanBuf:=False;						{Retorna o buffer de teclado ao normal}
		end;
{****************************Procedimento PlyDeath***************************}
{	Animaá∆o da morte do jogador.											 }
{****************************************************************************}
	procedure PlyDeath;
		begin
			if SoundStatus then						{Se o som estiver habilitado, ent∆o}
				sound(700);                         {Produz som}
			WaitVSyncStart;							{Aguarda um tempo}
			X_Pal2Dark(GamePal^);					{Escurece a palheta}
			X_ClearAll;								{Limpa a tela}
			X_Put_Pal_Raw(GamePal^,256,0,false);	{Recupera a palheta}
			Nosound;								{P†ra o som}
			dec(PlyLife);							{Reduz o n£mero de vidas do jogador}
			ResetLevel(Level mod 8);				{Reseta a fase}
			if PlyLife > 0 then
				LevelStart;							{Inicia a animaá∆o de in°cio de fase}
			PlyDead:=false;							{O jogador j† n∆o est† mais morto}
		end;
{*****************************Procedimento HighScores************************}
{	Registra e mostra os high scores.										 }
{****************************************************************************}
	procedure HighScores;
		var	HighFile:HighScoreFile;					{Arquivo contendo os high scores}
			HighVar,HighTmp:HighScoreVec;			{Vari†vel contendo os high scores}
			i,j:byte;								{Indexadores}
			TxtYOff:integer;						{Offset vertical do texto}
			Pal:^Palette;							{Ponteiro para a palheta}
		function HSString(Stri:String;X:Longint):String;{Escrita dos high scores}
			Var TmpStr1,TmpStr2,Tmp3:String[21];		{Frases tempor†rias}
				i:byte;
			begin
				TmpStr1:=Stri;
				TmpStr2:=Str(X);					{Converte o score para um string}
				if Length(TmpStr1)<>0 then			{Se n∆o for uma frase vazia, ent∆o}
					for i:=Length(TmpStr1) to 9 do
						TmpStr1:=TmpStr1+' '		{Preenche os espaáos vazios com espaáos}
				else								{Se for uma frase vazia}
					TmpStr1:='         ';			{Coloca um monte de espaáos para preenchà-la}
				TmpStr1:=TmpStr1+'...';				{Coloca 3 pontos no final}
				Tmp3:='';
				for i:=1 to 10-Length(TmpStr2) do
					Tmp3:=Tmp3+' ';					{Calcula quantos espaáos ser∆o colocados antes do score}
				Tmp3:=Tmp3+TmpStr2;
				HSString:=TmpStr1+Tmp3;				{Retorna o resultado}
			end;
		begin
			X_Set_Font(1);							{Carrega a fonte da bios}
			Assign(HighFile,'HISCORES.DAT');		{Seleciona o arquivo}
			Reset(HighFile);						{Abre o arquivo}
			if IOResult=0 then						{Se foi poss°vel abrir o arquivo, ent∆o}
				begin
					Read(HighFile,HighVar);			{Là o arquivo}
					FileClose(HighFile);			{Fecha o arquivo}
				end
			else
				begin
					for i:=1 to 10 do
						begin
							HighVar[i].Name:='';
							HighVar[i].Score:=0;
						end;
				end;
			i:=1;
			while (HighVar[i].Score > Score) and (i <= 10) do{Checa se bateu algum recorde}
				inc(i);
			HighTmp:=HighVar;
			if (i <= 10) and (not UsedDebug) then   {Registra o recorde}
				begin
					X_ClearAll;						{Limpa a tela}
					X_Set_Visible_Start_Addr(0,20);	{Seleciona a p†gina visual}
					X_Set_Activ_Start_Addr(0,20);	{Seleciona a p†gina ativa}
					X_Set_Clip_Rect(0,0,319,199);
					Pal:=LoadPal('TITLE3.SCR');		{Carrega a imagem e a palheta}
					X_Put_Pal_Raw(Pal^,256,0,false);{Carrega a palheta}
					dispose(Pal);					{Libera a mem¢ria}
					TxtYOff:=(200 - (X_Font_Height*3)) div 2;{Calcula offset vertical do texto}
					X_Write(0,TxtYOff,254,Center(320,'YOU''VE MADE A HIGH SCORE!!'));
					X_Write(0,TxtYOff+X_Font_Height,254,Center(320,'PLEASE TYPE IN YOUR NAME:'));
					PlayRAW('IAAAHOOO.RAW');		{Toca o som "YAHOOO!"}
					E_Read(160-40,TxtYOff+X_Font_Height*2,160+64,255,0,HighTmp[i].Name);{Là o nome}
					HighTmp[i].Score:=Score;		{Registra o score}
					if i < 10 then
						for j:=i+1 to 10 do
							HighTmp[j]:=HighVar[j-1];
				end
			else if UsedDebug then					{Avisa sobre o preáo por se usar o modo debug}
				begin
					X_ClearAll;						{Limpa a tela}
					X_Set_Visible_Start_Addr(0,20);	{Seleciona a p†gina visual}
					X_Set_Activ_Start_Addr(0,20);	{Seleciona a p†gina ativa}
					X_Set_Clip_Rect(0,0,319,199);
					Pal:=LoadPal('TITLE3.SCR');		{Carrega a imagem e a palheta}
					X_Put_Pal_Raw(Pal^,256,0,false);{Carrega a palheta}
					TxtYOff:=(200 - (X_Font_Height*3)) div 2;{Calcula offset vertical do texto}
					X_Write(0,TxtYOff,255,Center(320,'REMEMBER:'));
					X_Write(0,TxtYOff+X_Font_Height,255,Center(320,'CHEATERS CAN''T SAVE'));
					X_Write(0,TxtYOff+X_Font_Height*2,255,Center(320,'HIGH SCORES'));
					PlayRAW('CHEAT.RAW');			{Toca o som "CHEAT!"}
					for j:=1 to 100 do
						WaitVSyncStart;				{Aguarda um tempo}
					X_Pal2Dark(Pal^);				{Escurece a tela}
					dispose(Pal);					{Libera a mem¢ria}
				end;
			Assign(HighFile,'HISCORES.DAT');		{Cria um novo arquivo sobre o antigo}
			Rewrite(HighFile);						{Reescreve o arquivo}
			Write(HighFile,HighTmp);				{Escreve o arquivo}
			FileClose(HighFile);					{Fecha o arquivo}
			TxtYOff:=32;							{Ajusta o offset vertical do texto}
			for i:=0 to 255 do
				StarCoord[i].Y:=200;				{Reseta as estrelas}
			X_Register_UserFont(FONT_DIGITAL);		{Carrega a fonte}
			X_Set_Font(2);							{Seleciona a fonte}
			SwapPages;								{Inicializa as p†ginas de v°deo}
			X_ClearAll;								{Limpa a tela}
			X_Put_Pal_Raw(GamePal^,256,0,false);	{Carrega a palheta}
			repeat									{Escreve os high scores}
				DrawStars;
				X_Write(0,TxtYOff,25,Center(320,'THE'));
				X_Write(0,TxtYOff+X_Font_Height,25,Center(320,'GREATEST'));
				X_Write(0,TxtYOff+X_Font_Height*2,25,Center(320,'MEGAMANIACS'));
				for i:=1 to 10 do
					X_Write(0,TxtYOff+X_Font_Height*(i+3),255,Center(320,HSString(HighTmp[i].Name,HighTmp[i].Score)));
				X_Write(0,TxtYOff+X_Font_Height*15,255,Center(320,'YOUR SCORE: '+Str(Score)));
				SwapPages;
			until KeyPressed;
			ReadKey;								{Limpa o buffer de teclado}
			X_Register_UserFont(FONT_HAROLDO);		{Carrega a fonte}
		end;
{****************************Procedimento DebugInfo**************************}
{	Passa informaá‰es de debug.												 }
{****************************************************************************}
	procedure DebugInfo;
		begin
			SwapPages;
			X_Write(0,0,255,'NumEnemy = '+Str(Numenemy));
			X_Write(0,X_Font_Height,255,'PlyXCoord = '+Str(PlyXCoord));
			X_Write(0,X_Font_Height*2,255,'PlyYCoord = '+Str(PlyYCoord));
			X_Write(0,X_Font_Height*3,255,'MaxEnmShot = '+Str(MaxEnmShot));
			X_Write(0,X_Font_Height*4,255,'GroupPos.X = '+Str(GroupPos.X));
			X_Write(0,X_Font_Height*5,255,'GroupPos.Y = '+Str(GroupPos.Y));
			SwapPages;
			repeat
			until KeyPressed;
		end;
{*****************************Procedimento GameHelp**************************}
{	Mostra a ajuda.															 }
{****************************************************************************}
	procedure GameHelp;
		var Pal:^Palette;
		begin
			SwapPages;
			New(Pal);								{Aloca a mem¢ria}
			Pal:=LoadPal('HELP.SCR');               {Carrega o arquivo e a palheta}
			X_Put_Pal_Raw(Pal^,256,0,false);		{Ajusta a palheta}
			Dispose(Pal);							{Libera a mem¢ria}
			SwapPages;
			repeat
			until KeyPressed;
			X_Put_Pal_Raw(GamePal^,256,0,false);	{Restaura a palheta}
		end;
{*****************************Procedimento MainLoop**************************}
{	Loop principal do jogo.													 }
{****************************************************************************}
	procedure MainLoop;
		begin
			if not Init_MasterFile('MMANIA97.DAT') then{Inicializa o arquivo-mestre}
				begin           					{Se, por algum motivo, ele n∆o pìde ser inicializado...}
					X_Text_Mode;					{Volta ao modo texto}
					writeln;						{Salta uma linha}
					writeln('Erro:  Arquivo MMANIA97.DAT danificado ou inexistente.');{Avisa sobre o erro}
					writeln('Error: MMANIA97.DAT data file damaged or not found.');{Idem, mas em inglàs}
					writeln;						{Salta uma linha}
					writeln;						{Salta uma linha}
				end;
			X_Set_Mode(0,320);						{Modo 320x200, largura virtual 320}
			X_Set_Font(2);							{Usa a nova fonte}
			SwapPages;								{Inicializa as p†ginas de v°deo}
			X_ClearAll;								{Limpa todas as p†ginas de v°deo}
			X_Put_Pal_Raw(GamePal^,256,0,false);	{Ajusta a palheta}
			InitKeyboard;							{Inicializa o teclado}
			PlayerInit;								{Inicializa o jogador}
			Level:=0;
			UsedDebug:=false;
			InDebugMode:=false;
			FollowMode:=false;
			PauseMode:=0;
			PlayRAW('LETSGO.RAW');					{Toca o som "Get Ready!"}
			while PlyLife > 0 do					{Enquanto o jogador tiver pelo menos uma vida, faáa}
				begin
					if CDPlaying then				{Se o CD estiver tocando}
						if Audio_Busy=0 then		{Se a m£sica tiver parado}
							Play_Track(CDMusic);	{Toca de novo}
					inc(Level);						{Atualiza a fase}
					InitLevel(Level mod 10);		{Inicializa a fase}
					AnimCtrl:=0;
					MaxEnmShot:=Level div 3 + 1;	{N£mero de tiros simultÉneos na tela}
					if MaxEnmShot > 7 then
						MaxEnmShot:=7;
					EnergyCtrl:=0;
					LevelStart;						{Toca a animaá∆o do in°cio da fase}
					if Level mod 3 = 0 then
						begin
							inc(PlyLife);			{Caso j† se tenham passado 3 fases, dà uma vida extra}
							PlayRAW('XLIFE.RAW');	{Toca o som "Extra Life!"}
						end;
					while (NumEnemy > 0) and (PlyLife > 0) do{Enquanto n∆o tiver passado de fase ou estiver vivo, faáa}
						begin
							SwapPages;				{Troca as p†ginas de v°deo}
							DrawStars;				{Desenha as estrelas do fundo}
							case PauseMode of		{Caso o modo de pausa seja}
								1 : begin
										PlayRAW('PAUSE.RAW');{Toca o som "Paused!"}
										while UpCase(ReadKey)<>'P' do;{Aguarda a press∆o de tecla P}
										PauseMode:=0;
									end;
								2 : begin					{Aguarda um tempo}
										for PauseMode:=30 downto 0 do{Quando sair do loop, PauseMode estar† automaticamente de volta a 0}
											WaitVSyncStart;
									end;
							end;
							HandleLevel(Level mod 10);{Manipula a fase}
							HandlePlayer;			{Manipula o jogador}
							DrawStBar;				{Desenha a barra de status}
							if KeyPressed then		{Se alguma tecla for pressionada}
								case UpCase(ReadKey) of{Leia-a e interprete-a}
									#27:PlyLife:=0;
									'D':if InDebugMode then
											DebugInfo;{Informaá‰es de debug}
									'J':if InDebugMode then
											begin
												NumEnemy:=0;{Salta a fase}
												X_Write(0,92,255,Center(320,'LEVEL WARP!'));
												PlayRAW('CHEAT.RAW');{Toca o som "Cheat!"}
											end;
									'L':if InDebugMode then
											begin
												PlyLife:=10;{D† dez vidas ao jogador}
												PlayRAW('CHEAT.RAW');{Toca o som "Cheat!"}
												X_Write(0,92,255,Center(320,'EXTRA LIVES!'));
												PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
											end;
									'F':if InDebugMode then
											begin
												FollowMode:=not(FollowMode);{Ativa ou desativa o modo teleguiado}
												if FollowMode then
													X_Write(0,92,255,Center(320,'FOLLOW MODE ON'))
												else
													X_Write(0,92,255,Center(320,'FOLLOW MODE OFF'));
												PlayRAW('CHEAT.RAW');{Toca o som "Cheat!"}
												PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
											end;
									'P':begin
											Pausemode:=1;{Pausa o jogo}
											X_Write(0,92,255,Center(320,'PAUSED!!'));
										end;
									'K':begin       {Seleciona mouse ou teclado}
											UseKeyboard:=not(UseKeyboard);
											if UseKeyboard then
												begin
													X_Write(0,92,255,Center(320,'USING KEYBOARD'));
												end
											else
												begin
													X_Write(0,92,255,Center(320,'USING MOUSE'));
												end;
											PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
										end;
									'T':begin		{Ativa ou desativa modo turbo}
											InTurboMode:=not(InTurboMode);
											if InTurboMode then
												begin
													X_Write(0,92,255,Center(320,'TURBO MODE!!'));
												end
											else
												begin
													X_Write(0,92,255,Center(320,'NORMAL MODE'));
												end;
											PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
										end;
									'S':begin		{Liga ou desliga o som}
											SoundStatus:=not(SoundStatus);
											if SoundStatus then
												begin
													X_Write(0,92,255,Center(320,'SOUND ON'));
												end
											else
												begin
													X_Write(0,92,255,Center(320,'SOUND OFF'));
												end;
											PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
										end;
									'V':begin		{Liga ou desliga as vozes}
											VoiceOn:=not(VoiceOn);
											if VoiceOn then
												begin
													X_Write(0,92,255,Center(320,'VOICE ON'));
												end
											else
												begin
													X_Write(0,92,255,Center(320,'VOICE OFF'));
												end;
											PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
										end;
									'B':begin		{Liga ou desliga as estrelas no fundo}
											StarsEnabled:=not(StarsEnabled);
											if StarsEnabled then
												begin
													X_Write(0,92,255,Center(320,'STARS ON'));
												end
											else
												begin
													X_Write(0,92,255,Center(320,'STARS OFF'));
												end;
											PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
										end;
									'-':begin		{Diminui a velocidade do mouse}
											if MouseRatio > 1 then
												Dec(MouseRatio);
											MRatio(MouseRatio,10);
											X_Write(0,92,255,Center(320,'MOUSE SPEED: '+Str(MouseRatio)));
										end;
									'+':begin		{Aumenta a velocidade do mouse}
											if MouseRatio < 30 then
												Inc(MouseRatio);
											MRatio(MouseRatio,10);
											X_Write(0,92,255,Center(320,'MOUSE SPEED: '+Str(MouseRatio)));
										end;
									',':begin       {Toca CD/Pista anterior}
											if CDPlaying then
												begin
													Dec(CDMusic);
													if CDMusic < 1 then
														CDMusic:=Get_Titles;
												end;
											Play_Track(CDMusic);
											CDPlaying:=true;
											X_Write(0,92,255,Center(320,'PLAYING TRACK '+Str(CDMusic)));
											PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
										end;
									'.':begin		{Toca CD/Avanáa pista}
											if CDPlaying then
												begin
													Inc(CDMusic);
													if CDMusic > Get_Titles then
														CDMusic:=1;
												end;
											Play_Track(CDMusic);
											CDPlaying:=true;
											X_Write(0,92,255,Center(320,'PLAYING TRACK '+Str(CDMusic)));
											PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
										end;
									'C':begin		{Para o CD}
											CDPlaying:=false;
											Stop_Audio_1;
											X_Write(0,92,255,Center(320,'CD STOPPED'));
											PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
										end;
									#00:case ReadKey of
											F1:GameHelp;
											F2:Eject_CD;
											F3:Insert_CD;
											F10:if InDebugMode then
													begin{Sai do modo debug}
														X_Write(0,92,255,Center(320,'CHEAT MODE OFF.'));
														InDebugMode:=false;
														PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
													end
												else
													begin{Entra em modo debug}
														X_Write(0,92,255,Center(320,'CHEAT MODE ON!.'));
														InDebugMode:=true;
														UsedDebug:=true;
														PlayRAW('CHEAT.RAW');{Toca o som "Cheat!"}
														PauseMode:=2;{Manda o jogo aguardar um tempo no pr¢ximo loop}
													end;
										end;
								end;
							AnimCtrl:=(AnimCtrl+1) mod 3;{Controle principal de animaá∆o}
							EnmAnimCtrl:=AnimCtrl;	{Controle de animaá∆o do inimigo}
							PlaySound;				{Gera efeitos sonoros, se houver algum para gerar}
							if EnergyCtrl=20 then	{Se tiverem se passado 50 loops...}
								begin
									dec(Energy);	{Reduz a energia}
									EnergyCtrl:=0;	{Reseta o contador}
									if Energy=0 then{Se tiver acabado a energia}
										PlyDead:=true;{Mate o jogador}
								end
							else
								inc(EnergyCtrl);	{Aumenta o contador}
							if not(InTurboMode) then{Se n∆o estiver em modo turbo, ent∆o}
								WaitVSyncStart;		{Aguarda um tempo}
							if PlyDead then			{Se o jogador estiver morto, ent∆o}
								PlyDeath;			{Mata ele, oras!}
						end;
					if PlyLife > 0 then
						LevelEnd;					{Animaá∆o de fim de fase}
					DoneLevel(Level mod 10);
					SoundType:=0;					{Limpa o buffer de som}
				end;
			PlayerDone;								{Limpa os dados do jogador}
			DoneKeyboard;							{Recupera a antiga interrupá∆o de teclado}
			NoSound;								{Para o som}
			HighScores;								{Mostra os high scores}
		end;
{*******************************In°cio do programa***************************}
{	ê o in°cio do programa.													 }
{****************************************************************************}
Begin
	Randomize;										{Inicia gerador de n£meros aleat¢rios}
	InDebugMode:=false;								{N∆o est† em modo debug}
	StarsEnabled:=true;								{Estrelas ativadas}
	InTurboMode:=false;								{Desliga modo turbo}
	CDPlaying:=false;								{O CD ainda n∆o est† tocando}
	CDMusic:=2;										{Prepara m£sica n£mero 2}
	VoiceOn:=true;									{Aciona voz}
	for AnimCtrl:=0 to 255 do
		StarCoord[AnimCtrl].Y:=200;					{Reseta as estrelas}
	TitleReadKey:='/';								{Limpa a vari†vel}
	X_Set_Mode(0,320);								{Inicializa o modo gr†fico}
	X_Set_Black_Pal;								{Usa palheta escura}
	GamePal:=LoadPal('PALETTE.DAT');				{Carrega a palheta}
	X_Text_Init;									{Inicializa o gerador de caracteres}
	X_Register_UserFont(Font_Haroldo);				{Instala a fonte personalizada}
	while TitleReadKey<>#27 do						{Repete o loop atÇ ser pressionada a tecla ESC}
		begin
			X_Set_Mode(0,320);						{Inicia modo 320x200, com largura virtual 320}
			X_Set_Font(1);							{Usa a fonte 16x16 padr∆o}
			DrawTitle;								{Desenha o t°tulo}
			if TitleReadKey=#13 then				{Se foi pressionada a tecla enter, ent∆o}
				begin
					MainLoop;
				end;
		end;
	X_Text_Mode;									{Retorna ao modo texto}
End.