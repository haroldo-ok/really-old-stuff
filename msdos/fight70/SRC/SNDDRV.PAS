unit SndDrv;
{Rotinas de som para modo protegido}
{programado por Haroldo de Oliveira Pinheiro}
{2001-10-04: Modificado para usar a unit SBPlay}
interface
    uses sbPlay;
	const
		_DRIVER_INSTALLED   = $01;
		_DRIVER_TEMP_ADDR   = $02;
		_DRIVER_PLAY_MODULE = $03;
		_DRIVER_PLAY_EFFECT = $04;
		_DRIVER_EFFECT_SEG  = $05;

	type
		SoundEffect=pSound;
    procedure InitSound;
    procedure DoneSound;
    function  SoundDriverInstalled:boolean;
	procedure LoadSoundEffect(var SFX:SoundEffect;FileName:string);
	procedure PlaySoundEffect(SFX:SoundEffect);
    procedure ChangeMusic(FileName:string);
implementation
    uses Go32, sbDetect, sbMOD, Timer, Dos, Crt, Utils;

    var DriverInstalled:boolean;
	    RRegs:TRealRegs;
		i:word;
		S:string;
		DRV_DS:word;
		Junk:integer;
		TmpBufSeg,TmpBufOfs:word;
		DriverTemp: packed record
						TempStr:string;
					end;

        BaseIO  :Word;
        IRQ, DMA:Byte;
        ModLoaded:boolean;
        
    function SoundDriverInstalled:boolean;
        begin
            SoundDriverInstalled:=DriverInstalled;
        end;

	procedure LoadSoundEffect(var SFX:SoundEffect;FileName:string);
		begin
            SFX:=LoadRAW(FileName);
		end;

	procedure PlaySoundEffect(SFX:SoundEffect);
		begin
            if not DriverInstalled then
                Exit;
            PlaySound(8,SFX,11000,8,stOnce);
		end;

    procedure ChangeMusic(FileName:string);
        var i:byte;
        begin
            if not DriverInstalled then
                Exit;
            if Pos('.GDM',FileName) <> 0 then
                FileName:=ChangeExt(FileName,'MOD');
            if ModLoaded then
                begin
                    DoneTimer;
                    StopMOD;
                    FreeMOD;
                    for i:=1 to MaxChannel do
                        PlaySound(i,nil,11000,0,stStop);
                end;
            MOD2mem(FileName);
            PlayMOD;
            InitTimer(100);
            ModLoaded:=true;
        end;

    procedure InitSound;
        begin
            DriverInstalled:=true;
            if not(DetectSB(BaseIO, IRQ, DMA)) then
                begin 
                    Writeln('- NO SET BLASTER=Axxx Ix Dx ENVIRONMENT');
                    DriverInstalled:=false;
                end;
            if DriverInstalled then
                begin
                    if not(InitSB(BaseIO, IRQ, DMA)) then 
                        begin 
                            Writeln('- INIT OF SOUNDBLASTER FAILED');
                            DriverInstalled:=false;
                        end
                    else
                        begin
                            WriteLn('- Detected SB v', Hi(dspVersion),'.', Lo(dspVersion),' - ',SampleRate,' Hz',' - ',UpdateRate, ' ints/sec');
                            WriteLn('  BaseIO: $', HexStr(BaseIO,3),'   IRQ: ', IRQ, '   DMA: ', DMA);
                            WriteLn;
                            StartPlayer;
                        end;
                end;
            ModLoaded:=false;
            ChangeMusic('INTERF\DEFAULT.MOD');
        end;
    procedure DoneSound;
        begin
            DoneTimer;
            StopPlayer;
            ShutdownSB;
            FreeMOD;
        end;
End.