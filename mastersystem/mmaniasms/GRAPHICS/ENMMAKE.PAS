program MakeEnemy;
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

			for i:=0 to 1 do
				begin
					for j:=0 to 15 do
						EncodeLine(Tile,j,Img,(i*8)+(Img^.Width div 2)-8,j);
					BlockWrite(OutF,Tile,SizeOf(Tile));
				end;

			FreeRawImage(Img);
		end;
Begin
	if ParamCount < 2 then
		begin
			Writeln('EnmMake 1.0 by Haroldo de Oliveira Pinheiro');
			Writeln('USAGE: ENMMAKE <prefix> <outfile>');
			Halt;
		end;
	Assign(OutF,ParamStr(2));
	Rewrite(OutF,1);
	EncodeFrame(ParamStr(1)+'00.PCX');
	EncodeFrame(ParamStr(1)+'01.PCX');
	EncodeFrame(ParamStr(1)+'02.PCX');
	EncodeFrame(ParamStr(1)+'03.PCX');
	EncodeFrame(ParamStr(1)+'04.PCX');
	EncodeFrame(ParamStr(1)+'05.PCX');
	EncodeFrame(ParamStr(1)+'06.PCX');
	EncodeFrame(ParamStr(1)+'07.PCX');
	EncodeFrame(ParamStr(1)+'08.PCX');
	EncodeFrame(ParamStr(1)+'09.PCX');
	EncodeFrame(ParamStr(1)+'10.PCX');
	EncodeFrame(ParamStr(1)+'11.PCX');
	EncodeFrame(ParamStr(1)+'12.PCX');
	EncodeFrame(ParamStr(1)+'13.PCX');
	EncodeFrame(ParamStr(1)+'14.PCX');
	EncodeFrame(ParamStr(1)+'15.PCX');
	Close(OutF);
End.