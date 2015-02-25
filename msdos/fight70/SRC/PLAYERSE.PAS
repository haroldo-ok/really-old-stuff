unit PlayerSelect;
{FightX Game System - Sele‡Æo de personagens}
{programado por Haroldo de Oliveira Pinheiro}
interface
    uses FighterUnit;
    type
        FighterType=(ftPlayer,ftBoss);
        PFighterSel=^FighterSel;
        FighterSel= record
                        Next:PFighterSel;
                        FighterName:string;
                        ScriptName:string;
                        MusicName:string;
                        BigFaceL:FighterSpr;
                        BigFaceR:FighterSpr;
                        SmallFace:FighterSpr;
                        Background:FighterSpr;
                        Kind:FighterType;
                        IsPlayer:boolean;
                        Number:byte;
                    end;
        FighterSelList= record
                            First,Last:PFighterSel;
                            NumFighters:byte;
                            FaceLines,FaceCols:byte;
                            FaceX,FaceY:integer;
                        end;

        PFightOrder=^TFightOrder;
        TFightOrder=record
                        Next:PFightOrder;
                        FSel:PFighterSel;
                    end;
        FightOrderList= record
                            First,Last:PFightOrder;
                        end;

    var FgtSel1,FgtSel2:PFighterSel;
        Fgt1IsPlayer,Fgt2IsPlayer:boolean;

    procedure ReadFighterSel(var List:FighterSelList;FileName:string);
    procedure FighterSelect(var List:FighterSelList);

    procedure BuildFightOrder(var Sel:FighterSelList;var Order:FightOrderList);
    procedure DestroyFightOrder(var Order:FightOrderList);
