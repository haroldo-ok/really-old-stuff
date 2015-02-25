unit TVZZT;
interface
	uses
		Dos, Objects, Drivers, Memory, HistList, Views, Menus, App, WinDos,
		Dialogs, StdDlg;

	const
		cmZZT_Play = 1000;

	type
		PPanel = ^TPanel;
		TPanel = object(TGroup)
			Pattern: Char;
			constructor Init(var Bounds: TRect; APattern: Char);
			constructor Load(var S: TStream);
			procedure Draw; virtual;
			function GetPalette: PPalette; virtual;
			procedure Store(var S: TStream);
		end;

		PZZTWorldFileList = ^TZZTWorldFileList;
		TZZTWorldFileList = object(TFileList)
			function GetText(Item: Integer; MaxLen: Integer): String; virtual;
			constructor Init(var Bounds: TRect; AScrollBar: PScrollBar);
		end;

		PZZTWorldDialog  = ^TZZTWorldDialog;
		TZZTWorldDialog  = object(TFileDialog)
			constructor Init(AWildCard: String; const ATitle,
							 InputName: String; AOptions: Word; HistoryId: Byte);
		private
			procedure ReadDirectory;
		end;

		PZZTPlayField = ^TZZTPlayField;
		TZZTPlayField = object(TGroup)
			FrameBuffer: ^Word;
			constructor Init(Bounds: TRect; var FrameBuf);
			procedure Draw; virtual;
		end;

		PZZTTitlePanel = ^TZZTTitlePanel;
		TZZTTitlePanel = object(TPanel)
			constructor Init(Bounds: TRect);
			procedure Draw; virtual;
		end;

		PLineIndex = ^TLineIndex;
		TLineIndex = array[0..8191] of PChar;

		PZZTTextWindow = ^TZZTTextWindow;
		TZZTTextWindow = object(TDialog)
			Buf: PChar;
			ScrollBar: PScrollBar;
			LineCount: word;
			LineIndex: PLineIndex;
			Result: string;
			constructor Init(TxtBuf: PChar; WinTitle: string);
			destructor Done; virtual;
			procedure Draw; virtual;
			procedure HandleEvent(var Event: TEvent); virtual;
		end;

	procedure TVZZTCheat;
	function ShowZZTTextWindow(Title: string): string;

