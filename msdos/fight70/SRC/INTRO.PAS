unit Intro;
{FightX Game System - Anima‡äes de introdu‡Æo}
{programado por Haroldo de Oliveira Pinheiro}
interface
    procedure ShowGameIntro;
implementation
    uses Graph13h,PCXUnit,TimerUnit,Console,Lists,AnimUnit;

    procedure ShowGameIntro;
        var MarkPtr:Pointer;
            Anim:AnimPack;
            FrameSkip:longint;
            CurrFrame,AnimLen:longint;
            BkGnd:PRawImage;
            Pal,Pal2:Palette;
        begin
            Mark(MarkPtr);

            WriteLnCon(ANSI_YELLOW+'Carregando introdu‡Æo');
            LoadAnim(Anim,'INTRO\INTRO.ANS');

            AnimLen:=GetAnim(Anim.Anims,'Intro')^.Duration;

            WriteLnCon(ANSI_YELLOW+'Lendo ABKGND.PCX');
            AllocReadPCX(BkGnd,'INTERF\ABKGND.PCX');
            GetPCXPalette(Pal2,'INTERF\ABKGND.PCX');
            ReIndexColors(BkGnd^,Pal2,64,192);
            Move(Pal2[192],Pal[192],64*3);

            WritelnCon(ANSI_YELLOW+'Capturando timer');
            SetTimer(100);

            WriteLnCon(ANSI_YELLOW+'Iniciando introdu‡Æo...');
            MinY:=0;
            MaxY:=319;
            ClearBuffer(ScrBuf^);
            DisplayRawImageClip(0,0,BkGnd^);
		    TextX:=10;
    		TextY:=165;

            Timers[1]:=0;
            CurrFrame:=0;
            while CurrFrame <= AnimLen do
                begin
                    FrameSkip:=Timers[1];
                    Timers[1]:=0;
                    if (CurrFrame = 0) and (FrameSkip = 0) then
                        FrameSkip:=1;

                    while FrameSkip <> 0 do
                        begin
                            PlayAnimFrame(Anim,CurrFrame,'Intro');
                            if CurrFrame <= AnimLen then
                                Inc(CurrFrame);
                            Dec(FrameSkip);
                        end;


                    MinY:=0;
                    MaxY:=319;
                    DisplayRawImageClip(0,0,BkGnd^);

                    MinY:=4;
                    MaxY:=156;
                    DrawAnimFrame(Anim,Pal,CurrFrame,'Intro');

                    WaitVSyncStart;
                    PutPal(Pal);
                    Buffer2Screen(ScrBuf^);
                end;

            CleanUpTimer;

            MinY:=0;
            MaxY:=319;

            Release(MarkPtr);
        end;
End.