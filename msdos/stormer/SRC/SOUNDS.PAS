{STORMER - Unidade de manipula‡Æo de sons}
{programado por Haroldo de Oliveira Pinheiro}
{Utiliza a ferramenta Digital Sound Interface Kit, por Carlos Hasan}
unit Sounds;
interface
	uses Sound;
	var	Card:DSMCard;
		PlyShotSnd:PDSMInst;
		EnmExpSnd:PDSMInst;
		PlyExpSnd:PDSMInst;
		LevMusic:PDSMInst;
		DemoMusic:PDSMInst;
		Intro1Music:PDSMInst;
		Intro2Music:PDSMInst;
		Bleep1:PDSMInst;
		Bleep2:PDSMInst;
		Bleep3:PDSMInst;
		MusicNum:byte;
		MusCtrl:longint;
	procedure InitSounds;
	procedure HandleSounds;
	procedure PlaySound(Snd:PDSMInst;Chan,Pan,Vol:byte);
	procedure DoneSounds;
implementation
	uses X_Main,Load;
	const
		MusLength1=(33394 div 11000) * 1000 + 30;
		MusLength2=26396 div 11;
	var ActualChan:byte;
	procedure InitSounds;
		begin
			if DSMLoadSetup(Card) then
				begin
					X_Text_Mode;
					writeln('Please run SETUP.EXE to configure.');
					Halt(1);
				end;
			if DSMInit(Card) then
				begin
					X_Text_Mode;
					writeln('Error Initializing the Sound System.');
					Halt(1);
				end;
			PlyShotSnd:=DSMLoadSample('SHOOT.SND',0);
			EnmExpSnd:=DSMLoadSample('ENMEXPLO.SND',0);
			PlyExpSnd:=DSMLoadSample('PLYEXPLO.SND',0);
			LevMusic:=DSMLoadSample('MUSIC1.SND',0);
			DemoMusic:=DSMLoadSample('MUSIC2.SND',0);
			Intro1Music:=DSMLoadSample('INTRO.SND',0);
			Intro2Music:=DSMLoadSample('LEVINIT.SND',0);
			Bleep1:=DSMLoadSample('BLEEP1.SND',0);
			Bleep2:=DSMLoadSample('BLEEP2.SND',0);
			Bleep3:=DSMLoadSample('BLEEP3.SND',0);
			ActualChan:=0;
			MusCtrl:=0;
			MusicNum:=0;
			DSMSetupVoices(3,60);
		end;
	procedure HandleSounds;
		begin
			DSMPoll;
			case MusicNum of
				001:begin
						if MusCtrl=0 then
							PlaySound(LevMusic,2,64,64);
						MusCtrl:=(MusCtrl+1) mod MusLength1;
					end;
				002:begin
						if MusCtrl=0 then
							PlaySound(DemoMusic,2,64,64);
						MusCtrl:=(MusCtrl+1) mod MusLength2;
					end;
			end;
		end;
	procedure PlaySound(Snd:PDSMInst;Chan,Pan,Vol:byte);
		begin
			if Chan=5 then
				Chan:=ActualChan;
			DSMPlaySample(Chan,Snd);
			DSMSetBalance(Chan,Pan);
			DSMSetBalance(Chan,Vol);
		end;
	procedure DoneSounds;
		begin
			DSMDone;
			DSMFreeSample(PlyShotSnd);
		end;
End.