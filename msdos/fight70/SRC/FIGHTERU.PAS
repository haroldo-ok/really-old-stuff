unit FighterUnit;
{FightX Game System - Rotinas dos lutadores}
{programado por Haroldo de Oliveira Pinheiro}
interface
    uses Graph13h,Lists;
    type
        FighterSpr=record
                       Img:PRawImage;
                       OfsX,OfsY:integer;
                       Pal:Palette;
                   end;
        PFighterAttack=^FighterAttack;
        FighterAttack = record
                            Next:PFighterAttack;
                            Sequence:string;
                            AnimName:string;
                            MidAir:boolean;  //Ataque deve ser acionado durante o pulo?
                            Aerial:boolean;  //Ataque Ç aÇreo? (n∆o Ç a mesma coisa)
                            Damage:word;
                            Energy:word;
                        end;
        FgtAttackList = record
                            First,Last:PFighterAttack;
                        end;
        AnimState=(asNone,asWaiting,asPlaying);
        AnimStatRec=record
                        Anim:string;
                        State:AnimState;
                        CurrFrame:longint;
                    end;
        StandardStances=(ssStand,ssDefend,ssDodge,ssDuck,ssJumpUp,ssJumpFall,ssHit);
        Fighter=record
                    FighterName:string;
                    RightPlayer:boolean;
                    JumpCtrl:word;
                    JoySequence:string;
                    CurrStance:StandardStances; // Pose atual
                    DefStance:StandardStances;  // Usado na checagem de dano
                    BkGndStars:VectorArray;
                    StartColor:byte;
                    StdStances:array[StandardStances] of FighterSpr;
                    Attacks:FgtAttackList;
                    CurrAttack:PFighterAttack;
                    Life:word;   // Quanto falta para o lutador morrer
                    Power:word;  // Energia total dispon°vel
                    Damage:byte; // Dano do £ltimo golpe executado
                    Energy:byte; // Energia gasta no £ltimo ataque
                    Anims:AnimPack;
                    AnimStatus:AnimStatRec;
                    Enemy:^Fighter;
                end;
    var FgtStartColor:byte;
    procedure ReadFighter(var Fgt:Fighter;FileName:string;RightPlayer:boolean);
    procedure CheckFgtSequence(var Fgt:Fighter);