implementation

	uses Strings, ZZTLoad, ZZTRun, MsgBox, InfoBar, Utils;

	const
		PaZZTLogo:array[0..2] of string = ('   - - - - -    ',
										   '     PaZZT      ',
										   '   - - - - -    ');

	function GetCurDir: String;
		var CurDir: String;
		begin
			GetDir(0, CurDir);
			if Length(CurDir) > 3 then
				begin
					Inc(CurDir[0]);
					CurDir[Length(CurDir)] := '\';
				end;
			GetCurDir := CurDir;
		end;
 
	{************************ TPanel ************************}

	constructor TPanel.Init(var Bounds: TRect; APattern: Char);
		begin
			TView.Init(Bounds);
			GrowMode := gfGrowHiX + gfGrowHiY;
			Pattern := APattern;
		end;

	constructor TPanel.Load(var S: TStream);
		begin
			TView.Load(S);
			S.Read(Pattern, SizeOf(Pattern));
		end;

	procedure TPanel.Draw;
		var
			B: TDrawBuffer;
		begin
			MoveChar(B, Pattern, GetColor($01), Size.X);
			WriteLine(0, 0, Size.X, Size.Y, B);
			inherited Draw;
		end;

	function TPanel.GetPalette: PPalette;
		const
			P: String[Length(CDialog)] = CDialog;
		begin
			GetPalette := @P;
		end;

	procedure TPanel.Store(var S: TStream);
		begin
			TView.Store(S);
			S.Write(Pattern, SizeOf(Pattern));
		end;

	{************************ TZZTWorldDialog ************************}

	constructor TZZTWorldDialog.Init(AWildCard: String; const ATitle,
							   InputName: String; AOptions: Word; HistoryId: Byte);
		var Control: PView;
			R: TRect;
			Opt: Word;
		begin
			R.Assign(15,1,64,20);
			TDialog.Init(R, ATitle);
			Options := Options or ofCentered;
			WildCard := AWildCard;

			R.Assign(2,2,31,3);
			FileName := New(PFileInputLine, Init(R, 79));
			FileName^.Data^ := WildCard;
			Insert(FileName);
			R.Assign(1,1,3+CStrLen(InputName),1);
			Control := New(PLabel, Init(R, InputName, FileName));
			Insert(Control);
			R.Assign(31,2,34,3);
			Control := New(PHistory, Init(R, FileName, HistoryId));
			Insert(Control);

			R.Assign(46,4,47,13);
			Control := New(PScrollBar, Init(R));
			Insert(Control);
			R.Assign(2,4,46,13);
			FileList := New(PZZTWorldFileList, Init(R, PScrollBar(Control)));
			Insert(FileList);
			R.Assign(1,3,8,4);
			Control := New(PLabel, Init(R, '~F~iles', FileList));
			Insert(Control);

			R.Assign(2,14,13,16);
			Opt := bfDefault;
			if AOptions and fdOpenButton <> 0 then
				begin
					Insert(New(PButton, Init(R, '~O~pen', cmFileOpen, Opt)));
					Opt := bfNormal;
					Inc(R.A.X,12); Inc(R.B.X,12);
				end;
			if AOptions and fdOkButton <> 0 then
				begin
					Insert(New(PButton, Init(R, 'O~K~', cmFileOpen, Opt)));
					Opt := bfNormal;
					Inc(R.A.X,12); Inc(R.B.X,12);
				end;
			if AOptions and fdReplaceButton <> 0 then
				begin
					Insert(New(PButton, Init(R, '~R~eplace',cmFileReplace, Opt)));
					Opt := bfNormal;
					Inc(R.A.X,12); Inc(R.B.X,12);
				end;
			if AOptions and fdClearButton <> 0 then
				begin
					Insert(New(PButton, Init(R, '~C~lear',cmFileClear, Opt)));
					Opt := bfNormal;
					Inc(R.A.X,12); Inc(R.B.X,12);
				end;

			R.Assign(36,14,47,16);
			if AOptions and fdHelpButton <> 0 then
				begin
					Insert(New(PButton, Init(R, 'Help',cmHelp, bfNormal)));
					Dec(R.A.X,12); Dec(R.B.X,12);
				end;
			Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
			Dec(R.A.X,12); Dec(R.B.X,12);

			R.Assign(1,16,48,18);
			Control := New(PFileInfoPane, Init(R));
			Insert(Control);

			SelectNext(False);

			if AOptions and fdNoLoadDir = 0 then ReadDirectory;
		end;

	procedure TZZTWorldDialog.ReadDirectory;
		begin
			FileList^.ReadDirectory(WildCard);
			Directory := NewStr(GetCurDir);
		end;

	{************************ TZZTWorldFileList ************************}

	function TZZTWorldFileList.GetText(Item: Integer; MaxLen: Integer): String;
		type
			PSearchRec = ^TSearchRec;
		var S: String;
			SR: PSearchRec;
			Path: String;
		begin
			SR := PSearchRec(List^.At(Item));
			S := SR^.Name;
			if SR^.Attr and faDirectory <> 0 then
				begin
					S[Length(S)+1] := '\';
					Inc(S[0]);
				end;

