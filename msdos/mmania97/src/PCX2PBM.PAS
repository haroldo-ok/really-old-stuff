program PCX_to_PBM;{Converte pcx para pbm}
	uses Dos,X_Bitmap,X_FileIO;
	var X:longint;
		DirInfo:SearchRec;
		PcxVar,PbmVar:Pointer;
		TmpVar:String;
Begin
	GetMem(PbmVar,64000);										{Aloca mem¢ria para PbmVar}
	FindFirst('*.PCX',AnyFile,DirInfo);							{Encontra o primeiro arquivo PCX do diret¢rio}
		while DosError = 0 do									{Enquanto houver algum arquivo a ser convertido}
			begin
				X:=X_get_PCX_Size(Only_one_Ext(DirInfo.Name,'PCX'));{Calcula mem¢ria a ser alocada}
				GetMem(PcxVar,X);								{Aloca mem¢ria}
				FillChar(PcxVar^,X,0);							{Limpa a vari vel}
				X_Load_PCX_as_LBM(Only_one_Ext(DirInfo.Name,'PCX'),PcxVar^);{Carrega a imagem com LBM}
				X_LBM_to_PBM(PcxVar^,PbmVar^);					{Converte LBM para PBM}
				FillChar(TmpVar[1],SizeOf(TmpVar),#0);			{Limpa a vari vel}
				TmpVar:=Only_one_Ext(DirInfo.Name,'PBM');		{Nome do arquivo}
				X_Save_Pbm(TmpVar,PbmVar^);						{Salva o arquivo}
				FreeMem(PcxVar,X);								{Libera mem¢ria}
				FindNext(DirInfo);								{Procura o pr¢ximo arquivo}
			end;
	FreeMem(PbmVar,64000);										{Libera mem¢ria}
End.