implementation
    uses PCXUnit,AnimUnit,Console,Utils;

	procedure InitAttackList(var List:FgtAttackList);
		begin
			List.First:=nil;
			List.Last:=nil;
		end;
	function CreateAttack(var List:FgtAttackList;Sequence:String):PFighterAttack;
		var Fatk:PFighterAttack;
		begin
			New(Fatk);
			Fatk^.Sequence:=Sequence;
			Fatk^.Next:=nil;
			if List.First = nil then
				List.First:=Fatk;
			if List.Last <> nil then
				List.Last^.Next:=Fatk;
			List.Last:=Fatk;
			CreateAttack:=Fatk;
		end;

    var BaseDir:string;

    procedure ReadFighterAttack(var List:FgtAttackList;var T:Text;Params:string);
        var Token:string;
            Atk:PFighterAttack;
        begin
            Token:=GetToken(Params);
            if Token <> '' then
                begin
                    WritelnCon(ANSI_YELLOW+'Sequància: '+RemoveQuotes(Token));
                    Atk:=CreateAttack(List,RemoveQuotes(Token));
                    Atk^.MidAir:=false;
                    Atk^.Aerial:=false;
                    Atk^.Damage:=1;
                    Atk^.Energy:=1;
                    while (not Eof(T)) and (Token <> '#end') do
                        begin
                            ReadLn(T,Params);
                            Token:=GetToken(Params);
                            if Token='anim' then
                                begin
                                    Token:=GetToken(Params);
                                    WritelnCon(ANSI_GRAY+'  Animaá∆o: '+RemoveQuotes(Token));
                                    Atk^.AnimName:=RemoveQuotes(Token);
                                end
                            else if Token='onground' then
                                begin
                                    Atk^.Midair:=false;
                                end
                            else if Token='midair' then
                                begin
                                    Atk^.Midair:=true;
                                end
                            else if Token='ground' then
                                begin
                                    Atk^.Aerial:=false;
                                end
                            else if Token='aerial' then
                                begin
                                    Atk^.Aerial:=true;
                                end
                            else if Token='damage' then
                                begin
                                    Token:=GetToken(Params);
                                    Atk^.Damage:=ReadNumber(Token);
                                end
                            else if Token='power' then
                                begin
                                    Token:=GetToken(Params);
                                    Atk^.Energy:=ReadNumber(Token);
                                end;
                        end;
                end
            else
                begin
                    WritelnCon(ANSI_LTRED+'Erro: Sequància n∆o foi especificada');
                end;
        end;

    procedure MirrorFighterSpr(var FSpr:FighterSpr);
        var Img:PRawImage;
        begin
            AllocMirrorRawImage(FSpr.Img^,Img);
            FreeRawImage(FSpr.Img);
            FSpr.Img:=Img;
            FSpr.OfsX:=319-FSpr.OfsX-FSpr.Img^.Width;
        end;

    procedure ReadFighterSpr(var FSpr:FighterSpr;Params:string;RightPlayer:boolean);
        var Token:string;
        begin
            Token:=GetToken(Params);
            Token:=BaseDir+RemoveQuotes(Token);
            WritelnCon(ANSI_GRAY+'  Lendo imagem: '+Token); //***DEBUG***
            AllocReadPCX(FSpr.Img,Token);
            GetPCXPalette(FSpr.Pal,Token);
            ReIndexColors(FSpr.Img^,FSpr.Pal,64,FgtStartColor);
            Token:=GetToken(Params);
            FSpr.OfsX:=ReadNumber(Token);
            Token:=GetToken(Params);
            FSpr.OfsY:=ReadNumber(Token);
            if RightPlayer then
                MirrorFighterSpr(FSpr);
        end;

    procedure ReadFighter(var Fgt:Fighter;FileName:string;RightPlayer:boolean);
        var T:Text;
            S,Token:string;
            Stance:StandardStances;
        begin
            BaseDir:=GetBaseDir(FileName);

            WriteLnCon(ANSI_YELLOW+'Diret¢rio base Ç '+BaseDir); //***DEBUG***

            //Inicializa vari†veis

            if RightPlayer then
                begin
                    MinX:=160;
                    MaxX:=319;
                end
            else
                begin
                    MinX:=0;
                    MaxX:=159;
                end;
            Fgt.JumpCtrl:=0;
            Fgt.JoySequence:='';
            InitStars('yv',255,Fgt.BkGndStars);
            Fgt.StartColor:=FgtStartColor;
            Fgt.RightPlayer:=RightPlayer;
            Fgt.Damage:=0;
            Fgt.Energy:=0;
            Fgt.AnimStatus.State:=asNone;
            InitAttackList(Fgt.Attacks);
            Fgt.CurrAttack:=nil;
            for Stance:=ssStand to ssHit do
                Fgt.StdStances[Stance].Img:=nil;
            MinX:=0;
            MaxX:=319;

            //Interpreta o arquivo

            WriteLnCon(ANSI_YELLOW+'Lendo '+FileName); //***DEBUG***
            Assign(T,FileName);
            Reset(T);
            WriteLnCon(ANSI_YELLOW+'OK'); //***DEBUG***
            while not Eof(T) do
                begin
                    Readln(T,S);
                    Token:=GetToken(S);
                    if Token='#name' then
                        begin
                            Token:=GetToken(S);
                            Fgt.FighterName:=RemoveQuotes(Token);
                        end
                    else if Token='#stand' then
                        begin
                            ReadFighterSpr(Fgt.StdStances[ssStand],S,RightPlayer);
                        end
                    else if Token='#defend' then
                        begin
                            ReadFighterSpr(Fgt.StdStances[ssDefend],S,RightPlayer);
                        end
                    else if Token='#dodge' then
                        begin
                            ReadFighterSpr(Fgt.StdStances[ssDodge],S,RightPlayer);
                        end
                    else if Token='#duck' then
                        begin
                            ReadFighterSpr(Fgt.StdStances[ssDuck],S,RightPlayer);
                        end
                    else if Token='#jumpup' then
                        begin
                            ReadFighterSpr(Fgt.StdStances[ssJumpUp],S,RightPlayer);
                        end
                    else if Token='#jumpfall' then
                        begin
                            ReadFighterSpr(Fgt.StdStances[ssJumpFall],S,RightPlayer);
                        end
                    else if Token='#hit' then
                        begin
                            ReadFighterSpr(Fgt.StdStances[ssHit],S,RightPlayer);
                        end
                    else if Token='#attack' then
                        begin
                            ReadFighterAttack(Fgt.Attacks,T,S);
                        end;
                end;
            Close(T);

            //Carrega as Animaá‰es

            Delete(FileName,Pos('.',FileName),Length(FileName));
            FileName:=FileName+'.ANS';
            LoadAnim(Fgt.Anims,FileName);
        end;
    procedure CheckFgtSequence(var Fgt:Fighter);
        var Atk:PFighterAttack;
        function Match(S1,S2:string):boolean;
            var i:integer;
            begin
                if S1<>'' then
                    begin
                        i:=Length(S2)-Length(S1);
                        if i > -1 then
                            begin
                                Match:=( S1 = Copy( S2, i+1, Length(S1) ) );
                            end
                        else
                            begin
                                Match:=false;
                            end;
                    end
                else
                    begin
                        Match:=false;
                    end;
            end;
        function MatchAtk(Atk:FighterAttack;Fgt:Fighter):boolean;
            begin
                MatchAtk:=(Atk.MidAir=(Fgt.JumpCtrl<>0)) and Match(Atk.Sequence,Fgt.JoySequence);
            end;
        begin
            if Fgt.AnimStatus.State <> asWaiting then
                begin
                    Atk:=Fgt.Attacks.First;
                    while (Atk<>nil) and not (MatchAtk(Atk^,Fgt)) do
                        Atk:=Atk^.Next;
                    if (Atk <> nil) and (Fgt.Power >= Atk^.Energy) then
                        begin
                            Fgt.CurrAttack:=Atk;
                            Fgt.AnimStatus.Anim:=Atk^.AnimName;
                            Fgt.AnimStatus.State:=asWaiting;
                            Fgt.AnimStatus.CurrFrame:=0;
                            Fgt.Damage:=Atk^.Damage;
                            Fgt.Energy:=Atk^.Energy;
                        end;
                    Fgt.JoySequence:='';
                end;
        end;
end.