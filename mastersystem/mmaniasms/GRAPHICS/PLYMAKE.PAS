program MakePlayer;
	uses Graph13h,PCXUnit;
	type
		SMSTile8=array[0..7,0..3] of byte;
		SMSTile16=array[0..15,0..3] of byte;
	var OutF:file;
	procedure EncodeLine(var Til:SMSTile16;Ty:byte;Img:PRawImage;X,Y:integer);
		const Mask:array[0..3] of byte = ($01,$02,$04,$08);
		var i,j:byte;
			Tmp:byte;
			Msk:byte;
		begin
			for i:=0 to 3 do
				begin
					Tmp:=$00;
					Msk:=Mask[i];
					for j:=0 to 7 do
						begin
							Tmp:=Tmp shl 1;
							if (Img^.Data[(Y*Img^.Width)+X+j] and Msk) <> 0 then
								Tmp:=Tmp or $01;
						end;
					Til[Ty,i]:=Tmp;
				end;
		end;
	procedure EncodeFrame(FileName:string);
		var Img:PRawImage;
			Tile:SMSTile16;
			i,j:byte;
		begin
			AllocReadPCX(Img,FileName);
			{Parte superior}
			FillChar(Tile,SizeOf(Tile),0);
			for i:=0 to 1 do
				begin
					for j:=0 to 7 do
						EncodeLine(Tile,j+8,Img,(i*8)+(Img^.Width div 2)-8,j);
					BlockWrite(OutF,Tile,SizeOf(Tile));
				end;
			{Parte inferior}
			for i:=0 to 1 do
				begin
					for j:=0 to 15 do
						EncodeLine(Tile,j,Img,(i*8)+(Img^.Width div 2)-8,j+8);
					BlockWrite(OutF,Tile,SizeOf(Tile));
				end;
			{Pronto.}
			FreeRawImage(Img);
		end;
Begin
	Assign(OutF,'PLYSHIP.BIN');
	Rewrite(OutF,1);
	EncodeFrame('PLYSHIP0.PCX');
	EncodeFrame('PLYSHIP1.PCX');
	EncodeFrame('PLYSHIP2.PCX');
	EncodeFrame('PLYSHIP3.PCX');
	EncodeFrame('PLYSHIP4.PCX');
	EncodeFrame('PLYSHIP5.PCX');
	EncodeFrame('PLYSHIP6.PCX');
	EncodeFrame('PLYSHIP7.PCX');
	EncodeFrame('PLYSHIP8.PCX');
	Close(OutF);
End.