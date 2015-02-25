{Mega Mania 97: Rotinas de manipulaá∆o dos inimigos}
unit Enemy;
interface
	uses Player;

	var EnmSprite:array[0..2] of pointer;	{Sprite do inimigo}
		EnmShot:array[1..7] of PointType;	{Posiá∆o dos tiros inimigos}
		EnmShotInScr:array[1..7] of boolean;{O tiro do inimigo est† na tela?}
		NumShotInScr:byte;					{N£mero de tiros inimigos presentes na tela}
		MaxEnmShot:byte;					{M†ximo de tiros simultÉneos na tela}
		EnmAnimCtrl:byte;					{Controle de animaá∆o dos inimigos}
		EnmBonus:integer;					{Bìnus por destruir um inimigo}
		EnmSize:PointType;					{Tamanho do inimigo, usado para checagem de colis∆o}
		NumEnemy:byte;						{N£mero de inimigos na tela}
		SoundType:byte;						{Tipo de som a ser produzido}
		SoundCtrl:byte;						{Controle do}

	function Inside(x,y,x1,y1,x2,y2:integer):boolean;{Checa se um ponto est† dentro de uma certa †rea}
	procedure ResetEnmShots;				{Reseta os tiros dos inimigos}
	procedure FireEnmShot(X,Y:integer);		{Dispara o tiro do inimigo}
	procedure HandleEnmShot;				{Manipula os tiros presentes na tela}
	procedure LoadEnmSpr(Name:String);		{Carrega os sprites dos inimigos}
	procedure DoneEnmSpr;					{Libera a mem¢ria carregada para os sprites}
	function HandleEnemy(X,Y:integer):boolean;{Manipula o inimigo e diz se ele foi destru°do}
