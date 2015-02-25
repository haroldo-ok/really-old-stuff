unit ZZTRun;
interface
	const
		ZZT_KEY_NONE = 0;
		ZZT_KEY_UP = 1;
		ZZT_KEY_DOWN = 2;
		ZZT_KEY_LEFT = 3;
		ZZT_KEY_RIGHT = 4;

	type
		VideoChar = record
						Chr: char;
						Attr: byte;
					end;

	var ZZTRunning: boolean;
		ZZTInGame: boolean;
		ZZTPaused: boolean;
		ZZTFrameBuffer: array[0..24,0..59] of VideoChar;
		ZZTGlobalTimer: longint;
		ZZTKey: byte;
		ZZTBoardToLoad: word;
		ZZTNewX, ZZTNewY: word;

	procedure ZZTReset;
	procedure ZZTStart;

	procedure ZZTStep;
	procedure ZZTDraw;

	procedure ZZTTeleportPlayer(X,Y: byte; Board: word);

	procedure ZZTCheat(Cheat: string);
	procedure ZZTZap(X,Y: byte);

implementation
	uses ZZTLoad, ZZTStObj;

	const
		ZZT_CODE_TABLE:array[$00..$3D] of String = (
						Chr($00), {Vazio}
						Chr($00), {Especial: extremidade da fase}
						#00,#00,  {N∆o usados}
						Chr($02), {Jogador}
						Chr($84), {Muniá∆o}
						Chr($9D), {Tocha}
						Chr($04), {Gema}
						Chr($0C), {Chave}
						Chr($0A), {Porta}
						Chr($E8), {Pergaminho}
						Chr($F0), {Passagem}
						'.oO',    {Duplicador}
						Chr($0B), {Bomba}
						Chr($7F), {Energizador}
						'/-\|',   {Estrela}
						'/-\|',   {Esteira hor†ria}
						'/|\-',   {Esteira anti-hor†ria}
						Chr($F8), {Bala}
						Chr($B0), {µgua}
						Chr($B0), {Floresta}
						Chr($DB), {S¢lido}
						Chr($B2), {Normal}
						Chr($B1), {Quebr†vel}
						Chr($FE), {Pedregulho}
						Chr($12), {Deslizante: Norte/Sul}
						Chr($1D), {Deslizante: Leste/Oeste}
						Chr($B2), {Falso}
						Chr($00), {Muro invis°vel}
						Chr($FF), {Muro piscante}
						Chr($FF), {Transportador}
						Chr($FF), {Linha}
						Chr($2A), {Ricochete}
						Chr($CD), {Raio horizontal}
						Chr($99), {Urso}
						Chr($05), {Rufi∆o}
						Chr($02), {Objeto}
						Chr($2A), {Meleca}
						Chr($5E), {Tubar∆o}
						#17#30#16#31, {Arma girat¢ria}
						Chr($FF), {Empurrador}
						Chr($EA), {Le∆o}
						Chr($E3), {Tigre}
						Chr($BA), {Raio vertical}
						Chr($E9), {Cabeáa de centopÇia}
						Chr($4F), {Segmento de centopÇia}
						#00,      {N∆o usado}
						Chr($1F), {Texto azul}
						Chr($2F), {Texto verde}
						Chr($3F), {Texto ciano}
						Chr($4F), {Texto vermelho}
						Chr($5F), {Texto p£rpura}
						Chr($6F), {Texto amarelo}
						Chr($7F), {Texto branco}
						Chr($8F), {Texto branco piscante}
						Chr($9F), {Texto azul piscante}
						Chr($AF), {Texto verde piscante}
						Chr($BF), {Texto ciano piscante}
						Chr($CF), {Texto vermelho piscante}
						Chr($DF), {Texto p£rpura piscante}
						Chr($EF), {Texto amerelo piscante}
						Chr($FF)  {Texto cinza piscante}
						);

		ZZT_FUNC_TABLE:array[$00..$3D] of ZZTObjFunc = (
						nil, {Vazio}
						nil, {Especial: extremidade da fase}
						nil,nil,  {N∆o usados}
						ZZT_Player_Func, {Jogador}
						nil, {Muniá∆o}
						nil, {Tocha}
						nil, {Gema}
						nil, {Chave}
						nil, {Porta}
						nil, {Pergaminho}
						nil, {Passagem}
						nil, {Duplicador}
						nil, {Bomba}
						nil, {Energizador}
						nil, {Estrela}
						nil, {Esteira hor†ria}
						nil, {Esteira anti-hor†ria}
						nil, {Bala}
						nil, {µgua}
						nil, {Floresta}
						nil, {S¢lido}
						nil, {Normal}
						nil, {Quebr†vel}
						nil, {Pedregulho}
						nil, {Deslizante: Norte/Sul}
						nil, {Deslizante: Leste/Oeste}
						nil, {Falso}
						nil, {Muro invis°vel}
						nil, {Muro piscante}
						nil, {Transportador}
						nil, {Linha}
						nil, {Ricochete}
						nil, {Raio horizontal}
						nil, {Urso}
						nil, {Rufi∆o}
						ZZT_Object_Func, {Objeto}
						nil, {Meleca}
						nil, {Tubar∆o}
						nil, {Arma girat¢ria}
						nil, {Empurrador}
						ZZT_Lion_Func, {Le∆o}
						ZZT_Tiger_Func, {Tigre}
						nil, {Raio vertical}
						nil, {Cabeáa de centopÇia}
						nil, {Segmento de centopÇia}
						nil, {N∆o usado}
						nil, {Texto azul}
						nil, {Texto verde}
						nil, {Texto ciano}
						nil, {Texto vermelho}
						nil, {Texto p£rpura}
						nil, {Texto amarelo}
						nil, {Texto branco}
						nil, {Texto branco piscante}
						nil, {Texto azul piscante}
						nil, {Texto verde piscante}
						nil, {Texto ciano piscante}
						nil, {Texto vermelho piscante}
						nil, {Texto p£rpura piscante}
						nil, {Texto amerelo piscante}
						nil  {Texto cinza piscante}
						);

	procedure ZZTReset;
		begin
			if not ZZTWorldLoaded then
				Exit;

			ZZTInGame := False;

			ZZTRunning := False;

			LoadZZTBoard(0);

			ZZTGlobalTimer := 0;
			ZZTKey := ZZT_KEY_NONE;
			ZZTBoardToLoad := $FFFF;

			ZZTRunning := True;
		end;

	procedure ZZTStart;
		begin
			LoadZZTBoard(WorldHeader.StartBoard);

			ZZTBoardToLoad := $FFFF;
			ZZTInGame := True;
			ZZTPaused := False;
		end;

	procedure DisplayBoardChar(X,Y: byte; Data: ZZTChar);
		begin
			if Data.Code = 0 then {Espaáo vazio}
				begin
					ZZTFrameBuffer[Y,X].Chr := #0;
					ZZTFrameBuffer[Y,X].Attr := 0;
				end
			else if Data.Code = 4 then {Jogador}
				begin
					ZZTFrameBuffer[Y,X].Chr := ZZT_CODE_TABLE[Data.Code][1];
					ZZTFrameBuffer[Y,X].Attr := Data.Color;

					if ZZTPaused then
						ZZTFrameBuffer[Y,X].Attr := ZZTFrameBuffer[Y,X].Attr or $80;
				end
			else if Data.Code < $2F then {Objetos diversos}
				begin
					ZZTFrameBuffer[Y,X].Chr := ZZT_CODE_TABLE[Data.Code][1];
					ZZTFrameBuffer[Y,X].Attr := Data.Color;
				end
			else if Data.Code < $3E then {Texto}
				begin
					ZZTFrameBuffer[Y,X].Chr := Chr(Data.Color);
					ZZTFrameBuffer[Y,X].Attr := Ord(ZZT_CODE_TABLE[Data.Code][1]);
				end
			else {Outros (Desconhecidos)}
				begin
					ZZTFrameBuffer[Y,X].Chr := Chr(Data.Code);
					ZZTFrameBuffer[Y,X].Attr := Data.Color;
				end;
		end;

	procedure DisplayObject(Num: byte);
		var X, Y: byte;
		begin
			X := CurrentBoard.Objects[Num].X-1;
			Y := CurrentBoard.Objects[Num].Y-1;

			if (X > 59) or (Y > 24) then
				exit;

			case CurrentBoard.Map[Y,X].Code of
				$24:begin {Objeto}
						ZZTFrameBuffer[Y,X].Chr := Chr(CurrentBoard.Objects[Num].P1);
					end;
			end;

			if (Num = 0) and not ZZTInGame then
				begin
					ZZTFrameBuffer[Y,X].Chr := ' ';
					ZZTFrameBuffer[Y,X].Attr := 0;
				end;
		end;

	procedure ExecObject(Num: byte);
		var X, Y: byte;
			Code: byte;
			Attr: byte;
		begin
			X := CurrentBoard.Objects[Num].X-1;
			Y := CurrentBoard.Objects[Num].Y-1;

			if (X > 59) or (Y > 24) then
				exit;

			Code := CurrentBoard.Map[Y,X].Code;
			Attr := CurrentBoard.Map[Y,X].Color;

			if Code = 0 then {The object was Zapped. Kill it.}
				CurrentBoard.Objects[Num].X := 255;

			if (Code < $3E) and (@ZZT_FUNC_TABLE[Code] <> nil) then
				ZZT_FUNC_TABLE[Code](Num,ZZT_OBJ_STEP);
		end;

	procedure ZZTTeleportPlayer(X,Y: byte; Board: word);
		var
			OldCode, OldColor: word;
			Target: word;
		begin
{			CurrentBoard.Map[Y-1,X-1].Code := CurrentBoard.Objects[0].Uc;
			CurrentBoard.Map[Y-1,X-1].Color := CurrentBoard.Objects[0].Ut;}

			OldCode := CurrentBoard.Objects[0].Uc;
			OldColor := CurrentBoard.Objects[0].Ut;

			SaveZZTBoard(CurrentBoardNumber);
			LoadZZTBoard(Board);

			with CurrentBoard.Objects[0] do
				begin
					CurrentBoard.Map[Y-1,X-1].Code := Uc;
					CurrentBoard.Map[Y-1,X-1].Color := Ut;
				end;

			if X = 255 then {X = 255 : stay on default place }
				begin
					Target := Y;

					X := CurrentBoard.Objects[0].X;
					Y := CurrentBoard.Objects[0].Y;

					if Target = 255 then {Y = 255 : go to similar place, if possible}
						begin
							Target := ZZT_ObjOfType(OldCode, OldColor, 0);
							if Target <> $FFFF then
								begin
									X := CurrentBoard.Objects[Target].X;
									Y := CurrentBoard.Objects[Target].Y;
								end;
						end;
				end;

			CurrentBoard.Objects[0].X := X;
			CurrentBoard.Objects[0].Y := Y;

			CurrentBoard.Objects[0].Uc := CurrentBoard.Map[Y-1,X-1].Code;
			CurrentBoard.Objects[0].Ut := CurrentBoard.Map[Y-1,X-1].Color;

			CurrentBoard.Map[Y-1,X-1].Code := $04;
			CurrentBoard.Map[Y-1,X-1].Color := $1F;

			ZZTBoardToLoad := $FFFF;
		end;

	procedure ZZTCheat(Cheat: string);
		var i : byte;
		begin
			for i := 1 to Length(Cheat) do
				Cheat[i] := UpCase(Cheat[i]);

			if Cheat = 'ZAP' then
				ZZTZap(CurrentBoard.Objects[0].X-1,CurrentBoard.Objects[0].Y-1);
		end;

	procedure ZZTZap(X,Y: byte);
		begin
			if Y <> 0 then
				CurrentBoard.Map[Y-1,X].Code := 0;
			if Y < 25 then
				CurrentBoard.Map[Y+1,X].Code := 0;
			if X <> 0 then
				CurrentBoard.Map[Y,X-1].Code := 0;
			if X < 59 then
				CurrentBoard.Map[Y,X+1].Code := 0;
		end;

	procedure ZZTStep;
		var i : word;
		begin
			if not ZZTTextVisible and
			   (ZZTKey <> ZZT_KEY_NONE) then
				ZZTPaused := False;

			if ZZTPaused then
				exit;

			Inc(ZZTGlobalTimer);

			for i:=0 to CurrentBoard.Info.ObjCount do
				ExecObject(i);

			if ZZTBoardToLoad < WorldHeader.BoardCount then {Teleported to another board?}
				begin
					ZZTTeleportPlayer(ZZTNewX,ZZTNewY,ZZTBoardToLoad);
					ZZTBoardToLoad := $FFFF;
				end;

			ZZTKey := ZZT_KEY_NONE;
		end;

	procedure ZZTDraw;
		var i,j:word;
		begin
			FillChar(ZZTFrameBuffer,SizeOf(ZZTFrameBuffer),0);

			for i:=0 to 24 do
				for j:=0 to 59 do
					DisplayBoardChar(j,i,CurrentBoard.Map[i,j]);

			for i:=0 to CurrentBoard.Info.ObjCount do
				DisplayObject(i);
		end;

Begin
	ZZTRunning := False;
	ZZTInGame := False;
	ZZTPaused := False;
End.