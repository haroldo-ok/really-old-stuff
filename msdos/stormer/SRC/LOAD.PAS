(*  load.pas - Digital Sound Interface Kit V1.01a loading routines.

    Copyright 1993,94 Carlos Hasan
*)

unit Load;

interface
uses Sound;

(* Status Value *)
var
  DSMStatus : word;

(* Sound System API Routines *)
function DSMLoad(const FileName:String; FileOffset:dword):PDSM;
procedure DSMFree(Module:PDSM);
function DSMLoadSample(const FileName:String; FileOffset:dword):PDSMInst;
procedure DSMFreeSample(Inst:PDSMInst);
function DSMLoadSetup(var Card:DSMCard):boolean;
function DSMSaveSetup(var Card:DSMCard):boolean;

implementation

(* I/O File Operations *)
const
  SEEK_SET = 0;
  SEEK_CUR = 1;
  SEEK_END = 2;

function Open(var Handle:file; const FileName:String):boolean;
begin
  {$I-}
  System.Assign(Handle,FileName);
  System.Reset(Handle,1);
  {$I+}
  Open := (System.IOResult <> 0);
end;

function Create(var Handle:file; const FileName:String):boolean;
begin
  {$I-}
  System.Assign(Handle,FileName);
  System.Rewrite(Handle,1);
  {$I+}
  Create := (System.IOResult <> 0);
end;

procedure Close(var Handle:file);
begin
  {$I-}
  System.Close(Handle);
  {$I+}
end;

function Seek(var Handle:file; Offset:dword; Where:byte):boolean;
begin
  {$I-}
  case Where of
    SEEK_SET : System.Seek(Handle,Offset);
    SEEK_CUR : System.Seek(Handle,System.FilePos(Handle)+Offset);
    SEEK_END : System.Seek(Handle,System.FileSize(Handle)+Offset);
  end;
  {$I+}
  Seek := (System.IOResult <> 0);
end;

function Read(var Handle:file; var Buf; Count:word):word;
var
  Readed : word;
begin
  {$I-}
  System.BlockRead(Handle,Buf,Count,Readed);
  Read := Readed;
  {$I+}
end;

function Write(var Handle:file; var Buf; Count:word):word;
var
  Written : word;
begin
  {$I-}
  System.BlockWrite(Handle,Buf,Count,Written);
  Write := Written;
  {$I+}
end;


function DSMLoadInst(var Handle:file):PDSMInst;
var
  Inst    : PDSMInst;
  Samples : Pointer;
begin
  GetMem(Inst,sizeof(DSMInst));
  if Inst = nil then begin
    DSMStatus := ERR_NORAM;
    DSMLoadInst := nil;
    exit;
  end;
  if Read(Handle,Inst^,sizeof(DSMInst)) <> sizeof(DSMInst) then begin
    DSMStatus := ERR_ACCESS;
    FreeMem(Inst,sizeof(DSMInst));
    DSMLoadInst := nil;
    exit;
  end;
  if Inst^.Length = 0 then begin
    Inst^.Address := nil;
    DSMLoadInst := Inst;
    exit;
  end;
  GetMem(Samples,Inst^.Length);
  Inst^.Address := Samples;
  if Samples = nil then begin
    DSMStatus := ERR_NORAM;
    FreeMem(Inst,sizeof(DSMInst));
    DSMLoadInst := nil;
    exit;
  end;
  if Read(Handle,Inst^.Address^,Inst^.Length) <> Inst^.Length then begin
    DSMStatus := ERR_ACCESS;
    FreeMem(Inst^.Address,Inst^.Length);
    FreeMem(Inst,sizeof(DSMInst));
    DSMLoadInst := nil;
    exit;
  end;
  if DSMAllocSampleData(Inst) then begin
    DSMStatus := ERR_NODRAM;
    FreeMem(Samples,Inst^.Length);
    FreeMem(Inst,sizeof(DSMInst));
    DSMLoadInst := nil;
    exit;
  end;
  if DSMTypeOfRAM = RAM_CARD then begin
    FreeMem(Samples,Inst^.Length);
  end;
  DSMLoadInst := Inst;
end;

procedure DSMFreeInst(Inst:PDSMInst);
begin
  if Inst <> nil then begin
    if Inst^.Address <> nil then begin
      DSMFreeSampleData(Inst);
      if DSMTypeOfRAM <> RAM_CARD then begin
        FreeMem(Inst^.Address,Inst^.Length);
      end;
    end;
    FreeMem(Inst,sizeof(DSMInst));
  end;
end;

function DSMLoadPatt(var Handle:file):PDSMPatt;
var
  Patt   : PDSMPatt;
  Length : word;
