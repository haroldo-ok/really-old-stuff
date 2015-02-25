{	Unidade Keybd, por Haroldo de Oliveira Pinheiro. }
{	Manipulador especial de teclado.                 }
{	VersÆo original: 1997  Modificado em: 2003		 }
unit Keybd;
interface
	uses Crt,Dos;
	const										{N£meros das teclas}
		{Fileira das teclas de fun‡Æo}
		scEsc       = 001;
		scF1        = 059;
		scF2        = 060;
		scF3        = 061;
		scF4        = 062;
		scF5        = 063;
		scF6        = 064;
		scF7        = 065;
		scF8        = 066;
		scF9        = 067;
		scF10       = 068;
		scF11       = 087;
		scF12       = 088;
		scScrlLock  = 070;
		{Fileira dos n£meros}
		scTilde     = 041;
		sc1         = 002;
		sc2         = 003;
		sc3         = 004;
		sc4         = 005;
		sc5         = 006;
		sc6         = 007;
		sc7         = 008;
		sc8         = 009;
		sc9         = 010;
		sc0         = 011;
		scMinus     = 012;
		scEqual     = 013;
		scBackSpace = 014;
		{Fileira QWERTY}
		scTab       = 015;
		scQ         = 016;
		scW         = 017;
		scE         = 018;
		scR         = 019;
		scT         = 020;
		scY         = 021;
		scU         = 022;
		scI         = 023;
		scO         = 024;
		scP         = 025;
		scOpenSq    = 026;
		scCloseSq   = 027;
		scEnter     = 028;
		{Fileira ASDFGH}
		scCapsLock  = 058;
		scA         = 030;
		scS         = 031;
		scD         = 032;
		scF         = 033;
		scG         = 034;
		scH         = 035;
		scJ         = 036;
		scK         = 037;
		scL         = 038;
		scSemicolon = 039;
		scQoute     = 040;
		{Fileira dos Shifts}
		scLShift    = 042;
		scBackSlash = 043;
		scZ         = 044;
		scX         = 045;
		scC         = 046;
		scV         = 047;
		scB         = 048;
		scN         = 049;
		scM         = 050;
		scComma     = 051;
		scPeriod    = 052;
		scSlash     = 053;
		scRShift    = 054;
		{Fileira dos Ctrls}
		scCtrl      = 029;
		scAlt       = 056;
		scSpace     = 057;
		{Teclado num‚rico}
		scHome      = 071;
		scUp        = 072;
		scPgUp      = 073;
		scLeft      = 075;
		scKey5      = 076;
		scRight     = 077;
		scEnd       = 079;
		scDown      = 080;
		scPgDn      = 081;
		scNumLock   = 069;
		scGrayMinus = 074;
		scGrayPlus  = 078;
		scAsterisk  = 055;
		scIns       = 082;
		scDel       = 083;
	var Keys:array[0..127] of boolean;			{Diz quais teclas foram pressionadas}
		CleanBuf:boolean;						{Diz se o buffer de teclado deve ser mantido limpo (Pode conflitar com outros procedimentos)}
		KeybdInstalled:boolean;
{**************************Procedimento InitKeyboard*************************}
{	Inicializa o manipulador especial de teclado.							 }
{****************************************************************************}
	procedure InitKeyboard;
{**************************Procedimento DoneKeyboard*************************}
{	Volta ao antigo manipulador de teclado.									 }
{****************************************************************************}
	procedure DoneKeyboard;
implementation
	var KbdIntVec : Procedure;                  {Antiga interrup‡Æo de teclado}
	{$F+}
	procedure Keyclick;interrupt;				{Nova interrup‡Æo de teclado. Parcialmente baseado no arquivo de ajuda do Turbo Pascal}
		var NextState:boolean;					{Novo estado da tecla}
			Key:byte;							{Tecla a ser modificada}
			Key2:char;							{Tecla lida}
		begin
			Key:=Port[$60];						{Armazena os dados enviados pelo teclado na vari vel Key}
			NextState:=Key<127;					{Checa se a tecla foi pressionada ou liberada}
			Key:=Key and 127;					{S¢ vamos precisar dos primeiros 7 bits}
			Keys[Key]:=NextState;				{Atualiza o status das teclas}
			inline ($9C);
			KbdIntVec;							{Chama a antiga interrup‡Æo de teclado}
			if CleanBuf and KeyPressed then
				begin
					Key2:=ReadKey;				{Limpa o buffer de teclado}
					if Key2=#0 then				{Se for tecla especial}
						ReadKey;				{Repete a leitura}
				end;
		end;
	{$F-}
	procedure InitKeyboard;
		var i:byte;
		begin
			if KeybdInstalled then
				Exit;

			for i:=0 to 127 do					{Limpa o status das teclas}
				Keys[i]:=false;
			GetIntVec($9,@KbdIntVec);			{Pega o endere‡o da antiga interrup‡Æo de teclado}
			SetIntVec($9,Addr(Keyclick));		{Instala a nova interrup‡Æo de teclado}

			KeybdInstalled := True;
		end;
	procedure DoneKeyboard;
		begin
			if not KeybdInstalled then
				Exit;

			SetIntVec($9,Addr(KbdIntVec));		{Retorna as coisas ao seu estado original}

			KeybdInstalled := False;
		end;

	var OldExit:pointer;

	procedure NewExitProc;Far; {Uma salvaguarda para o caso do programa dar erro.}
		begin
			DoneKeyboard;
			ExitProc := OldExit;
		end;

Begin
	CleanBuf:=false;
	KeybdInstalled:=false;
	OldExit:=ExitProc;
	ExitProc := @NewExitProc;
End.