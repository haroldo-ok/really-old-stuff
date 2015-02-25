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

UNIT SBMOD;

INTERFACE

USES  GO32,SBPLAY,TIMER;


CONST mod_max_ch ={16} 8; { MAX. MOD-CHANNELS }
      mod_max_vol=16; { MAX. MOD-VOLUME }

TYPE  mod_instrument = packed record
                    name    : array[0..21]of char;
                    length  : word;
                    finetune: byte;
                    def_vol : byte;
                    loop_start : word;
                    loop_length: word;
                   end;
      mod_header = packed record
                    song_name  : array[0..19]of char;
                    instrument : array[1..31]of mod_instrument;
                    song_length: byte;
                    ciaa_speed : byte;
                    song_arrangement : array[0..127]of byte;
                    modtype : array[0..3]of char;
                   end;
      my_mod_note = record
                    instrumentnr : byte;
                    toneheight : word;
                    effect : byte;
                    op : byte;
                   end;
      org_mod_note = packed record
                    instrumentnr : byte;
                    toneheight : byte;
                    effect : byte;
                    op : byte;
                   end;


VAR   mod_num_pat, mod_num_ch : longint;                        { NUMBER OF MOD-PATTERNS/MOD-CHANNELS }
      mod_h   : mod_header;
      mod_pat : array[0..63,0..63,1..mod_max_ch]of my_mod_note; { MAX. 64 PATTERNS … 64 LINES … MOD_MAX_CH CHANNELS }
      mod_sam : array[1..31]of pointer;                         { SAMPLE-DATA }

      mod_pat_row, mod_mom_pat, mod_arrangement_pos : longint;  { PATTERNROW, PATTERN PLAYED RIGHT NOW, POSITION IN ARRANGEMENT }
      mod_BPM, mod_num_ticks, mod_ticks, mod_timercalls : longint;


PROCEDURE MOD2Mem(mod_name : string);
PROCEDURE FreeMOD;
PROCEDURE PlayMOD;
PROCEDURE StopMOD;
PROCEDURE ResumeMOD; { FIRST, OF COURSE, CALL STOPMOD =) }


IMPLEMENTATION


CONST mod_notes : array[0..60]of word=($36,$39,$3C,$40,$43,$47,$4C,$55,$5A,$5F,$65,$6B,$71,$78,$7F,$87,$8F,$97,$A0,$AA,$B4,$BE,$CA,$D6,$E2,$F0,$FE,$10D,$11D,$12E,$140,$153,$168,$17D,$194,$1AC,$1C5,$1E0,$1FC,$21A,$23A,$25C,$280,$2A6,$2D0,$2FA,$328,$358,$386,$3C1,$3FA,$436,$477,$4BB,$503,$54F,$5A0,$5F5,$650,$6B0,$6B0);

VAR   sbvolslide : array[1..mod_max_ch]of longint;
      sbportamento, sbportamentonote : array[1..mod_max_ch]of longint;
      sbtoneheight : array[1..mod_max_ch]of word;
      sbarpeggiopos, sbarpeggio0, sbarpeggio1, sbarpeggio2 : array[1..mod_max_ch]of longint;


PROCEDURE SetChannelRate(chan : byte; rate : word);
BEGIN

 sbadder[chan]:=((3579364 div rate) shl FixedPointShift) div SampleRate;

END;


PROCEDURE MOD2Mem(mod_name : string);
 Var f : file;
     v,v2,v3 : longint;
     note : org_mod_note;
     pt,pt2 : pointer;
