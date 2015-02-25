unit Lists;
{Interpretador de script de animaá∆o - Rotinas de manipulaá∆o de listas}
{programado por Haroldo de Oliveira Pinheiro}
interface
    {$PACKRECORDS 1}
	uses Graph13h,PCXUnit,SndDrv;
	type
        {Estruturas relacionadas a sprites}
		PSprite=^Sprite;
		Sprite= record
					Next:PSprite;
					SprName:string[12];
					Sprite:PRawImage;
					ImgOfs:Vector;
					StartColor,Colors:byte;
					Pal:Palette;
					ImgPos:Vector;
					Visible:boolean;
				end;
		SpriteList= record
						First,Last:PSprite;
					end;

        {Estruturas relacionadas Ös sequàncias de sprites}
        PSpriteFrame=^SpriteFrame;
        SpriteFrame=record
                        Next:PSpriteFrame;
                        Sprite:PSprite;
                        Duration:longint;
                    end;
        PSpriteSeq=^SpriteSeq;
        SpriteSeq = record
                        Next:PSpriteSeq;
                        SeqName:string[12];
                        First,Last:PSpriteFrame;
                        Current:PSpriteFrame;
                        TimeCounter:longint;
    					ImgPos:Vector;
                        Visible:boolean;
                    end;
        SpriteSeqList = record
                            First,Last:PSpriteSeq;
                        end;

        {Estruturas relacionadas aos efeitos sonoros}
        PSoundFX=^SoundFX;
        SoundFX=record
                    Next:PSoundFX;
                    SFXName:string[12];
                    Sound:SoundEffect;
                end;
        SoundEffectList=record
                            First,Last:PSoundFX;
                        end;

        {Estruturas relacionadas Ös sequàncias de animaá∆o}
		AnimType=(anPlace,anPath,anShow,anHide,anWrite,anStar,anFlash,anBackg,anSound);
		PAnimSlice=^AnimSlice;
		AnimSlice = record
						Next:PAnimSlice;
						SprName:string[12];
						case AType:AnimType of
							anPlace:(
								PlacePos:Vector;
								PlaceTime:longint;
							);
							anPath:(
								PathCount:byte;
								PathPos:array[0..15] of Vector;
								PathStart:longint;
								PathEnd:longint;
							);
							anShow:(
								ShowTime:longint;
							);
							anHide:(
								HideTime:longint;
							);
							anWrite:(
								WriteStr:^String;
								WriteColor:byte;
								WriteStart:longint;
								WriteEnd:longint;
								WriteDly:longint;
							);
							anStar:(
								StarKind:string[6];
								StarStartColor:byte;
								StarStartRGB:Vector;
								StarEndColor:byte;
								StarEndRGB:Vector;
								StarCount:word;
								StarPos:^VectorArray;
								StarSpeed:integer;
								StarStart:longint;
								StarEnd:longint;
								StarPal:^Palette;
							);
							anFlash:(
								FlashCount:byte;
								FlashColor:array[0..15] of Vector;
								FlashStart:longint;
								FlashEnd:longint;
                                FlashPeriod:word;
							);
							anBackg:(
								BackgStart:longint;
								BackgEnd:longint;
                                BackgSpeed:Vector;
                                BackgPos:Vector;
							);
                            anSound:(
                                SoundTime:longint;
                            );
					end;
		PAnimSliceList=^AnimSliceList;
		AnimSliceList = record
							Next:PAnimSliceList;
							AnimName:string[12];
                            Duration:longint;
							First,Last:PAnimSlice;
						end;
		AnimList=record
					First,Last:PAnimSliceList;
				 end;

        {Estrutura principal da animaá∆o}
		AnimPack=record
					Sprites:SpriteList;
					SpriteSeqs:SpriteSeqList;
					Sounds:SoundEffectList;
					Anims:AnimList;
				 end;

	procedure InitSpriteList(var List:SpriteList);
	function  CreateSprite(var List:SpriteList;Name:String):PSprite;
	function  GetSprite(List:SpriteList;Name:String):PSprite;
	procedure DeleteSprite(var List:SpriteList;Name:String);

	procedure InitSpriteSeq(var List:SpriteSeq);
	function  AddSpriteToSeq(var List:SpriteSeq;Sprite:PSprite):PSpriteFrame;

    procedure InitSpriteSeqList(var List:SpriteSeqList);
    function  CreateSpriteSeq(var List:SpriteSeqList;Name:String):PSpriteSeq;
    function  GetSpriteSeq(var List:SpriteSeqList;Name:String):PSpriteSeq;

    procedure InitSoundEffectList(var List:SoundEffectList);
    function  CreateSoundEffect(var List:SoundEffectList;Name:String):PSoundFX;
    function  GetSoundEffect(var List:SoundEffectList;Name:String):PSoundFX;

	procedure InitAnimSliceList(var List:AnimSliceList);
	function  CreateAnimSlice(var List:AnimSliceList):PAnimSlice;

	procedure InitAnimList(var List:AnimList);
	function  CreateAnim(var List:AnimList;Name:String):PAnimSliceList;
	function  GetAnim(List:AnimList;Name:String):PAnimSliceList;

