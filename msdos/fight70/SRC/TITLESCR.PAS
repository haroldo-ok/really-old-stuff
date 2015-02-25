unit TitleScreen;
{FightX Game System - Tela t¡tulo}
{programado por Haroldo de Oliveira Pinheiro}
interface
    function ShowTitleScreen(GameVersion:string):byte;
    function AskContinue:boolean;
implementation
    uses Graph13h,PCXUnit,Keybd,TimerUnit,Console,Joystick,SndDrv,Utils;

    var Pal:Palette;

    function ShowTitleScreen(GameVersion:string):byte;
        var MarkPtr:Pointer;
            BkgdImg:PRawImage;
            BkgdPal:Palette;
            TitlImg:PRawImage;
            TitlPal:Palette;
            BkgX,BkgY:longint;
            i,j:longint;
            SList:StrList;
            CurrStr:PStrItem;
            CurrChar:byte;
            CrCtrl:word;
            CrStep:byte;
            CurrCaption:string;
            Done:byte;
        procedure InitCredits;
            var T:text;
                S:string;
            begin
                InitStrList(SList);
                AddToStrList(SList,' '+GameVersion);
                AddToStrList(SList,'programado por Haroldo O. Pinheiro');
                //
                {$I-}
                Assign(T,'CREDITS.LST');
                Reset(T);
                if IOResult = 0 then
                    begin
                        while not Eof(T) do
                            begin
                                Readln(T,S);
                                AddToStrList(SList,S);
                            end;
                        Close(T);
                    end;
                {$I+}
                //
                CurrStr:=SList.First;
                CurrChar:=0;
                CrCtrl:=0;
                CrStep:=0;
                CurrCaption:='';
            end;
        procedure ShowCredits;
            const
                _10_spc='          ';
            var S:string;
                CrStr:string;
                XOfs:word;
                TxY:integer;
            begin
                S:=_10_spc+_10_spc+_10_spc+_10_spc;
                FillChar(CrStr,SizeOf(CrStr),' ');
                CrStr:=CurrStr^.Str;
                if CrStr[1] = ' ' then
                    begin
                        Delete(CrStr,1,1);
                        CurrCaption:='';
                    end;
                TxY:=192;
                //
                case CrStep of
                    0:  begin    // Formando a frase
                            XOfs:=(40-Length(CrStr)) div 2;
                            Insert(Copy(CrStr,1,CurrChar),S,XOfs);
                            if CrCtrl > 2 then
                                begin
                                    CrCtrl:=0;
                                    Inc(CurrChar);
                                end
                            else
                                begin
                                    S[( (XOfs+CurrChar)*CrCtrl+
                                        40*(2-CrCtrl) ) div 2]:=CrStr[CurrChar+1];
                                    Inc(CrCtrl);
                                end;
                            if CurrChar > Length(CrStr) then
                                begin
                                    CrCtrl:=40;
                                    CrStep:=1;
                                end;
                        end;
                    1 : begin    // Aguarda um tempo
                            XOfs:=(40-Length(CrStr)) div 2;
                            Insert(CrStr,S,XOfs);
                            if CrCtrl = 0 then
                                begin
                                    if CurrStr^.Str[1] <> ' ' then
                                        begin
                                            CurrChar:=1;
                                            CrStep:=2;
                                        end
                                    else
                                        begin
                                            CurrCaption:='';
                                            CrCtrl:=0;
                                            CrStep:=3;
                                        end;
                                end
                            else
                                begin
                                    Dec(CrCtrl);
                                end;
                        end;
                    2 : begin    // Sa¡da... Pela esquerda!!
                            XOfs:=(40-Length(CrStr)) div 2;
                            Insert(CrStr,S,XOfs);
                            Delete(S,1,CurrChar);
                            Inc(CurrChar,2);
                            if CurrChar > (XOfs+Length(CrStr)) then
                                begin
                                    CurrStr:=CurrStr^.Next;
                                    if CurrStr = nil then
                                        CurrStr:=SList.First;
                                    CurrChar:=0;
                                    CrCtrl:=0;
                                    CrStep:=0;
                                end;
                        end;
                    3 : begin    // Subindo...
                            XOfs:=(40-Length(CrStr)) div 2;
                            Insert(CrStr,S,XOfs);
                            if CrCtrl > 20 then
                                begin
                                    CurrCaption:=S;
                                    S:='';
                                    CurrStr:=CurrStr^.Next;
                                    if CurrStr = nil then
                                        CurrStr:=SList.First;
                                    CurrChar:=0;
                                    CrCtrl:=0;
                                    CrStep:=0;
                                end
                            else
                                begin
                                    TxY:=192-((CrCtrl*8) div 20);
                                    Inc(CrCtrl);
                                end;
                        end;
                end;
                //
                OutText(0,TxY-8,255,Copy(CurrCaption,1,40));
                OutText(0,TxY,255,Copy(S,1,40));
            end;
        begin
            Mark(MarkPtr);
            //
    		MinX:=0;
    		MaxX:=319;
    		MinY:=0;
    		MaxY:=199;
            //
            AllocReadPCX(TitlImg,'INTERF\TITLBIG.PCX');
            GetPCXPalette(TitlPal,'INTERF\TITLBIG.PCX');
            ReIndexColors(TitlImg^,TitlPal,63,1);
            //
            AllocReadPCX(BkgdImg,'INTERF\TIT_BKGD.PCX');
            GetPCXPalette(BkgdPal,'INTERF\TIT_BKGD.PCX');
            ReIndexColors(BkgdImg^,BkgdPal,63,65);
            //
            InitCredits;
            //
            FillChar(Pal,SizeOf(Pal),0);
            Move(TitlPal[1],Pal[1],63*3);
            BkgX:=0;
            BkgY:=0;
            for i:=0 to 70 do
                begin
                    DisplayRawImageClip((320-TitlImg^.Width) div 2,
                                        (((-TitlImg^.Height)*(70-i))+((200-TitlImg^.Height) div 2)*i) div 70,
                                        TitlImg^);
                    WaitVSyncStart;
                    PutPal(Pal);
                    Buffer2Screen(ScrBuf^);
                    ClearBuffer(ScrBuf^);
                end;
            for i:=0 to 70 do
                begin
                    TexturizeBackground(BkgX,BkgY,BkgdImg^);
                    DisplayRawImageClip((320-TitlImg^.Width) div 2,
                                        (200-TitlImg^.Height) div 2,
                                        TitlImg^);
                    //
                    for j:=0 to 63 do
                        begin
                            Pal[65+j,0]:=(BkgdPal[65+j,0]*i) div 70;
                            Pal[65+j,1]:=(BkgdPal[65+j,1]*i) div 70;
                            Pal[65+j,2]:=(BkgdPal[65+j,2]*i) div 70;
                        end;
                    //
                    Dec(BkgX);
                    Dec(BkgY);
                    //
                    WaitVSyncStart;
                    PutPal(Pal);
                    Buffer2Screen(ScrBuf^);
                    ClearBuffer(ScrBuf^);
                end;
            //
            Move(TitlPal[1],Pal[1],63*3);
            Move(BkgdPal[65],Pal[65],63*3);
            for i:=0 to 63 do
                begin
                    Pal[i+192,0]:=((i shr 0) and $03) shl 4;
                    Pal[i+192,1]:=((i shr 2) and $03) shl 4;
                    Pal[i+192,2]:=((i shr 4) and $03) shl 4;
                end;
            //
            Done:=0;
            InitKeyboard;
            while Done = 0 do
                begin
                    TexturizeBackground(BkgX,BkgY,BkgdImg^);
                    DisplayRawImageClip((320-TitlImg^.Width) div 2,
                                        (200-TitlImg^.Height) div 2,
                                        TitlImg^);
                    ShowCredits;
                    //
                    Dec(BkgX);
                    Dec(BkgY);
                    //
                    WaitVSyncStart;
                    PutPal(Pal);
                    Buffer2Screen(ScrBuf^);
                    ClearBuffer(ScrBuf^);
                    //
                    if Keys[scEnter] then
                        Done:=1;
                    if Keys[scEsc] then
                        Done:=2;
                end;
            while Keys[scEnter] do;
            while Keys[scEsc] do;
            DoneKeyboard;
            //
            Release(MarkPtr);
            //
            ShowTitleScreen:=Done;
        end;

    function AskContinue:boolean;
        var MarkPtr:Pointer;
            BkgdImg:PRawImage;
            BkgdPal:Palette;
            ContImg:PRawImage;
            ContPal:Palette;
            NumbImg:array[0..9] of PRawImage;
            NumbPal:array[0..9] of Palette;
            BkgX,BkgY:longint;
            i,j:longint;
            CountDown:byte;
            Done:byte;
        begin
            Mark(MarkPtr);
            //
    		MinX:=0;
    		MaxX:=319;
    		MinY:=0;
    		MaxY:=199;
            //
            AllocReadPCX(ContImg,'INTERF\CONTIN.PCX');
            GetPCXPalette(ContPal,'INTERF\CONTIN.PCX');
            ReIndexColors(ContImg^,ContPal,63,1);
            //
            AllocReadPCX(BkgdImg,'INTERF\CNT_BKGD.PCX');
            GetPCXPalette(BkgdPal,'INTERF\CNT_BKGD.PCX');
            ReIndexColors(BkgdImg^,BkgdPal,63,65);
            //
            for i:=0 to 9 do
                begin
                    AllocReadPCX(NumbImg[i],'INTERF\CNT'+IntToStr(i)+'.PCX');
                    GetPCXPalette(NumbPal[i],'INTERF\CNT'+IntToStr(i)+'.PCX');
                    ReIndexColors(NumbImg[i]^,NumbPal[i],63,129);
                end;
            //
            FillChar(Pal,SizeOf(Pal),0);
            Move(ContPal[1],Pal[1],63*3);
            Move(BkgdPal[65],Pal[65],63*3);
            Move(NumbPal[9][129],Pal[129],63*3);
            //
            BkgX:=0;
            BkgY:=0;
            Done:=0;
            CountDown:=9;
            InitKeyboard;
            SetTimer(100);
            Timers[1]:=0;
            while Done = 0 do
                begin
                    TexturizeBackground(BkgX,BkgY,BkgdImg^);
                    DisplayRawImageClip((320-ContImg^.Width) div 2,
                                        8,
                                        ContImg^);
                    DisplayRawImageClip((320-NumbImg[CountDown]^.Width) div 2,
                                        ((ContImg^.Height+8)+200-NumbImg[CountDown]^.Height) div 2,
                                        NumbImg[CountDown]^);
                    //
                    Dec(BkgX);
                    Dec(BkgY);
                    //
                    WaitVSyncStart;
                    PutPal(Pal);
                    Buffer2Screen(ScrBuf^);
                    //
                    if Keys[scEnter] then
                        Done:=1;
                    if Keys[scEsc] then
                        Done:=2;
                    //
                    if Timers[1] > 200 then
                        begin
                            Timers[1]:=0;
                            Dec(CountDown);
                            Move(NumbPal[CountDown][129],Pal[129],63*3);
                        end;
                    if CountDown = 0 then
                        Done:=2;
                end;
            //
            if Done = 2 then
                begin
                    Move(Pal,BkgdPal,SizeOf(BkgdPal));
                    for i:= 70 downto 0 do
                        begin
                            TexturizeBackground(BkgX,BkgY,BkgdImg^);
                            DisplayRawImageClip((320-ContImg^.Width) div 2,
                                                8,
                                                ContImg^);
                            DisplayRawImageClip((320-NumbImg[CountDown]^.Width) div 2,
                                                ((ContImg^.Height+8)+200-NumbImg[CountDown]^.Height) div 2,
                                                NumbImg[CountDown]^);
                            //
                            for j:=0 to 255 do
                                begin
                                    Pal[j,0]:=(BkgdPal[j,0]*i) div 70;
                                    Pal[j,1]:=(BkgdPal[j,1]*i) div 70;
                                    Pal[j,2]:=(BkgdPal[j,2]*i) div 70;
                                end;
                            //
                            Dec(BkgX);
                            Dec(BkgY);
                            //
                            WaitVSyncStart;
                            PutPal(Pal);
                            Buffer2Screen(ScrBuf^);
                        end;
                end;
            //
            CleanupTimer;
            DoneKeyboard;
            Release(MarkPtr);
            //
            AskContinue:=(Done = 1);
        end;
End.