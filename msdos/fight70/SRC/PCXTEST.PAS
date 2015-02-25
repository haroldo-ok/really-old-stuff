program PCXTest;
	uses Crt,Graph13h,PCXUnit;
	var Image:PRawImage;
		Image2:PRawImage;
		Pal:Palette;
Begin
	AllocReadPCX(Image,'IMAGE1.PCX');

    InitGraph13h;
	DisplayRawImage(64,64,Image^);
	DisplayRawImageClip(-32,-10,Image^);

	AllocCutRawImage(Image^,10,10,42,42,Image2);
	DisplayRawImage(160,20,Image2^);

	GetPCXPalette(Pal,'IMAGE1.PCX');
	PutPal(Pal);

	Readln;

	ReIndexColors(Image^,Pal,64,1);
	PutPal(Pal);
	DisplayRawImageClip(140,10,Image^);

	Readln;

	FreeRawImage(Image);
	FreeRawImage(Image2);

    CloseGraph13h;
End.