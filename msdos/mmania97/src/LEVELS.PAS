{Mega Mania 97: Rotinas de controle das fases}
unit Levels;
interface
	Uses Player;
	type
		Level1Info=array[0..9,0..2] of boolean;		{Informa‡Æo usada na fase 1}
		Level2Info=array[0..3,0..9] of boolean;		{Informa‡Æo usada na fase 2}
		Level3_5Info=array[0..15,0..2] of boolean;	{Informa‡Æo usada nas fases 3 e 5}
		Level6Rec=record							{Registro usado na fase 6}
					Pos:PointType;					{Posi‡Æo}
					Living:boolean;					{Est  vivo?}
				  end;
		Level6Info=array[0..19] of Level6Rec;		{Informa‡Æo usada na fase 6}

	var Lvl1Inf:^Level1Info;						{Informa‡äes sobre a fase 1}
		Lvl2Inf:^Level2Info;						{Informa‡äes sobre as fases 2, 4 e 7}
		Lvl3Inf:^Level3_5Info;						{Informa‡äes sobre as fases 3 e 5}
		Lvl6Inf:^Level6Info;						{Informa‡äes sobre a fase 6}
		GroupPos:PointType;							{Informa‡Æo sobre a posi‡Æo do grupo de inimigos}
		EnmDir:boolean;								{Informa‡Æo sobre a dire‡Æo para a qual os inimigos se movem}
		EnmMovCtrl:byte;							{Controle de movimento do inimigo}

	procedure InitLevel(Num:byte);					{Inicializa a fase}
	procedure HandleLevel(Num:byte);				{Manipula a fase}
	procedure ResetLevel(Num:byte);					{Reseta a fase}
	procedure DoneLevel(Num:byte);					{De-inicializa a fase}
