{$OUTPUT_FORMAT AS}
unit TimerUnit;
{Unidade de timer}
{programado por Haroldo de Oliveira Pinheiro}
{2001-10-04: Modificada para usar a unit Timer da biblioteca sbPlay}
interface
    const
        TimerCount=4;
    var Timers:array[0..Pred(TimerCount)] of longint;
	procedure SetTimer(Frequency:word);
	procedure CleanUpTimer;
implementation
    uses Go32, sbPlay, sbDetect, sbMOD, Timer, Dos, Crt;
	var Captured:boolean;

    procedure CustomHandler;
        var i:byte;
        begin
            for i:=0 to Pred(TimerCount) do
                Inc(Timers[i]);
        end;

	procedure SetTimer(Frequency:word);
		begin
            CallTimerProc:=false;
            TimerProc:=CustomHandler;
            CallTimerProc:=true;
            if Captured then
                DoneTimer;
            InitTimer(Frequency);
            Captured:=true;
		end;
	procedure CleanUpTimer;
		begin
            CallTimerProc:=false;
            if Captured then
                DoneTimer;
            Captured:=false;
		end;
Begin
	Captured:=false;
End.