begin
  if Read(Handle,Length,sizeof(Length)) <> sizeof(Length) then begin
    DSMStatus := ERR_ACCESS;
    DSMLoadPatt := nil;
    exit;
  end;
  GetMem(Patt,Length);
  if Patt = nil then begin
    DSMStatus := ERR_NORAM;
    DSMLoadPatt := nil;
    exit;
  end;
  Patt^.Length := Length;
  dec(Length,sizeof(Length));
  if Read(Handle,Patt^.Data,Length) <> Length then begin
    DSMStatus := ERR_ACCESS;
    FreeMem(Patt,Patt^.Length);
    DSMLoadPatt := nil;
    exit;
  end;
  DSMLoadPatt := Patt;
end;

procedure DSMFreePatt(Patt:PDSMPatt);
begin
  if Patt <> nil then FreeMem(Patt,Patt^.Length);
end;

function DSMLoad(const FileName:String; FileOffset:dword):PDSM;
var
  Handle : file;
  Header : DSMHeader;
  Block  : DSMBlock;
  Module : PDSM;
  Inst   : ^PDSMInst;
  Patt   : ^PDSMPatt;
begin
  GetMem(Module,sizeof(DSM));
  if Module = nil then begin
    DSMStatus := ERR_NORAM;
    DSMLoad := nil;
    exit;
  end;
  FillChar(Module^,sizeof(DSM),0);
  Inst := Addr(Module^.Inst);
  Patt := Addr(Module^.Patt);

  if Open(Handle,FileName) then begin
    DSMStatus := ERR_NOFILE;
    DSMFree(Module);
    DSMLoad := nil;
    exit;
  end;
  if Seek(Handle,FileOffset,SEEK_SET) then begin
    DSMStatus := ERR_ACCESS;
    DSMFree(Module);
    Close(Handle);
    DSMLoad := nil;
    exit;
  end;
  if Read(Handle,Header,sizeof(Header)) <> sizeof(Header) then begin
    DSMStatus := ERR_ACCESS;
    DSMFree(Module);
    Close(Handle);
    DSMLoad := nil;
    exit;
  end;
  if (Header.ID <> ID_RIFF) or (Header.FileType <> ID_DSMF) then begin
    DSMStatus := ERR_FORMAT;
    DSMFree(Module);
    Close(Handle);
    DSMLoad := nil;
    exit;
  end;
  dec(Header.Length,sizeof(Header.FileType));
  while Header.Length <> 0 do begin
    if Read(Handle,Block,sizeof(Block)) <> sizeof(Block) then begin
      DSMStatus := ERR_ACCESS;
      DSMFree(Module);
      Close(Handle);
      DSMLoad := nil;
      exit;
    end;
    dec(Header.Length,sizeof(Block)+Block.Length);
    if Block.ID = ID_SONG then begin
      if Read(Handle,Module^.Song,Block.Length) <> Block.Length then begin
        DSMStatus := ERR_ACCESS;
        DSMFree(Module);
        Close(Handle);
        DSMLoad := nil;
        exit;
      end;
    end
    else if Block.ID = ID_INST then begin
      Inst^ := DSMLoadInst(Handle);
      if Inst^ = nil then begin
        DSMFree(Module);
        Close(Handle);
        DSMLoad := nil;
        exit;
      end;
      inc(Inst);
    end
    else if Block.ID = ID_PATT then begin
      Patt^ := DSMLoadPatt(Handle);
      if Patt^ = nil then begin
        DSMFree(Module);
        Close(Handle);
        DSMLoad := nil;
        exit;
      end;
      inc(Patt);
    end
    else begin
      if Seek(Handle,Block.Length,SEEK_CUR) then begin
        DSMStatus := ERR_ACCESS;
        DSMFree(Module);
        Close(Handle);
        DSMLoad := nil;
        exit;
      end;
    end;
  end;
  Close(Handle);
  DSMLoad := Module;
end;

procedure DSMFree(Module:PDSM);
var
  I    : word;
  Inst : ^PDSMInst;
  Patt : ^PDSMPatt;
begin
  if Module <> nil then begin
    Inst := Addr(Module^.Inst);
    for I := 0 to Pred(MAXSAMPLES) do begin
      if Inst^ <> nil then DSMFreeInst(Inst^);
      inc(Inst);
    end;
    Patt := Addr(Module^.Patt);
    for I := 0 to pred(MAXORDERS) do begin
      if Patt^ <> nil then DSMFreePatt(Patt^);
      inc(Patt);
    end;
    FreeMem(Module,sizeof(DSM));
  end;
end;

function DSMLoadSample(const FileName:String; FileOffset:dword):PDSMInst;
var
  Handle  : file;
  Inst    : PDSMInst;
  Samples : Pointer;
  Wave    : record
              Header : DSMHeader;
              Format : DSMBlock;
              Fmt    : DSMWave;
              Data   : DSMBlock;
            end;
