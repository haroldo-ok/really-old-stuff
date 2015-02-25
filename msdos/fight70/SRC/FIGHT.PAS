program Fight;
{FightX Game System - Programa principal}
{programado por Haroldo de Oliveira Pinheiro}
	uses Graph13h,Console,TitleScreen,Intro,PlayerSelect,BattleUnit,SndDrv;
    const
        FGX_VERSION = 'FIGHTX GAME SYSTEM v0.70';
    var FgtList:FighterSelList;
    procedure GameLoop;
        var FgtOrder:FightOrderList;
            CurrFgt:PFightOrder;
            GameOver:boolean;
        begin
            BuildFightOrder(FgtList,FgtOrder);
            CurrFgt:=FgtOrder.First;

            GameOver:=false;
            while not GameOver do
                begin
                    if not Fgt1IsPlayer then
                        FgtSel1:=CurrFgt^.FSel;
                    if not Fgt2IsPlayer then
                        FgtSel2:=CurrFgt^.FSel;
                    //
                    case StartBattle(FgtSel1,FgtSel2) of
                        _BATTLE_QUIT:
                            begin
                                GameOver:=true;
                            end;
                        _BATTLE_1P_WON:
                            begin
                                if Fgt1IsPlayer then
                                    begin
                                        if Fgt2IsPlayer then
                                            Fgt2IsPlayer:=false
                                        else
                                            CurrFgt:=CurrFgt^.Next;
                                    end
                                else
                                    begin
                                        if Fgt2IsPlayer then
                                            begin
                                                ChangeMusic('INTERF\CONTINUE.MOD');
                                                GameOver:=not AskContinue;
                                            end;
                                    end;
                                ChangeMusic('INTERF\DEFAULT.MOD');
                            end;
                        _BATTLE_2P_WON:
                            begin
                                if Fgt2IsPlayer then
                                    begin
                                        if Fgt1IsPlayer then
                                            Fgt1IsPlayer:=false
                                        else
                                            CurrFgt:=CurrFgt^.Next;
                                    end
                                else
                                    begin
                                        if Fgt1IsPlayer then
                                            begin
                                                ChangeMusic('INTERF\CONTINUE.MOD');
                                                GameOver:=not AskContinue;
                                            end;
                                    end;
                                ChangeMusic('INTERF\DEFAULT.MOD');
                            end;
                        _BATTLE_1P_JOIN:
                            begin
                                Fgt1IsPlayer:=true;
                                FighterSelect(FgtList);
                            end;
                        _BATTLE_2P_JOIN:
                            begin
                                Fgt2IsPlayer:=true;
                                FighterSelect(FgtList);
                            end;
                    end;
                    if CurrFgt = nil then
                        GameOver:=true;
                end;
//          StartBattle('FIGHTERS\HIEI.FGT','FIGHTERS\PIKACHU.FGT');
//          StartBattle('FIGHTERS\BDROID.FGT','FIGHTERS\BDROID.FGT');

            DestroyFightOrder(FgtOrder);
        end;
Begin
    InitSound;
    InitGraph13h;
    LoadFont('FONT.BIN');

    ClearBuffer(ScrBuf^);
    OutText(160-Length(FGX_VERSION)*4,88,12,FGX_VERSION);
    OutText(160-Length('Aguarde,')*4,96,7,'Aguarde,');
    OutText(160-Length('Carregando...')*4,104,7,'Carregando...');
    Buffer2Screen(ScrBuf^);

    OpenConsole;

    WriteLnCon(ANSI_BLUE+'------------------------------');
    WriteLnCon(ANSI_BLUE+FGX_VERSION);
    WriteLnCon(ANSI_BLUE+'------------------------------');

    ReadFighterSel(FgtList,'FIGHTERS.LST');

    Randomize;
    while ShowTitleScreen(FGX_VERSION) <> 2 do
        begin
            ShowGameIntro;

            Fgt1IsPlayer:=true;
            Fgt2IsPlayer:=false;

            FighterSelect(FgtList);

            GameLoop;

            ChangeMusic('INTERF\DEFAULT.MOD');
        end;

    CloseConsole;
    CloseGraph13h;
    DoneSound;

    Writeln('-------------------------------------------');
    Writeln(FGX_VERSION);
    Writeln('Programado por Haroldo de Oliveira Pinheiro');
    Writeln('-------------------------------------------');
    Writeln('HomePage: www.haroldoop.hpg.com.br');
    Writeln('E-Mail:   haroldoop@ieg.com.br');
    Writeln('-------------------------------------------');
End.