unit BattleUnit;
{FightX Game System - Combate}
{programado por Haroldo de Oliveira Pinheiro}
interface
    uses PlayerSelect;
    const
        _BATTLE_QUIT = 1;
        _BATTLE_1P_WON = 2;
        _BATTLE_2P_WON = 3;
        _BATTLE_1P_JOIN = 4;
        _BATTLE_2P_JOIN = 5;
    function StartBattle(Figh1,Figh2:PFighterSel):byte;
implementation
	uses TimerUnit,Graph13h,PCXUnit,Keybd,Console,Lists,AnimUnit,
         FighterUnit,SndDrv,Joystick,Fgt_AI;
    const
        JoyStrings:Array [0..15] of Char=(' ','8','2',' ',  // N  U   D   UD
                                          '4','7','1',' ',  // L  UL  DL  UDL
                                          '6','9','3',' ',  // R  UR  DR  UDR
                                          ' ',' ',' ',' '); // LR ULR DLR UDLR
    var BkGnd:PRawImage;
        Button:PRawImage;
        Scenario:PRawImage;
        JoyL,JoyR,JoyU,JoyD:PRawImage;
        Bar1L,Bar2L,Bar1R,Bar2R:PRawImage;
        Life1,Life2:word;
        Power1,Power2:word;
        RechargeCtrl:longint;
        Panel:PRawImage;
        Pal,Pal2,Pal3:Palette;
        Fgtr,Fgtr2:Fighter;
        Fgt1AI,Fgt2AI:Fighter_AI;
        Stars:VectorArray;
        JumpCount:word;
