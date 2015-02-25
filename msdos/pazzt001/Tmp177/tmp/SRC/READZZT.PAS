program ReadZZT;
	uses Crt;

	const
		ZZT_MAX_OBJECTS = 255;
		ZZT_MAX_PROGSIZE = 32*1024;

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
						'<^>V',   {Arma girat¢ria}
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

	type
		String20 = string[20];
		String34 = string[34];
		String58 = string[58];

		ZZTChar=packed record
					Code:byte;
					Color:byte;
				end;

		ZZTHeader = packed record
						Signature:word;
						BoardCount:word;
						Ammo:word;
						Gems:word;
						Keys:array[0..6] of boolean;
						Health:word;
						StartBoard:word;
						Torches:word;
						TorchCycles:word;
						EnergCycles:word;
						Padding1:word;
						Score:word;
						Title:String20;
						Flags:array[0..9] of String20;
						TimeLeft:word;
						Padding2:word;
						SaveGame:boolean;
						Padding3:array[$10A..$200] of byte;
					end;

		ZZTBoardHeader= packed record
							BoardSize:word;
							Title:String34;
							Padding:array[0..15] of byte;
						end;

		ZZTBoardMap=array[0..24,0..59] of ZZTChar;

		ZZTBoardInfo=packed record
						MaxShots:byte;
						Darkness:boolean;
						BoardNorth:byte;
						BoardSouth:byte;
						BoardWest:byte;
						BoardEast:byte;
						ReEnterZap:boolean;
						Message:String58;
						Padding1:word;
						TimeLimit:word;
						Padding2:array[0..15] of byte;
						ObjCount:word;
					 end;

		ZZTObjHeader=packed record
						X,Y:byte;
						XStep,YStep:word;
						Cycle:word;
						P1,P2,P3:byte;
						P4:longint;
						Uc,Ut:byte;
						Ptr:longint;
						CurrIns:word;
						Length:word;
						Padding:array[0..7] of byte;
					 end;

		ZZTBoard=record
					Header:ZZTBoardHeader;
					Map:ZZTBoardMap;
					Info:ZZTBoardInfo;
					Objects:array[0..Pred(ZZT_MAX_OBJECTS)] of ZZTObjHeader;
					Programs:array[0..Pred(ZZT_MAX_OBJECTS)] of PChar;
					ProgBuffer:PChar;
				 end;

	var F:file;
		Header:ZZTHeader;
		Board:ZZTBoard;
		i:word;
		S:string;

	procedure ReadHeader;
		begin
			BlockRead(F,Header,SizeOf(Header));
		end;

	procedure ShowHeader;
		var i:byte;
		begin
			Writeln('Assinatura: ',Header.Signature);
			Writeln('No. de Fases: ',Header.BoardCount);
			Writeln('Muniá∆o: ',Header.Ammo);
			Writeln('Gemas: ',Header.Gems);

			Write('Chave Azul: ',Header.Keys[0]);
			Write(' Chave Verde: ',Header.Keys[1]);
			Write(' Chave Ciano: ',Header.Keys[2]);
			Writeln(' Chave Vermelha: ',Header.Keys[3]);

			Write('Chave P£rpura: ',Header.Keys[4]);
			Write(' Chave Amarela: ',Header.Keys[5]);
			Writeln(' Chave Branca: ',Header.Keys[6]);

			Writeln('Sa£de: ',Header.Health);
			Writeln('Fase Inicial: ',Header.StartBoard);
			Writeln('Tochas: ',Header.Torches);
			Writeln('Duraá∆o Tocha: ',Header.TorchCycles);
			Writeln('Duraá∆o Energizador: ',Header.EnergCycles);

			Writeln('Pontos Iniciais: ',Header.Score);
			Writeln('Nome do Jogo: ',Header.Title);

			for i:=0 to 9 do
				begin
					Write('Flag ',i,':',Header.Flags[i]);
					if i mod 2 = 1 then
						Writeln
					else
						GotoXY(40,WhereY);
				end;

			Writeln('Tempo Restante: ',Header.TimeLeft);
			Writeln('SaveGame: ',Header.SaveGame);
		end;

	procedure DecodeBoardMap;
		type
			CodeRec=packed record
						Len,Code,Color:byte;
					end;
		var
			Code:CodeRec;
			CharCounter:integer;
			i:byte;
			Dest:^Byte;
		begin
			Dest:=Addr(Board.Map);
			CharCounter:=60*25;
			while CharCounter > 0 do
				begin
					BlockRead(F,Code,SizeOf(Code));
					for i:=0 to Pred(Code.Len) do
						begin
							Dest^:=Code.Code;
							Inc(Dest);
							Dest^:=Code.Color;
							Inc(Dest);
							Dec(CharCounter);
						end;
				end;
		end;

	procedure ReadObjects;
		var Ptr:PChar;
			i:byte;
		begin
			Ptr:=Board.ProgBuffer;
			for i:=0 to Board.Info.ObjCount do
				begin
					BlockRead(F,Board.Objects[i],SizeOf(Board.Objects[i]));

					if Board.Objects[i].Length > 10000 then
						Board.Objects[i].Length := 0;

					BlockRead(F,Ptr^,Board.Objects[i].Length);

					Board.Programs[i]:=Ptr;
					Inc(Ptr,Board.Objects[i].Length);
				end;
		end;

	procedure ReadBoard;
		begin
			BlockRead(F,Board.Header,SizeOf(Board.Header));

			DecodeBoardMap;

			BlockRead(F,Board.Info,SizeOf(Board.Info));

			ReadObjects;
		end;

	procedure DisplayBoardChar(X,Y: byte; Data: ZZTChar);
		begin
			if Data.Code < $2F then
				begin
					Mem[$B800:((Y*80)+X)*2]:=Ord(ZZT_CODE_TABLE[Data.Code][1]);
					Mem[$B800:((Y*80)+X)*2+1]:=Data.Color;
				end
			else if Data.Code < $3E then
				begin
					Mem[$B800:((Y*80)+X)*2]:=Data.Color;
					Mem[$B800:((Y*80)+X)*2+1]:=Ord(ZZT_CODE_TABLE[Data.Code][1]);
				end
			else
				begin
					Mem[$B800:((Y*80)+X)*2]:=Data.Code;
					Mem[$B800:((Y*80)+X)*2+1]:=Data.Color;
				end;
		end;

	procedure ShowBoard;
		var i,j:byte;
		begin
			Writeln('Tamanho: ',Board.Header.BoardSize);
			Writeln('T°tulo: ',Board.Header.Title);

			Writeln('Pressione enter para visualizar o mapa');
			Readln;

			ClrScr;
			for i:=0 to 24 do
				for j:=0 to 59 do
					DisplayBoardChar(j,i,Board.Map[i,j]);
			TextAttr:=$07;

			Readln;

			ClrScr;

			Writeln('M†ximo de tiros: ', Board.Info.MaxShots);
			Writeln('Escurid∆o: ', Board.Info.Darkness);

			Writeln('Sa°da Norte: ', Board.Info.BoardNorth);
			Writeln('Sa°da Sul: ', Board.Info.BoardSouth);
			Writeln('Sa°da Oeste: ', Board.Info.BoardWest);
			Writeln('Sa°da Leste: ', Board.Info.BoardEast);

			Writeln('Reentra quando zapeado: ', Board.Info.ReEnterZap);
			Writeln('Mensagem: ', Board.Info.Message);

			Writeln('Limite de Tempo: ', Board.Info.TimeLimit);
			Writeln('Quantidade de Objetos: ', Board.Info.ObjCount);
		end;

	procedure ShowObject;
		var StObj,EndObj,i:byte;
		begin
			Write('N£mero do objeto inicial (0 a ',Board.Info.ObjCount,'): ?'+#8);
			Readln(StObj);

			Write('N£mero do objeto final (',StObj,' a ',Board.Info.ObjCount,'): ?'+#8);
			Readln(EndObj);

			for i:=StObj to EndObj do
				with Board.Objects[i] do
					begin
						Writeln('Objeto ',i);
						Writeln('X: ',X);
						Writeln('Y: ',Y);
						Writeln('Passo X: ',XStep);
						Writeln('Passo Y: ',YStep);
						Writeln('Ciclo: ',Cycle);
						Writeln('P1: ',P1,' P2: ',P2,' P3: ',P3,' P4: ',P4);
						Writeln('Instruá∆o atual: ',CurrIns);
						Writeln('Tamanho total: ',Length);

						if i <> EndObj then
							Readln;
					end;
		end;

	procedure ShowProgram;
		var ProgNum:byte;
			Ptr:PChar;
			Cnt:word;
			LineCtrl:byte;
		begin
			Write('N£mero do objeto: ?'+#8);
			Readln(ProgNum);

			Ptr:=Board.Programs[ProgNum];
			Cnt:=Board.Objects[ProgNum].Length;
			LineCtrl:=20;

			while Cnt <> 0 do
				begin
					case Ptr^ of
						#13:begin
								Writeln;
								Dec(LineCtrl);
								if LineCtrl = 0 then
									begin
										LineCtrl:=20;
										Writeln;
										Writeln('-- mais --');
										Readln;
									end;
							end;
					else
						Write(Ptr^);
					end;
					Inc(Ptr);
					Dec(Cnt);
				end;
		end;

	{$L 8x16.OBJ}
	procedure VGA_Font8x16;external;

	var VGA_Old_Font: Pointer;

	procedure LoadVGAFont(Font: Pointer);
		var Segm, Offs: word;
		begin
			Segm := Seg(Font^);
			Offs := Ofs(Font^);

			asm
				push 	bp
				mov		ax, 1100h
				mov		es, [Segm]
				mov		bp, [Offs]
				mov		cx, 256
				mov		dx, 0
				mov		bl, 0
				mov		bh, 16
				int		10h
				pop		bp
			end;
		end;

	procedure SetupVideo;
		var Segm, Offs: word;
		begin
			TextMode(co80);

			{Salva a antiga fonte}
			asm
				push	bp
				mov		ax, 1130h
				mov		bh, 06h
				int		10h
				mov		ax, bp
				pop		bp
				mov		[Segm], es
				mov		[Offs], ax
			end;

			VGA_Old_Font := Ptr(Segm,Offs);

			{Ajusta a fonte para 8x16}
			asm
				push	bp
				mov		ax, 1202h
				mov		bx, 0030h
				int		10h
				pop		bp
			end;

			TextMode(co80);

{			Offs := Port[$3DA]; {Coloca $3C0 em modo de leitura}
{			Port[$3C0] := $10;
			Port[$3C0] := Port[$3C1] or $40;}
			Port[$3C4] := $01;
			Port[$3C5] := $01;{     -- char width of 8}
			Port[$3C2] := $63;{     -- use 25.175MHz dotclock}
			Offs := Port[$3DA];{       -- reset attrib control}
			Port[$3C0] := $33;
			Port[$3C0] := $00;{    -- reset}

			{Configura a fonte nova}
			LoadVGAFont(Addr(VGA_Font8x16));
		end;

	procedure FinishVideo;
		begin
			{Ajusta a fonte para 8x16}
			asm
				push	bp
				mov		ax, 1202h
				mov		bx, 0030h
				int		10h
				pop		bp
			end;
			TextMode(co80);

			{Restaura a antiga fonte}
			LoadVGAFont(VGA_Old_Font);
		end;

Begin
	SetupVideo;

	TextAttr:=$07;
	ClrScr;

	Assign(F,'TOWN.ZZT');
{	Assign(F,'E:\TMP175\ZZTGAME\ENIGMA.ZZT');}
	Reset(F,1);

	GetMem(Board.ProgBuffer,ZZT_MAX_PROGSIZE);

	ReadHeader;

	ShowHeader;

	Readln;

	i := 0;
	while i <> Header.BoardCount+1 do
		begin
			ReadBoard;

			ShowBoard;

			S:=' ';
			while (S <> '') do
				begin
					Writeln;
					Writeln('Digite "Q" para sair, "O" para visualizar objetos,');
					Writeln('"P" para visualizar programas,');
					Writeln('ou enter para continuar.');
					Readln(S);
					if S <> '' then
						begin
							if UpCase(S[1]) = 'Q' then
								begin
									i := Header.BoardCount+1;
									S := '';
								end
							else if UpCase(S[1]) = 'O' then
								begin
									ShowObject;
								end
							else if UpCase(S[1]) = 'P' then
								begin
									ShowProgram;
								end;
						end
					else
						begin
							Inc(i);
						end;
				end;
		end;

	Writeln(SizeOf(ZZTObjHeader));

	Close(F);

	FinishVideo;
End.