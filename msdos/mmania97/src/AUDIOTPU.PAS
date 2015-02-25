{ AUDIOTPU.PAS  - (c) Ansgar Scherp, Joachim Gelhaus
  All rights reserved / vt'95 }

{$A+,B+,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q+,R-,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}

UNIT AUDIOTPU;

INTERFACE

USES Dos, Crt { Delay };


var  maxTitles : integer; {jo INTEGER!!}

CONST
  NOT_CHANGED        = $01;
  IOO_CLOSE_TRAY     = 5;
  LOCK               = $01;
  SEEK_1             = 131;
  DIGITALCOPY        = $20;
  DEV_CLOSE          = 14;
  HAS_CHANGED        = $FF;
  STOP_AUDIO         = 133;
  IOI_SECT_SIZE      = 7;
  IOCTL_INP          = 3;
  IOCTL_OUTP         = 12;
  EMPHASIS           = $10;
  FOURTRACK          = $80;
  DOOR_OPEN          = $001{L};
  DATA_AND_AUDIO     = $010{L};
  DOOR_UNLOCKED      = $002{L};
  TWOTRACK           = $00;
  PREFETCHING        = $080{L};
  UNLOCK             = $00;
  DEV_OPEN           = 13;
  HSG_AND_RED        = $200{L};
  INTERLEAVING       = $020{L};
  WRITE_LONG         = 134;
  IOI_DRIVE_BYTES    = 5;
  IOI_QCHAN_INFO     = 12;
  READ_LONG          = 128;
  DONT_KNOW          = $00;
  RESUME_AUDIO       = 136;
  IOI_UPC            = 14;
  DATA               = $40;
  IOI_AUDIO_INFO     = 10;
  AUDIO_MANIPULATION = $100{L};
  IOO_EJECT          = 0;
  IOI_VOL_SIZE       = 8;
  IOI_DEV_STAT       = 6;
  IOI_LOC_HEAD       = 1;
  IOI_DRV_HEAD       = 0;
  IOI_MEDIA_CHANG    = 9;
  WRITE_LONG_VERIFY  = 135;
  IOI_AUDIO_STATUS   = 15;
  PLAY_AUDIO         = 132;
  IOO_LOCK           = 1;
  IOO_AUDIOCHAN_CTRL = 3;
  IOI_AUDIOCHAN_INFO = 4;
  COOKED_AND_RAW     = $004{L};
  Red                = 1;
  READ_WRITE         = $008{L};
  IOI_TRACK_INFO     = 11;
  READ_LONG_PREFETCH = 130;
  INIT               = 0;
  HSG                = 0;
  IOO_RESET          = 2;
  OUTPUT_FLUSH       = 8;
  INPUT_FLUSH        = 7;

TYPE
  CD_Addr = RECORD CASE INTEGER OF
    0 : (HSG_Sector : WORD);
    1 : (Time       : RECORD
                        Frame  : BYTE;
                        Second : BYTE;
                        Minute : BYTE;
                        Unused : BYTE;
                      END);
  END;

  pInteger = ^INTEGER;

  Audio_Status = RECORD
    Status : WORD;
    Start  : CD_Addr;
    End_1  : CD_Addr;
  END;

  Request_Hdr = RECORD
    rq_Len    : BYTE;
    rq_Unit   : BYTE;
    rq_Cmd    : BYTE;
    rq_Status : WORD;
    Reserved  : ARRAY [0..7] OF BYTE;
  END;

  QChannel_Info = RECORD
    Tno    : BYTE; { Track }
    x      : BYTE;
    tMin   : BYTE;
    tSec   : BYTE;
    tFrame : BYTE;
    Zero   : BYTE;
    dMin   : BYTE;
    dSec   : BYTE;
    dFrame : BYTE;
  END;

  Audio_Play_Request = RECORD
    Play_rqh  : Request_Hdr;
    Addr_Mode : BYTE;         { RED or HSG }
    Start     : CD_Addr;      { Startframe }
    nFrames   : LONGINT;
  END;

  IO_Inp_Audio_Status = RECORD
    IOctl_Cmd : BYTE;
    Report    : Audio_Status;
  END;

  IO_Inp_Track_Info = RECORD
    IOctl_Cmd : BYTE;
    Tno       : BYTE;
    Start     : CD_Addr;
    Control   : BYTE;
  END;
  { control:
              TWOTRACK      $0
              FOURTRACK     $80
              EMPHASIS      $10
              DATA          $40
              DIGITALCOPY   $20 }

  IO_Inp_Audio_Info = RECORD
    IOctl_Cmd      : BYTE;
    Track_Lo       : BYTE;
    Track_Hi       : BYTE;
    Track_Lead_Out : CD_Addr;
  END;

  IOCTL_Inp_Request = RECORD
    IOctl_Rqh    : Request_Hdr;

    IOctl_Media  : BYTE;
    IOCtl_xFer   : pInteger;
    IOCtl_nBytes : WORD;
    IOctl_Sector : WORD;
    IOctl_VolID  : pInteger;
  END;

  Track_Info_Tag = RECORD
    Start  : CD_Addr;
    Frames : LONGINT;
    Delta  : CD_Addr;
  END;

  A_TrackInfoTag_99 = ARRAY [0..98] OF Track_Info_Tag;

  IO_Inp_Device_Status = RECORD
    IOctl_Cmd : BYTE;
    Status    : WORD;
  END;

  IO_Inp_UPC = RECORD
    IOctl_Cmd : BYTE;
    Addr_Mode : BYTE;
    Signature : ARRAY [0..13] OF CHAR;
    aFrame    : BYTE;                  { ????? }
  END;

  IO_Inp_Device_Hdr = RECORD
    IOctl_Cmd  : BYTE;
    Device_Hdr : pInteger;
  END;

  IO_Inp_Media_Changed = RECORD
    IOctl_Cmd  : BYTE;
    Media_Byte : BYTE;
  END;

  IO_Inp_QChannel = RECORD
    IOctl_Cmd : BYTE;
    Addr_Mode : BYTE;
    qInfo     : QChannel_Info;
  END;

  IO_Outp_Eject = RECORD
    IOctl_Cmd : BYTE;
  END;

  IO_Inp_Audiochan_Info = RECORD
    IOctl_Cmd : BYTE;
    Inp_Chan0 : BYTE;
    Vol_Chan0 : BYTE;
    Inp_Chan1 : BYTE;
    Vol_Chan1 : BYTE;
    Inp_Chan2 : BYTE;
    Vol_Chan2 : BYTE;
    Inp_Chan3 : BYTE;
    Vol_Chan3 : BYTE;
  END;

  IO_Outp_Lock_Door = RECORD
    IOctl_Cmd  : BYTE;
    Function_1 : BYTE;
  END;

  IO_Inp_Volume_Size = RECORD
    IOctl_Cmd : BYTE;
    HSG_Sect  : WORD;
  END;

  IO_Inp_Sector_Size = RECORD
    IOctl_Cmd : BYTE;
    Addr_Mode : BYTE;
    Sect_Size : WORD;
  END;

  IO_Inp_Drive_Bytes = RECORD
    IOctl_Cmd  : BYTE;
    Bytes2read : BYTE;
    Read_Buff  : ARRAY [0..127] OF BYTE;
  END;

  IO_Inp_Head_Loc = RECORD
    IOctl_Cmd : BYTE;
    Addr_Mode : BYTE;
    Location  : WORD;
  END;

CONST
  rq_Input : IO_Inp_Audiochan_Info = (
    IOctl_Cmd : 0;
    Inp_Chan0 : 0;
    Vol_Chan0 : 0;
    Inp_Chan1 : 0;
    Vol_Chan1 : 0;
    Inp_Chan2 : 0;
    Vol_Chan2 : 0;
    Inp_Chan3 : 0;
    Vol_Chan3 : 0);

  rq_Volume : IO_Inp_Audiochan_Info = (
    IOctl_Cmd : 0;
    Inp_Chan0 : 0;
    Vol_Chan0 : 0;
    Inp_Chan1 : 0;
    Vol_Chan1 : 0;
    Inp_Chan2 : 0;
    Vol_Chan2 : 0;
    Inp_Chan3 : 0;
    Vol_Chan3 : 0);

  rq_Insert : IO_Outp_Eject = (IOctl_Cmd : 0);

  rq_Eject  : IO_Outp_Eject = (IOctl_Cmd : 0);

  rq_Reset  : IO_Outp_Eject = (IOctl_Cmd : 0);

  rq_QChan  : IO_Inp_QChannel = (
    IOctl_Cmd : 0;
    Addr_Mode : 0;
    qInfo     : (
      Tno    : 0;
      x      : 0;
      tMin   : 0;
      tSec   : 0;
      tFrame : 0;
      Zero   : 0;
      dMin   : 0;
      dSec   : 0;
      dFrame : 0));

  Index : A_TrackInfoTag_99 = (
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0)),
    (Start:(HSG_Sector: 0);Frames:0;Delta:(HSG_Sector : 0))
  );

  Start_Play : LONGINT = 0;
  End_Play   : LONGINT = 0;

  qInfo : QChannel_Info = (
    Tno    : 0;
    x      : 0;
    tMin   : 0;
    tSec   : 0;
    tFrame : 0;
    Zero   : 0;
    dMin   : 0;
    dSec   : 0;
    dFrame : 0);

  Audio_Drive : WORD = 0;
  Titles      : BYTE = 0;

  rqInp : IOCTL_Inp_Request = (
    IOctl_Rqh : (
      rq_Len    : SizeOf(IOCTL_Inp_Request);
      rq_Unit   : 0;
      rq_Cmd    : IOCTL_INP;
      rq_Status : 0;
      Reserved  : (0,0,0,0,0,0,0,0));
    IOctl_Media  : 0;
    IOCtl_xFer   : NIL;
    IOCtl_nBytes : 0;
    IOctl_Sector : 0;
    IOctl_VolID  : NIL);

  rq_Status : IO_Inp_Device_Status = (
    IOctl_Cmd : IOI_DEV_STAT;
    Status    : 0);

  rq_UPC : IO_Inp_UPC = (
    IOctl_Cmd : IOI_UPC;
    Addr_Mode : Red;
    Signature : (#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0);
    aFrame    : 0);

  rq_Header : IO_Inp_Device_Hdr = (
    IOctl_Cmd  : IOI_DRV_HEAD;
    Device_Hdr : NIL);

  rq_Busy : IO_Inp_Device_Hdr = (
    IOctl_Cmd  : IOI_DRV_HEAD;
    Device_Hdr : NIL);

  rq_Audio_Status : IO_Inp_Audio_Status = (
    IOctl_Cmd : IOI_AUDIO_STATUS;
    Report    : (
      Status : 0;
      Start  : (HSG_Sector : 0);
      End_1  : (HSG_Sector : 0)));

  rq_Media : IO_Inp_Media_Changed = (
    IOctl_Cmd  : IOI_MEDIA_CHANG;
    Media_Byte : 0);

  rqOutp : IOCTL_Inp_Request = (
    IOctl_Rqh   : (
      rq_Len    : SizeOf(IOCTL_Inp_Request);
      rq_Unit   : 0;
      rq_Cmd    : IOCTL_OUTP;
      rq_Status : 0;
      Reserved  : (0,0,0,0,0,0,0,0));
    IOctl_Media  : 0;
    IOCtl_xFer   : NIL;
    IOCtl_nBytes : 0;
    IOctl_Sector : 0;
    IOctl_VolID  : NIL);

  rq_Play : Audio_Play_Request = (
    Play_rqh : (
      rq_Len    : SizeOf(Audio_Play_Request);
      rq_Unit   : 0;
      rq_Cmd    : PLAY_AUDIO;
      rq_Status : 0;
      Reserved  : (0,0,0,0,0,0,0,0));
    Addr_Mode : Red;
    Start     : (HSG_Sector : 0);
    nFrames   : 0);

  rq_Stop : Audio_Play_Request = (
    Play_rqh : (
      rq_Len    : SizeOf(Request_Hdr);
      rq_Unit   : 0;
      rq_Cmd    : STOP_AUDIO;
      rq_Status : 0;
      Reserved  : (0,0,0,0,0,0,0,0));
    Addr_Mode : Red;
    Start     : (HSG_Sector : 0);
    nFrames   : 0);

  rq_Resume : Audio_Play_Request = (
    Play_rqh : (
      rq_Len    : SizeOf(Request_Hdr);
      rq_Unit   : 0;
      rq_Cmd    : RESUME_AUDIO;
      rq_Status : 0;
      Reserved  : (0,0,0,0,0,0,0,0));
    Addr_Mode : Red;
    Start     : (HSG_Sector : 0);
    nFrames   : 0);

  FUNCTION Red2HSG(Time : CD_Addr) : LONGINT;
  PROCEDURE HSG2Red(nSect : LONGINT; VAR Local : CD_Addr);
  FUNCTION IOctl_In(Drive    : WORD;
                    Unit_1   : BYTE;
                    pRequest : pInteger;
                    rqLen    : WORD) : WORD;
  FUNCTION Get_Status(Drive : CHAR) : WORD;
  PROCEDURE Get_UPC(VAR UPC : STRING);
  FUNCTION Get_Header : pInteger;
  FUNCTION Audio_Busy : WORD;
  PROCEDURE Read_Audio_Status(VAR Status : Audio_Status);
  FUNCTION Get_Media_Changed : BYTE;
  FUNCTION Get_TOC : BYTE;
  FUNCTION Audio_Pause : WORD;
  FUNCTION Get_Track_Info(Tno : BYTE) : BYTE;
  PROCEDURE Read_QChannel(VAR QC : QChannel_Info);
  FUNCTION IOctl_Out(Drive    : WORD;
                     Unit_1   : BYTE;
                     pRequest : pInteger;
                     rqLen    : WORD) : WORD;
  PROCEDURE CD_Reset;
  PROCEDURE Eject_CD;
  PROCEDURE Insert_CD;
  PROCEDURE SetVolume(Chan0, Chan1, Chan2, Chan3 : BYTE);
  PROCEDURE SetInput(Chan0, Chan1, Chan2, Chan3 : BYTE);
  FUNCTION Play_Audio_1(Start    : CD_Addr;
                        nSectors : LONGINT) : WORD;
  FUNCTION Play_Track(Tno : BYTE) : BOOLEAN;
  FUNCTION Play_Tracks(From, To_1 : LONGINT) : BOOLEAN;
  FUNCTION Play_Track_Intro(Tno : INTEGER) : BOOLEAN;
  FUNCTION Stop_Audio_1 : WORD;
  FUNCTION Resume_Audio_1 : WORD;
  FUNCTION Skip_Audio(Frames : LONGINT) : WORD;
  FUNCTION Init_CDAudio : INTEGER;
  FUNCTION Get_Titles : BYTE;
  PROCEDURE Get_Len(Tno : CHAR; VAR Len : CD_Addr);
  FUNCTION Get_Actual_Track : INTEGER;
  PROCEDURE Get_Time_In_Track(T : QChannel_Info);
  FUNCTION Get_Audio_Drive : CHAR;

IMPLEMENTATION

  FUNCTION Red2HSG(Time : CD_Addr) : LONGINT;
  BEGIN
    Red2HSG := LONGINT ( LONGINT(Time.Time.Minute) * 4500 +
                         LONGINT(Time.Time.Second) *   75 +
                         LONGINT(Time.Time.Frame) );
  END;

  PROCEDURE HSG2Red(nSect : LONGINT; VAR Local : CD_Addr);
  BEGIN
    Local.Time.Frame  := nSect MOD 75;
    nSect             := nSect DIV 75;
    Local.Time.Second := nSect MOD 60;
    Local.Time.Minute := nSect DIV 60;
  END;

  FUNCTION IOctl_In(Drive    : WORD;
                    Unit_1   : BYTE;
                    pRequest : pInteger;
                    rqLen    : WORD) : WORD;
  VAR
    Regs : Registers;
  BEGIN
    rqInp.IOCtl_nBytes      := rqLen;
    rqInp.IOCtl_xFer        := pInteger(pRequest);
    rqInp.IOctl_Rqh.rq_Unit := Unit_1;

    Regs.AX := $1510; { send device request }
    Regs.CX := Drive;
    Regs.BX := Ofs(rqInp);
    Regs.ES := Seg(rqInp);
    Intr($2F, Regs);
    IOctl_In := (rqInp.IOctl_Rqh.rq_Status);
  END;

  FUNCTION Get_Status(Drive : CHAR) : WORD;
  BEGIN
    IF (IOctl_In(INTEGER(Drive), 0, @rq_Status,
                 SizeOf(IO_Inp_Device_Status))
                 AND $8000) <> 0 THEN BEGIN
      Get_Status := ($FFFF);
      Exit;
    END ELSE BEGIN
      Get_Status := (rq_Status.Status);
      Exit;
    END;
  END;

  PROCEDURE Get_UPC(VAR UPC : STRING);
  VAR
    I : INTEGER;
  BEGIN
    IOctl_In(Audio_Drive, 0, @rq_UPC, SizeOf(IO_Inp_UPC));
    FOR I := 0 TO 7 DO
      UPC[I+1] := rq_UPC.Signature[I];
  END;

 FUNCTION Get_Header : pInteger;
  BEGIN
    IOctl_In(Audio_Drive, 0, @rq_Header,
             SizeOf(IO_Inp_Device_Hdr));
    Get_Header := (rq_Header.Device_Hdr);
  END;

  FUNCTION Audio_Busy : WORD;
  BEGIN
    Audio_Busy := (IOctl_In(Audio_Drive, 0, @rq_Busy,
                   SizeOf(IO_Inp_Device_Hdr)) AND $8200);
  END;

  PROCEDURE Read_Audio_Status(VAR Status : Audio_Status);
  BEGIN
    IOctl_In(Audio_Drive, 0, @rq_Audio_Status,
             SizeOf(IO_Inp_Audio_Status));
    Status := (rq_Audio_Status.Report);
  END;

  FUNCTION Get_Media_Changed : BYTE;
  BEGIN
    IOctl_In(Audio_Drive, 0, @rq_Media,
             SizeOf(IO_Inp_Media_Changed));
    Get_Media_Changed := (rq_Media.Media_Byte);
  END;

  FUNCTION Get_TOC : BYTE;
  VAR
    rq_TOC   : IO_Inp_Audio_Info;
    rq_Track : IO_Inp_Track_Info;
    I        : INTEGER;
  BEGIN
    rq_TOC.IOctl_Cmd := IOI_AUDIO_INFO;
    IOctl_In(Audio_Drive, 0, @rq_TOC,
             SizeOf(IO_Inp_Audio_Info));
    rq_Track.IOctl_Cmd := IOI_TRACK_INFO;
    I := INTEGER(rq_TOC.Track_Lo);
    WHILE (I <= INTEGER(rq_TOC.Track_Hi)) DO BEGIN
      rq_Track.Tno := I;
      IOctl_In(Audio_Drive, 0, @rq_Track,
               SizeOf(IO_Inp_Track_Info));
      Index[I].Start    := rq_Track.Start;
      Index[I-1].Frames := Red2HSG(Index[I].Start) -
                           Red2HSG(Index[I-1].Start);
      HSG2Red(Index[I-1].Frames, Index[I-1].Delta);
      I := Succ(I);
    END;
    Index[I-1].Frames := Red2HSG(rq_TOC.Track_Lead_Out) -
                         Red2HSG(Index[I-1].Start);
    HSG2Red(Index[I-1].Frames, Index[I-1].Delta);
    Index[0].Start  := Index[1].Start;
    Index[0].Frames := Red2HSG(rq_TOC.Track_Lead_Out) -
                       Red2HSG(Index[1].Start);
    HSG2Red(Index[0].Frames, Index[0].Delta);
    Get_TOC := (rq_TOC.Track_Hi);
  END;

  FUNCTION Audio_Pause : WORD;
  VAR
    rq_Audio_Status : IO_Inp_Audio_Status;
  BEGIN
    rq_Audio_Status.IOctl_Cmd := IOI_AUDIO_STATUS;
    IOctl_In(Audio_Drive, 0, @rq_Audio_Status,
             SizeOf(IO_Inp_Audio_Status));
    Audio_Pause := (rq_Audio_Status.Report.Status AND $01);
  END;

  FUNCTION Get_Track_Info(Tno : BYTE) : BYTE;
  VAR
    rq_Track : IO_Inp_Track_Info;
  BEGIN
    rq_Track.IOctl_Cmd := IOI_TRACK_INFO;
    rq_Track.Tno       := Tno;
    IOctl_In(Audio_Drive, 0, @rq_Track,
             SizeOf(IO_Inp_Track_Info));
    Get_Track_Info := (rq_Track.Control);
  END;

  PROCEDURE Read_QChannel(VAR QC : QChannel_Info);
  BEGIN
    rq_QChan.IOctl_Cmd := IOI_QCHAN_INFO;
    rq_QChan.Addr_Mode := Red;
    IOctl_In(Audio_Drive, 0, @rq_QChan,
             SizeOf(IO_Inp_QChannel));
    QC := (rq_QChan.qInfo);
  END;

  FUNCTION IOctl_Out(Drive    : WORD;
                     Unit_1   : BYTE;
                     pRequest : pInteger;
                     rqLen    : WORD) : WORD;
  VAR
    Regs : Registers;
  BEGIN
    rqOutp.IOCtl_nBytes      := rqLen;
    rqOutp.IOCtl_xFer        := pInteger(pRequest);
    rqOutp.IOctl_Rqh.rq_Unit := Unit_1;

    Regs.AX := $1510;
    Regs.CX := Drive;
    Regs.BX := Ofs(rqOutp);
    Regs.ES := Seg(rqOutp);
    Intr($2F, Regs);
    IOctl_Out := (rqOutp.IOctl_Rqh.rq_Status);
  END;

  PROCEDURE CD_Reset;
  BEGIN
    rq_Reset.IOctl_Cmd := IOO_RESET;
    IOctl_Out(Audio_Drive, 0, @rq_Reset,
              SizeOf(IO_Outp_Eject));
  END;

  PROCEDURE Eject_CD;
  BEGIN
    rq_Eject.IOctl_Cmd := IOO_EJECT;
    IOctl_Out(Audio_Drive, 0, @rq_Eject,
              SizeOf(IO_Outp_Eject));
  END;

  PROCEDURE Insert_CD;
  BEGIN
    rq_Insert.IOctl_Cmd := IOO_CLOSE_TRAY;
    IOctl_Out(Audio_Drive, 0, @rq_Insert,
              SizeOf(IO_Outp_Eject));
  END;

  PROCEDURE SetVolume(Chan0, Chan1, Chan2, Chan3 : BYTE);
  BEGIN
    rq_Volume.IOctl_Cmd := IOI_AUDIOCHAN_INFO;
    IOctl_In(Audio_Drive, 0, @rq_Volume,
             SizeOf(IO_Inp_Audiochan_Info));

    rq_Volume.IOctl_Cmd := IOO_AUDIOCHAN_CTRL;
    rq_Volume.Vol_Chan0 := Chan0;
    rq_Volume.Vol_Chan1 := Chan1;
    rq_Volume.Vol_Chan2 := Chan2;
    rq_Volume.Vol_Chan3 := Chan3;
    IOctl_Out(Audio_Drive, 0, @rq_Volume,
              SizeOf(IO_Inp_Audiochan_Info));
  END;

  PROCEDURE SetInput(Chan0, Chan1, Chan2, Chan3 : BYTE);
  BEGIN
    rq_Input.IOctl_Cmd := IOI_AUDIOCHAN_INFO;
    IOctl_In(Audio_Drive, 0, @rq_Input,
             SizeOf(IO_Inp_Audiochan_Info));
    rq_Input.IOctl_Cmd := IOO_AUDIOCHAN_CTRL;
    rq_Input.Inp_Chan0 := Chan0;
    rq_Input.Inp_Chan1 := Chan1;
    rq_Input.Inp_Chan2 := Chan2;
    rq_Input.Inp_Chan3 := Chan3;
    IOctl_Out(Audio_Drive, 0, @rq_Input,
              SizeOf(IO_Inp_Audiochan_Info));
  END;

  FUNCTION Play_Audio_1(Start    : CD_Addr;
                        nSectors : LONGINT) : WORD;
  VAR
    Regs : Registers;
  BEGIN
    rq_Play.Start   := Start;
    rq_Play.nFrames := nSectors;

    Regs.AX := $1510;
    Regs.CX := Audio_Drive;
    Regs.BX := Ofs(rq_Play);
    Regs.ES := Seg(rq_Play);
    Intr($2F, Regs);
    Play_Audio_1 := (rq_Play.Play_rqh.rq_Status);
  END;

  FUNCTION Play_Track(Tno : BYTE) : BOOLEAN;
  BEGIN
    IF (Tno <= Titles) THEN BEGIN
      Play_Audio_1(Index[INTEGER(Tno)].Start,
                   Index[INTEGER(Tno)].Frames);
      Start_Play := Red2HSG(Index[INTEGER(Tno)].Start);
      End_Play   := Red2HSG(Index[INTEGER(Tno)].Start) +
                            Index[INTEGER(Tno)].Frames;
      Play_Track := TRUE;
    END ELSE
      Play_Track := FALSE;
  END;

  FUNCTION Play_Tracks(From, To_1 : LONGINT) : BOOLEAN;
  VAR
    Frames : LONGINT;
  BEGIN
    Frames := 0;
    IF (INTEGER(From) > 0) AND (From <= To_1) AND
       (To_1 <= Titles) THEN BEGIN
      Frames := Red2HSG(Index[INTEGER(To_1)].Start) -
                Red2HSG(Index[INTEGER(From)].Start) +
                        Index[INTEGER(To_1)].Frames;
      Play_Audio_1(Index[INTEGER(From)].Start, Frames);
      Start_Play  := Red2HSG(Index[INTEGER(From)].Start);
      End_Play    := Start_Play + Frames;
      Play_Tracks := TRUE;
    END ELSE
      Play_Tracks := FALSE;
  END;

  FUNCTION Play_Track_Intro(Tno : INTEGER) : BOOLEAN;
  BEGIN
    IF (Tno >= 0) AND (Tno <= INTEGER(Titles)) THEN BEGIN
      Play_Audio_1(Index[Tno].Start, 10*75);
      Start_Play:=Red2HSG(Index[Tno].Start);
      End_Play:=Red2HSG(Index[Tno].Start)+(10*75);
      Play_Track_Intro := TRUE;
    END ELSE
      Play_Track_Intro := FALSE;
  END;

  FUNCTION Stop_Audio_1 : WORD;
  VAR
    Regs : Registers;
  BEGIN
    Regs.AX := $1510;
    Regs.CX := Audio_Drive;
    Regs.BX := Ofs(rq_Stop);
    Regs.ES := Seg(rq_Stop);
    Intr($2F, Regs);
    Stop_Audio_1 := (rq_Stop.Play_rqh.rq_Status);
  END;

  FUNCTION Resume_Audio_1 : WORD;
  VAR
    Regs : Registers;
  BEGIN
    Regs.AX := $1510;
    Regs.CX := Audio_Drive;
    Regs.BX := Ofs(rq_Resume);
    Regs.ES := Seg(rq_Resume);
    Intr($2F, Regs);
    Resume_Audio_1 := (rq_Resume.Play_rqh.rq_Status);
  END;

  FUNCTION Skip_Audio(Frames : LONGINT) : WORD;
  VAR
    Skip_Delta : LONGINT;
    Skip_To    : CD_Addr;
    Tmp_Start  : LONGINT;
    Stat_Audio : Audio_Status;
    Dummy      : CD_Addr;
  BEGIN
    Read_QChannel(qInfo);
    Tmp_Start := LONGINT ( LONGINT(qInfo.dMin) * 4500 +
                           LONGINT(qInfo.dSec) *   75 +
                           LONGINT(qInfo.dFrame) + Frames);
    IF (Tmp_Start >= End_Play) THEN BEGIN
      Skip_Audio := 0;
      Exit;
    END;
    IF (Tmp_Start > Start_Play) THEN BEGIN
      HSG2Red(Tmp_Start, Skip_To);
      Skip_Delta := End_Play - Tmp_Start;
      Stop_Audio_1;
      Play_Audio_1(Skip_To, Skip_Delta);
    END ELSE BEGIN
      Stop_Audio_1;
      HSG2Red(Start_Play, Dummy);
      Play_Audio_1(Dummy, End_Play - Start_Play);
    END;
    Skip_Audio := 1;
  END;

  FUNCTION Init_CDAudio : INTEGER;
  VAR
    Regs           : Registers;
    Stat_Audio     : Audio_Status;
    I              : INTEGER;
    nDrives        : INTEGER;
    Logical_Drives : ARRAY [0..25] OF CHAR;
  BEGIN
    Regs.AX := $1500;
    Regs.BX := 0;
    Intr($2F, Regs);
    IF (Regs.BX = 0) THEN BEGIN
      Init_CDAudio := -1;
      Exit;
    END;
    nDrives := Regs.BX;
    Regs.AX := $150D;
    Regs.ES := Seg(Logical_Drives);
    Regs.BX := Ofs(Logical_Drives);
    Intr($2F, Regs);

    I := 0;
    WHILE (I < nDrives) DO BEGIN
      IF ((Get_Status(Logical_Drives[I]) AND
           DATA_AND_AUDIO)) <> 0 THEN BEGIN
        Audio_Drive := INTEGER(Logical_Drives[I]);
        (* goto Break_1; *) Break;
      END;
      I := Succ(I);
    END;
(*  Break_1: *)
    IF (I = nDrives) THEN BEGIN
      Init_CDAudio := (-2);
      Exit;
    END;
    Get_Header;

    I := 1;
    WHILE (I <= 20) DO BEGIN
      IF (INTEGER(Get_Media_Changed) < 128) THEN BEGIN
        (* goto Break_2; *) Break;
      END;
      I := Succ(I);
    END;
(*  Break_2: *)
    IF (INTEGER(Get_Media_Changed) > 128) THEN BEGIN
      Init_CDAudio := (-3);
      Exit;
    END;

    Titles := Get_TOC;

    Read_Audio_Status(Stat_Audio);
    End_Play     := Red2HSG(Stat_Audio.End_1);
    Init_CDAudio := INTEGER(Titles);
  END;

  FUNCTION Get_Titles : BYTE;
  BEGIN
    Get_Titles := Titles;
  END;

  PROCEDURE Get_Len(Tno : CHAR; VAR Len : CD_Addr);
  BEGIN
    Len := Index[INTEGER(Tno)].Delta;
  END;

  FUNCTION Get_Actual_Track : INTEGER;
  BEGIN
    Read_QChannel(qInfo);
    Get_Actual_Track := ((INTEGER(qInfo.Tno) SHR 4)*10) +
                         (INTEGER(qInfo.Tno) AND $0F);
  END;

  PROCEDURE Get_Time_In_Track(T : QChannel_Info);
  BEGIN
    Read_QChannel(qInfo);
    T := qInfo;
  END;

  FUNCTION Get_Audio_Drive : CHAR;
  BEGIN
    Get_Audio_Drive := CHAR(Audio_Drive);
  END;


BEGIN
  maxTitles := Init_CDAudio;
END.