//        TestAnim:AnimPack;
        AnimCtrl:longint;
        FrameSkip:longint;
        PlayingAnim:boolean;
        CheckVictory:boolean;
    procedure DrawJoystick(X:integer;State:byte);
        begin
            if (State and _JOY_BTN1) <> 0 then
                DisplayRawImageClip(X,177,Button^);
            if (State and _JOY_BTN2) <> 0 then
                DisplayRawImageClip(X+16,177,Button^);
            if (State and _JOY_LEFT) <> 0 then
                DisplayRawImageClip(X+36,185,JoyL^);
            if (State and _JOY_RIGHT) <> 0 then
                DisplayRawImageClip(X+51,185,JoyR^);
            if (State and _JOY_UP) <> 0 then
                DisplayRawImageClip(X+44,177,JoyU^);
            if (State and _JOY_DOWN) <> 0 then
                DisplayRawImageClip(X+44,192,JoyD^);
        end;
    procedure DrawBars;
        begin
            MinX:=(255-Life1)*Bar1L^.Width div 255 + 10;
            DisplayRawImageClip(10,148,Bar1L^);
            MinX:=(255-Power1)*Bar2L^.Width div 255 + 10;
            DisplayRawImageClip(10,166,Bar2L^);
            MaxX:=Life2*Bar1R^.Width div 255 + 168;
            DisplayRawImageClip(168,148,Bar1R^);
            MaxX:=Power2*Bar2R^.Width div 255 + 168;
            DisplayRawImageClip(168,166,Bar2R^);
            MinX:=0;
            MaxX:=319;
        end;
{    procedure PlayAnim;
        var i,FrameSkip:longint;
        begin
            AnimCtrl:=0;
            Timers[1]:=0;
            while AnimCtrl < GetAnim(TestAnim.Anims,'Main')^.Duration do
                begin
                    FrameSkip:=Timers[1];
                    Timers[1]:=0;
                    for i:=0 to Pred(FrameSkip) do
                        begin
                            PlayAnimFrame(TestAnim,AnimCtrl,'Main');
                            Inc(AnimCtrl);
                        end;
                    ClearBufferLines(ScrBuf^,4,96);
                    DisplayRawImageClip(0,100,Panel^);
                    DrawAnimFrame(TestAnim,Pal,AnimCtrl,'Main');
                    WaitVSyncStart;
                    Buffer2Screen(ScrBuf^);
                    PutPal(Pal);
                end;
        end;}
    procedure DrawFgtStdStance(X,Y:longint;Stance:StandardStances;Fgtr:Fighter);
        begin
            if Fgtr.StdStances[Stance].Img <> nil then
                begin
                    DisplayRawImageClip(X+Fgtr.StdStances[Stance].OfsX,
                                        Y+Fgtr.StdStances[Stance].OfsY,
                                        Fgtr.StdStances[Stance].Img^);
                    Move(Fgtr.StdStances[Stance].Pal[Fgtr.StartColor],Pal[Fgtr.StartColor],64*3);
                end;
        end;
    procedure SwapJoyLR(var Joy:byte);
        var JoyL,JoyR:boolean;
        begin
            JoyL:=((Joy and _JOY_LEFT) <> 0);
            JoyR:=((Joy and _JOY_RIGHT) <> 0);
            Joy:=Joy and not(_JOY_LEFT or _JOY_RIGHT);
            if JoyL then
                Joy:=Joy or _JOY_RIGHT;
            if JoyR then
                Joy:=Joy or _JOY_LEFT;
        end;
    procedure CorrectAttackDamage(var Fgt:Fighter);
        begin
            // Corrige o dano do ataque de acordo com o estado do inimigo
            if Fgt.CurrAttack^.Aerial then
                begin
                    // Ataques a‚reos tˆm 75% de chance de errar um inimigo agachado
                    if (Fgt.Enemy^.DefStance = ssDuck) and (Random(100) < 75) then
                        Fgt.Damage:=0;
                    // Ataques a‚reos tˆm 25% de chance de errar um inimigo em p‚
                    if (Fgt.Enemy^.DefStance = ssStand) and (Random(100) < 25) then
                        Fgt.Damage:=0;
                end
            else
                begin
                    // Ataques de terra tˆm 75% de chance de errar o inimigo na subida
                    if (Fgt.Enemy^.DefStance = ssJumpUp) and (Random(100) < 75) then
                        Fgt.Damage:=0;
                    // Ataques de terra tˆm 50% de chance de errar o inimigo na descida
                    if (Fgt.Enemy^.DefStance = ssJumpFall) and (Random(100) < 50) then
                        Fgt.Damage:=0;
                end;
            // A defesa reduz o dano pela metade
            if Fgt.Enemy^.DefStance = ssDefend then
                Fgt.Damage:=Fgt.Damage div 2;
            // Ser atingido no ar confere 60% a mais de dano
            if Fgt.Enemy^.DefStance in [ssJumpUp,ssJumpFall] then
                Fgt.Damage:=(Fgt.Damage * 160) div 100;
        end;
    procedure HandleFgtrAnim(var Fgt:Fighter);
        begin
            if Fgt.AnimStatus.State = asPlaying then
                begin
                    if GetAnim(Fgt.Anims.Anims,Fgt.AnimStatus.Anim) = nil then
                        begin
                            exit;
                        end;
                    if Fgt.AnimStatus.CurrFrame < GetAnim(Fgt.Anims.Anims,Fgt.AnimStatus.Anim)^.Duration then
                        begin
                            PlayAnimFrame(Fgt.Anims,Fgt.AnimStatus.CurrFrame,Fgt.AnimStatus.Anim);
                        end
                    else
                        begin
                            if Fgt.AnimStatus.CurrFrame = GetAnim(Fgt.Anims.Anims,Fgt.AnimStatus.Anim)^.Duration then
                                begin
                                    if Fgt.Enemy^.AnimStatus.State = asNone then
                                        Fgt.Enemy^.DefStance:=Fgt.Enemy^.CurrStance
                                    else if Fgt.Enemy^.CurrStance in [ssJumpUp,ssJumpFall] then
                                        Fgt.Enemy^.DefStance:=Fgt.Enemy^.CurrStance
                                    else
                                        Fgt.Enemy^.DefStance:=ssStand;
                                    CorrectAttackDamage(Fgt);
                                end;
                
                            if Fgt.Enemy^.DefStance = ssJumpUp then
                                begin
                                    MoveStars('yv',255,3,Stars);
                                end
                            else if Fgt.Enemy^.DefStance = ssJumpFall then
                                begin
                                    MoveStars('yv',255,-3,Stars);
                                end
                            else
                                begin
                                    if Fgt.Enemy^.RightPlayer then
                                        MoveStars('xh',255,-3,Stars)
                                    else
                                        MoveStars('xh',255,3,Stars);
                                end;
                        end;
                    Inc(Fgt.AnimStatus.CurrFrame);
                end;
        end;
    procedure CheckFgtrAnim(var Fgt:Fighter);
        begin
            if (not PlayingAnim) and (Fgt.AnimStatus.State = asWaiting) and
               (Fgt.Life <> 0) then
                begin
                    PlayingAnim:=true;
                    Fgt.AnimStatus.State:=asPlaying;
                end;
        end;
    procedure DrawFgtrAnim(var Fgt:Fighter);
        var FrameCnt:longint;
            XOfs:longint;
        begin
            if Fgt.AnimStatus.State = asPlaying then
                begin
                    if GetAnim(Fgt.Anims.Anims,Fgt.AnimStatus.Anim) = nil then
                        begin
                            Fgt.AnimStatus.State:=asNone;
                            PlayingAnim:=false;
                            CheckVictory:=(Fgt.Enemy^.Life = 0);
                            exit;
                        end;
                    FrameCnt:=GetAnim(Fgt.Anims.Anims,Fgt.AnimStatus.Anim)^.Duration;
                    if Fgt.AnimStatus.CurrFrame < FrameCnt then
                        begin
                            DrawAnimFrame(Fgt.Anims,Pal,Fgt.AnimStatus.CurrFrame,Fgt.AnimStatus.Anim);
                        end
                    else if (Fgt.AnimStatus.CurrFrame < FrameCnt+200) and 
                            (Fgt.Enemy^.Life <> 0) then
                        begin
                            if (Fgt.Enemy^.DefStance in [ssJumpUp,ssJumpFall]) and
                               (Fgt.AnimStatus.CurrFrame < FrameCnt+150) then
                                XOfs:=75
                            else
                                XOfs:=((FrameCnt+200)-Fgt.AnimStatus.CurrFrame) div 2;
                            if Fgt.Enemy^.RightPlayer then
                                XOfs:=-XOfs;

                            if Fgt.Enemy^.DefStance in [ssJumpUp,ssJumpFall] then
                                DrawStars('yv',255,208,223,Stars)
                            else
                                DrawStars('xh',255,208,223,Stars);
                            FillChar(Pal[0],3,0);

                            if Fgt.Enemy^.DefStance = ssDefend then
                                begin
                                    if Fgt.AnimStatus.CurrFrame > FrameCnt+150 then
                                        begin
                                            if Fgt.AnimStatus.CurrFrame mod 8 < 4 then
                                                FillChar(Pal[0],3,32);
                                        end;
                                    DrawFgtStdStance(XOfs,0,ssDefend,Fgt.Enemy^);
                                end
                            else
                                begin
                                    if (Fgt.AnimStatus.CurrFrame < FrameCnt+150) or
                                       (Fgt.Damage = 0) then
                                        begin
                                            case Fgt.Enemy^.DefStance of
                                                ssJumpUp,ssJumpFall,ssDuck:
                                                    DrawFgtStdStance(XOfs,0,Fgt.Enemy^.DefStance,Fgt.Enemy^);
                                            else
                                                DrawFgtStdStance(XOfs,0,ssStand,Fgt.Enemy^);
                                            end;
                                        end
                                    else
                                        begin
                                            if Fgt.AnimStatus.CurrFrame mod 8 < 4 then
                                                Pal[0,0]:=63;
                                            DrawFgtStdStance(XOfs,0,ssHit,Fgt.Enemy^);
                                        end;
                                end;
                        end
                    else
                        begin
                            Fgt.AnimStatus.State:=asNone;
                            PlayingAnim:=false;
                            Fgt.JumpCtrl:=0;
                            CheckVictory:=(Fgt.Enemy^.Life = 0);
                        end;
                end;
        end;
    procedure HandleFighter(var Fgt:Fighter;Joy:byte);
        begin
            if Fgt.RightPlayer then
                SwapJoyLR(Joy);
            Fgt.CurrStance:=ssStand;
            if (Joy and _JOY_LEFT) <> 0 then
                Fgt.CurrStance:=ssDefend;
            if (Joy and _JOY_RIGHT) <> 0 then
                Fgt.CurrStance:=ssDodge;
            if (Joy and _JOY_UP) <> 0 then
                begin
                    if Fgt.JumpCtrl=0 then
                        Fgt.JumpCtrl:=512;
                end;
            if (Joy and _JOY_DOWN) <> 0 then
                Fgt.CurrStance:=ssDuck;
            if Fgt.JumpCtrl <> 0 then
                begin
                    if Fgt.JumpCtrl > 256 then
                        begin
                            Fgt.CurrStance:=ssJumpUp;
                            MoveStars('yv',255,3,Fgt.BkGndStars);
                        end
                    else
                        begin
                            Fgt.CurrStance:=ssJumpFall;
                            MoveStars('yv',255,-3,Fgt.BkGndStars);
                        end;
                    Dec(Fgt.JumpCtrl);
                end;
            if (Joy and $0F <> 0) and 
               (Fgt.JoySequence[Length(Fgt.JoySequence)] <> JoyStrings[Joy and $0F]) then
                begin
                    Fgt.JoySequence:=Fgt.JoySequence+JoyStrings[Joy and $0F];
                end;
            if (Joy and $30 <> 0) and (Fgt.AnimStatus.State = asNone) then
                begin
                    if Joy and _JOY_BTN1 <> 0 then
                        Fgt.JoySequence:=Fgt.JoySequence+'P'
                    else if Joy and _JOY_BTN2 <> 0 then
                        Fgt.JoySequence:=Fgt.JoySequence+'K';
                    CheckFgtSequence(Fgt);
                end;
            if Length(Fgt.JoySequence) > 20 then
                begin
                    Delete(Fgt.JoySequence,1,Length(Fgt.JoySequence)-20);
                end;
            if (not PlayingAnim) and (Fgt.AnimStatus.State = asWaiting) and 
               (Fgt.Life <> 0) then
                begin
                    PlayingAnim:=true;
                    Str2Write:='';
                    ResetAnim(Fgt.Anims);
                    Fgt.AnimStatus.State:=asPlaying;
                end;
        end;
    procedure DrawFighter(var Fgt:Fighter);
        var YOfs:Integer;
        begin
            YOfs:=0;
            if Fgt.JumpCtrl <> 0 then
                begin
                    if Fgt.JumpCtrl > 64 then
                        begin
                            if Fgt.JumpCtrl > 448 then
                                YOfs:=(Fgt.JumpCtrl-448) div 2;
                            DrawStars('yv',255,208,223,Fgt.BkGndStars);
                        end
                    else
                        begin
                            if Fgt.JumpCtrl < 64 then
                                YOfs:=(64-Fgt.JumpCtrl) div 2;
                            DrawStars('yv',255,208,223,Fgt.BkGndStars);
                        end;
                    Dec(Fgt.JumpCtrl);
                end
            else
                begin
                    DisplayRawImageClip(MinX,0,Scenario^);
                end;
            DrawFgtStdStance(0,Abs((Timers[0] shr 3 and $0F) - $07)+YOfs,Fgt.CurrStance,Fgt);
        end;
    procedure CheckFighterDamage(var Fgtr:Fighter; var EnemyLife:word);
        begin
            if (Fgtr.Damage <> 0) and // Acaba de executar um golpe
               (Fgtr.AnimStatus.State = asNone) then
                begin
                    // Retira pontos de vida do advers rio
                    if EnemyLife > Fgtr.Damage then
                        Dec(EnemyLife,Fgtr.Damage)
                    else
                        EnemyLife:=0;
                    Fgtr.Damage:=0;
                end;
        end;
    procedure CheckFighterEnergy(var Fgtr:Fighter; var Power:word);
        begin
            if Fgtr.Energy <> 0 then // Acaba de consumir energia para um golpe
                begin
                    // Atualiza a energia
                    if Power > Fgtr.Energy then
                        Dec(Power,Fgtr.Energy)
                    else
                        Power:=0;
                    Fgtr.Energy:=0;
                end
            else if Fgtr.AnimStatus.State = asNone then // Recarrega lentamente a energia
                begin
                    if (Power < 255) and ((RechargeCtrl and $03) = 0) then
                        Inc(Power);
                end;
            Fgtr.Power:=Power;
        end;
    function StartBattle(Figh1,Figh2:PFighterSel):byte;
        var MarkPtr:Pointer;
            FighName1,FighName2:string;
            Done:byte;
        begin
            Mark(MarkPtr);

            FighName1:=Figh1^.ScriptName;
            FighName2:=Figh2^.ScriptName;

            WriteLnCon(ANSI_YELLOW+'Lendo BKGND.PCX');
            AllocReadPCX(BkGnd,'INTERF\BKGND.PCX');
            GetPCXPalette(Pal2,'INTERF\BKGND.PCX');
            ReIndexColors(BkGnd^,Pal2,64,192);
            Move(Pal2[192],Pal[192],64*3);
        
            WritelnCon(ANSI_YELLOW+'Lendo '+FighName1+' (Player 1)');
            MinX:=0;
            MaxX:=159;
            FgtStartColor:=1;
            ReadFighter(Fgtr,FighName1,False);
            Fgtr.Enemy:=Addr(Fgtr2);
            if not Fgt1IsPlayer then
                begin
                    WritelnCon(ANSI_YELLOW+'Inicializando A.I.');
                    InitFighterAI(Fgt1AI,Fgtr);
                end;
        
            WritelnCon(ANSI_YELLOW+'Lendo '+FighName2+' (Player 2)');
            MinX:=160;
            MaxX:=319;
            FgtStartColor:=65;
            ReadFighter(Fgtr2,FighName2,True);
            Fgtr2.Enemy:=Addr(Fgtr);
            Fgtr2.RightPlayer:=true;
            if not Fgt2IsPlayer then
                begin
                    WritelnCon(ANSI_YELLOW+'Inicializando A.I.');
                    InitFighterAI(Fgt2AI,Fgtr2);
                end;

            TextX:=8;
            TextY:=108;

            if Figh2^.Background.Img <> nil then
                begin
                    WritelnCon(ANSI_YELLOW+'Carregando cen rio do Lutador 2.');
                    Scenario:=Figh2^.Background.Img;
                    Move(Figh2^.Background.Pal,Pal3,SizeOf(Pal3));
                end
            else
                begin
                    WritelnCon(ANSI_YELLOW+'Lutador 2 nÆo tem cen rio.');
                    WritelnCon(ANSI_YELLOW+'Carregando MNTAIN.PCX');
                    AllocReadPCX(Scenario,'INTERF\MNTAIN.PCX');
                    GetPCXPalette(Pal3,'INTERF\MNTAIN.PCX');
                    ReIndexColors(Scenario^,Pal3,62,130);
                end;
        
            WritelnCon(ANSI_YELLOW+'Construindo interface');
            AllocCutRawImage(BkGnd^, 21, 16, 35, 30, Button);
            AllocCutRawImage(BkGnd^, 0, 100, 319, 198, Panel);
            AllocCutRawImage(BkGnd^, 57, 23+1, 63, 29, JoyL);
            AllocCutRawImage(BkGnd^, 72, 23+1, 77, 29, JoyR);
            AllocCutRawImage(BkGnd^, 65, 16, 70, 21, JoyU);
            AllocCutRawImage(BkGnd^, 65, 31, 70, 36, JoyD);
            AllocCutRawImage(BkGnd^, 96, 21, 236, 29, Bar1L);
            AllocCutRawImage(BkGnd^, 96, 39, 236, 47, Bar2L);
            AllocMirrorRawImage(Bar1L^,Bar1R);
            AllocMirrorRawImage(Bar2L^,Bar2R);
        
            InitStars('xh',255,Stars);
            JumpCount:=0;

            WritelnCon(ANSI_YELLOW+'Capturando teclado');
            InitKeyboard;
        
            WritelnCon(ANSI_YELLOW+'Capturando timer');
            SetTimer(100);
        
            WritelnCon(ANSI_YELLOW+'Carregando m£sica');
            if Figh2^.MusicName <> '' then
                ChangeMusic(Figh2^.MusicName);
        
            Life1:=255;
            Life2:=255;
            Power1:=255;
            Power2:=255;
            RechargeCtrl:=0;

            PlayingAnim:=false;
            CheckVictory:=false;
        
            WritelnCon(ANSI_WHITE+'Iniciando...');
            Move(BkGnd^.Data,ScrBuf^,320*200);
            Timers[1]:=0;
            Done:=0;            
            while Done = 0 do
                begin
                    FrameSkip:=Timers[1];
                    Timers[1]:=0;
                    for AnimCtrl:=0 to Pred(FrameSkip) do
                        begin
                            MinY:=4;
                            MaxY:=99;
                            //
                            case Fgtr.AnimStatus.State of
                                asNone,asWaiting:
                                    begin
                                        MinX:=0;
                                        MaxX:=159;
                                        CheckFighterDamage(Fgtr,Life2);
                                        if Fgt1IsPlayer then
                                            HandleFighter(Fgtr,ReadLeftJoy)
                                        else
                                            HandleFighter(Fgtr,Fgt1AI.JoyPos);
                                        CheckFighterEnergy(Fgtr,Power1);
                                        Fgtr.Life:=Life1;
                                    end;
                                asPlaying:
                                    begin
                                        MinX:=0;
                                        MaxX:=319;
                                        HandleFgtrAnim(Fgtr);
                                    end;
                            end;
                            case Fgtr2.AnimStatus.State of
                                asNone,asWaiting:
                                    begin
                                        MinX:=160;
                                        MaxX:=319;
                                        CheckFighterDamage(Fgtr2,Life1);
                                        if Fgt2IsPlayer then
                                            HandleFighter(Fgtr2,ReadRightJoy)
                                        else
                                            HandleFighter(Fgtr2,Fgt2AI.JoyPos);
                                        CheckFighterEnergy(Fgtr2,Power2);
                                        Fgtr2.Life:=Life2;
                                        Fgtr.Life:=Life1;
                                    end;
                                asPlaying:
                                    begin
                                        MinX:=0;
                                        MaxX:=319;
                                        HandleFgtrAnim(Fgtr2);
                                    end;
                            end;
                            Inc(RechargeCtrl);
                            //
                            if not Fgt1IsPlayer then
                                HandleFighterAI(Fgt1AI);
                            if not Fgt2IsPlayer then
                                HandleFighterAI(Fgt2AI);
                            //
                            if (Fgtr.AnimStatus.State <> asPlaying) and (Fgtr2.Life = 0) then
                                begin
                                    Fgtr2.AnimStatus.State:=asNone;
                                    Fgtr2.Damage:=0;
                                    Fgtr2.Energy:=0;
                                    Fgtr.AnimStatus.Anim:='Victory';
                                    Fgtr.AnimStatus.State:=asPlaying;
                                    Fgtr.AnimStatus.CurrFrame:=0;
                                    Fgtr.Damage:=0;
                                    Fgtr.Energy:=0;
                                    if not CheckVictory then
                                        begin
                                            PlayingAnim:=true;
                                            Str2Write:='';
                                            ResetAnim(Fgtr.Anims);
                                        end
                                    else
                                        begin
                                            Done:=_BATTLE_1P_WON;
                                        end;
                                end
                            else if (Fgtr2.AnimStatus.State <> asPlaying) and (Fgtr.Life = 0) then
                                begin
                                    Fgtr.AnimStatus.State:=asNone;
                                    Fgtr.Damage:=0;
                                    Fgtr.Energy:=0;
                                    Fgtr2.AnimStatus.Anim:='Victory';
                                    Fgtr2.AnimStatus.State:=asPlaying;
                                    Fgtr2.AnimStatus.CurrFrame:=0;
                                    Fgtr2.Damage:=0;
                                    Fgtr2.Energy:=0;
                                    if not CheckVictory then
                                        begin
                                            PlayingAnim:=true;
                                            Str2Write:='';
                                            ResetAnim(Fgtr2.Anims);
                                        end
                                    else
                                        begin
                                            Done:=_BATTLE_2P_WON;
                                        end;
                                end;
                            if not Fgt1IsPlayer and 
                               ((ReadLeftJoy and (_JOY_BTN1 or _JOY_BTN2)) <> 0) then
                                begin
                                    Done:=_BATTLE_1P_JOIN;
                                end;
                            if not Fgt2IsPlayer and 
                               ((ReadRightJoy and (_JOY_BTN1 or _JOY_BTN2)) <> 0) then
                                begin
                                    Done:=_BATTLE_2P_JOIN;
                                end;
                            if Keys[scEsc] then
                                Done:=_BATTLE_QUIT;
                        end;
                    MinY:=4;
                    MaxY:=99;
                    FillChar(Pal[0],3,0);
                    ClearBufferLines(ScrBuf^,4,96);
                    if PlayingAnim then
                        begin
                            MinX:=0;
                            MaxX:=319;
                            DrawFgtrAnim(Fgtr);
                            DrawFgtrAnim(Fgtr2);
                        end
                    else
                        begin
                            MinX:=0;
                            MaxX:=159;
                            DrawFighter(Fgtr);
                            MinX:=160;
                            MaxX:=319;
                            DrawFighter(Fgtr2);
                            MinX:=0;
                            MaxX:=319;
                            Move(Pal3[130],Pal[130],62*3);
                            VLine(159,4,96,216);
                            VLine(160,4,96,216);
                        end;
                    MinX:=0;
                    MaxX:=319;
                    MinY:=100;
                    MaxY:=200;
                    DisplayRawImageClip(0,100,Panel^);
                    if Fgt1IsPlayer then
                        DrawJoystick(95,ReadLeftJoy)
                    else
                        DrawJoystick(95,Fgt1AI.JoyPos);
                    if Fgt2IsPlayer then
                        DrawJoystick(253,ReadRightJoy)
                    else
                        DrawJoystick(253,Fgt2AI.JoyPos);
                    DrawBars;
                    if PlayingAnim then
                        begin
                			OutTextFmt(TextX,TextY,StrColor,Str2Write);
                            Str2Write:='';
                        end
                    else
                        begin