implementation
	procedure InitSpriteList(var List:SpriteList);
		begin
			List.First:=nil;
			List.Last:=nil;
		end;
	function CreateSprite(var List:SpriteList;Name:String):PSprite;
		var Spr:PSprite;
		begin
			New(Spr);
			Spr^.SprName:=Name;
			Spr^.Next:=nil;
			if List.First = nil then
				List.First:=Spr;
			if List.Last <> nil then
				List.Last^.Next:=Spr;
			List.Last:=Spr;
			CreateSprite:=Spr;
		end;
	function GetSprite(List:SpriteList;Name:String):PSprite;
		var Spr:PSprite;
		begin
			Spr:=List.First;
			while (Spr <> nil) and (Spr^.SprName <> Name) do
				Spr:=Spr^.Next;
			GetSprite:=Spr;
		end;
	procedure DeleteSprite(var List:SpriteList;Name:String);
		var Spr,LastSpr:PSprite;
		begin
			Spr:=List.First;
			LastSpr:=nil;
			while (Spr <> nil) and (Spr^.SprName <> Name) do
				begin
					LastSpr:=Spr;
					Spr:=Spr^.Next;
				end;
			if Spr <> nil then
				begin
					if List.First = Spr then
						List.First:=Spr^.Next;
					if List.Last = Spr then
						List.Last:=LastSpr;
					if LastSpr <> nil then
						LastSpr^.Next:=Spr^.Next;
					Dispose(Spr);
				end;
		end;

	procedure InitSpriteSeq(var List:SpriteSeq);
        begin
            List.First:=nil;
            List.Last:=nil;
            List.Next:=nil;
            List.Current:=nil;
{            List.TimeCounter:=0; //  TimeCounter, ImgPos e Visible
            List.ImgPos.X:=0;     // s∆o inicializadas pelo Parser
            List.ImgPos.Y:=0;
            List.ImgPos.Z:=0;
            List.Visible:=false;}
        end;
	function  AddSpriteToSeq(var List:SpriteSeq;Sprite:PSprite):PSpriteFrame;
        var Frame:PSpriteFrame;
        begin
            New(Frame);
            Frame^.Next:=nil;
            Frame^.Duration:=0;
            Frame^.Sprite:=Sprite;
            if List.First = nil then
                begin
                    List.First:=Frame;
                end
            else
                begin
                    List.Last^.Next:=Frame;
                end;
            List.Last:=Frame;
            List.Current:=List.First;
            AddSpriteToSeq:=Frame;            
        end;

    procedure InitSpriteSeqList(var List:SpriteSeqList);
        begin
            List.First:=nil;
            List.Last:=nil;
        end;
    function  CreateSpriteSeq(var List:SpriteSeqList;Name:String):PSpriteSeq;
        var Seq:PSpriteSeq;
        begin
            New(Seq);
            InitSpriteSeq(Seq^);
            Seq^.Next:=nil;
            Seq^.SeqName:=Name;
            if List.First = nil then
                begin
                    List.First:=Seq;
                end
            else
                begin
                    List.Last^.Next:=Seq;
                end;
            List.Last:=Seq;
            CreateSpriteSeq:=Seq;
        end;
    function  GetSpriteSeq(var List:SpriteSeqList;Name:String):PSpriteSeq;
        var Seq:PSpriteSeq;
        begin
            Seq:=List.First;
            while (Seq <> nil) and (Seq^.SeqName <> Name) do
                Seq:=Seq^.Next;
            GetSpriteSeq:=Seq;
        end;

    procedure InitSoundEffectList(var List:SoundEffectList);
        begin
            List.First:=nil;
            List.Last:=nil;
        end;
    function  CreateSoundEffect(var List:SoundEffectList;Name:String):PSoundFX;
        var SFX:PSoundFX;
        begin
            New(SFX);
            SFX^.Next:=nil;
            SFX^.SFXName:=Name;
//            SFX^.Sound.Length:=0;
            if List.First = nil then
                begin
                    List.First:=SFX;
                end
            else
                begin
                    List.Last^.Next:=SFX;
                end;
            List.Last:=SFX;
            CreateSoundEffect:=SFX;
        end;
    function  GetSoundEffect(var List:SoundEffectList;Name:String):PSoundFX;
        var SFX:PSoundFX;
        begin
            SFX:=List.First;
            while (SFX <> nil) and (SFX^.SFXName <> Name) do
                SFX:=SFX^.Next;
            GetSoundEffect:=SFX;
        end;

	procedure InitAnimSliceList(var List:AnimSliceList);
		begin
			List.First:=nil;
			List.Last:=nil;
		end;
	function CreateAnimSlice(var List:AnimSliceList):PAnimSlice;
		var Anm:PAnimSlice;
		begin
			New(Anm);
			Anm^.Next:=nil;
			if List.First = nil then
				List.First:=Anm;
			if List.Last <> nil then
				List.Last^.Next:=Anm;
			List.Last:=Anm;
			CreateAnimSlice:=Anm;
		end;

	procedure InitAnimList(var List:AnimList);
		begin
			List.First:=nil;
			List.Last:=nil;
		end;
	function CreateAnim(var List:AnimList;Name:String):PAnimSliceList;
		var Anm:PAnimSliceList;
		begin
			New(Anm);
			Anm^.AnimName:=Name;
			Anm^.First:=nil;
			Anm^.Last:=nil;
			Anm^.Next:=nil;
			if List.First = nil then
				List.First:=Anm;
			if List.Last <> nil then
				List.Last^.Next:=Anm;
			List.Last:=Anm;
			CreateAnim:=Anm;
		end;
	function GetAnim(List:AnimList;Name:String):PAnimSliceList;
		var Anm:PAnimSliceList;
		begin
			Anm:=List.First;
			while (Anm <> nil) and (Anm^.AnimName <> Name) do
				Anm:=Anm^.Next;
			GetAnim:=Anm;
		end;
End.