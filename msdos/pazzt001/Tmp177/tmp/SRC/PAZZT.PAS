program Test;
	uses
		Runtime, Crt, Objects, Drivers, Memory, HistList, Views, Menus, App, StdDlg,
		TpTimer, TextFuncs, TVZZT, ZZTLoad, ZZTRun, HVMM;
	type
		TTestApp=object(TApplication)
			LastTimer:longint;
			SidePanel:PPanel;
			PlayField:PZZTPlayField;
			TitlePanel:PZZTTitlePanel;
			procedure InitMenuBar; virtual;
			procedure InitStatusLine; virtual;
			procedure InitDesktop; virtual;
			procedure InitSidePanel; virtual;
			procedure ShowTitlePanel; virtual;
			procedure OpenWorld; virtual;
			procedure HandleEvent(var Event: TEvent); virtual;
			procedure Idle; virtual;
			constructor Init;
		end;

	var AppTest:TTestApp;

	procedure TTestApp.InitStatusLine;
		var
		  R: TRect;
		begin
		  GetExtent(R);
		  R.A.X := 60;
		  R.A.Y := R.B.Y - 1;
		  New(StatusLine, Init(R,
			NewStatusDef(0, $FFFF,
			  NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
			  StdStatusKeys(nil)), nil)));
		end;

	procedure TTestApp.InitMenuBar;
		var
		  R: TRect;
		begin
		  GetExtent(R);
		  R.A.X := 60;
		  R.B.Y := R.A.Y + 1;
		  MenuBar := New(PMenuBar, Init(R, NewMenu(
			NewSubMenu('~F~ile', hcNoContext, NewMenu(
			  StdFileMenuItems(nil)),nil))));
		end;

	procedure TTestApp.InitDesktop;
		var
			R: TRect;
		begin
			GetExtent(R);
{			Inc(R.A.Y);
			Dec(R.B.Y);}
			R.B.X := 60;
			New(Desktop, Init(R));
		end;

	constructor TTestApp.Init;
		begin
			TApplication.Init;
			InitSidePanel;
			if SidePanel <> nil then Insert(SidePanel);
			ShowTitlePanel;
			PlayField := nil;
			LastTimer := ReadTimer;
		end;

	procedure TTestApp.InitSidePanel;
		var
			R: TRect;
		begin
			GetExtent(R);
			Inc(R.A.Y);
			Dec(R.B.Y);
			R.A.X := 60;
			New(SidePanel, Init(R, ' '));
		end;

	procedure TTestApp.ShowTitlePanel;
		var R: TRect;
		begin
			GetExtent(R);
			Inc(R.A.Y);
			Dec(R.B.Y);
			R.A.X := 60;

			Dispose(SidePanel, Done);
			SidePanel := New(PZZTTitlePanel,Init(R));
			Insert(SidePanel);
		end;

	procedure TTestApp.OpenWorld;
		var FileName: string;
			R: TRect;
		begin
			FileName := '*.ZZT';
			if ExecuteDialog(New(PZZTWorldDialog,Init('*.ZZT','Open new World','',fdOpenButton,0)),@FileName) <> cmCancel then
				begin
					LoadZZTWorld(FileName);
					ZZTReset;
					if PlayField <> nil then
						begin
							Dispose(PlayField,Done);
							PlayField := nil;
						end;
					R.A.X := 0;
					R.A.Y := 0;
					R.B.X := 60;
					R.B.Y := 25;
					PlayField := New(PZZTPlayField,Init(R,ZZTFrameBuffer));
					InsertWindow(Pointer(PlayField));
					ShowTitlePanel;
				end;
		end;

	procedure TTestApp.HandleEvent(var Event: TEvent);
		begin
			inherited HandleEvent(Event);

			case Event.What of
				evCommand:
					case Event.Command of
						cmOpen:
							OpenWorld;
						cmZZT_Play:
							ZZTStart;
					end;
				evKeyDown:
					case Event.KeyCode of
						kbUp: ZZTKey := ZZT_KEY_UP;
						kbDown: ZZTKey := ZZT_KEY_DOWN;
						kbLeft: ZZTKey := ZZT_KEY_LEFT;
						kbRight: ZZTKey := ZZT_KEY_RIGHT;
						kbAltP:
							if ZZTInGame then
								ZZTPaused := True
							else
								Message(Application, evCommand, cmZZT_Play, nil);
					else
						case Event.CharCode of
							'P','p':
								if ZZTInGame then
									ZZTPaused := True
								else
									Message(Application, evCommand, cmZZT_Play, nil);
							'?':TVZZTCheat;
							'W','w':
								if not ZZTInGame then
									OpenWorld;
						end;
					end;
			end;
		end;

	procedure TTestApp.Idle;
		var CurrentTimer: longint;
		begin
			if ZZTRunning then
				begin
					CurrentTimer := ReadTimer;

					if ElapsedTime(LastTimer, CurrentTimer) >= 100 then
						begin
							ZZTStep;
							ZZTDraw;

							if PlayField <> nil then
								PlayField^.Draw;

							LastTimer := CurrentTimer;
						end;
				end;
		end;

Begin
	InitializeTimer;
	InitHVMM;
	TextMode80x25_Char8;
	AppTest.Init;
	AppTest.Run;
	RestoreTextMode;
	DoneHVMM;
	RestoreTimer;
End.