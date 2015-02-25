{
Zop compiler - The "linker" routines
by Haroldo de Oliveira Pinheiro

You may do wathever you want with these sources, as long as
you give proper credit.
}
unit ZopLinker;
interface
	const
		ZOP_EVENT_COUNT = 3;

		ZOP_EVT_NONE  = 0;
		ZOP_EVT_TOUCH = 1;
		ZOP_EVT_TALK  = 2;
		ZOP_EVT_THUD  = 3;

		ZOP_EVENT_LABELS: array[0..Pred(ZOP_EVENT_COUNT)] of String = ('TOUCH','TALK','THUD');
		ZOP_EVENT_CODES:  array[0..Pred(ZOP_EVENT_COUNT)] of Word = (ZOP_EVT_TOUCH,ZOP_EVT_TALK,ZOP_EVT_THUD);

	type
		PZopLabelRec=^TZopLabelRec;
		TZopLabelRec=record
						Name: String[16];
						Ptr : PChar;
						Next: PZopLabelRec;
					 end;

		ZopLinkerInfo=record
						Labels: PZopLabelRec;
						Refs  : PZopLabelRec;
					  end;

	procedure ZopLinkInfoInit(var Info: ZopLinkerInfo);
	function  ZopLabelAdd(var Lbl: PZopLabelRec; Name: String; Ptr: PChar): PZopLabelRec;
	function  ZopLabelSearch(Lbl: PZopLabelRec; Name: String): PZopLabelRec;

	procedure ZopResolveInternalRefs(var Data; Info: ZopLinkerInfo);
	function  ZopBuildHeader(var Data; var Head: PChar; Info: ZopLinkerInfo): word;
implementation
	uses Utils;

	procedure ZopLinkInfoInit(var Info: ZopLinkerInfo);
		begin
			Info.Labels := nil;
			Info.Refs   := nil;
		end;

	function  ZopLabelAdd(var Lbl: PZopLabelRec; Name: String; Ptr: PChar): PZopLabelRec;
		var P: PZopLabelRec;
		begin
			New(P);

			P^.Name := Name;
			P^.Ptr	:= Ptr;
			P^.Next := Lbl;
			Lbl		:= P;

			ZopLabelAdd := Lbl;
		end;

	function  ZopLabelSearch(Lbl: PZopLabelRec; Name: String): PZopLabelRec;
		begin
			while (Lbl <> nil) and (Lbl^.Name <> Name) do
				Lbl := Lbl^.Next;

			ZopLabelSearch := Lbl;
		end;

	procedure ZopResolveInternalRefs(var Data; Info: ZopLinkerInfo);
		var Ref: PZopLabelRec;
			Lbl: PZopLabelRec;
			Adr: word;
			P  : PChar;
		begin
			Ref := Info.Refs;
			while Ref <> nil do
				begin
					Lbl := ZopLabelSearch(Info.Labels, Ref^.Name);
					if Lbl = nil then
						begin
							Writeln('Linker error: Unresolved internal reference: ', Ref^.Name);
{							Lbl := Info.Labels;
							while Lbl <> nil do
								begin
									Writeln(Lbl^.Name);
									Lbl := Lbl^.Next;
								end;}
							Halt(255);
						end;

					Adr := CalcFlatAddr(Lbl^.Ptr^) - CalcFlatAddr(Data);
					P   := Ref^.Ptr;

					P^ := Chr(Adr shr 8);
					Inc(P);
					P^ := Chr(Adr and $00FF);

					Ref := Ref^.Next;
				end;
		end;

	function ZopBuildHeader(var Data; var Head: PChar; Info: ZopLinkerInfo): word;
		type
			PEvtData=^EvtData;
			EvtData=record
						Code: word;
						Addr: word;
					end;

		var Lbl    : PZopLabelRec;
			EvtCnt : word;
			Size   : word;
			Adr	   : word;
			P      : PChar;
			Events : PEvtData;
			EvtP   : PEvtData;
			i, j   : word;

			function FindCode(Lbl: String): word;
				var i : word;
				begin
					i := 0;
					while (i <> ZOP_EVENT_COUNT) and
						  (ZOP_EVENT_LABELS[i] <> Lbl) do
						Inc(i);

					if i <> ZOP_EVENT_COUNT then
						FindCode := ZOP_EVENT_CODES[i]
					else
						FindCode := 0;
				end;
		begin
			{Counts the events}
			Lbl    := Info.Labels;
			EvtCnt := 0;
			while Lbl <> nil do
				begin
					if FindCode(Lbl^.Name) <> 0 then
						Inc(EvtCnt);

					Lbl := Lbl^.Next;
				end;

			{Builds the event data}
			GetMem(Events, EvtCnt*SizeOf(EvtData));
			Lbl  := Info.Labels;
			i	 := 0;
			EvtP := Events;
			while Lbl <> nil do
				begin
					j := FindCode(Lbl^.Name);
					if j <> 0 then
						begin
							EvtP^.Code := j;
							EvtP^.Addr := CalcFlatAddr(Lbl^.Ptr^) - CalcFlatAddr(Data);
							Inc(EvtP);
							Inc(i);
						end;

					Lbl := Lbl^.Next;
				end;

			{Assembles the header}
			Size := 4 + 2 + (EvtCnt*4);
			GetMem(Head, Size);
			P := Head;

			P^ := 'Z'; Inc(P);
			P^ := 'O'; Inc(P);
			P^ := 'P'; Inc(P);
			P^ := #00; Inc(P);

			P^ := Chr(EvtCnt shr 8);     Inc(P);
			P^ := Chr(EvtCnt and $00FF); Inc(P);

			EvtP := Events;
			for i := 0 to Pred(EvtCnt) do
				begin
					P^ := Chr(EvtP^.Code shr 8);     Inc(P);
					P^ := Chr(EvtP^.Code and $00FF); Inc(P);

					P^ := Chr(EvtP^.Addr shr 8);     Inc(P);
					P^ := Chr(EvtP^.Addr and $00FF); Inc(P);

					Inc(EvtP);
				end;

			ZopBuildHeader := Size;
		end;
End.