unit ZZTLoad;
interface
	const
		ZZT_MAX_OBJECTS = 255;
		ZZT_MAX_PROGSIZE = 32*1024;

		ZZT_MAX_TEXT = 16*1024;

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
						XStep,YStep:integer;
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

		ZZTErrorProc=procedure(Message: string);
		ZZTProgressProc=procedure(Heading: string; Progress, Max: longint);
		ZZTTextFunc=function(Title: string): string;

	var WorldHeader: ZZTHeader;
		CurrentBoard: ZZTBoard;
		CurrentBoardNumber: word;
		TextBuffer: PChar;
		TextBufferPos: word;
		TextBufferLines: word;
		ZZTWorldLoaded:boolean;
		ZZTTextVisible:boolean;

	procedure LoadZZTWorld(FileName: string);
	procedure DisposeZZTWorld;

	procedure LoadZZTBoard(Number: word);
	procedure SaveZZTBoard(Number: word);

	procedure SetZZTErrorProc(Proc:Pointer);
	procedure SetZZTProgressProc(Proc:Pointer);
	procedure SetZZTTextFunc(Proc:Pointer);

	procedure ClearZZTText;
	procedure WriteZZTTextLine(Text:string);
	function  ShowZZTText(Caption: string): string;

implementation
	uses Crt, HVMM, Utils;

	type
		WordArray=array[0..32000] of word;

	var F:file;
		i:word;
		S:string;
		BoardHandles:^WordArray;
		ZZTErrProc:ZZTErrorProc;
		ZZTPrgssProc:ZZTProgressProc;
		ZZTTxtFunc:ZZTTextFunc;

	procedure ReadHeader;
		begin
			BlockRead(F,WorldHeader,SizeOf(WorldHeader));
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
			Dest:=Addr(CurrentBoard.Map);
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
			Ptr:=CurrentBoard.ProgBuffer;
			for i:=0 to CurrentBoard.Info.ObjCount do
				begin
					BlockRead(F,CurrentBoard.Objects[i],SizeOf(CurrentBoard.Objects[i]));

					if CurrentBoard.Objects[i].Length > ZZT_MAX_PROGSIZE then
						CurrentBoard.Objects[i].Length := 0;

					BlockRead(F,Ptr^,CurrentBoard.Objects[i].Length);

					CurrentBoard.Programs[i]:=Ptr;
					Inc(Ptr,CurrentBoard.Objects[i].Length);
				end;
		end;

	procedure ReadBoard;
		var Err:byte;
		begin
			BlockRead(F,CurrentBoard.Header,SizeOf(CurrentBoard.Header));

			DecodeBoardMap;

			BlockRead(F,CurrentBoard.Info,SizeOf(CurrentBoard.Info));

			ReadObjects;
		end;

	procedure LoadZZTWorld(FileName: string);
		var i : word;
		begin
			if not FileExists(FileName) then
				begin
					if @ZZTErrProc <> nil then
						ZZTErrProc('File not found.');
					Exit;
				end;

			if ZZTWorldLoaded then
				DisposeZZTWorld;

			GetMem(CurrentBoard.ProgBuffer,ZZT_MAX_PROGSIZE);

			GetMem(TextBuffer, ZZT_MAX_TEXT);
			FillChar(TextBuffer^,ZZT_MAX_TEXT,#0);
			ClearZZTText;

			Assign(F,FileName);
			Reset(F,1);

			ReadHeader;

			GetMem(BoardHandles,WorldHeader.BoardCount*SizeOf(Word));

			for i := 0 to Pred(WorldHeader.BoardCount) do
				begin
					ReadBoard;

					if @ZZTPrgssProc <> nil then
						ZZTPrgssProc('Loading ZZT World',i,WorldHeader.BoardCount);
					Delay(10);

					BoardHandles^[i] := GetMemHVMM(SizeOf(ZZTBoard) + ZZT_MAX_PROGSIZE);

					if BoardHandles^[i] = $FFFF then
						if @ZZTErrProc <> nil then
							ZZTErrProc('Error loading board ' + IntToStr(i));

					WriteHVMM(BoardHandles^[i],CurrentBoard,0,SizeOf(ZZTBoard));
					WriteHVMM(BoardHandles^[i],CurrentBoard.ProgBuffer^,SizeOf(ZZTBoard),ZZT_MAX_PROGSIZE);
				end;
			ZZTPrgssProc('',0,0);

			ZZTWorldLoaded := True;
		end;

	procedure DisposeZZTWorld;
		var i : word;
		begin
			for i := 0 to Pred(WorldHeader.BoardCount) do
				FreeMemHVMM(BoardHandles^[i]);

			FreeMem(BoardHandles,WorldHeader.BoardCount*SizeOf(Word));
			FreeMem(CurrentBoard.ProgBuffer,ZZT_MAX_PROGSIZE);

			FreeMem(TextBuffer, ZZT_MAX_TEXT);

			ZZTWorldLoaded := False;
		end;

	procedure LoadZZTBoard(Number: word);
		begin
			ReadHVMM(BoardHandles^[Number],CurrentBoard,0,SizeOf(ZZTBoard));
			ReadHVMM(BoardHandles^[Number],CurrentBoard.ProgBuffer^,SizeOf(ZZTBoard),ZZT_MAX_PROGSIZE);
			CurrentBoardNumber := Number;
		end;

	procedure SaveZZTBoard(Number: word);
		begin
			WriteHVMM(BoardHandles^[Number],CurrentBoard,0,SizeOf(ZZTBoard));
			WriteHVMM(BoardHandles^[Number],CurrentBoard.ProgBuffer^,SizeOf(ZZTBoard),ZZT_MAX_PROGSIZE);
		end;

	procedure SetZZTErrorProc(Proc:Pointer);
		begin
			ZZTErrProc := ZZTErrorProc(Proc);
		end;

	procedure SetZZTProgressProc(Proc:Pointer);
		begin
			ZZTPrgssProc := ZZTProgressProc(Proc);
		end;

	procedure SetZZTTextFunc(Proc:Pointer);
		begin
			ZZTTxtFunc := ZZTTextFunc(Proc);
		end;

	procedure ClearZZTText;
		begin
			TextBuffer[0] := #0;
			TextBufferPos := 0;
			TextBufferLines := 0;
		end;

	procedure WriteZZTTextLine(Text:string);
		var C: PChar;
		begin
			if TextBufferPos >= ZZT_MAX_TEXT - 2 then
				exit;

			if TextBufferPos+Length(Text)+1 >= ZZT_MAX_TEXT then
				Text := Copy(Text,1,ZZT_MAX_TEXT-TextBufferPos-2);

			C := TextBuffer;
			Inc(C,TextBufferPos);

			if TextBufferPos <> 0 then
				begin
					C^ := #13;
					Inc(C);
					Inc(TextBufferPos);
				end;
			Move(Text[1],C^,Length(Text));
			Inc(C,Length(Text)+1);
			C^ := #00;

			Inc(TextBufferPos,Length(Text));
			Inc(TextBufferLines);
		end;

	function ShowZZTText(Caption: string): string;
		begin
			ShowZZTText := '';

			ZZTTextVisible := True;

			if @ZZTTxtFunc <> nil then
				ShowZZTText := ZZTTxtFunc(Caption);

			ZZTTextVisible := False;
		end;
Begin
	ZZTWorldLoaded := False;
	ZZTTextVisible := False;
	ZZTErrProc := nil;
	ZZTPrgssProc := nil;
	ZZTTxtFunc := nil;
End.