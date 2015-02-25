unit ZZTStObj;
interface
	const
		ZZT_OBJ_STEP = $01;
		ZZT_OBJ_PUSH = $02;

		ZZT_FLG_EMPTY = $0001;
		ZZT_FLG_EDGE = $0002;
		ZZT_FLG_ITEM = $0004;
		ZZT_FLG_SHOT = $0008;
		ZZT_FLG_PASSAGE = $0010;
		ZZT_FLG_WATER = $0020;
		ZZT_FLG_FOREST = $0040;
		ZZT_FLG_FAKE = $0080;
		ZZT_FLG_ENEMY = $0100;


	type
		ZZTObjFunc = function(ObjNum: word; Cmd: byte): word;

	function  ZZT_CanWalkInto(X,Y,Flags: word): boolean;
	function  ZZT_ObjAtPos(X,Y: byte; Obj: word): word;
	procedure ZZT_EraseObj(ObjNum: word);
	function  ZZT_ObjOfType(Code, Color: integer; StartIndex: word): word;
	procedure ZZT_CheckGround(ObjNum: word);
	function  ZZT_TryPushing(X,Y,FromX,FromY : byte): boolean;

	function ZZT_Player_Func(ObjNum: word; Cmd: byte): word;
	function ZZT_Object_Func(ObjNum: word; Cmd: byte): word;
	function ZZT_Lion_Func(ObjNum: word; Cmd: byte): word;
	function ZZT_Tiger_Func(ObjNum: word; Cmd: byte): word;