BEGIN

  assign(f,mod_name);
  reset(f,1);

  blockread(f,mod_h,sizeof(mod_h));

  for v:=1 to 31 do with mod_h do begin
   instrument[v].length:=swap(instrument[v].length)*2;
   instrument[v].loop_start:=swap(instrument[v].loop_start)*2;
   instrument[v].loop_length:=swap(instrument[v].loop_length)*2;
   if instrument[v].def_vol>MaxVolume then instrument[v].def_vol:=MaxVolume;
  end; { CONVERSION OF AMIGA-WORDS }

  if (mod_h.modtype='6CHN') then mod_num_ch:=6
   else if (mod_h.modtype='8CHN') then mod_num_ch:=8
    else if (mod_h.modtype='12CH') then mod_num_ch:=12
     else if (mod_h.modtype='16CH') then mod_num_ch:=16
      else mod_num_ch:=4; { NUMBER OF CHANNELS }

  mod_num_pat:=filesize(f)-sizeof(mod_h);
  for v:=1 to 31 do dec(mod_num_pat,mod_h.instrument[v].length);
  mod_num_pat:=mod_num_pat div (sizeof(org_mod_note)*64*mod_num_ch); { CALCULATE NUM. OF PATTERNS }

  getmem(pt,mod_num_pat*64*mod_num_ch*sizeof(org_mod_note));  { READ PATTERNS }
  blockread(f,pt^,mod_num_pat*64*mod_num_ch*sizeof(org_mod_note));
  pt2:=pt;

  for v:=0 to mod_num_pat-1 do
   for v2:=0 to 63 do
    for v3:=1 to mod_num_ch do begin
     move(pt2^,note,sizeof(note));
     inc(pt2,sizeof(note));
     mod_pat[v,v2,v3].instrumentnr:=(note.instrumentnr and $F0) + (note.effect shr 4);
     mod_pat[v,v2,v3].toneheight:=((note.instrumentnr and $0F) shl 8) + note.toneheight;
     mod_pat[v,v2,v3].effect:=note.effect and $0F;
     mod_pat[v,v2,v3].op:=note.op;
    end; { CONVERSION OF DUMB NOTE-FORMAT TO USEFUL FORMAT }

  freemem(pt,mod_num_pat*64*mod_num_ch*sizeof(org_mod_note));

  for v:=1 to 31 do
   if mod_h.instrument[v].length>0 then begin
    getmem(mod_sam[v],mod_h.instrument[v].length);
    blockread(f,mod_sam[v]^,mod_h.instrument[v].length);
   end; { READ SAMPLES }

  close(f);

  {for v:=1 to 31 do
   if mod_h.instrument[v].length>0 then begin
    str(v,st);
    assign(f,st+'.raw');
    rewrite(f,1);
    blockwrite(f,mod_sam[v]^,mod_h.instrument[v].length);
    close(f);
   end;} { WRITE SAMPLES }

END;


PROCEDURE FreeMOD;
 Var v : longint;
BEGIN

  for v:=1 to 31 do
   if mod_h.instrument[v].length>0 then freemem(mod_sam[v],mod_h.instrument[v].length);

END;


