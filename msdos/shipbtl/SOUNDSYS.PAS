unit SoundSystem;
{Unidade SoundSystem: Interface de som}
{adaptado por Haroldo de Oliveira Pinheiro}
{a partir do exemplo EFFECTS.PAS do Midas Sound System}
interface
	uses crt, midas, sdevice, mplayer, modp, mtm, s3m, mfile, mmem, errors, mconfig;
	const
		FXCHANNELS = 4;
		MAXMUSCHANNELS = 8;
		FXRATE = 11025;
		modulePlayers : array[0..NUMMPLAYERS-1] of PModulePlayer =( @mpS3M, @mpMOD, @mpMTM );
	var fxChannel:integer;
		MP:PModulePlayer;
		SD:PSoundDevice;
		defAmplify : word;                  { default amplification }
		amplification : word;               { current amplification }
		masterVolume : word;                { music master volume }
		module : PmpModule;                 { current playing module }
	procedure InitSoundSystem;
	procedure DoneSoundSystem;
	function toASCIIZ(dest : PChar; str : string) : PChar;
	function LoadEffect(fileName:PChar;looping:integer):word;
	procedure FreeEffect(instHandle : word);
	procedure PlayEffect(instHandle : word; rate : longint; volume : word;	panning : integer);
	function NewModule(fileName:PChar):PmpModule;
	procedure StopModule(module : PmpModule);
implementation
	procedure ErrorExit(msg : string);
		begin
			WriteLn('Error: ', msg);
			midasClose;
			Halt;
		end;
	function toASCIIZ(dest : PChar; str : string) : PChar;
		var	spos, slen : integer;
			i : integer;
		begin
			spos := 0;                          { string position = 0 }
			slen := ord(str[0]);                { string length }
			while spos < slen do
				begin
					dest[spos] := str[spos+1];
					spos := spos + 1;
				end;
			dest[spos] := chr(0);               { put terminating 0 to end of string }
			toASCIIZ := dest;
		end;
	function LoadEffect(fileName:PChar;looping:integer):word;
		var	instHandle:word;
			error:integer;
			f:fileHandle;
			smpLength:longint;
			smpBuf:^byte;
		begin
			error := fileOpen(fileName, fileOpenRead, @f);
			if error <> OK then
				midasError(error);
			error := fileGetSize(f, @smpLength);
			if error <> OK then
				midasError(error);
			if smpLength > SMPMAX then
				midasError(errInvalidInst);
			error := memAlloc(smpLength, @smpBuf);
			if error <> OK then
				midasError(error);
			error := fileRead(f, smpBuf, smpLength);
			if error <> OK then
				midasError(error);
			error := fileClose(f);
			if error <> OK then
				midasError(error);
			if looping = 1 then
				begin
					error := SD^.AddInstrument(smpBuf, smp8bit, smpLength, 0, smpLength,
						64, 1, 1, @instHandle);
				end
			else
				begin
					error := SD^.AddInstrument(smpBuf, smp8bit, smpLength, 0, 0, 64, 0,
						1, @instHandle);
				end;
			if error <> OK then
				midasError(error);
			error := memFree(smpBuf);
			if error <> OK then
				midasError(error);
			LoadEffect := instHandle;
		end;
	procedure FreeEffect(instHandle : word);
		var	error : integer;
		begin
			error := SD^.RemInstrument(instHandle);
			if error <> OK then
				midasError(error);
		end;
	procedure PlayEffect(instHandle : word; rate : longint; volume : word;
				panning : integer);
		var	error : integer;
		begin
			error := SD^.SetInstrument(fxChannel, instHandle);
			if error <> OK then
				midasError(error);
			error := SD^.SetVolume(fxChannel, volume);
			if error <> OK then
				midasError(error);
			error := SD^.SetPanning(fxChannel, panning);
			if error <> OK then
				midasError(error);
			error := SD^.PlaySound(fxChannel, rate);
			if error <> OK then
				midasError(error);
			fxChannel := fxChannel + 1;         { channel for next effect }
			if fxChannel >= FXCHANNELS then
				fxChannel := 0;
		end;
	function NewModule(fileName:PChar):PmpModule;
		var header : ^byte;
			f : fileHandle;
			module : PmpModule;
			error, mpNum, recognized : integer;
		begin
			error := memAlloc(MPHDRSIZE, @header);
			if error <> OK then
				midasError(error);
			error := fileOpen(fileName, fileOpenRead, @f);
			if error <> OK then
				midasError(error);
			error := fileRead(f, header, MPHDRSIZE);
			if error <> OK then
				midasError(error);
			error := fileClose(f);
			if error <> OK then
				midasError(error);
			mpNum := 0; MP := NIL;
			while (mpNum < NUMMPLAYERS) and (MP = NIL) do
				begin
					error := modulePlayers[mpNum]^.Identify(header, @recognized);
					if error <> OK then
						midasError(error);
					if recognized = 1 then
						MP :=modulePlayers[mpNum];
					mpNum := mpNum + 1;
				end;
			error := memFree(header);
			if error <> OK then
				midasError(error);
			if MP = NIL then
				ErrorExit('Unknown module format');
			module := midasLoadModule(fileName, MP, NIL);
			if module^.numChans > MAXMUSCHANNELS then
				ErrorExit('Too many channels in module');
			midasPlayModule(module, 0);
			MP^.SetMasterVolume(64);
			NewModule := module;
		end;
	procedure StopModule(module : PmpModule);
		begin
			midasStopModule(module);
			midasFreeModule(module);
		end;
	procedure InitSoundSystem;
		var error,isconfig:integer;
		begin
			error := fileExists('MIDAS.CFG', @isConfig);
			if error <> OK then
				midasError(error);
			if isConfig <> 1 then
				begin
					WriteLn('Configuration file not found - run MSETUP.EXE');
					Halt;
				end;
			midasSetDefaults;                   { set MIDAS defaults }
			midasLoadConfig('MIDAS.CFG');       { load configuration }
			midasInit;                          { initialize MIDAS Sound System }
			SD := midasSD;                      { copy Sound Device pointer }
			midasOpenChannels(FXCHANNELS + MAXMUSCHANNELS);
			SD^.SetAmplification(255);
			error := SD^.GetAmplification(@defAmplify);
			if error <> OK then
				midasError(error);
			amplification := defAmplify;
		end;
	procedure DoneSoundSystem;
		begin
			midasClose;                         { uninitialize MIDAS }
		end;
End.