implementation
	uses Crt, ZZTLoad, ZZTRun, ZZTOOP;

	function ZZT_CanWalkInto(X,Y,Flags: word): boolean;
		begin
			ZZT_CanWalkInto := False;
			if (X > 0) and (X <= 60) and (Y > 0) and (Y <= 25) then
				begin
					case CurrentBoard.Map[Y-1,X-1].Code of
						$00:if (Flags and ZZT_FLG_EMPTY <> 0) then {Vazio}
								ZZT_CanWalkInto := True;
						$01:if (Flags and ZZT_FLG_EDGE <> 0) then {Extremo da tela}
								ZZT_CanWalkInto := True;
						$05,$06,$07,$08,$0A,$0E: {Muniá∆o, Tocha, Gema, Chave, Pergaminho, Energizador}
							if (Flags and ZZT_FLG_ITEM <> 0) then
								ZZT_CanWalkInto := True;
						$0F,$12: {Estrela, Tipo}
							if (Flags and ZZT_FLG_SHOT <> 0) then {Extremo da tela}
								ZZT_CanWalkInto := True;
						$0B:if (Flags and ZZT_FLG_PASSAGE <> 0) then {Passagem}
								ZZT_CanWalkInto := True;
						$13:if (Flags and ZZT_FLG_WATER <> 0) then {µgua}
								ZZT_CanWalkInto := True;
						$14:if (Flags and ZZT_FLG_FOREST <> 0) then {Floresta}
								ZZT_CanWalkInto := True;
						$1B:if (Flags and ZZT_FLG_FAKE <> 0) then {Parede falsa}
								ZZT_CanWalkInto := True;
						$22,$23,$25,$26,$29,$2A,$2C,$2D: {Urso, Rufi∆o, Meleca, Tubar∆o, Le∆o, Tigre, Cabeáa CentopÇia, Segmento CentopÇia}
							if (Flags and ZZT_FLG_ENEMY <> 0) then
								ZZT_CanWalkInto := True;
					end;
				end;
		end;

	function  ZZT_ObjAtPos(X,Y: byte; Obj: word): word;
		var i : word;
			Found : word;
		begin
			i := 0;
			Found := $FFFF;
			while (i <= CurrentBoard.Info.ObjCount) and
				  (Found = $FFFF) do
				begin
					if (CurrentBoard.Objects[i].X - 1 = X) and
					   (CurrentBoard.Objects[i].Y - 1 = Y) and
					   (i <> Obj) then
						Found := i;
					Inc(i);
				end;
			ZZT_ObjAtPos := Found;
		end;

	procedure ZZT_EraseObj(ObjNum: word);
		var Obj : ^ZZTObjHeader;
		begin
			if ObjNum > CurrentBoard.Info.ObjCount then
				exit;

			Obj := Addr(CurrentBoard.Objects[ObjNum]);

			if (Obj^.X < 1) or (Obj^.X > 60) or
			   (Obj^.Y < 1) or (Obj^.Y > 25) then
				exit;

			CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code := Obj^.Uc;
			CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Color := Obj^.Ut;

			Obj^.Cycle := 0;
			Obj^.X := 255;
		end;

	function  ZZT_ObjOfType(Code, Color: integer; StartIndex: word): word;
		var
			Found : word;
		begin
			Found := $FFFF;
			while (StartIndex <= CurrentBoard.Info.ObjCount) and
				  (Found = $FFFF) do
				with CurrentBoard.Objects[StartIndex] do
					begin
						if (X > 0) and (X < 61) and (Y > 0) and (Y < 26) and
						   ((Code < 0) or (CurrentBoard.Map[Y-1,X-1].Code = Code)) and
						   ((Color < 0) or (CurrentBoard.Map[Y-1,X-1].Color = Color)) then
							Found := StartIndex;

						Inc(StartIndex);
					end;
			ZZT_ObjOfType := Found;
		end;

	procedure ZZT_CheckGround(ObjNum: word);
		var Obj, Obj2 : ^ZZTObjHeader;
			X,Y : byte;
			Obj2Num : word;
		begin
			Obj := Addr(CurrentBoard.Objects[ObjNum]);
			X := Obj^.X - 1;
			Y := Obj^.Y - 1;

			if (X > 59) or (Y > 24) then
				exit;

			Obj2Num := ZZT_ObjAtPos(X,Y,ObjNum);

			if Obj2Num <> $FFFF then
				Obj2 := Addr(CurrentBoard.Objects[Obj2Num])
			else
				Obj2 := nil;

			case CurrentBoard.Map[Y,X].Code of
				$01:begin {Board edge}
					end;

				$05:begin {Ammo}
						CurrentBoard.Map[Y,X].Code := 0;
					end;

				$06:begin {Torch}
						CurrentBoard.Map[Y,X].Code := 0;
					end;

				$07:begin {Gem}
						CurrentBoard.Map[Y,X].Code := 0;
					end;

				$08:begin {Key}
						CurrentBoard.Map[Y,X].Code := 0;
					end;

				$0A:begin {Scroll}
					end;

				$0B:begin {Passage}
						ZZTNewX := 255;
						ZZTNewY := 255;
						ZZTBoardToLoad := Obj2^.P3;
						ZZTPaused := True;
					end;

				$0E:begin {Energizer}
						CurrentBoard.Map[Y,X].Code := 0;
					end;

				$0F:begin {Star}
						ZZT_EraseObj(Obj2Num);
					end;

				$12:begin {Bullet}
						ZZT_EraseObj(Obj2Num);
					end;

				$14:begin {Forest}
						CurrentBoard.Map[Y,X].Code := 0;
					end;

				$22:begin {Bear}
						ZZT_EraseObj(Obj2Num);
					end;

				$23:begin {Ruffian}
						ZZT_EraseObj(Obj2Num);
					end;

				$25:begin {Slime}
						ZZT_EraseObj(Obj2Num);
					end;

				$26:begin {Shark}
						ZZT_EraseObj(Obj2Num);
					end;

				$29:begin {Lion}
						ZZT_EraseObj(Obj2Num);
					end;

				$2A:begin {Tiger}
						ZZT_EraseObj(Obj2Num);
					end;

				$2C:begin {Centipede Head}
						ZZT_EraseObj(Obj2Num);
					end;

				$2D:begin {Centipede Segment}
						ZZT_EraseObj(Obj2Num);
					end;
			end;
		end;

	function  ZZT_TryPushing(X,Y,FromX,FromY : byte): boolean;
		var Target: word;
		begin
			ZZT_TryPushing := False;

			if (X = 0) or (X > 60) or (Y = 0) or (Y > 25) or
			   (FromX = 0) or (FromX > 60) or
			   (FromY = 0) or (FromY > 25) then
				exit;

			case CurrentBoard.Map[Y-1,X-1].Code of
				$24:begin {Object}
						Target := ZZT_ObjAtPos(X-1,Y-1,0);
						if Target <> $FFFF then
							ZZT_Object_Func(Target,ZZT_OBJ_PUSH);
					end;
			end;
		end;

	function ZZT_Player_Func(ObjNum: word; Cmd: byte): word;
		const
			ZZT_PLAYER_FLG = ZZT_FLG_EMPTY or ZZT_FLG_EDGE or ZZT_FLG_ITEM or
							 ZZT_FLG_PASSAGE or ZZT_FLG_FOREST or ZZT_FLG_FAKE or
							 ZZT_FLG_ENEMY;

		var Obj : ^ZZTObjHeader;
			Code, Color : byte;
			NewX, NewY	: byte;
		begin
			ZZT_Player_Func := 0;

			Obj := Addr(CurrentBoard.Objects[ObjNum]);

			case Cmd of
				ZZT_OBJ_STEP:
					begin
						Code := CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code;
						Color := CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Color;

						CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code := Obj^.Uc;
						CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Color := Obj^.Ut;

						NewX := Obj^.X;
						NewY := Obj^.Y;

						case ZZTKey of
							ZZT_KEY_UP: Dec(NewY);
							ZZT_KEY_DOWN: Inc(NewY);
							ZZT_KEY_LEFT: Dec(NewX);
							ZZT_KEY_RIGHT: Inc(NewX);
						end;

						if NewX = 0 then {Exiting board from left}
							begin
								ZZTNewX := 60;
								ZZTNewY := NewY;
								ZZTBoardToLoad := CurrentBoard.Info.BoardWest;
							end
						else if NewX = 61 then {Exiting board from right}
							begin
								ZZTNewX := 1;
								ZZTNewY := NewY;
								ZZTBoardToLoad := CurrentBoard.Info.BoardEast;
							end
						else if NewY = 0 then {Exiting board from top}
							begin
								ZZTNewX := NewX;
								ZZTNewY := 25;
								ZZTBoardToLoad := CurrentBoard.Info.BoardNorth;
							end
						else if NewY = 26 then {Exiting board from bottom}
							begin
								ZZTNewX := NewX;
								ZZTNewY := 1;
								ZZTBoardToLoad := CurrentBoard.Info.BoardSouth;
							end;

						if not ZZT_CanWalkInto(NewX,NewY,ZZT_PLAYER_FLG) and
						   not ZZT_TryPushing(NewX, NewY, Obj^.X, Obj^.Y) then
							begin
								NewX := Obj^.X;
								NewY := Obj^.Y;
							end;

						Obj^.X := NewX;
						Obj^.Y := NewY;

						ZZT_CheckGround(ObjNum);

						Obj^.Uc := CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code;
						Obj^.Ut := CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Color;

						if CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code <> $0B then {not Teleporter}
							begin
								CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code := Code;
								CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Color := Color;
							end;
					end;
			end;
		end;

	function ZZT_Object_Func(ObjNum: word; Cmd: byte): word;
		var Obj : ^ZZTObjHeader;
			Code, Color : byte;
			NewX, NewY	: byte;
		begin
			ZZT_Object_Func := 0;

			Obj := Addr(CurrentBoard.Objects[ObjNum]);

			case Cmd of
				ZZT_OBJ_STEP:
					begin
						if (Obj^.Cycle = 0) or
						   (ZZTGlobalTimer mod Obj^.Cycle <> 0) then
							exit;

						ExecuteObjectScript(ObjNum);
					end;
				ZZT_OBJ_PUSH:
					begin
						SendObjectToLabel(ObjNum,'touch');
					end;
			end;
		end;

	function ZZT_Lion_Func(ObjNum: word; Cmd: byte): word;
		var Obj : ^ZZTObjHeader;
			Code, Color : byte;
			NewX, NewY	: byte;
		begin
			ZZT_Lion_Func := 0;

			Obj := Addr(CurrentBoard.Objects[ObjNum]);

			case Cmd of
				ZZT_OBJ_STEP:
					begin
						if (Obj^.Cycle = 0) or
						   (ZZTGlobalTimer mod Obj^.Cycle <> 0) then
							exit;

						Code := CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code;
						Color := CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Color;

						CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code := Obj^.Uc;
						CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Color := Obj^.Ut;

						NewX := Obj^.X;
						NewY := Obj^.Y;

						case Random(5) of
							1: Inc(NewX);
							2: Dec(NewX);
							3: Inc(NewY);
							4: Dec(NewY);
						end;

						if not ZZT_CanWalkInto(NewX,NewY,ZZT_FLG_EMPTY) then
							begin
								NewX := Obj^.X;
								NewY := Obj^.Y;
							end;

						Obj^.X := NewX;
						Obj^.Y := NewY;

						Obj^.Uc := CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code;
						Obj^.Ut := CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Color;

						CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Code := Code;
						CurrentBoard.Map[Obj^.Y-1,Obj^.X-1].Color := Color;
					end;
			end;
		end;

	function ZZT_Tiger_Func(ObjNum: word; Cmd: byte): word;
		begin
			ZZT_Tiger_Func := ZZT_Lion_Func(ObjNum,Cmd);
		end;
End.