begin
  GetMem(Inst,sizeof(DSMInst));
  if Inst = nil then begin
    DSMStatus := ERR_NORAM;
    DSMLoadSample := nil;
    exit;
  end;
  FillChar(Inst^,sizeof(DSMInst),0);
  if Open(Handle,FileName) then begin
    DSMStatus := ERR_NOFILE;
    FreeMem(Inst,sizeof(DSMInst));
    DSMLoadSample := nil;
    exit;
  end;
  if Seek(Handle,FileOffset,SEEK_SET) then begin
    DSMStatus := ERR_ACCESS;
    FreeMem(Inst,sizeof(DSMInst));
    Close(Handle);
    DSMLoadSample := nil;
    exit;
  end;
  if Read(Handle,Wave,sizeof(Wave)) <> sizeof(Wave) then begin
    DSMStatus := ERR_ACCESS;
    FreeMem(Inst,sizeof(DSMInst));
    Close(Handle);
    DSMLoadSample := nil;
    exit;
  end;
  if (Wave.Header.ID <> ID_RIFF) or (Wave.Header.FileType <> ID_WAVE) or
     (Wave.Format.ID <> ID_FMT) or (Wave.Data.ID <> ID_DATA) or
     (Wave.Fmt.SampleFormat <> 1) or (Wave.Fmt.NumChannels <> 1) or
     (Wave.Fmt.BitsPerSmpl <> 8) then begin
    DSMStatus := ERR_FORMAT;
    FreeMem(Inst,sizeof(DSMInst));
    Close(Handle);
    DSMLoadSample := nil;
    exit;
  end;
  Inst^.Period := (dword(MIDCFREQ)*MIDCPERIOD) div Wave.Fmt.PlayRate;
  Inst^.Length := Wave.Data.Length;
  Inst^.MidCRate := Wave.Fmt.PlayRate;
  Inst^.Volume := 64;
  GetMem(Samples,Inst^.Length);
  Inst^.Address := Samples;
  if Samples = nil then begin
    DSMStatus := ERR_NORAM;
    FreeMem(Inst,sizeof(DSMInst));
    Close(Handle);
    DSMLoadSample := nil;
    exit;
  end;
  if Read(Handle,Inst^.Address^,Inst^.Length) <> Inst^.Length then begin
    DSMStatus := ERR_ACCESS;
    FreeMem(Inst^.Address,Inst^.Length);
    FreeMem(Inst,sizeof(DSMInst));
    Close(Handle);
    DSMLoadSample := nil;
    exit;
  end;
  if DSMAllocSampleData(Inst) then begin
    DSMStatus := ERR_NODRAM;
    FreeMem(Inst^.Address,Inst^.Length);
    FreeMem(Inst,sizeof(DSMInst));
    Close(Handle);
    DSMLoadSample := nil;
    exit;
  end;
  if DSMTypeOfRAM = RAM_CARD then begin
    FreeMem(Samples,Inst^.Length);
  end;
  Close(Handle);
  DSMLoadSample := Inst;
end;

procedure DSMFreeSample(Inst:PDSMInst);
begin
  if Inst <> nil then begin
    if Inst^.Address <> nil then begin
      DSMFreeSampleData(Inst);
      if DSMTypeOfRAM <> RAM_CARD then begin
        FreeMem(Inst^.Address,Inst^.Length);
      end;
    end;
    FreeMem(Inst,sizeof(DSMInst));
  end;
end;

function DSMLoadSetup(var Card:DSMCard):boolean;
var
  Handle : file;
begin
  if Open(Handle,'SOUND.CFG') then begin
    DSMLoadSetup := true;
    exit;
  end;
  if Read(Handle,Card,sizeof(DSMCard)) <> sizeof(DSMCard) then begin
    Close(Handle);
    DSMLoadSetup := true;
    exit;
  end;
  Close(Handle);
  DSMLoadSetup := false;
end;

function DSMSaveSetup(var Card:DSMCard):boolean;
var
  Handle : file;
begin
  if Create(Handle,'SOUND.CFG') then begin
    DSMSaveSetup := true;
    exit;
  end;
  if Write(Handle,Card,sizeof(DSMCard)) <> sizeof(DSMCard) then begin
    Close(Handle);
    DSMSaveSetup := true;
    exit;
  end;
  Close(Handle);
  DSMSaveSetup := false;
end;


function HeapFunc(Size:Word): Integer; far;
begin
  if Size<>0 then HeapFunc := 1;
end;

begin
  if Test8086 < 2 then begin
    writeln('This program requires at least an 80386 processor.');
    halt;
  end;
  HeapError := @HeapFunc;
end.