FUNCTION  GetNote(rate : word) : longint; { I DON'T KNOW IF THIS ONE IS ALRIGHT }
 Var v : longint;
BEGIN

  if (rate<=mod_notes[0]) then begin getnote:=0; exit; end;
  if (rate>=mod_notes[59]) then begin getnote:=59; exit; end;

  for v:=0 to 59 do
   if (rate=mod_notes[v]) or (rate<mod_notes[v+1]) then begin getnote:=v; exit; end;

END;


PROCEDURE MODT;
 Var continue : boolean;
     ch : longint;
 Label oncemore;
BEGIN

  inc(mod_timercalls,(((mod_BPM*2) div 5) shl FixedPointShift) div timerfreq); { TO BE INDEPENDENT OF THE TIMERFREQUENCY }

  oncemore:

  if (mod_timercalls<=1 shl FixedPointShift) then exit;
  dec(mod_timercalls,1 shl FixedPointShift);

  inc(mod_ticks);

  if (mod_ticks<mod_num_ticks) then begin
   for ch:=1 to mod_num_ch+1 do begin

    if (sbvolslide[ch]>0) then begin     { VOLUME SLIDE FX }
     inc(sbvolume[ch],sbvolslide[ch]);
     if (sbvolume[ch]>mod_max_vol) then begin sbvolume[ch]:=mod_max_vol; sbvolslide[ch]:=0; end;
    end;
    if (sbvolslide[ch]<0) then begin
     if (longint(sbvolume[ch])+sbvolslide[ch]<0) then begin sbvolume[ch]:=0; sbvolslide[ch]:=0; end
      else inc(sbvolume[ch],sbvolslide[ch]);
    end;

    if (sbportamento[ch]<>0) then begin  { PORTAMENTO FX }
     inc(sbtoneheight[ch],sbportamento[ch]);
     if (sbportamentonote[ch]>0) then
      if ((sbtoneheight[ch]<sbportamentonote[ch]) and (sbportamento[ch]<0)) or ((sbtoneheight[ch]>sbportamentonote[ch]) and (sbportamento[ch]>0)) then begin sbtoneheight[ch]:=sbportamentonote[ch]; sbportamento[ch]:=0; end;
     if (sbtoneheight[ch]<$36) then begin sbtoneheight[ch]:=$36; sbportamento[ch]:=0; end;
     setchannelrate(ch,sbtoneheight[ch]);
    end;

    if (sbarpeggiopos[ch]>0) then begin  { ARPEGGIO FX }
     inc(sbarpeggiopos[ch]);
     case (sbarpeggiopos[ch] mod 3) of
      0 : setchannelrate(ch,sbarpeggio2[ch]);
      1 : setchannelrate(ch,sbarpeggio0[ch]);
      2 : setchannelrate(ch,sbarpeggio1[ch]);
     end;
    end;
   end;
   goto oncemore
  end;

  mod_ticks:=0;
  continue:=false;

  for ch:=1 to mod_num_ch do with mod_pat[mod_mom_pat,mod_pat_row,ch] do begin

   if (toneheight>0) and (effect<>3) then begin { FREQUENCY CHANGED }
    setchannelrate(ch,toneheight);
    sbtoneheight[ch]:=toneheight;
    sbportamento[ch]:=0;
    sbarpeggiopos[ch]:=0;
    sbportamentonote[ch]:=0;
   end;

   if (instrumentnr>0) then begin { INSTRUMENT CHANGED }
    sbStart [ch]:=longint(mod_sam[instrumentnr]);
    sbPos   [ch]:=0;
    sbEnd   [ch]:=mod_h.instrument[instrumentnr].length shl FixedPointShift;
    if (mod_h.instrument[instrumentnr].loop_length=0) then sbStatus[ch]:=stOnce { LOOP ? }
     else begin
      sbStatus    [ch]:=stLoop;
      sbLoopStart [ch]:=mod_h.instrument[instrumentnr].loop_start shl FixedPointShift;
      sbLoopEnd   [ch]:=(mod_h.instrument[instrumentnr].loop_length+mod_h.instrument[instrumentnr].loop_start) shl FixedPointShift;
     end;
    sbVolume[ch]:=mod_h.instrument[instrumentnr].def_vol*mod_max_vol div MaxVolume;
    sbportamento[ch]:=0;
    sbarpeggiopos[ch]:=0;
    sbportamentonote[ch]:=0;
    sbvolslide[ch]:=0;
   end;

   case effect of
    0  : if (op>0) then begin { ARPEGGIO .. DON'T KNOW IF THIS ONES ALRIGHT }
          sbarpeggiopos[ch]:=1;
          sbarpeggio0[ch]:=sbtoneheight[ch];
          if sbarpeggio0[ch]<$36 then sbarpeggio0[ch]:=$36;
          if (getnote(sbtoneheight[ch])-longint(op shr 4)<0) then sbarpeggio1[ch]:=$36
           else sbarpeggio1[ch]:=mod_notes[getnote(sbtoneheight[ch])-longint(op shr 4)];
          if (getnote(sbtoneheight[ch])-longint(op and $0F)<0) then sbarpeggio2[ch]:=$36
           else sbarpeggio2[ch]:=mod_notes[getnote(sbtoneheight[ch])-longint(op and $0F)];
         end;
    1  : sbportamento[ch]:=-op; { PORTAMENTO }
    2  : sbportamento[ch]:=op;
    3  : if (toneheight>0) then   { PORTAMENTO TO NOTE }
          if (sbtoneheight[ch]<toneheight) then begin sbportamento[ch]:=op; sbportamentonote[ch]:=toneheight; end
           else begin sbportamento[ch]:=-op; sbportamentonote[ch]:=toneheight; end;
    9  : sbPos[ch]:=(op shl 8) shl FixedPointShift; { SAMPLE-POSITION CHANGE }
    5,6,10 : if (op shr 4=0) then sbvolslide[ch]:=-op else sbvolslide[ch]:=op shr 4; { VOLUME SLIDE }
    11 : begin { POSITION JUMP }
          mod_pat_row:=0;
          mod_arrangement_pos:=op;
          if mod_arrangement_pos>=mod_h.song_length then mod_arrangement_pos:=0;
          mod_mom_pat:=mod_h.song_arrangement[mod_arrangement_pos];
          continue:=true;
         end;
    12 : sbVolume[ch]:=op*mod_max_vol div MaxVolume; { VOLUME CHANGE }
    13 : begin { PATTERN BREAK }
          mod_pat_row:=op;
          inc(mod_arrangement_pos);
          if mod_arrangement_pos>=mod_h.song_length then mod_arrangement_pos:=0;
          mod_mom_pat:=mod_h.song_arrangement[mod_arrangement_pos];
          continue:=true;
         end;
    15 : if (op<=31) then mod_num_ticks:=op else mod_BPM:=op; { SET SPEED }

    14 : case (op shr 4) of
          1  : begin { FINE PORTAMENTO }
                dec(sbtoneheight[ch],op and $0F);
                if (sbtoneheight[ch]<$36) then sbtoneheight[ch]:=$36;
                setchannelrate(ch,sbtoneheight[ch]);
               end;
          2  : begin
                inc(sbtoneheight[ch],op and $0F);
                setchannelrate(ch,sbtoneheight[ch]);
               end;
          10 : begin { FINE VOLUME SLIDE }
                inc(sbvolume[ch],op and $0F);
                if (sbvolume[ch]>mod_max_vol) then sbvolume[ch]:=mod_max_vol;
               end;
          11 : if (longint(sbvolume[ch])-longint(op and $0F)<0) then sbvolume[ch]:=0 else dec(sbvolume[ch],op and $0F);
         end;
   end;
  end;

  if continue=false then begin
   inc(mod_pat_row);
   if (mod_pat_row>63) then begin
    mod_pat_row:=0;
    inc(mod_arrangement_pos);
    if mod_arrangement_pos>=mod_h.song_length then mod_arrangement_pos:=0;
    mod_mom_pat:=mod_h.song_arrangement[mod_arrangement_pos];
   end;
  end;

  goto oncemore

END;


PROCEDURE PlayMOD;
BEGIN

  mod_arrangement_pos:=0;
  mod_mom_pat:=mod_h.song_arrangement[0];
  mod_pat_row:=0;

  mod_BPM:=125;
  mod_num_ticks:=6;
  mod_ticks:=0;

  mod_timercalls:=0;

  timerproc2:=modt;
  calltimerproc2:=true;

END;


PROCEDURE StopMOD;
BEGIN

  calltimerproc2:=false;

END;


PROCEDURE ResumeMOD;
BEGIN

  calltimerproc2:=true;

END;

END.

{
  History:

  v.0.1.0: First Public Release

  v.0.1.1: A very tiny Bugfix which fixes a LOT of errors..
           For example:
           -Arpeggio is O.K. in most MODs now..
           -No more =) lockups after starting a MOD..
           (Forgot to add the SampleStart to SBLoopEnd if the sample is looped..)

  v.0.1.2: Just reorganised everything a bit..
           And fixed the mod-timer routine (with a nasty GOTO :)..
}