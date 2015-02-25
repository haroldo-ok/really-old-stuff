unit HVMM;
{ unit HVMM by Haroldo de Oliveira Pinheiro }
{ manages EMS/XMS/Flat/Virtual memory in a  }
{ way that's transparent to the programmer. }
{ note: for now, only uses XMS.				}
interface
	const
		HVMMInitialized:Boolean=False;

	procedure InitHVMM;
	procedure DoneHVMM;

	function GetMemHVMM(Total: longint): word;
	procedure FreeMemHVMM(Handle: word);

	function ReadHVMM(Handle: word; var Data; Offset, Total: longint):longint;
	function WriteHVMM(Handle: word; var Data; Offset, Total: longint):longint;

	procedure TestXMS;
implementation
	uses XMS30;

	const
		MaxPages=$2000; {8k p†ginas}
		Page_Unused=$FFFF;
		Page_Last=$FFFE;
		MaxHVMMHandles=$400;{1024 handles}

	type
		HVMMIndexBlk=record
						StartPage: word;
						Length: longint;
						Allocated: longint;
					 end;
		PByte = ^Byte;

	var PageCount: word;
		PageSize: word;
		PageTable: array[0..Pred(MaxPages)] of word;
		Blocks: array[0..Pred(MaxHVMMHandles)] of HVMMIndexBlk;
		XMS_Handle: word;
		XMS_Total: longint;
		PageBuffer: PByte;

	procedure InitHVMM;
		var i: word;
		begin
			PageCount := 0;
			PageSize := 1024;

			XMS_Handle := 0;

			if XMS_Installed then
				begin
					XMS_Total := MaxAvailXMS;
					XMS_Handle := GetMemXMS(XMS_Total);
					Inc(PageCount,XMS_Total);
				end;

			for i := 0 to Pred(MaxPages) do
				PageTable[i] := Page_Unused;

			for i := 0 to Pred(MaxHVMMHandles) do
				begin
					Blocks[i].StartPage := Page_Unused;
					Blocks[i].Length := 0;
				end;

			GetMem(PageBuffer, PageSize);

			HVMMInitialized := True;
		end;

	procedure DoneHVMM;
		begin
			if not HVMMInitialized then
				Exit;

			if XMS_Installed then
				begin
					FreeMemXMS(XMS_Handle);
				end;

			FreeMem(PageBuffer, PageSize);

			HVMMInitialized := False;
		end;

	function SearchFreeHandle: word;
		var i: word;
		begin
			i := 0;
			while (i < MaxHVMMHandles) and
				  (Blocks[i].StartPage <> Page_Unused) do
				Inc(i);

			if (i < MaxHVMMHandles) then
				SearchFreeHandle := i
			else
				SearchFreeHandle := Page_Unused;
		end;

	function SearchFreePage: word;
		var i: word;
		begin
			i := 0;
			while (i < MaxPages) and
				  (PageTable[i] <> Page_Unused) do
				Inc(i);

			if i < MaxPages then
				SearchFreePage := i
			else
				SearchFreePage := Page_Unused;
		end;

	function GetMemHVMM(Total: longint): word;
		var Handle: word;
			StartPage: word;
			CurrPage: word;
			PrevPage: word;
			Allocated: longint;
		begin
			GetMemHVMM := Page_Unused;

			Handle := SearchFreeHandle;
			StartPage := SearchFreePage;
			PrevPage := Page_Unused;
			Allocated := 0;

			if (Handle <> Page_Unused) and
			   (StartPage <> Page_Unused) then
				begin
					while Allocated < Total do
						begin
							CurrPage := SearchFreePage;
							if CurrPage = Page_Unused then
								Break;

							if PrevPage <> Page_Unused then
								PageTable[PrevPage] := CurrPage;
							PageTable[CurrPage] := Page_Last;

							Inc(Allocated,PageSize);

							PrevPage := CurrPage;
						end;

					Blocks[Handle].StartPage := StartPage;
					Blocks[Handle].Length := Total;
					Blocks[Handle].Allocated := Allocated;

					GetMemHVMM := Handle;
				end;
		end;

	procedure FreeMemHVMM(Handle: word);
		var CurrPage, PrevPage: word;
		begin
			if (Handle < MaxHVMMHandles) and
			   (Blocks[Handle].StartPage <> Page_Unused) then
				begin
					CurrPage := Blocks[Handle].StartPage;
					while (CurrPage <> Page_Unused) and
						  (CurrPage <> Page_Last) and
						  (CurrPage < MaxPages) do
						begin
							PrevPage := CurrPage;
							CurrPage := PageTable[CurrPage];
							PageTable[PrevPage] := Page_Unused;
						end;

					Blocks[Handle].StartPage := Page_Unused;
					Blocks[Handle].Length := 0;
					Blocks[Handle].Allocated := 0;
				end;
		end;

	function SeekPage(Page: word; Count: word): word;
		begin
			while (Count <> 0) and
				  (PageTable[Page] <> Page_Last) and
				  (PageTable[Page] <> Page_Unused) and
				  (Page < MaxPages) do
				begin
					Page := PageTable[Page];
					Dec(Count);
				end;

			if (Count <> 0) or
			   (Page > MaxPages) then {Erro}
				SeekPage := Page_Unused
			Else
				SeekPage := Page;
		end;

	procedure ReadPage(Page: word; var Buffer);
		var Offset: longint;
		begin
			If XMS_Installed then
				begin
					Offset := Page;
					Offset := Offset*PageSize;

					XMS2DOS(XMS_Handle,Addr(Buffer),Offset,PageSize);
				end;
		end;

	procedure WritePage(Page: word; var Buffer);
		var Offset: longint;
		begin
			If XMS_Installed then
				begin
					Offset := Page;
					Offset := Offset*PageSize;

					DOS2XMS(Addr(Buffer),XMS_Handle,Offset,PageSize);
				end;
		end;

	function ReadHVMM(Handle: word; var Data; Offset, Total: longint):longint;
		var
			P, B: PByte;
			ToRead: longint;
			PrevPageNum,
			PageNum,
			PageOfs: word;
			CurrPage: word;
		begin
			if (Handle >= MaxHVMMHandles) or
			   (Blocks[Handle].StartPage = Page_Unused) or
			   (Offset >= Blocks[Handle].Length) then
				begin {Erro}
					ReadHVMM := 0;
					Exit;
				end;

			if (Offset + Total) > Blocks[Handle].Length then {Total maior do que a mem¢ria alocada}
				Total := Blocks[Handle].Length - Offset;

			P := Addr(Data);
			ToRead := Total;
			CurrPage := Blocks[Handle].StartPage;
			PrevPageNum := 0;

			while ToRead > 0 do
				begin
					PageNum := Offset div PageSize; {Note que PageNum indica o °ndice da p†gina dentro da sequància, n∆o o seu n£mero real.}
					PageOfs := Offset mod PageSize;

					CurrPage := SeekPage(CurrPage, PageNum-PrevPageNum);

					if CurrPage = Page_Unused then
						begin {Erro}
							ReadHVMM := Total - ToRead;
							Exit;
						end;

					B := PageBuffer;
					ReadPage(CurrPage, B^); {Primeiro, là a p†gina requisitada}
					Inc(B,PageOfs); {Ajusta a posiá∆o que ser† lida}

					if ToRead > PageSize - PageOfs then {Se os bytes a ler ultrapassarem a p†gina}
						Move(B^, P^, PageSize - PageOfs) {Là s¢ o que der}
					else
						Move(B^, P^, ToRead); {Sen∆o, là tudo o que faltar}

					Inc(P, PageSize - PageOfs);
					Inc(Offset, PageSize - PageOfs);
					Dec(ToRead, PageSize - PageOfs);

					PrevPageNum := PageNum;
				end;

			ReadHVMM := Total;
		end;

	function WriteHVMM(Handle: word; var Data; Offset, Total: longint):longint;
		var
			P, B: PByte;
			ToWrite: longint;
			PrevPageNum,
			PageNum,
			PageOfs: word;
			CurrPage: word;
		begin
			if (Handle >= MaxHVMMHandles) or
			   (Blocks[Handle].StartPage = Page_Unused) or
			   (Offset >= Blocks[Handle].Length) then
				begin {Erro}
					WriteHVMM := 0;
					Exit;
				end;

			if (Offset + Total) > Blocks[Handle].Length then {Total maior do que a mem¢ria alocada}
				Total := Blocks[Handle].Length - Offset;

			P := Addr(Data);
			ToWrite := Total;
			CurrPage := Blocks[Handle].StartPage;
			PrevPageNum := 0;

			while ToWrite > 0 do
				begin
					PageNum := Offset div PageSize; {Note que PageNum indica o °ndice da p†gina dentro da sequància, n∆o o seu n£mero real.}
					PageOfs := Offset mod PageSize;

					CurrPage := SeekPage(CurrPage, PageNum-PrevPageNum);

					if CurrPage = Page_Unused then
						begin {Erro}
							WriteHVMM := Total - ToWrite;
							Exit;
						end;

					B := PageBuffer;
					ReadPage(CurrPage, B^); {Primeiro, là a p†gina requisitada}
					Inc(B,PageOfs); {Ajusta a posiá∆o que ser† sobrescrita}

					if ToWrite > PageSize - PageOfs then {Se os bytes a escrever ultrapassarem a p†gina}
						Move(P^, B^, PageSize - PageOfs) {Escreve s¢ o que der}
					else
						Move(P^, B^, ToWrite); {Sen∆o, escreve tudo o que sobrar}
					WritePage(CurrPage, PageBuffer^); {Por fim, escreve a p†gina de volta}

					Inc(P, PageSize - PageOfs);
					Inc(Offset, PageSize - PageOfs);
					Dec(ToWrite, PageSize - PageOfs);

					PrevPageNum := PageNum;
				end;

			WriteHVMM := Total;
		end;

	procedure TestXMS;
		var S: string;
		begin
			Writeln('Testando XMS.');

			S := 'Offset 0 Ok!!!';
			DOS2XMS(Addr(S),XMS_Handle,0,SizeOf(S));
			S := 'Erro!!!';
			XMS2DOS(XMS_Handle,Addr(S),0,SizeOf(S));
			Writeln(S);

			S := 'Offset 1000 Ok!!!';
			DOS2XMS(Addr(S),XMS_Handle,1000,SizeOf(S));
			S := 'Erro!!!';
			XMS2DOS(XMS_Handle,Addr(S),1000,SizeOf(S));
			Writeln(S);

			S := 'Offset 10000 Ok!!!';
			DOS2XMS(Addr(S),XMS_Handle,10000,SizeOf(S));
			S := 'Erro!!!';
			XMS2DOS(XMS_Handle,Addr(S),10000,SizeOf(S));
			Writeln(S);

			S := 'Offset 1000000 Ok!!!';
			DOS2XMS(Addr(S),XMS_Handle,1000000,SizeOf(S));
			S := 'Erro!!!';
			XMS2DOS(XMS_Handle,Addr(S),1000000,SizeOf(S));
			Writeln(S);
		end;

	var OldExit:pointer;

	procedure NewExitProc;Far; {Uma salvaguarda para o caso do programa dar erro.}
		begin
			DoneHVMM;
			ExitProc := OldExit;
		end;

Begin
	OldExit := ExitProc;
	ExitProc := @NewExitProc;
End.