implementation
    uses Graph13h,PCXUnit,Keybd,Console,Joystick,SndDrv,Utils;

    var Pal:Palette;

    procedure InitFgtSelList(var List:FighterSelList);
        begin
            List.First:=nil;
            List.Last:=nil;
        end;

    function AddFgtToSel(var List:FighterSelList;ScriptName:string):PFighterSel;
        var Fgt:PFighterSel;
        begin
            New(Fgt);
            Fgt^.Next:=nil;
            Fgt^.FighterName:='???';
            Fgt^.ScriptName:=ScriptName;
            Fgt^.MusicName:='';
            Fgt^.BigFaceL.Img:=nil;
            Fgt^.BigFaceR.Img:=nil;
            Fgt^.SmallFace.Img:=nil;
            Fgt^.Background.Img:=nil;
            Fgt^.Kind:=ftPlayer;
            Fgt^.IsPlayer:=false;
            Fgt^.Number:=List.NumFighters;
            //
            if List.First = nil then
                List.First:=Fgt
            else
                List.Last^.Next:=Fgt;
            List.Last:=Fgt;
            AddFgtToSel:=Fgt;
            Inc(List.NumFighters);
        end;

    var BaseDir:string;

    procedure MirrorFighterSpr(var FSpr:FighterSpr);
        var Img:PRawImage;
        begin
            AllocMirrorRawImage(FSpr.Img^,Img);
            FreeRawImage(FSpr.Img);
            FSpr.Img:=Img;
            FSpr.OfsX:=319-FSpr.OfsX-FSpr.Img^.Width;
        end;

    procedure ReadFighterSpr(var FSpr:FighterSpr;Params:string;StartColor:byte;Mirror:boolean);
        var Token:string;
        begin
            Token:=GetToken(Params);
            Token:=BaseDir+RemoveQuotes(Token);
            WritelnCon('Lendo imagem: '+Token); //***DEBUG***
            AllocReadPCX(FSpr.Img,Token);
            GetPCXPalette(FSpr.Pal,Token);
            ReIndexColors(FSpr.Img^,FSpr.Pal,64,StartColor);
            Token:=GetToken(Params);
            FSpr.OfsX:=ReadNumber(Token);
            Token:=GetToken(Params);
            FSpr.OfsY:=ReadNumber(Token);
            if Mirror then
                MirrorFighterSpr(FSpr);
        end;

    procedure DrawFighterSpr(X,Y:longint;StartColor,Colors:byte;var FSpr:FighterSpr);
        begin
            if FSpr.Img <> nil then
                begin
                    DisplayRawImageClip(X+FSpr.OfsX,
                                        Y+FSpr.OfsY,
                                        FSpr.Img^);
                    Move(Fspr.Pal[StartColor],Pal[StartColor],Colors*3);
                end;
        end;

    procedure ReadFgtSel(var Fgt:FighterSel;FileName:string);
        var T:Text;
            S,Token:string;
        begin
            BaseDir:=GetBaseDir(FileName);

            //Inicializa vari veis

            Fgt.Kind:=ftPlayer;
            Fgt.ScriptName:=FileName;

            //Interpreta o arquivo

            WriteLnCon(ANSI_GRAY+'  Lendo '+FileName); //***DEBUG***
            {$I-}
            Assign(T,FileName);
            Reset(T);
            {$I+}
            if IOResult <> 0 then
                begin
                    WriteLnCon(ANSI_LTRED+'  Erro ao ler o arquivo.');
                    Exit;
                end;
            while not Eof(T) do
                begin
                    Readln(T,S);
                    Token:=GetToken(S);
                    if Token='#name' then
                        begin
                            Token:=GetToken(S);
                            Fgt.FighterName:=RemoveQuotes(Token);
                            WriteCon(ANSI_YELLOW+'  ->');
                            WriteLnCon(ANSI_GRAY+'Lutador: '+Fgt.FighterName);
                        end
                    else if Token='#selface' then
                        begin
                            ReadFighterSpr(Fgt.BigFaceL,S,1,False);
                            ReadFighterSpr(Fgt.BigFaceR,S,65,True);
                        end
                    else if Token='#selicon' then
                        begin
                            ReadFighterSpr(Fgt.SmallFace,S,192,False);
                            Fgt.SmallFace.OfsX:=0;
                            Fgt.SmallFace.OfsY:=0;
                        end
                    else if Token='#background' then
                        begin
                            ReadFighterSpr(Fgt.Background,S,130,False);
                            Fgt.Background.OfsX:=0;
                            Fgt.Background.OfsY:=0;
                        end
                    else if Token='#bgmusic' then
                        begin
                            Token:=GetToken(S);
                            Fgt.MusicName:=BaseDir+RemoveQuotes(Token);
                        end;
                end;
            Close(T);
        end;

    procedure ReadFighterSel(var List:FighterSelList;FileName:string);
        var Fgt:PFighterSel;
            T:text;
            S:string;
        begin
            WritelnCon(ANSI_YELLOW+'Lendo lista de lutadores');
            InitFgtSelList(List);
            Assign(T,FileName);
            Reset(T);
            while not Eof(T) do
                begin
                    Readln(T,S);
                    RemoveTab(S,1);
                    RemoveComment(S);
                    if S <> '' then
                        begin
                            Fgt:=AddFgtToSel(List,S);
                            ReadFgtSel(Fgt^,S);
                        end;
                end;
            Close(T);
            //
            List.NumFighters:=0;
            Fgt:=List.First;
            while Fgt <> nil do
                begin
                    Fgt^.Number:=List.NumFighters;
                    Inc(List.NumFighters);
                    Fgt:=Fgt^.Next;
                end;
            case List.NumFighters of
                0..4:List.FaceCols:=List.NumFighters;
                5..6:List.FaceCols:=3;
                7..8:List.FaceCols:=4;
                9..10:List.FaceCols:=5;
                11..12:List.FaceCols:=6;
                13..14:List.FaceCols:=7;
                15..16:List.FaceCols:=8;
                17:List.FaceCols:=5;
                18:List.FaceCols:=6;
                19..21:List.FaceCols:=7;
                22..24:List.FaceCols:=8;
                25..30:List.FaceCols:=10;
                31..36:List.FaceCols:=9;
            else
                List.FaceCols:=10;
            end;
            List.FaceLines:=List.NumFighters div List.FaceCols;
            if List.FaceLines*List.FaceCols < List.NumFighters then
                Inc(List.FaceLines);
            List.FaceX:=(320-(List.FaceCols*21)) div 2;
            List.FaceY:=100;
        end;

    procedure FighterSelect(var List:FighterSelList);
        var Fgt:PFighterSel;
            Sel1,Sel2:PFighterSel;
            BkgdImg:PRawImage;
            BkgdPal:Palette;
            BkgX,BkgY:longint;
            JDly1,JDly2:byte;
            MarkPtr:Pointer;
        //
        procedure DrawSelSquare(X,Y:integer;Color:byte);
            begin
                VLine(X-1,Y,21,Color);
                VLine(X+20,Y,21,Color);
                //
                HLine(X-1,Y-1,22,Color);
                HLine(X-1,Y+20,22,Color);
            end;
        procedure HalfSelSquare(X,Y:integer;Color:byte);
            begin
                VLine(X-1,Y+10,11,Color);
                VLine(X+20,Y+10,11,Color);
                //
                HLine(X-1,Y+20,22,Color);
            end;
        //
        procedure DrawSelectFaces;
            var Fgt:PFighterSel;
                i,j:byte;
                X,Y:integer;
            begin
                Fgt:=List.First;
                for i:=0 to Pred(List.FaceLines) do
                    for j:=0 to Pred(List.FaceCols) do
                        begin
                            X:=List.FaceX+(j*22);
                            Y:=List.FaceY+(i*22);
                            if Fgt <> nil then
                                begin
                                    DrawSelSquare(X,Y,255);
                                    //
                                    DrawFighterSpr(X,Y,192,64,Fgt^.SmallFace);
                                    //
                                    if (Fgt = Sel1) and Fgt1IsPlayer then
                                        begin
                                            DrawSelSquare(X,Y,195);
                                        end;
                                    if (Fgt = Sel2) and Fgt2IsPlayer then
                                        begin
                                            if (Sel1 <> Sel2) or not Fgt1IsPlayer then
                                                DrawSelSquare(X,Y,207)
                                            else
                                                HalfSelSquare(X,Y,207);
                                        end;
                                    //
                                    Fgt:=Fgt^.Next;
                                end;
                        end;
            end;
        //
        procedure HandleSelectFaces(var Fgt,Sel:PFighterSel;Joy:byte;var JoyDly:byte);
            procedure NextRow(var Fgt:PFighterSel;Reverse:boolean);
                var Row,Col,Num:byte;
                begin
                    Row:=Fgt^.Number div List.FaceCols;
                    Col:=Fgt^.Number mod List.FaceCols;
                    if not Reverse then
                        begin
                            Inc(Row);
                            if Row > Pred(List.FaceLines) then
                                Row:=0;
                        end
                    else
                        begin
                            if Row = 0 then
                                Row:=Pred(List.FaceLines)
                            else
                                Dec(Row);
                        end;
                    Num:=(Row*List.FaceCols)+Col;
                    Fgt:=List.First;
                    while (Fgt <> nil) and (Num <> 0) do
                        begin
                            Fgt:=Fgt^.Next;
                            Dec(Num);
                        end;
                    if Fgt = nil then
                        Fgt:=List.Last;
                end;
            procedure NextCol(var Fgt:PFighterSel;Reverse:boolean);
                var Row,Col,Num:byte;
                begin
                    Row:=Fgt^.Number div List.FaceCols;
                    Col:=Fgt^.Number mod List.FaceCols;
                    if not Reverse then
                        begin
                            Inc(Col);
                            if Col > Pred(List.FaceCols) then
                                Col:=0;
                        end
                    else
                        begin
                            if Col = 0 then
                                Col:=Pred(List.FaceCols)
                            else
                                Dec(Col);
                        end;
                    Num:=(Row*List.FaceCols)+Col;
                    Fgt:=List.First;
                    while (Fgt <> nil) and (Num <> 0) do
                        begin
                            Fgt:=Fgt^.Next;
                            Dec(Num);
                        end;
                    if Fgt = nil then
                        Fgt:=List.Last;
                end;
            begin
                if (Joy <> 0) and (JoyDly = 0) then
                    begin
                        if Fgt <> nil then
                            begin
                                if (Joy and _JOY_UP) <> 0 then
                                    NextRow(Fgt,true);
                                if (Joy and _JOY_DOWN) <> 0 then
                                    NextRow(Fgt,false);
                                if (Joy and _JOY_LEFT) <> 0 then
                                    NextCol(Fgt,true);
                                if (Joy and _JOY_RIGHT) <> 0 then
                                    NextCol(Fgt,false);
                                if (Joy and _JOY_BTN1) <> 0 then
                                    Sel:=Fgt;
                                if (Joy and _JOY_BTN2) <> 0 then
                                    Sel:=Fgt;
                            end;
                        JoyDly:=4;
                    end
                else
                    begin
                        Dec(JoyDly);
                        if Joy = 0 then
                            JoyDly:=0;
                    end;
            end;
        //
        begin
            Mark(MarkPtr);
            //
    		MinX:=0;
    		MaxX:=319;
    		MinY:=0;
    		MaxY:=199;
            //
            AllocReadPCX(BkgdImg,'INTERF\SEL_BKGD.PCX');
            GetPCXPalette(BkgdPal,'INTERF\SEL_BKGD.PCX');
            ReIndexColors(BkgdImg^,BkgdPal,63,129);
            ChangeMusic('INTERF\SELECT.GDM');
            //
            InitKeyboard;
            Sel1:=List.First;
            Sel2:=List.First;
            FgtSel1:=nil;
            FgtSel2:=nil;
            BkgX:=0;
            BkgY:=0;
            JDly1:=0;
            JDly2:=0;
            while (Fgt1IsPlayer and (FgtSel1 <> Sel1)) or 
                  (Fgt2IsPlayer and (FgtSel2 <> Sel2)) do
                begin
                    if not Fgt1IsPlayer and 
                       ((ReadLeftJoy and (_JOY_BTN1 or _JOY_BTN2)) <> 0) then
                        begin
                            Fgt1IsPlayer:=true;
                        end;
                    if not Fgt2IsPlayer and 
                       ((ReadRightJoy and (_JOY_BTN1 or _JOY_BTN2)) <> 0) then
                        begin
                            Fgt2IsPlayer:=true;
                        end;
                    HandleSelectFaces(Sel1,FgtSel1,ReadLeftJoy,JDly1);
                    HandleSelectFaces(Sel2,FgtSel2,ReadRightJoy,JDly2);
                    if Keys[scEnter] then // Permite selecionar o jogador 1 com enter
                        FgtSel1:=Sel1;
                    TexturizeBackground(BkgX,BkgY,BkgdImg^);
                    Move(BkgdPal[129],Pal[129],63*3);
                    Dec(BkgX);
                    Dec(BkgY);
                    if Fgt1IsPlayer and (Sel1 <> nil) then
                        begin
                            DrawFighterSpr(0,0,1,64,Sel1^.BigFaceL);
                            OutText((160-(Length(Sel1^.FighterName)*8)) div 2,
                                    4,240,Sel1^.FighterName);
                        end;
                    if Fgt2IsPlayer and (Sel2 <> nil) then
                        begin
                            DrawFighterSpr(0,0,65,64,Sel2^.BigFaceR);
                            OutText(160+(160-(Length(Sel2^.FighterName)*8)) div 2,
                                    4,240,Sel2^.FighterName);
                        end;
                    DrawSelectFaces;
                    WaitVSyncStart;
                    PutPal(Pal);
                    Buffer2Screen(ScrBuf^);
                    ClearBuffer(ScrBuf^);
                end;
            DoneKeyboard;
            //
            Release(MarkPtr);
        end;

    procedure InitFightOrderList(var List:FightOrderList);
        begin
            List.First:=nil;
            List.Last:=nil;
        end;
    function AddFightOrder(var List:FightOrderList;Sel:PFighterSel):PFightOrder;
        var FOrd:PFightOrder;
        begin
            New(FOrd);
            FOrd^.Next:=nil;
            FOrd^.FSel:=Sel;
            //
            if List.First = nil then
                List.First:=FOrd
            else
                List.Last^.Next:=FOrd;
            List.Last:=FOrd;
            //
            AddFightOrder:=FOrd;
        end;
    procedure BuildFightOrder(var Sel:FighterSelList;var Order:FightOrderList);
        var FSel:PFighterSel;
            FOrd1,FOrd2:PFightOrder;
            i:byte;
        procedure WalkOnList(List:FightOrderList;var FOrd:PFightOrder;Count:byte);
            var i:byte;
            begin
                for i:=0 to Count do
                    begin
                        FOrd:=FOrd^.Next;
                        if FOrd = nil then
                            FOrd:=List.First;
                    end;
            end;
        begin
            // Primeiro, Constr¢i a lista
            InitFightOrderList(Order);
            FSel:=Sel.First;
            while FSel <> nil do
                begin
                    AddFightOrder(Order,FSel);
                    FSel:=FSel^.Next;
                end;
            // Depois, randomiza a lista
            FOrd1:=Order.First;
            FOrd2:=Order.First;
            for i:=0 to 100 do
                begin
                    WalkOnList(Order,FOrd1,Random(5));
                    WalkOnList(Order,FOrd2,Random(5));
                    FSel:=FOrd1^.FSel;
                    FOrd1^.FSel:=FOrd2^.FSel;
                    FOrd2^.FSel:=FSel;
                end;
        end;
    procedure DestroyFightOrder(var Order:FightOrderList);
        var FOrd:PFightOrder;
        begin
            while Order.First <> nil do
                begin
                    FOrd:=Order.First;
                    Order.First:=FOrd^.Next;
                    Dispose(FOrd);
                end;
            Order.Last:=nil;
        end;
Begin
    Fgt1IsPlayer:=false;
    Fgt2IsPlayer:=false;
End.