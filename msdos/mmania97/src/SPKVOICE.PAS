{*************Unidade SpkVoice, por Haroldo de Oliveira Pinheiro*************}
{	Toca arquivos RAW pelo PC Speaker.										 }
{	Procedimentos para mediá∆o de velocidade e acceso direto ao alto-falante }
{baseados em exemplos do livro "Turbo Pascal Soluá‰es".						 }
{****************************************************************************}
unit SpkVoice;
interface
	type
		SndBuffer=array[0..65000] of byte;				{Buffer usado para os sons}
		SpkSound=record									{Vari†vel usada para os sons}
					Size:Word;							{Tamanho}
					Sounds:^SndBuffer;					{Os sons propriamente ditos}
				 end;
{**************************Procedimento LoadSpkSound*************************}
{	Carrega um arquivo RAW para a mem¢ria.									 }
{	FileName Ç o nome do arquivo a ser carregado, podendo incluir o caminho. }
{	Snd Ç a vari†vel onde os sons ser∆o guardados.							 }
{****************************************************************************}
	procedure LoadSpkSound(FileName:String;var Snd:SpkSound);
{**************************Procedimento PlaySpkSound*************************}
{	Toca um arquivo RAW previamente carregado.								 }
{****************************************************************************}
	procedure PlaySpkSound(Snd:SpkSound);
{*************************Procedimento UnLoadSpkSound************************}
{	Libera a mem¢ria carregada para o efeito sonoro.						 }
{****************************************************************************}
	procedure UnLoadSpkSound(var Snd:SpkSound);
implementation
	uses Dos;
	const SndDivFactor=1400;
{****************************************************************************}
	procedure LoadSpkSound(FileName:String;var Snd:SpkSound);
		var F:file;
		begin
			assign(F,FileName);
			reset(F,1);
			if FileSize(F) < 65002 then
				Snd.Size:=FileSize(F)
			else
				Snd.Size:=65001;                            {N∆o Ç poss°vel alocar mais que 65001 bytes para os efeitos sonoros}
			GetMem(Snd.Sounds,Snd.Size);
			BlockRead(F,Snd.Sounds^,Snd.Size);
			close(F);
		end;
	procedure UnLoadSpkSound(var Snd:SpkSound);
		begin
			FreeMem(Snd.Sounds,Snd.Size);
			Snd.Size:=1;									{Evita erros no procedimento PlaySpkSound}
		end;
{****************************************************************************}
	var SoundDelay:longint;
		Port61:byte;
		OldPort61:byte;
	procedure PlaySpkSound(Snd:SpkSound);
		var x:byte;
			i,j,k:longint;
		begin
			for i:=0 to (Snd.Size - 1) do
				begin
					X:=Snd.Sounds^[i];
					{Move alto-falante para dentro}
					Port61:=Port61 and $FC;
					InLine( $A0/Port61 );
					InLine( $E6/$61 );
					for j:=1 to (X*SoundDelay) div SndDivFactor do;
					{Move alto-falante para fora}
					Port61:=Port61 or 2;
					InLine( $A0/Port61 );
					InLine( $E6/$61 );
					for j:=1 to ((not(X))*SoundDelay) div SndDivFactor do;
				end;
			InLine( $A0/OldPort61 );
			InLine( $E6/$61 );
		end;
{****************************************************************************}
	var Loops:longint;
		ctl:boolean;
	procedure TempPtr;interrupt;
		begin
			ctl:=false;
		end;
	procedure TestSpd;
		var OldPtr:pointer;
			i:byte;
			X:byte;
		begin
			InLine( $E4/$61 );
			InLine( $A2/Port61 );
			OldPort61:=Port61;
			X:=127;
			Loops:=0;
			getintvec($1C,OldPtr);
			setintvec($1C,@TempPtr);
			ctl:=true;
			repeat
			until not ctl;
			ctl:=true;
			while ctl do
				begin
					{Move alto-falante para dentro}
					Port61:=Port61 and $FC;
					InLine( $A0/Port61 );
					InLine( $E6/$61 );
					for i:=1 to X do;
					{Move alto-falante para fora}
					Port61:=Port61 or 2;
					InLine( $A0/Port61 );
					InLine( $E6/$61 );
					for i:=1 to not (X) do;
					inc(Loops);
				end;
			setintvec($1C,OldPtr);
			InLine( $A0/OldPort61 );
			InLine( $E6/$61 );
		end;
Begin
	WriteLn('SpkVoice_Init: Testing speed');
	TestSpd;
	SoundDelay:=Loops;
	If SoundDelay = 0 then
		SoundDelay:=1;
	WriteLn('  SoundDelay = ',SoundDelay);
End.