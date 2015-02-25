unit Console;
{FightX Game System - Console}
{programado por Haroldo de Oliveira Pinheiro}
interface
    const
        ANSI_BLACK   = #27+'[30m';
        ANSI_BLUE    = #27+'[34m';
        ANSI_GREEN   = #27+'[32m';
        ANSI_CYAN    = #27+'[36m';
        ANSI_RED     = #27+'[31m';
        ANSI_PURPLE  = #27+'[35m';
        ANSI_BROWN   = #27+'[33m';
        ANSI_GRAY    = #27+'[37m';
        ANSI_DKGRAY  = #27+'[30m';
        ANSI_LTBLUE  = #27+'[34m';
        ANSI_LTGREEN = #27+'[32m';
        ANSI_LTCYAN  = #27+'[36m';
        ANSI_LTRED   = #27+'[31m';
        ANSI_PINK    = #27+'[35m';
        ANSI_YELLOW  = #27+'[33m';
        ANSI_WHITE   = #27+'[37m';
    procedure OpenConsole;
    procedure CloseConsole;
    procedure WriteCon(Msg:string);
    procedure WriteLnCon(Msg:string);
    procedure ReadCon(var Msg:string);
implementation
    uses Graph13h,PCXUnit;
    const
        LineCount=20;
        ColumnCount=38;
        TabSize=4;
        TabMask=$03;
        WindowX=8;
        WindowY=48;
    type
        ColorChar=record
                    Ch:char;
                    Color:byte;
                  end;
        ConsoleScreen=array[0..Pred(LineCount),0..Pred(ColumnCount)] of ColorChar;
    var
        CursorX,CursorY:byte;
        ScrCons:ConsoleScreen;
        ConsoleBkg:PRawImage;
        ConsoleTitl:PRawImage;
        ConsolePal:Palette;
        CharColor:byte;
        OldCurX,OldCurY:byte;
    procedure DrawConsole;
        var OldMinX,OldMaxX,OldMinY,OldMaxY:word;
            i,j:byte;
        begin
            OldMinX:=MinX;
            OldMaxX:=MaxX;
            OldMinY:=MinY;
            OldMaxY:=MaxY;

            MinX:=0;
            MaxX:=319;
            MinY:=0;
            MaxY:=199;

            DisplayRawImageClip(0,0,ConsoleBkg^);
            DisplayRawImageClip((320-ConsoleTitl^.Width) div 2,(48-ConsoleTitl^.Height) div 2,ConsoleTitl^);
            for i:=0 to Pred(ColumnCount) do
                for j:=0 to Pred(LineCount) do
                    with ScrCons[j,i] do
                        if Ch <> #0 then
                            PutChar(WindowX+(i*8),WindowY+(j*8),65+Color,Ch);
            WaitVSyncStart;
            PutPal(ConsolePal);
            Buffer2Screen(ScrBuf^);

            MinX:=OldMinX;
            MaxX:=OldMaxX;
            MinY:=OldMinY;
            MaxY:=OldMaxY;
        end;
    procedure ScrollUp;
        var i,j:byte;
        begin
            for i:=0 to Pred(ColumnCount) do
                for j:=1 to Pred(LineCount) do
                    ScrCons[(j-1),i]:=ScrCons[j,i];
        end;
    procedure OpenConsole;
        var i:byte;
            TempPal:Palette;
        begin
            CursorX:=1;
            CursorY:=1;
            CharColor:=15;
            FillChar(ScrCons,SizeOf(ScrCons),0);
            //
            AllocReadPCX(ConsoleBkg,'INTERF\CONSOLE.PCX');
            GetPCXPalette(ConsolePal,'INTERF\CONSOLE.PCX');
            ReIndexColors(ConsoleBkg^,ConsolePal,254,1);
            //
            AllocReadPCX(ConsoleTitl,'INTERF\TITLSMAL.PCX');
            GetPCXPalette(TempPal,'INTERF\TITLSMAL.PCX');
            ReIndexColors(ConsoleTitl^,TempPal,64,192);
            Move(TempPal[192],ConsolePal[192],64*3);
        end;
    procedure CloseConsole;
        begin
            FreeRawImage(ConsoleBkg);
        end;
    procedure WriteCon(Msg:string);
        const 
            ColorMap:array[0..7] of byte=(0,4,2,6,1,5,3,7);
        var i:byte;
            Parms:array[0..7] of byte;
            ParmCount:byte;
        procedure DoANSI;
            var j:byte;
            begin
                case Msg[i] of
                    'H','f': //Posiciona cursor
                        begin
                            CursorX:=Parms[0]+1;
                            CursorY:=Parms[1]+1;
                            if CursorX > ColumnCount then
                                CursorX:=ColumnCount;
                            if CursorY > LineCount then
                            CursorY:=LineCount;
                        end;
                    'A':begin //Cursor p/cima
                            if CursorY - Parms[0] > 1 then
                                begin
                                    Dec(CursorY,Parms[0]);
                                end
                            else
                                begin
                                    CursorY:=1;
                                end;
                        end;
                    'B':begin //Cursor p/baixo
                            if CursorY + Parms[0] < LineCount then
                                begin
                                    Inc(CursorY,Parms[0]);
                                end
                            else
                                begin
                                    CursorY:=LineCount;
                                end;
                        end;
                    'C':begin //Cursor p/direita
                            if CursorX - Parms[0] > 1 then
                                begin
                                    Dec(CursorX,Parms[0]);
                                end
                            else
                                begin
                                    CursorX:=1;
                                end;
                        end;
                    'D':begin //Cursor p/esquerda
                            if CursorX + Parms[0] < ColumnCount then
                                begin
                                    Inc(CursorX,Parms[0]);
                                end
                            else
                                begin
                                    CursorX:=ColumnCount;
                                end;
                        end;
                    's':begin //Salva posi‡Æo do cursor
                            OldCurX:=CursorX;
                            OldCurY:=CursorY;
                        end;
                    'u':begin //Restaura posi‡Æo do cursor
                            CursorX:=OldCurX;
                            CursorY:=OldCurY;
                        end;
                    'J':begin //Limpa tela
                            FillChar(ScrCons,SizeOf(ScrCons),0);
                            CursorX:=1;
                            CursorY:=1;
                        end;
                    'K':begin //Limpa linha
                            for j:=CursorX to ColumnCount do
                                ScrCons[CursorY,j].Ch:=#0;
                        end;
                    'm':begin //Atributos de texto
                            //Obs: apenas os atributos "negrito" e as cores de primeiro plano foram implementadas
                            for j:=0 to Pred(ParmCount) do
                                case Parms[j] of
                                      0:begin //Desativar Atributos de texto
                                            CharColor:=CharColor and $07;
                                        end;
                                      1:begin //Negrito;
                                            CharColor:=CharColor or $08;
                                        end;
                                      4:begin //Sublinhado
                                        end;
                                      5:begin //Intermitente
                                        end;
                                      7:begin //Reverso
                                        end;
                                      8:begin //Oculto
                                        end;
                                      30..37: //Cor de primeiro plano
                                        begin
                                            CharColor:=(CharColor and $80) or ColorMap[Parms[j]-30];
                                        end;
                                      40..47: //Cor de segundo plano
                                        begin
                                        end;
                                end;
                        end;
                end;
            end;
        begin
            i:=1;
            while i <= Length(Msg) do
                begin
                    case Msg[i] of
                        #07:begin // Bell
                            end;
                        #08:begin // BackSpace
                                if CursorX > 0 then
                                    Dec(CursorX);
                            end;
                        #09:begin // Tab
                                CursorX:=(CursorX+TabSize) and TabMask;
                            end;
                        #10:begin // Line Feed
                                Inc(CursorY);
                            end;
                        #13:begin // Carriage Return
                                CursorX:=1;
                            end;
                        #27:begin // Sequˆncia de escape (ANSI)
                                Inc(i);
                                FillChar(Parms,SizeOf(Parms),0);
                                ParmCount:=0;
                                Parms[ParmCount]:=0;
                                if Msg[i] = '[' then
                                    begin
                                        Inc(i);
                                        while Msg[i] in ['0'..'9',';'] do
                                            case Msg[i] of
                                                '0'..'9':
                                                    begin
                                                        Parms[ParmCount]:=Parms[ParmCount]*10;
                                                        Inc(Parms[ParmCount],Ord(Msg[i])-Ord('0'));
                                                        Inc(i);
                                                    end;
                                                ';':begin
                                                        Inc(ParmCount);
                                                        Parms[ParmCount]:=0;
                                                        Inc(i);
                                                    end;
                                            end;
                                        Inc(ParmCount);
                                        DoANSI;
                                    end
                                else
                                    begin
                                        Dec(i);
                                    end;
                            end;
                    else
                        ScrCons[Pred(CursorY),Pred(CursorX)].Ch:=Msg[i];
                        ScrCons[Pred(CursorY),Pred(CursorX)].Color:=CharColor;
                        Inc(CursorX);
                    end;
                    while CursorX >= ColumnCount do
                       begin
                          CursorX:=CursorX - ColumnCount + 1;
                          Inc(CursorY);
                       end;
                    while CursorY >= LineCount do
                        begin
                            ScrollUp;
                            Dec(CursorY);
                        end;
                    Inc(i);
                end;
            DrawConsole;
        end;
    procedure WriteLnCon(Msg:string);
        begin
            WriteCon(Msg+#10+#13);
        end;
    procedure ReadCon(var Msg:string);
        begin
        end;
End.