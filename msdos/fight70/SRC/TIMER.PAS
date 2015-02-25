{
  sbMod v.0.1.2

  (C)2K-1 by CARSTEN WAECHTER aka THE TOXIC AVENGER/AINC.

  This Unit is Public Domain..
   Feel free to use, enhance or even learn about this code..
  If you like it, please drop a message to:
   toxie@gmx.net
  To get the newest version of sbMod surf to:
   http://www.uni-ulm.de/~s_cwaech/

  All changes are listed below..
}

{$OUTPUT_FORMAT AS}
UNIT TIMER;

INTERFACE

USES GO32;

VAR  TimerProc,TimerProc2 : procedure;       { USER DEFINED PROCS CALLED WITH TimerFreq RATE }
     CallTimerProc,CallTimerProc2 : boolean; { CALL PROCS ?? }
     TimerFreq : longint;                    { TIMERFREQUENCY }

     Time,TimerCount : longint;  { COUNTERS }
     Frame,FrameCount : longint; { EASY FPS COUNTER .. JUST INCREASE THEM IN YOUR MAINLOOP }
     FpS : string[3];            { AND YOU'LL GET THE CORRECT FPS IN HERE }


PROCEDURE InitTimer(freq : longint);
PROCEDURE DoneTimer;                         { MUST (!!) BE CALLED AT PROGRAM-END }

PROCEDURE TimerSpeed(freq : longint);        { CHANGE TIMERSPEED }


IMPLEMENTATION


VAR  Timer_In_Progress : boolean;
     OldTimerIRQ,NewTimerIRQ : tseginfo;


PROCEDURE NewTimer;
BEGIN

  {$I386_DIRECT}
  asm
   pusha
   pushw %ds
   pushw %es
   movw  %cs:INT8DS, %ax
   movw  %ax, %ds
   movw  %ax, %es
  end ['EAX'];

  if (timer_in_progress=false) then begin
   timer_in_progress:=true;

   inc(time);

   if (timercount<timerfreq-1) then inc(timercount)
    else begin
     str(framecount,fps);
     timercount:=0;
     framecount:=0;
    end;

   if calltimerproc then timerproc;
   if calltimerproc2 then timerproc2;
   timer_in_progress:=false;
  end;
  outportb($20,$20);

  asm
   popw  %es
   popw  %ds
   popa
   leave
   iret
  INT8DS:
   .word 0
  end [ ];

END;


PROCEDURE TimerSpeed(freq : longint);
BEGIN

  outportb($43,$36);
  outportb($40,lo(word(1193180 div freq)));
  outportb($40,hi(word(1193180 div freq)));

  TimerFreq:=freq;

END;


PROCEDURE InitTimer(freq : longint);
BEGIN

  get_pm_interrupt(8,oldtimerirq);
  newtimerirq.segment:=get_cs;
  newtimerirq.offset:=@newtimer;
  asm
   movw  %ds, %ax
   movw  %ax, INT8DS
  end ['EAX'];

  timerspeed(freq);
  set_pm_interrupt(8,newtimerirq);

END;


PROCEDURE DoneTimer;
BEGIN

  outportb($43,$36);
  outportb($40,0);
  outportb($40,0);

  set_pm_interrupt(8,oldtimerirq);

END;


BEGIN

  calltimerproc:=false;
  calltimerproc2:=false;
  timer_in_progress:=false;
  frame:=0;
  time:=0;
  timercount:=0;
  framecount:=0;
  fps:='666';

END.
{
  History:

  v.0.1.0: First Public Release

  v.0.1.2: Just reorganised everything a bit..
}