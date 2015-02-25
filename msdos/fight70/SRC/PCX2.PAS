program PCX;
{Programa para vizualizar arquivos PCX}
{Programado por Haroldo de Oliveira Pinheiro}
{Baseado em informa‡Æo encontrada na Games Programming Encyclopedia}
	uses Crt,X_Const,X_Pal;
	type
		PCXHeader = record
						Manufacturer:byte;
						Version:byte;
						Encoding:byte;
						BitsPerPixel:byte;
						XMin,YMin,XMax,YMax:word;
						HDPI,VDPI:word;
						ColorMap16:array[0..47] of byte;
						Reserved:byte;
						NPlanes:byte;
						BytesPerLine:word;
						PaletteInfo:word;
						HScreenSize:word;
						VScreenSize:word;
						Filler:array[0..53] of byte;
					end;
		PRawImage=^RawImage;
		RawImage=record
					Width,Height:word;
					Data:array[0..65530] of byte;
				 end;
	var PCXFile:file;
		PCXH:PCXHeader;
		DestImg:PRawImage;
	procedure PCXInfo;
		begin
			Writeln('Manufacturer: ',PCXH.Manufacturer);
			Writeln('Version:      ',PCXH.Version);
			Writeln('Encoding:     ',PCXH.Encoding);
			Writeln('BitsPerPixel: ',PCXH.BitsPerPixel);
			Writeln('XMin:         ',PCXH.XMin);
			Writeln('YMin:         ',PCXH.YMin);
			Writeln('XMax:         ',PCXH.XMax);
			Writeln('YMax:         ',PCXH.YMax);
			Writeln('HDPI:         ',PCXH.HDPI);
			Writeln('VDPI:         ',PCXH.VDPI);
			Writeln('NPlanes:      ',PCXH.NPlanes);
			Writeln('BytesPerLine: ',PCXH.BytesPerLine);
			Writeln('PaletteInfo:  ',PCXH.PaletteInfo);
			Writeln('HScreenSize:  ',PCXH.HScreenSize);
			Writeln('VScreenSize:  ',PCXH.VScreenSize);
			Readln;
		end;
	procedure DecodePCX;
		type
			Buffer=array[0..0] of byte;
		var XSize,YSize:word;
			TotalBytes:word;
			Buf:^Buffer;
			LineNumber:word;
		procedure DecodeLine;
			var SubTotal:word;
				Data,Count:byte;
				i:byte;
			procedure GetData;
				begin
					BlockRead(PCXFile,Data,1);
					Count:=1;
					if (Data and $C0)=$C0 then
						begin
							Count:=Data and $3F;
							BlockRead(PCXFile,Data,1);
						end;
				end;
			begin
				SubTotal:=0;
				while SubTotal < TotalBytes do
					begin
						GetData;
						FillChar(Buf^[SubTotal],Count,Data);
						Inc(SubTotal,Count);
					end;
			end;
		procedure DisplayLine;
			begin
				Move(Buf^,DestImg^.Data[LineNumber*DestImg^.Width],XSize);
			end;
		begin
			if DestImg <> nil then
				begin
					XSize:=PCXH.XMax-PCXH.XMin+1;
					YSize:=PCXH.YMax-PCXH.YMin+1;
					TotalBytes:=PCXH.NPlanes*PCXH.BytesPerLine;
					GetMem(Buf,TotalBytes);
					for LineNumber:=0 to Pred(YSize) do
						begin
							DecodeLine;
							DisplayLine;
						end;
					FreeMem(Buf,TotalBytes);
				end;
		end;
	procedure GetPCXHeader(FileName:string);
		begin
			Assign(PCXFile,FileName);
			Reset(PCXFile,1);
			BlockRead(PCXFile,PCXH,SizeOf(PCXHeader));
		end;
	procedure ReadPCX(var Img:RawImage;FileName:string);
		begin
			GetPCXHeader(FileName);
			Img.Width:=PCXH.XMax-PCXH.XMin+1;
			Img.Height:=PCXH.YMax-PCXH.YMin+1;
			DestImg:=Addr(Img);
			DecodePCX;
			DestImg:=nil;
			Close(PCXFile);
		end;
	procedure AllocReadPCX(var Img:PRawImage;FileName:string);
		begin
			GetPCXHeader(FileName);
			GetMem(Img,(PCXH.XMax-PCXH.XMin+1)*(PCXH.XMin-PCXH.XMax+1));
			Img^.Width:=PCXH.XMax-PCXH.XMin+1;
			Img^.Height:=PCXH.YMax-PCXH.YMin+1;
			DestImg:=Img;
			DecodePCX;
			DestImg:=nil;
			Close(PCXFile);
		end;
	procedure AllocRawImage(var Img:PRawImage;Width,Height:word);
		begin
			GetMem(Img,Width*Height);
			Img^.Width:=Width;
			Img^.Height:=Height;
		end;
	procedure FreeRawImage(var Img:PRawImage);
		begin
			GetMem(Img,Img^.Width*Img^.Height);
		end;
	procedure DisplayRawImage(X,Y:integer;var Img:RawImage);
		var i,j:word;
		begin
			for i:=0 to Pred(Img.Width) do
				for j:=0 to Pred(Img.Height) do
					Mem[$A000:((j+Y)*320)+i+X]:=Img.Data[(j*Img.Width)+i];
		end;
	procedure DisplayRawImageClip(X,Y:integer;var Img:RawImage);
		var AftrSkip:word;
			Lines2Skip,Lines2Draw:word;
			Cols2Skip,Cols2Draw,Cols2Ignr:word;
			StartAddr:word;
			ImgOfs:word;
		begin
			if (X > -Img.Width) and (X < 320) and (Y > -Img.Height) and (Y < 200) then
				begin
					Cols2Draw:=Img.Width;
					Cols2Skip:=0;
					Cols2Ignr:=0;
					if X < 0 then
						begin
							Inc(Cols2Draw,X); {X ‚ negativo}
							Cols2Skip:=-X;
							X:=0;
						end;
					if X+Cols2Draw > 320 then
						begin
							Cols2Draw:=320-X;
							Cols2Ignr:=Img.Width-Cols2Draw;
						end;
					AftrSkip:=320-Cols2Draw;

					Lines2Draw:=Img.Height;
					Lines2Skip:=0;
					if Y < 0 then
						begin
							Inc(Lines2Draw,Y); {Y ‚ negativo}
							Lines2Skip:=-Y;
							Y:=0;
						end;
					if Y+Lines2Draw > 200 then
						begin
							Lines2Draw:=200-Y;
						end;

					StartAddr:=(Y*320)+X;
					ImgOfs:=(Lines2Skip*Img.Width)+Cols2Skip;
					Inc(Cols2Skip,Cols2Ignr);
					asm
						cld
						push ds
						lds si, [Img]
						add si, 4
						add si, ImgOfs;
						mov ax, 0A000h
						mov es, ax
						mov di, StartAddr
						mov dx, Cols2Skip
						mov bx, Lines2Draw
					  @RowLoop:
						mov cx, Cols2Draw
					  @ColLoop:
						lodsb
						or al, al
						jz @SkipPixel
						mov es:[di], al
					  @SkipPixel:
						inc di
						loop @ColLoop
						add si, dx
						add di, AftrSkip
						dec bx
						or  bx,bx
						jnz @RowLoop
						pop ds
					end;
				end;
		end;
	procedure CutRawImage(var Src:RawImage;X1,Y1,X2,Y2:integer;var Dest:RawImage);
		var i,j:integer;
		begin
			Dest.Width:=(X2-X1)+1;
			Dest.Height:=(Y2-Y1)+1;
			for i:=0 to X2-X1 do
				for j:=0 to Y2-Y1 do
					Dest.Data[(j*Dest.Width)+i]:=Src.Data[((j+Y1)*Src.Width)+i+X1];
		end;
	procedure AllocCutRawImage(var Src:RawImage;X1,Y1,X2,Y2:integer;var Dest:PRawImage);
		begin
			GetMem(Dest,(X2-X1+1)*(Y2-Y2+1));
			CutRawImage(Src,X1,Y1,X2,Y2,Dest^);
		end;
	procedure GetPcxPalette(var Pal:Palette; FileName:string);
		var F:file;
			i,j:byte;
		begin
			Assign(F,FileName);
			Reset(F,1);
			Seek(F,FileSize(F)-SizeOf(Pal));
			BlockRead(F,Pal,SizeOf(Pal));
			for i:=0 to 255 do
				for j:=0 to 2 do
					Pal[i,j]:=Pal[i,j] shr 2;
			Close(F);
		end;
	var Image:PRawImage;
		Image2:PRawImage;
		Pal:Palette;
Begin
	ClrScr;
	asm
		mov ax, 13h
		int 10h
	end;

	AllocReadPCX(Image,'IMAGE1.PCX');
	DisplayRawImage(64,64,Image^);
	DisplayRawImageClip(-32,-10,Image^);

	AllocCutRawImage(Image^,10,10,42,42,Image2);
	DisplayRawImage(160,20,Image2^);

	GetPCXPalette(Pal,'IMAGE1.PCX');
	X_Put_Pal_Raw(Pal,256,0,false);

	Readln;

	FreeRawImage(Image);
	FreeRawImage(Image2);
	asm
		mov ax, 03h
		int 10h
	end;
End.