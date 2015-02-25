{	Unidade Keybd, por Haroldo de Oliveira Pinheiro.}
{	Manipulador especial de teclado.}
{	VersÆo 32 bits.}
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
{**************************Procedimento InitKeyboard*************************}
{	Inicializa o manipulador especial de teclado.							 }
{****************************************************************************}
	procedure InitKeyboard;
{**************************Procedimento DoneKeyboard*************************}
{	Volta ao antigo manipulador de teclado.									 }
{****************************************************************************}
	procedure DoneKeyboard;
implementation
    {$ASMMODE INTEL}
    uses Go32;
	var KbdIntVec, CustomKbd : TSegInfo;        {Antiga interrup‡Æo de teclado}
	procedure KeyClick;interrupt;				{Nova interrup‡Æo de teclado. Parcialmente baseado no arquivo de ajuda do Turbo Pascal}
		var NextState:boolean;					{Novo estado da tecla}
			Key:byte;							{Tecla a ser modificada}
		begin
            asm
                pushad
            end;
			Key:=InPortB($60);					{Armazena os dados enviados pelo teclado na vari vel Key}
			NextState:=Key<127;					{Checa se a tecla foi pressionada ou liberada}
			Key:=Key and 127;					{S¢ vamos precisar dos primeiros 7 bits}
			Keys[Key]:=NextState;				{Atualiza o status das teclas}
            OutPortB($20,$20);                  {Avisa que recebeu a interrup‡Æo}  
            asm
                popad
            end;
		end;
    procedure KeyClick_Dummy; begin end;        {S¢ para marcar o lugar}

	procedure InitKeyboard;
		var i:byte;
		begin
            asm
                cli
            end;
            Lock_Data(Keys,SizeOf(Keys));
            Lock_Code(@KeyClick, 
                      longint(@KeyClick_Dummy)-longint(@KeyClick));
			for i:=0 to 127 do					{Limpa o status das teclas}
				Keys[i]:=false;
        	CustomKbd.OffSet:=@KeyClick;
            CustomKbd.Segment:=Get_CS;
            Get_Pm_Interrupt($09, KbdIntVec);
            Set_Pm_Interrupt($09, CustomKbd);
            asm
                sti
            end;
		end;
	procedure DoneKeyboard;
		begin
            asm
                cli
            end;
            UnLock_Data(Keys,SizeOf(Keys));
            UnLock_Code(@KeyClick, 
                        longint(@KeyClick_Dummy)-longint(@KeyClick));
			Set_Pm_Interrupt($09,KbdIntVec);	{Retorna as coisas ao seu estado original}
            asm
                sti
            end;
		end;
Begin
End.