unit Fgt_AI;
{FightX Game System - Rotinas de inteligˆncia artificial}
{programado por Haroldo de Oliveira Pinheiro}
interface
    uses FighterUnit;
    type
        Fighter_AI= record
                        Fighter:^Fighter;
                        Enemy:^Fighter;
                        CurrAttack:PFighterAttack;
                        JoyPos:byte;
                    end;
    procedure InitFighterAI(var AI:Fighter_AI;var Fgt:Fighter);
    procedure HandleFighterAI(var AI:Fighter_AI);
implementation
    uses Lists,Joystick;

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

    function AttackIsValid(var Fgt:Fighter;Atk:PFighterAttack):boolean;
        var Ok:boolean;
        begin
            Ok:=true;

            if (Atk^.MidAir) and not (Fgt.CurrStance in [ssJumpUp,ssJumpFall]) then
                Ok:=false;
            if (not Atk^.MidAir) and (Fgt.CurrStance in [ssJumpUp,ssJumpFall]) then
                Ok:=false;

            AttackIsValid:=Ok;
        end;
    procedure SelectNextValidAttack(var AI:Fighter_AI);
        var Atk,Marker:PFighterAttack;
        begin
            Atk:=AI.CurrAttack;
            Marker:=AI.CurrAttack;
            repeat
                Atk:=Atk^.Next;
                if Atk = nil then
                    Atk:=AI.Fighter^.Attacks.First;
            until (Atk = Marker) or (AttackIsValid(AI.Fighter^,Atk));
            AI.CurrAttack:=Atk;
        end;
    procedure SelectAnotherAttack(var AI:Fighter_AI);
        var i:byte;
        begin
            for i:=0 to Random(10) do
                SelectNextValidAttack(AI);
        end;

    procedure InitFighterAI(var AI:Fighter_AI;var Fgt:Fighter);
        begin
            AI.Fighter:=Addr(Fgt);
            AI.Enemy:=Fgt.Enemy;
            AI.CurrAttack:=Fgt.Attacks.First;
            SelectAnotherAttack(AI);
        end;
    procedure HandleDefense(var AI:Fighter_AI);
        var EnmAnimLen:longint;
        begin
            if (AI.Enemy^.AnimStatus.State = asPlaying) and (AI.JoyPos = 0) then
                begin
                    if AI.Enemy^.CurrAttack^.Aerial then
                        begin
                            if Random(100) < 75 then
                                AI.JoyPos:=_JOY_DOWN
                            else if Random(100) < 75 then
                                AI.JoyPos:=_JOY_LEFT
                            else if Random(100) < 75 then
                                AI.JoyPos:=_JOY_RIGHT;
                        end
                    else
                        begin
                            if Random(100) < 50 then
                                AI.JoyPos:=_JOY_UP
                            else if Random(100) < 75 then
                                AI.JoyPos:=_JOY_LEFT
                            else if Random(100) < 75 then
                                AI.JoyPos:=_JOY_RIGHT;
                        end;
                    if AI.Fighter^.RightPlayer then
                        SwapJoyLR(AI.JoyPos);
                end
            else if AI.Enemy^.AnimStatus.State in [asWaiting,asNone] then
                begin
                    AI.JoyPos:=0;
                end;
        end;
    procedure HandleFighterAI(var AI:Fighter_AI);
        begin
            if AI.Fighter^.AnimStatus.State = asNone then
                begin
                    if (not AttackIsValid(AI.Fighter^,AI.CurrAttack)) or
                       (Random(100) < 3) then
                        SelectAnotherAttack(AI);
                    if (AI.CurrAttack^.Energy <= AI.Fighter^.Power) and
                       (Random(100) < 10) then
                        begin
                            AI.Fighter^.JoySequence:=AI.CurrAttack^.Sequence;
                            CheckFgtSequence(AI.Fighter^);
                            SelectAnotherAttack(AI);
                        end
                    else 
                        begin
                            HandleDefense(AI);
                        end;
                end
            else
                begin
                    AI.JoyPos:=0;
                end;
        end;
End.