//                            OutText(TextX,TextY,215,Fgtr.JoySequence);
                        end;
                    //
                    if Fgtr.AnimStatus.State = asPlaying then
                        OutText(10,180,230+(Timers[3] and $07),Fgtr.FighterName)
                    else
                        OutText(10,180,230,Fgtr.FighterName);
                    //
                    if Fgtr2.AnimStatus.State = asPlaying then
                        OutText(170,180,230+(Timers[3] and $07),Fgtr2.FighterName)
                    else
                        OutText(170,180,230,Fgtr2.FighterName);
                    //
                    WaitVSyncStart;
                    PutPal(Pal);
                    Buffer2Screen(ScrBuf^);
                end;

            if Done in [_BATTLE_1P_JOIN,_BATTLE_2P_JOIN] then
                begin
                    Timers[1]:=0;
                    while Timers[1] < 300 do
                        begin
                            if Done = _BATTLE_1P_JOIN then
                                begin
                                    OutText(TextX,TextY+4,230+(Timers[3] and $07),
                                            'Jogador 1 entrou na disputa!!');
                                end
                            else
                                begin
                                    OutText(TextX,TextY+4,230+(Timers[3] and $07),
                                            'Jogador 2 entrou na disputa!!');
                                end;
                            WaitVSyncStart;
                            PutPal(Pal);
                            Buffer2Screen(ScrBuf^);
                        end;
                end;

            CleanUpTimer;
            DoneKeyboard;

            Release(MarkPtr);

            StartBattle:=Done;
        end;
End.