implementation
	uses Enemy;
{*******************************Fun‡Æo Mod_**********************************}
{	Similar ao operador mod, mas tamb‚m funciona c/n£meros negativos.		 }
{****************************************************************************}
	function Mod_(A,B:integer):integer;
		begin
			if A < 0 then							{Se A for negativo, entÆo}
				Mod_:=-((-A) mod B)					{Faz a opera‡Æo p/n£meros negativos}
			else									{SenÆo}
				Mod_:=A mod B;						{Faz a opera‡Æo padrÆo}
		end;
{*****************************Procedimento InitLvl1**************************}
{	Inicializa a fase 1.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl1;
		var i,j:byte;								{Indexadores}
		begin
			ResetEnmShots;							{Reseta os tiros dos inimigos}
			LoadEnmSpr('SAUCER');					{Carrega as imagens dos inimigos}
			new(Lvl1Inf);							{Aloca mem¢ria para a vari vel}
			GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
			GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos (fixa)}
			for i:=0 to 9 do
				for j:=0 to 2 do
					Lvl1Inf^[i,j]:=true;			{"D  vida" aos inimigos}
			NumEnemy:=30;
		end;
{*****************************Procedimento InitLvl2**************************}
{	Inicializa a fase 2.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl2;
		var i,j:byte;								{Indexadores}
		begin
			ResetEnmShots;							{Reseta os tiros dos inimigos}
			LoadEnmSpr('YELLOW');					{Carrega as imagens dos inimigos}
			new(Lvl2Inf);							{Aloca mem¢ria para a vari vel}
			GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
			GroupPos.Y:=-370;						{Posi‡Æo vertical do grupo de inimigos}
			for i:=0 to 3 do
				for j:=0 to 9 do
					Lvl2Inf^[i,j]:=true;			{"D  vida" aos inimigos}
			NumEnemy:=40;
			EnmMovCtrl:=0;
		end;
{*****************************Procedimento InitLvl3**************************}
{	Inicializa a fase 3.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl3;
		var i,j:byte;								{Indexadores}
		begin
			ResetEnmShots;							{Reseta os tiros dos inimigos}
			LoadEnmSpr('DONUT');					{Carrega as imagens dos inimigos}
			new(Lvl3Inf);							{Aloca mem¢ria para a vari vel}
			GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
			GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos (fixa)}
			for i:=0 to 15 do
				for j:=0 to 2 do
					Lvl3Inf^[i,j]:=true;			{"D  vida" aos inimigos}
			NumEnemy:=48;
			EnmMovCtrl:=0;
			EnmDir:=true;
		end;
{*****************************Procedimento InitLvl4**************************}
{	Inicializa a fase 4.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl4;
		var i,j:byte;								{Indexadores}
		begin
			ResetEnmShots;							{Reseta os tiros dos inimigos}
			LoadEnmSpr('WHAT');						{Carrega as imagens dos inimigos}
			new(Lvl2Inf);							{Aloca mem¢ria para a vari vel}
			GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
			GroupPos.Y:=-295;						{Posi‡Æo vertical do grupo de inimigos}
			for i:=0 to 2 do
				for j:=0 to 9 do
					Lvl2Inf^[i,j]:=true;			{"D  vida" aos inimigos}
			NumEnemy:=30;
			EnmMovCtrl:=0;
		end;
{*****************************Procedimento InitLvl5**************************}
{	Inicializa a fase 5.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl5;
		var i,j:byte;								{Indexadores}
		begin
			ResetEnmShots;							{Reseta os tiros dos inimigos}
			LoadEnmSpr('TIE');						{Carrega as imagens dos inimigos}
			new(Lvl3Inf);							{Aloca mem¢ria para a vari vel}
			GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
			GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos (fixa)}
			for i:=0 to 15 do
				for j:=0 to 2 do
					Lvl3Inf^[i,j]:=true;			{"D  vida" aos inimigos}
			NumEnemy:=48;
			EnmMovCtrl:=0;
			EnmDir:=true;
		end;
{*****************************Procedimento InitLvl6**************************}
{	Inicializa a fase 6.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl6;
		var i:byte;									{Indexador}
		begin
			LoadEnmSpr('ALIEN');					{Carrega as imagens dos inimigos}
			new(Lvl6Inf);							{Aloca mem¢ria para a vari vel}
			for i:=0 to 19 do
				begin								{"D  vida" aos inimigos}
					Lvl6Inf^[i].Living:=true;
					Lvl6Inf^[i].Pos.X:=160;
					Lvl6Inf^[i].Pos.Y:=230;
				end;
			NumEnemy:=20;
		end;
{*****************************Procedimento InitLvl7**************************}
{	Inicializa a fase 7.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl7;
		var i,j:byte;								{Indexadores}
		begin
			ResetEnmShots;							{Reseta os tiros dos inimigos}
			LoadEnmSpr('TRI');						{Carrega as imagens dos inimigos}
			new(Lvl3Inf);							{Aloca mem¢ria para a vari vel}
			GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
			GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos (fixa)}
			for i:=0 to 15 do
				for j:=0 to 2 do
					Lvl3Inf^[i,j]:=true;			{"D  vida" aos inimigos}
			NumEnemy:=48;
			EnmMovCtrl:=0;
			EnmDir:=true;
		end;
{*****************************Procedimento InitLvl8**************************}
{	Inicializa a fase 8.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl8;
		var i,j:byte;								{Indexadores}
		begin
			ResetEnmShots;							{Reseta os tiros dos inimigos}
			LoadEnmSpr('GHOST');					{Carrega as imagens dos inimigos}
			new(Lvl2Inf);							{Aloca mem¢ria para a vari vel}
			GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
			GroupPos.Y:=-370;						{Posi‡Æo vertical do grupo de inimigos}
			for i:=0 to 3 do
				for j:=0 to 9 do
					Lvl2Inf^[i,j]:=true;			{"D  vida" aos inimigos}
			NumEnemy:=40;
			EnmMovCtrl:=0;
		end;
{*****************************Procedimento InitLvl9**************************}
{	Inicializa a fase 9.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl9;
		var i,j:byte;								{Indexadores}
		begin
			ResetEnmShots;							{Reseta os tiros dos inimigos}
			new(Lvl1Inf);							{Aloca mem¢ria para a vari vel}
			LoadEnmSpr('PINAPPL');					{Carrega as imagens dos inimigos}
			GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
			GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos (fixa)}
			for i:=0 to 9 do
				for j:=0 to 2 do
					Lvl1Inf^[i,j]:=true;			{"D  vida" aos inimigos}
			NumEnemy:=30;
		end;
{****************************Procedimento InitLvl10**************************}
{	Inicializa a fase 10.  utilizado pelo procedimento InitLevel.			 }
{****************************************************************************}
	procedure InitLvl10;
		var i,j:byte;								{Indexadores}
		begin
			ResetEnmShots;							{Reseta os tiros dos inimigos}
			LoadEnmSpr('CPU');						{Carrega as imagens dos inimigos}
			new(Lvl2Inf);							{Aloca mem¢ria para a vari vel}
			GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
			GroupPos.Y:=-295;						{Posi‡Æo vertical do grupo de inimigos}
			for i:=0 to 3 do
				for j:=0 to 9 do
					Lvl2Inf^[i,j]:=true;			{"D  vida" aos inimigos}
			NumEnemy:=40;
			EnmMovCtrl:=0;
		end;
{****************************Procedimento HandleLvl1*************************}
{	Manipula a fase 1. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl1;
		var i,j:byte;								{Indexadores}
		begin
			for i:=0 to 9 do
				for j:=0 to 2 do
					if Lvl1Inf^[i,j] then			{Se o inimigo estiver vivo, fa‡a procedimentos relacionados}
						Lvl1Inf^[i,j]:=HandleEnemy((GroupPos.X+(i*32)+(j*16)) mod 320,GroupPos.Y+(j*20));
			HandleEnmShot;
			inc(GroupPos.X,4);
			GroupPos.X:=GroupPos.X mod 320;
		end;
{****************************Procedimento HandleLvl2*************************}
{	Manipula a fase 2. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl2;
		var i,j:byte;								{Indexadores}
		function CalcX(i,j:byte):integer;			{Calcula o X do inimigo}
			var X:integer;							{Vari vel tempor ria}
			begin
				if j mod 2 = 0 then
					X:=(GroupPos.X + (i*80)) mod 320
				else
					begin
						X:=320-(GroupPos.X + (i*80));
						if X < 0 then				{Se X for negativo, entÆo}
							X:= -((-X) mod 320)
						else
							X:=X mod 320;
					end;
				if X < 0 then						{Se a coordenada for negativa, entÆo}
					inc(X,320);						{Passa para a correspondente positiva}
				CalcX:=X;							{Retorna o valor}
			end;
		begin
			for i:=0 to 3 do
				for j:=0 to 9 do
					if Lvl2Inf^[i,j] then			{Se o inimigo estiver vivo, fa‡a procedimentos relacionados}
						Lvl2Inf^[i,j]:=HandleEnemy(CalcX(i,j),Mod_((GroupPos.Y+(j*40)),400));
			HandleEnmShot;
			if EnmDir then
				inc(GroupPos.X,4)						{Atualiza a posi‡Æo X}
			else
				dec(GroupPos.X,4);						{Atualiza a posi‡Æo X}
			if GroupPos.X < 0 then
				inc(GroupPos.X,320)
			else
				GroupPos.X:=GroupPos.X mod 320;
			if EnmAnimCtrl = 0 then
				begin
					inc(GroupPos.Y);							{Atualiza a posi‡Æo Y}
					inc(EnmMovCtrl);
					if EnmMovCtrl > 15 then
						begin
							EnmDir:=not EnmDir;					{Muda a dire‡Æo do movimento}
							EnmMovCtrl:=0;
						end;
				end;
			if GroupPos.Y > 400 then
				dec(GroupPos.Y,400);
		end;
{****************************Procedimento HandleLvl3*************************}
{	Manipula a fase 3. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl3;
		var i,j:byte;								{Indexadores}
		begin
			for i:=0 to 15 do
				for j:=0 to 2 do
					if Lvl3Inf^[i,j] then			{Se o inimigo estiver vivo, fa‡a procedimentos relacionados}
						Lvl3Inf^[i,j]:=HandleEnemy((GroupPos.X+(i*32)+(j*16)) mod 320,GroupPos.Y+(j*20));
			HandleEnmShot;
			inc(GroupPos.X,4);
			GroupPos.X:=GroupPos.X mod 320;
			if EnmMovCtrl=20 then
				if EnmDir then
					inc(GroupPos.Y)					{Desce o grupo de inimigos}
				else
					dec(GroupPos.Y);				{Sobe o grupo de inimigos}
			inc(EnmMovCtrl);						{Atualiza a vari vel de controle}
			EnmMovCtrl:=EnmMovCtrl mod 21;
			if GroupPos.Y < 15 then					{Se o inimigo estiver acima da posi‡Æo permitida}
				EnmDir:=true						{Faz ele se mover para baixo}
			else if GroupPos.Y > 100 then			{Se o inimigo estiver abaixo da posi‡Æo permitida}
				EnmDir:=false;						{Faz ele se mover para cima}
		end;
{****************************Procedimento HandleLvl4*************************}
{	Manipula a fase 4. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl4;
		var i,j:byte;								{Indexadores}
		begin
			for i:=0 to 2 do
				for j:=0 to 9 do
					if Lvl2Inf^[i,j] then			{Se o inimigo estiver vivo, fa‡a procedimentos relacionados}
						Lvl2Inf^[i,j]:=HandleEnemy(GroupPos.X+i*60,Mod_((GroupPos.Y+(j*30)),300));
			HandleEnmShot;
			if EnmDir then
				inc(GroupPos.X,1)						{Atualiza a posi‡Æo X}
			else
				dec(GroupPos.X,1);						{Atualiza a posi‡Æo X}
			if GroupPos.X < 0 then
				EnmDir:=true
			else if GroupPos.X > 120 then
				EnmDir:=false;
			if EnmAnimCtrl = 0 then
				begin
					inc(GroupPos.Y);							{Atualiza a posi‡Æo Y}
					inc(EnmMovCtrl);
					if EnmMovCtrl > 14 then
						begin
							EnmDir:=EnmDir xor (Random(5)=0);	{Muda a dire‡Æo do movimento (ou nÆo!)}
							EnmMovCtrl:=0;
						end;
				end;
			if GroupPos.Y > 300 then
				dec(GroupPos.Y,300);
		end;
{****************************Procedimento HandleLvl5*************************}
{	Manipula a fase 5. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl5;
		var i,j:byte;								{Indexadores}
		begin
			for i:=0 to 15 do
				for j:=0 to 2 do
					if Lvl3Inf^[i,j] then			{Se o inimigo estiver vivo, fa‡a procedimentos relacionados}
						Lvl3Inf^[i,j]:=HandleEnemy((GroupPos.X+(i*32)+(j*16)) mod 320,GroupPos.Y+(j*20));
			HandleEnmShot;
			inc(GroupPos.X,4);
			GroupPos.X:=GroupPos.X mod 320;
			if EnmDir then
				inc(GroupPos.Y)						{Desce o grupo de inimigos}
			else
				dec(GroupPos.Y);					{Sobe o grupo de inimigos}
			inc(EnmMovCtrl);						{Atualiza a vari vel de controle}
			EnmMovCtrl:=EnmMovCtrl mod 21;
			if GroupPos.Y < 15 then					{Se o inimigo estiver acima da posi‡Æo permitida}
				EnmDir:=true						{Faz ele se mover para baixo}
			else if GroupPos.Y > 100 then			{Se o inimigo estiver abaixo da posi‡Æo permitida}
				EnmDir:=false;						{Faz ele se mover para cima}
		end;
{****************************Procedimento HandleLvl6*************************}
{	Manipula a fase 6. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl6;
		var i:byte;									{Indexador}
		begin
			for i:=0 to 19 do
				if Lvl6Inf^[i].Living then
					begin
						if (Lvl6Inf^[i].Pos.Y > 200) then{Se saiu pelo fundo}
							begin
							if Random(100)=0 then
								begin
									Lvl6Inf^[i].Pos.X:=random(320);
									Lvl6Inf^[i].Pos.Y:=-10;
								end;
							end
						else
							begin
								inc(Lvl6Inf^[i].Pos.Y,1);{Atualiza a posi‡Æo}
								Lvl6Inf^[i].Living:=HandleEnemy(Lvl6Inf^[i].Pos.X,Lvl6Inf^[i].Pos.Y);{Manipula o inimigo}
							end;
					end;
		end;
{****************************Procedimento HandleLvl7*************************}
{	Manipula a fase 7. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl7;
		var i,j:byte;								{Indexadores}
		begin
			for i:=0 to 15 do
				for j:=0 to 2 do
					if Lvl3Inf^[i,j] then			{Se o inimigo estiver vivo, fa‡a procedimentos relacionados}
						Lvl3Inf^[i,j]:=HandleEnemy((GroupPos.X+(i*32)+(j*16)) mod 320,GroupPos.Y+(j*20));
			HandleEnmShot;
			inc(GroupPos.X,3);
			GroupPos.X:=GroupPos.X mod 320;
			if EnmMovCtrl=0 then
				if EnmDir then
					inc(GroupPos.Y)						{Desce o grupo de inimigos}
				else
					dec(GroupPos.Y);					{Sobe o grupo de inimigos}
			inc(EnmMovCtrl);						{Atualiza a vari vel de controle}
			EnmMovCtrl:=EnmMovCtrl mod 5;
			if GroupPos.Y < 15 then					{Se o inimigo estiver acima da posi‡Æo permitida}
				EnmDir:=true						{Faz ele se mover para baixo}
			else if GroupPos.Y > 100 then			{Se o inimigo estiver abaixo da posi‡Æo permitida}
				EnmDir:=false;						{Faz ele se mover para cima}
		end;
{****************************Procedimento HandleLvl8*************************}
{	Manipula a fase 8. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl8;
		var i,j:byte;								{Indexadores}
		function CalcX(i,j:byte):integer;			{Calcula o X do inimigo}
			var X:integer;							{Vari vel tempor ria}
			begin
				if j mod 2 = 0 then
					X:=(GroupPos.X + (i*80)) mod 320
				else
					begin
						X:=320-(GroupPos.X + (i*80));
						if X < 0 then				{Se X for negativo, entÆo}
							X:= -((-X) mod 320)
						else
							X:=X mod 320;
					end;
				if X < 0 then						{Se a coordenada for negativa, entÆo}
					inc(X,320);						{Passa para a correspondente positiva}
				CalcX:=X;							{Retorna o valor}
			end;
		begin
			for i:=0 to 3 do
				for j:=0 to 9 do
					if Lvl2Inf^[i,j] then			{Se o inimigo estiver vivo, fa‡a procedimentos relacionados}
						Lvl2Inf^[i,j]:=HandleEnemy(CalcX(i,j),Mod_((GroupPos.Y+(j*40)),400));
			HandleEnmShot;
			if EnmDir then
				inc(GroupPos.X,1)						{Atualiza a posi‡Æo X}
			else
				dec(GroupPos.X,1);						{Atualiza a posi‡Æo X}
			if GroupPos.X < 0 then
				inc(GroupPos.X,320)
			else
				GroupPos.X:=GroupPos.X mod 320;
			if EnmAnimCtrl > 0 then
				begin
					inc(GroupPos.Y);							{Atualiza a posi‡Æo Y}
					inc(EnmMovCtrl);
					if EnmMovCtrl > 10 then
						begin
							EnmDir:=not EnmDir;					{Muda a dire‡Æo do movimento}
							EnmMovCtrl:=0;
						end;
				end;
			if GroupPos.Y > 400 then
				dec(GroupPos.Y,400);
		end;
{****************************Procedimento HandleLvl9*************************}
{	Manipula a fase 9. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl9;
		var i,j:byte;								{Indexadores}
		begin
			for i:=0 to 9 do
				for j:=0 to 2 do
					if Lvl1Inf^[i,j] then			{Se o inimigo estiver vivo, fa‡a procedimentos relacionados}
						Lvl1Inf^[i,j]:=HandleEnemy((GroupPos.X+(i*32)+(j*16)) mod 320,GroupPos.Y+(j*20));
			HandleEnmShot;
			inc(GroupPos.X,4);
			GroupPos.X:=GroupPos.X mod 320;
			if EnmMovCtrl=0 then
				if EnmDir then
					inc(GroupPos.Y)					{Desce o grupo de inimigos}
				else
					dec(GroupPos.Y);				{Sobe o grupo de inimigos}
			inc(EnmMovCtrl);						{Atualiza a vari vel de controle}
			EnmMovCtrl:=EnmMovCtrl mod 2;
			if GroupPos.Y < 15 then					{Se o inimigo estiver acima da posi‡Æo permitida}
				EnmDir:=true						{Faz ele se mover para baixo}
			else if GroupPos.Y > 100 then			{Se o inimigo estiver abaixo da posi‡Æo permitida}
				EnmDir:=false;						{Faz ele se mover para cima}
		end;
{***************************Procedimento HandleLvl10*************************}
{	Manipula a fase 10. Usado internamente por HandleLevel.					 }
{****************************************************************************}
	procedure HandleLvl10;
		var i,j:byte;								{Indexadores}
		begin
			for i:=0 to 3 do
				for j:=0 to 9 do
					if Lvl2Inf^[i,j] then			{Se o inimigo estiver vivo, fa‡a procedimentos relacionados}
						Lvl2Inf^[i,j]:=HandleEnemy(GroupPos.X+i*60,Mod_((GroupPos.Y+(j*30)),300));
			HandleEnmShot;
			if EnmDir then
				inc(GroupPos.X,2)						{Atualiza a posi‡Æo X}
			else
				dec(GroupPos.X,2);						{Atualiza a posi‡Æo X}
			if GroupPos.X < 0 then
				EnmDir:=true
			else if GroupPos.X > 120 then
				EnmDir:=false;
			if EnmAnimCtrl = 0 then
				begin
					inc(GroupPos.Y);							{Atualiza a posi‡Æo Y}
					inc(EnmMovCtrl);
					if EnmMovCtrl > 14 then
						begin
							EnmDir:=EnmDir xor (Random(5)=0);	{Muda a dire‡Æo do movimento (ou nÆo!)}
							EnmMovCtrl:=0;
						end;
				end;
			if GroupPos.Y > 300 then
				dec(GroupPos.Y,300);
		end;
{****************************Procedimento DoneLvl1***************************}
{	Limpa os dados da fase 1. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl1;
		begin
			dispose(Lvl1Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{****************************Procedimento DoneLvl2***************************}
{	Limpa os dados da fase 2. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl2;
		begin
			dispose(Lvl2Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{****************************Procedimento DoneLvl3***************************}
{	Limpa os dados da fase 3. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl3;
		begin
			dispose(Lvl3Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{****************************Procedimento DoneLvl4***************************}
{	Limpa os dados da fase 4. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl4;
		begin
			dispose(Lvl2Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{****************************Procedimento DoneLvl5***************************}
{	Limpa os dados da fase 5. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl5;
		begin
			dispose(Lvl3Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{****************************Procedimento DoneLvl6***************************}
{	Limpa os dados da fase 6. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl6;
		begin
			dispose(Lvl6Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{****************************Procedimento DoneLvl7***************************}
{	Limpa os dados da fase 7. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl7;
		begin
			dispose(Lvl3Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{****************************Procedimento DoneLvl8***************************}
{	Limpa os dados da fase 8. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl8;
		begin
			dispose(Lvl2Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{****************************Procedimento DoneLvl9***************************}
{	Limpa os dados da fase 9. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl9;
		begin
			dispose(Lvl1Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{***************************Procedimento DoneLvl10***************************}
{	Limpa os dados da fase 10. Usado pelo procedimento DoneLevel.			 }
{****************************************************************************}
	procedure DoneLvl10;
		begin
			dispose(Lvl2Inf);                       {Libera a mem¢ria previamente alocada}
			DoneEnmSpr;								{Libera a mem¢ria alocada para o sprite do inimigo}
		end;
{****************************Procedimento InitLevel**************************}
{	Inicializa os dados referentes … fase indicada por Num.					 }
{****************************************************************************}
	procedure InitLevel(Num:byte);
		begin
			case Num of
				1:InitLvl1;
				2:InitLvl2;
				3:InitLvl3;
				4:InitLvl4;
				5:InitLvl5;
				6:InitLvl6;
				7:InitLvl7;
				8:InitLvl8;
				9:InitLvl9;
				0:InitLvl10;
			end;
		end;
{****************************Procedimento HandleLevel************************}
{	Controla a fase indicada em Num.										 }
{****************************************************************************}
	procedure HandleLevel(Num:byte);
		begin
			case Num of
				1:HandleLvl1;
				2:HandleLvl2;
				3:HandleLvl3;
				4:HandleLvl4;
				5:HandleLvl5;
				6:HandleLvl6;
				7:HandleLvl7;
				8:HandleLvl8;
				9:HandleLvl9;
				0:HandleLvl10;
			end;
		end;
{*****************************Procedimento ResetLevel************************}
{	Reseta a fase indicada em Num (Os inimigos nÆo retornam).				 }
{****************************************************************************}
	procedure ResetLevel(Num:byte);
		var i:byte;											{Indexador}
		begin
			ResetEnmShots;
			case Num of
				1:begin										{Fase 1}
					GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
					GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos (fixa)}
				  end;
				2:begin										{Fase 2}
					GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
					GroupPos.Y:=-400;						{Posi‡Æo vertical do grupo de inimigos}
				  end;
				3:begin										{Fase 3}
					GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
					GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos}
					EnmMovCtrl:=0;							{Reseta o controle de movimento}
				  end;
				4:begin										{Fase 4}
					GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
					GroupPos.Y:=-295;						{Posi‡Æo vertical do grupo de inimigos}
				  end;
				5:begin										{Fase 5}
					GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
					GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos}
					EnmMovCtrl:=0;							{Reseta o controle de movimento}
				  end;
				6:begin										{Fase 6}
					for i:=0 to 19 do
						begin								{"D  vida" aos inimigos}
							Lvl6Inf^[i].Living:=true;
							Lvl6Inf^[i].Pos.X:=160;
							Lvl6Inf^[i].Pos.Y:=230;
						end;
				  end;
				7:begin										{Fase 7}
					GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
					GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos}
					EnmMovCtrl:=0;							{Reseta o controle de movimento}
				  end;
				8:begin										{Fase 8}
					GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
					GroupPos.Y:=-400;						{Posi‡Æo vertical do grupo de inimigos}
				  end;
				9:begin										{Fase 9}
					GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
					GroupPos.Y:=15;							{Posi‡Æo vertical do grupo de inimigos (fixa)}
				  end;
				0:begin										{Fase 10}
					GroupPos.X:=0;							{Posi‡Æo horizontal do grupo de inimigos}
					GroupPos.Y:=-295;						{Posi‡Æo vertical do grupo de inimigos}
				  end;
			end;
		end;
{*****************************Procedimento DoneLevel*************************}
{	De-inicializa os dados correspondentes … fase indicada por Num, preparan-}
{do-se para a pr¢xima fase, ou para o Game Over.							 }
{****************************************************************************}
	procedure DoneLevel(Num:byte);
		begin
			case Num of
				1:DoneLvl1;
				2:DoneLvl2;
				3:DoneLvl3;
				4:DoneLvl4;
				5:DoneLvl5;
				6:DoneLvl6;
				7:DoneLvl7;
				8:DoneLvl8;
				9:DoneLvl9;
				0:DoneLvl10;
			end;
		end;
End.