implementation
	uses Crt,X_Main,X_Text,X_Bitmap,X_FileIO;
{**************************Procedimento EnmDeathSound***********************}
{	Produz o som de morte dos inimigos.										}
{***************************************************************************}
	procedure EnmDeathSound;
		begin
			NoSound;						{Para qualquer som que estiver tocando}
			SoundType:=1;					{Seleciona o som}
			SoundCtrl:=10;					{Prepara o som para tocar}
		end;
{*******************************Funá∆o Inside********************************}
{	Checa se o ponto definido por x e y est† dentro do retÉngulo definido por}
{x1, x2, y1 e y2.															 }
{****************************************************************************}
	function Inside(x,y,x1,y1,x2,y2:integer):boolean;
		begin
			Inside:=(x>=x1) and (x<=x2) and (y>=y1) and (y<=y2);
		end;
{**************************Procedimento ResetEnmShots************************}
{	Reseta os tiros dos inimigos. ê recomend†vel usar este procedimento no 	 }
{in°cio de cada fase.														 }
{****************************************************************************}
	procedure ResetEnmShots;
		var i:byte;							{Indexador}
		begin
			for i:=1 to MaxEnmShot do
				EnmShotInScr[i]:=false;		{Tira todos os tiros da tela}
			NumShotInScr:=0;				{Avisa para o jogo que n∆o h† mais nenhum tiro na tela}
		end;
{**************************Procedimento FireEnmShot**************************}
{	Coloca mais um tiro na tela, iniciando nas coordenadas X e Y, desde que	 }
{n∆o se ultrapasse o n£mero m†ximo de tiros na tela.						 }
{****************************************************************************}
	procedure FireEnmShot(X,Y:integer);
		var i:byte;									{Indexador}
		begin
			if NumShotInScr < MaxEnmShot then		{Se for poss°vel colocar mais um tiro na tela...}
				begin
					i:=1;
					while EnmShotInScr[i] and (i<>MaxEnmShot) do
						inc(i);                     {Procura por um espaáo livre no array}
					EnmShot[i].X:=X;				{Posiciona o tiro}
					EnmShot[i].Y:=Y;				{Idem}
					EnmShotInScr[i]:=true;			{Coloca mais um tiro na tela}
					inc(NumShotInScr);				{Avisa para o jogo que foi colocado mais um tiro na tela}
				end;
		end;
{***************************Procedimento HandleEnmShot***********************}
{	Move os tiros do inimigo, checa se atravessaram a parte de baixo da tela }
{e, caso tenham atravessado, os elimina da lista de tiros.					 }
{****************************************************************************}
	procedure HandleEnmShot;
		var i:byte;									{Indexador}
		begin
			if NumShotInScr<>0 then					{Se houver pelo menos um tiro na tela, ent∆o}
				for i:=1 to MaxEnmShot do			{Para cada poss°vel tiro,faáa}
					if EnmShotInScr[i] then			{O tiro est† na tela?}
						if EnmShot[i].Y < 200 then	{Se n∆o tiver sa°do por baixo...}
							begin
								DrawShot(EnmShot[i].X,EnmShot[i].Y,190);{Desenha o tiro}
								inc(EnmShot[i].Y,4);					{Move-o}
								PlyDead:=PlyDead or						{Checa se o tiro acertou o jogador (Desculpe a quebra de linha, mas ela estava muito longa)}
											Inside(EnmShot[i].X,EnmShot[i].Y,PlyXCoord,PlyYCoord,PlySize.X+PlyXCoord,PlySize.Y+PlyYCoord+5);
							end
						else
							begin
								EnmShotInScr[i]:=false;	{Avisa ao jogo que o tiro saiu da tela}
								dec(NumShotInScr);		{Atualiza o contador de tiros}
							end;
		end;
{****************************Procedimento LoadEnmSpr*************************}
{	Carrega os sprites dos inimigos. "Name" s¢ dever† conter o in°cio do nome}
{do arquivo. Por exemplo: fornecendo 'Saucer', ele carregar† 'Saucer1.PBM',	 }
{'Saucer2.PBM' e 'Saucer3.PBM'.												 }
{****************************************************************************}
	procedure LoadEnmSpr(Name:String);
		var F:file;									{Arquivo}
			i:word;									{Indexador}
			Y:word;									{Vari†vel auxiliar}
			TmpStr:String;							{Usado para guardar o nome dos arquivos}
		begin
			for i:=1 to 20 do
				TmpStr[i]:=#0;										{Limpa a frase}
			for i:=1 to 3 do
				begin
					TmpStr:=Name+Str(i)+'.PBM';						{O nome do arquivo Ç [Nome][n£mero].PBM}
					if F_Open_Read(F,TmpStr) then					{O arquivo pìde ser aberto?}
						begin										{Sim.}
							GetMem(EnmSprite[i-1],F_Size(TmpStr));	{Aloca mem¢ria para a vari†vel}
							BlockRead(F,EnmSprite[i-1]^,F_Size(TmpStr));{Là o arquivo}
							F_Close(F);								{Fecha o arquivo}
						end;
				end;
			X_Get_Pbm_SizeXY(i,Y,EnmSprite[0]^);	{Calcula o tamanho do Sprite, usando i como X}
			EnmSize.X:=i;							{Tamanho horizontal do inimigo}
			EnmSize.Y:=Y;							{Tamanho vertical do inimigo}
		end;
{****************************Procedimento DoneEnmSpr*************************}
{	Libera a mem¢ria alocada para os sprites dos inimigos.					 }
{****************************************************************************}
	procedure DoneEnmSpr;
		var i:byte;									{Indexador}
		begin
			for i:=0 to 2 do						{Para cada sprite, faáa}
				FreeMem(EnmSprite[i],X_SizeOf_Pbm(EnmSprite[i]^));{Libera a mem¢ria previamente alocada}
		end;
{******************************Funá∆o HandleEnemy****************************}
{	Ela desenha o inimigo nas coordenadas X e Y, checa se ele foi atingido,	 }
{manipula os tiros, etc. Caso o inimigo tenha sido atingido, ele adiciona os }
{bìnus necess†rios e retorna false, ou seja, o inimigo foi destru°do.		 }
{****************************************************************************}
	function HandleEnemy(X,Y:integer):boolean;
		var Dead:boolean;							{O inimigo morreu?}
		begin
			Dead:=false;							{O inimigo ainda n∆o morreu}
			if random(20)=0 then
				FireEnmShot((X + EnmSize.X div 2) mod 320,Y+EnmSize.Y);{Dispara um tiro}
			if X > 320-EnmSize.X then				{Se o inimigo estiver quase saindo da tela pela direita}
				begin
					X_Put_Masked_Pbm_ClipXY(X,Y,EnmSprite[EnmAnimCtrl]^);		{Desenha pela direita, saindo}
					X_Put_Masked_Pbm_ClipXY(X - 320,Y,EnmSprite[EnmAnimCtrl]^);	{Desenha pela esquerda, entrando}
					if (Inside(PlyShot.X,PlyShot.Y,X,Y,319,EnmSize.Y+Y+5)
											or Inside(PlyShot.X,PlyShot.Y,0,Y,EnmSize.X+(320-X),EnmSize.Y+Y+5)) then{Foi atingido?}
						begin
							inc(Score,10+(Level*2));{Aumenta o score}
							HandleEnemy:=False;		{Destr¢i o inimigo}
							if not Dead then
								dec(NumEnemy);		{Avisa ao jogo que um inimigo foi destru°do}
							Dead:=true;				{O inimigo morreu}
							PlyShotInScreen:=false;	{O tiro do jogador foi destru°do}
							EnmDeathSound;			{Produz o som de morte}
						end;
				if Inside(X-320,Y,PlyXCoord-EnmSize.X,PlyYCoord-EnmSize.Y,PlySize.X+PlyXCoord,PlyYCoord+PlySize.Y) then
						begin                       {Se colidir com o jogador, ent∆o}
							inc(Score,10+(Level*2));{Aumenta o score}
							HandleEnemy:=false;		{Destr¢i o inimigo}
							PlyDead:=true;			{Destr¢i o jogador}
							if not Dead then
								dec(NumEnemy);		{Avisa ao jogo que um inimigo foi destru°do}
							Dead:=true;				{O inimigo morreu}
						end;
				end
			else
				begin
					X_Put_Masked_Pbm_ClipY(X,Y,EnmSprite[EnmAnimCtrl]^);	{Desenha o inimigo}
					if Inside(PlyShot.X,PlyShot.Y,X,Y,EnmSize.X+X,EnmSize.Y+Y+5) then{Foi atingido?}
						begin
							inc(Score,10+(Level*2));{Aumenta o score}
							HandleEnemy:=False;		{Destr¢i o inimigo}
							if not Dead then
								dec(NumEnemy);		{Avisa ao jogo que um inimigo foi destru°do}
							Dead:=true;				{O inimigo morreu}
							PlyShotInScreen:=false;	{Destr¢i o tiro do jogador}
							EnmDeathSound;			{Produz o som de morte}
						end;
				end;
			if Inside(X,Y,PlyXCoord-EnmSize.X,PlyYCoord-EnmSize.Y,PlySize.X+PlyXCoord,PlyYCoord+PlySize.Y) then
				begin                       {Se colidir com o jogador, ent∆o}
					inc(Score,10+(Level*2));{Aumenta o score}
					HandleEnemy:=false;		{Destr¢i o inimigo}
					PlyDead:=true;			{Destr¢i o jogador}
					if not Dead then
						dec(NumEnemy);			{Avisa ao jogo que um inimigo foi destru°do}
					Dead:=true;				{O inimigo morreu}
				end;
		end;
End.