{			Path := FExpand(PFileDialog(Owner)^.Directory^+S);

			while Length(S) < 16 do
				S := S + ' ';
			S := S + #179 + ' ';

			if SR^.Attr and faDirectory <> 0 then
				begin
				end
			else
				begin
				end;}

			GetText := S;
		end;

	constructor TZZTWorldFileList.Init(var Bounds: TRect; AScrollBar: PScrollBar);
		begin
			TSortedListBox.Init(Bounds, 1, AScrollBar);
		end;

	{************************ TZZTPlayField ************************}

	constructor TZZTPlayField.Init(Bounds: TRect; var FrameBuf);
		begin
			TView.Init(Bounds);
			GrowMode := gfGrowHiX + gfGrowHiY;
			FrameBuffer := Addr(FrameBuf);
		end;

	procedure TZZTPlayField.Draw;
		var
			P: ^Word;
			i: byte;
			Buf: array[0..59,0..1] of byte;
		begin
			P := Pointer(FrameBuffer);

			for i := 0 to 24 do
				begin
					WriteLine(0, i, Size.X, 1, P^);
					Inc(P,60);
				end;

			if CurrentBoard.Info.Message <> '' then
				begin
					FillChar(Buf, SizeOf(Buf), 0);
					for i := 1 to Length(CurrentBoard.Info.Message) do
						begin
							Buf[i,0] := Ord(CurrentBoard.Info.Message[i]);
							Buf[i,1] := $02;
						end;
					WriteLine((58+Length(CurrentBoard.Info.Message)) div 2,
							  24,
							  Length(CurrentBoard.Info.Message),
							  1, Buf);
				end;
		end;

	{************************ TZZTTitlePanel ************************}
	constructor TZZTTitlePanel.Init(Bounds: TRect);
		var
			Lbl: PLabel;
			Button: PButton;
			Scrl: PScrollBar;
			R: TRect;
		begin
			TPanel.Init(Bounds,' ');

			GetExtent(R);
			Inc(R.A.X,1);
			Dec(R.B.X,2);
			Inc(R.A.Y,3);
			R.B.Y := R.A.Y + 2;

			Button := New(PButton,Init(R,'~W~orld',cmOpen,bfDefault));
			Insert(Button);
			Inc(R.A.Y, 2); 	Inc(R.B.Y, 2);

			if ZZTWorldLoaded then
				Lbl := New(PLabel,Init(R,' ' + WorldHeader.Title,nil))
			else
				Lbl := New(PLabel,Init(R,' ' + '**NONE**',nil));
			Insert(Lbl);
			Inc(R.A.Y, 2); 	Inc(R.B.Y, 2);

			Button := New(PButton,Init(R,'~P~lay!',cmZZT_Play,bfDefault));
			Insert(Button);
			Inc(R.A.Y, 2); 	Inc(R.B.Y, 2);

			Button := New(PButton,Init(R,'~R~estore Game',0,bfDefault));
			Insert(Button);
			Inc(R.A.Y, 2); 	Inc(R.B.Y, 2);

			Button := New(PButton,Init(R,'~Q~uit',0,bfDefault));
			Insert(Button);
			Inc(R.A.Y, 3); 	Inc(R.B.Y, 3);

			Button := New(PButton,Init(R,'~A~bout PaZZT',0,bfDefault));
			Insert(Button);
			Inc(R.A.Y, 2); 	Inc(R.B.Y, 2);

			Button := New(PButton,Init(R,'~H~igh Scores',0,bfDefault));
			Insert(Button);
			Inc(R.A.Y, 2); 	Inc(R.B.Y, 2);

			Button := New(PButton,Init(R,'World ~E~ditor',0,bfDefault));
			Insert(Button);
			Inc(R.A.Y, 2); 	Inc(R.B.Y, 2);

			Inc(R.A.Y); Inc(R.A.X);
			Scrl := New(PScrollBar,Init(R));
			Scrl^.Max := 9;
			Scrl^.Value := 5;
			Insert(Scrl);
			Dec(R.A.Y); Dec(R.B.Y); Dec(R.A.X);
			Lbl := New(PLabel,Init(R,'~-~  Game Speed  ~+~',Scrl));
			Insert(Lbl);
			Inc(R.A.Y, 2); 	Inc(R.B.Y, 3);
		end;

	procedure TZZTTitlePanel.Draw;
		var
			Buf: TDrawBuffer;
			Color1, Color2: byte;
		begin
			inherited Draw;

			{Draws the PaZZT logo}
			Color1 := (GetColor($01) and $F0) or (GetColor($04) shr 4);
			Color2 := (GetColor($04) and $F0) or $0F;

			MoveStr(Buf, PaZZTLogo[0], Color1);
			WriteLine(2, 0, 15, 1, Buf);
			MoveStr(Buf, PaZZTLogo[1], Color2);
			WriteLine(2, 1, 15, 1, Buf);
			MoveStr(Buf, PaZZTLogo[2], Color1);
			WriteLine(2, 2, 15, 1, Buf);
		end;

	{************************ TZZTTextWindow ************************}

	constructor TZZTTextWindow.Init(TxtBuf: PChar; WinTitle: string);
		var R: TRect;
			C: PChar;
			NewLine: boolean;
			i: integer;
		begin
			R.Assign(15,1,64,20);
			TWindow.Init(R,WinTitle,0);

			Options := Options or ofCenterX or ofCenterY;
			Flags := wfMove or wfClose;

			Buf := TxtBuf;

			C := Buf;
			LineCount := 0;
			while C^ <> #0 do
				begin
					if C^ = #13 then
						begin
							Inc(LineCount);
							Inc(C);
							if C^ = #10 then
								Inc(C);
							NewLine := True;
						end
					else if C^ = #10 then
						begin
							Inc(LineCount);
							Inc(C);
							if C^ = #13 then
								Inc(C);
							NewLine := True;
						end
					else
						begin
							NewLine := False;
							Inc(C);
						end;
				end;

			if not NewLine then
				Inc(LineCount);

			GetMem(LineIndex, SizeOf(PChar)*LineCount);
			FillChar(LineIndex^, SizeOf(PChar)*LineCount, #0);

			C := Buf;
			i := 0;
			LineIndex^[i] := C;
			while C^ <> #0 do
				begin
					if C^ = #13 then
						begin
							Inc(i);
							Inc(C);
							if C^ = #10 then
								Inc(C);
							LineIndex^[i] := C;
						end
					else if C^ = #10 then
						begin
							Inc(i);
							Inc(C);
							if C^ = #13 then
								Inc(C);
							LineIndex^[i] := C;
						end
					else
						Inc(C);
				end;

			ScrollBar := StandardScrollBar(sbVertical or sbHandleKeyboard);
			ScrollBar^.Max := Pred(LineCount);
			ScrollBar^.Value := 0;
			ScrollBar^.SetStep(18,1);
			Insert(ScrollBar);

			Result := '';
		end;

	destructor TZZTTextWindow.Done;
		begin
			FreeMem(LineIndex, SizeOf(PChar)*LineCount);
			inherited Done;
		end;

	procedure TZZTTextWindow.Draw;
		var X,Y: word;
			Line: longint;
			R: TRect;
			C: PChar;
			S: string[48];
			i: byte;
			Attr: byte;
		begin
			inherited Draw;

			GetExtent(R);
			R.Grow(-1,-1);
			X := R.A.X;
			Y := R.A.Y;

			Line := ScrollBar^.Value - ((R.A.Y+R.B.Y) div 2) + 1;

			FillChar(S[1],47,'°');
			S[0] := #47;

			while (Line < -1) and (Y <> R.B.Y) do
				begin
					WriteStr(X,Y,S,1);
					Inc(Line);
					Inc(Y);
				end;

			if (Line = -1) and (Y <> R.B.Y) then
				begin
					Inc(Line);
					Inc(Y);
				end;

			while (Line < LineCount) and (Y <> R.B.Y) do
				begin
					X := R.A.X + 1;
					FillChar(S[1],46,' ');
					S[0] := #46;

					Attr := 6;
					C := LineIndex^[Line];
					i := 1;
					if C <> nil then
						begin
							if C^ = '$' then
								begin
									Inc(C);
									Attr := $FF; { $FF is a flag that tells "center text"}
								end;

							if C^ = '!' then
								begin
									Inc(C);
									while not (C^ in [#0,#10,#13,';']) do
										Inc(C);

									if C^ = ';' then
										Inc(C);

									S[0] := #44;

									Attr := $FE; { $FE is a flag that tells "use hipertext link"}
								end;

							while (not (C^ in [#0,#10,#13])) and
								  (i < 46) do
								begin
									S[i] := C^;
									Inc(C);
									Inc(i);
								end;

							if Attr = $FF then
								begin
									S[0] := Chr(i-1);
									Inc(X,(46-Length(S)) div 2);
									WriteStr(X,Y,S,2);
								end
							Else
							if Attr = $FE then
								begin
									WriteStr(X,Y,#16,3);
									WriteStr(X+2,Y,S,2);
								end
							else
								WriteStr(X,Y,S,Attr);
						end;

					Inc(Line);
					Inc(Y);
				end;

			X := R.A.X;
			if (Line = LineCount) and (Y <> R.B.Y) then
				begin
					Inc(Line);
					Inc(Y);
				end;

			FillChar(S[1],47,'°');
			S[0] := #47;
			while Y <> R.B.Y do
				begin
					WriteStr(X,Y,S,1);
					Inc(Y);
				end;

			WriteStr(X,((R.A.Y+R.B.Y) div 2),'¯',3);
			WriteStr(R.B.X-1,((R.A.Y+R.B.Y) div 2),'®',3);
		end;

	procedure TZZTTextWindow.HandleEvent(var Event: TEvent);
		var C: PChar;
		begin
			case Event.What of
				evKeyDown:
					case Event.KeyCode of
						kbHome: ScrollBar^.SetValue(0);
						kbEnd: ScrollBar^.SetValue(ScrollBar^.Max);
						kbEnter:
							begin
								Result := '';
								C := LineIndex^[ScrollBar^.Value];
								If (C <> nil) and (C^ = '!') then
									begin
										Result := StrPas(C);
										Result := Copy(Result,2,Pos(';',Result)-2);
									end;

								EndModal(1);
							end;
					end;

				evBroadCast:
					case Event.Command of
						cmScrollBarChanged: Draw;
					end;
			end;
			inherited HandleEvent(Event);
		end;

	{************************ Various Functions ************************}

	type
		PProgressDialog = ^TProgressDialog;
		TProgressDialog = object(TDialog)
			InfoBar: PInfoBar;
			constructor Init(Heading: String; Max: Longint);
			procedure SetProgress(Position: longint);
		end;

	constructor TProgressDialog.Init(Heading: String; Max: Longint);
		var
			R: TRect;
			Rec: TInfoBarRec;
		begin
			R.Assign(14, 9, 65, 14);
			inherited Init(R,Heading);
			Options:= Options or ofCenterX or ofCenterY;
			Flags:= wfMove;

			{ start values for Text1, Text2 and Size }
			with Rec do
				begin
					Text1:= '0%';
					Text2:= '';
					Size := Max;
				end;

			R.Assign(5, 2, 46, 3);
			InfoBar:= New(PInfoBar, Init(R, @rec));
			Insert(InfoBar);

			SelectNext(False);
		end;

	procedure TProgressDialog.SetProgress(Position: longint);
		var
			Rec: TInfoBarRec;
		begin
			with Rec do
				begin
					if InfoBar^.Max <> 0 then
						Text1:= IntToStr(Position * 100 div InfoBar^.Max) + '%'
					else
						Text1:= '';
					Text2 := '';
					Size := Position;
				end;
			InfoBar^.Update(Addr(Rec));
		end;

	var ProgressDialog: PProgressDialog;

	procedure ZZTErrProc(Message: string);far;
		begin
			MessageBox(Copy(Message,1,38),nil,mfError or mfOkButton);
		end;

	procedure ZZTPrgssProc(Heading: string; Progress, Max: longint);far;
		begin
			if Max < 1 then
				begin
					Dispose(ProgressDialog, Done);
					ProgressDialog := nil;
				end;

			if (Max > 0) and (ProgressDialog = nil) then
				begin
					ProgressDialog := New(PProgressDialog,Init(Heading, Max));
					Application^.InsertWindow(ProgressDialog);
				end;

			if ProgressDialog <> nil then
				ProgressDialog^.SetProgress(Progress);
		end;

	procedure TVZZTCheat;
		var Cheat: string;
		begin
			if not ZZTInGame then
				exit;

			ZZTPaused := True;

			Cheat := '';
			InputBox('Debug','Enter debug command:',Cheat,255);
			ZZTCheat(Cheat);

			ZZTPaused := False;
		end;

	function ShowZZTTextWindow(Title: string): string;
		var TxWindow: PZZTTextWindow;
		begin
			ZZTPaused := True;

			TxWindow := New(PZZTTextWindow,Init(TextBuffer,Title));
			Desktop^.ExecView(TxWindow);
			ShowZZTTextWindow := TxWindow^.Result;
			Dispose(TxWindow,Done);

			ZZTPaused := False;
		end;

Begin
	SetZZTErrorProc(Addr(ZZTErrProc));

	ProgressDialog := nil;
	SetZZTProgressProc(Addr(ZZTPrgssProc));

	SetZZTTextFunc(Addr(ShowZZTTextWindow));
End.