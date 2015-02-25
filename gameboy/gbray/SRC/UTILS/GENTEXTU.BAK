program GenTexture;
	uses Graph13h,PCXUnit;
	const
		TEXTURE_COUNT = 128;
	var T:text;
		Img:PRawImage;
		Tex:array[0..15,0..1] of word;
		Mask:array[0..15] of word;
		i,j,k,l:word;
	procedure GetTex(X,Y:word);
		var i,j:word;
		begin
			X:=(X*17)+14;
			Y:=(Y*17)+9;
			{Limpa a textura e a m scara}
			for i:=0 to 15 do
				begin
					Tex[i,0]:=$0000;
					Tex[i,1]:=$0000;
					Mask[i]:=$0000;
				end;
			{Gera a nova textura e a nova m scara}
			for i:=0 to 15 do
				for j:=0 to 15 do
					begin
						Tex[i,0]:=Tex[i,0] shl 1;
						Tex[i,1]:=Tex[i,1] shl 1;
						Mask[i]:=Mask[i] shl 1;

						if Img^.Data[(j+Y)*Img^.Width+(i+X)] and $01 <> 0 then
							Tex[i,0]:=Tex[i,0] or $0001;
						if Img^.Data[(j+Y)*Img^.Width+(i+X)] and $02 <> 0 then
							Tex[i,1]:=Tex[i,1] or $0001;
						if Img^.Data[(j+Y)*Img^.Width+(i+X)] and $04 = 0 then
							Mask[i]:=Mask[i] or $0001;
					end;
		end;
	function HexWord(W:word):string;
		const
			HexChar:array[$0..$F] of char=('0','1','2','3',
										   '4','5','6','7',
										   '8','9','A','B',
										   'C','D','E','F');
		begin
			HexWord:=HexChar[(W shr 12) and $0F]+
					 HexChar[(W shr 8) and $0F]+
					 HexChar[(W shr 4) and $0F]+
					 HexChar[W and $0F];
		end;
Begin
	AllocReadPCX(Img,'TEX.PCX');

	Assign(T,'..\TEXTURES.C');
	Rewrite(T);
	Writeln(T,'#include <gb.h>');

	Writeln(T,'UWORD tex_data[]={');
	for k:=0 to Pred(TEXTURE_COUNT) do
		begin
			GetTex(k mod 18,k div 18);
			if k <> 0 then
				Writeln(T,',');
			Writeln(T,'// Textura ',k);
			for i:=0 to 15 do
				begin
					if i <> 0 then
						Writeln(T,',');
					for j:=0 to 1 do
						begin
							if j <> 0 then
								Write(T,',');
							Write(T,'0x',HexWord(Tex[i,j]),'UL');
						end;
				end;
		end;
	Writeln(T);
	Writeln(T,'};');

	Writeln(T,'UWORD tex_mask_data[]={');
	for k:=0 to Pred(TEXTURE_COUNT) do
		begin
			GetTex(k mod 18,k div 18);
			if k <> 0 then
				Writeln(T,',');
			Writeln(T,'// Textura ',k);
			for i:=0 to 15 do
				begin
					if i <> 0 then
						Writeln(T,',');
					Write(T,'0x',HexWord(Mask[i]),'UL');
				end;
		end;
	Writeln(T);
	Writeln(T,'};');

	Writeln(T,'UWORD *textures[]={');
	for k:=0 to Pred(TEXTURE_COUNT) do
		begin
			if k <> 0 then
				Writeln(T,',');
			Write(T,'tex_data+0x',HexWord(k*SizeOf(Tex) div 2),'UL');
		end;
	Writeln(T);
	Writeln(T,'};');

	Writeln(T,'UWORD *tex_masks[]={');
	for k:=0 to Pred(TEXTURE_COUNT) do
		begin
			if k <> 0 then
				Writeln(T,',');
			Write(T,'tex_mask_data+0x',HexWord(k*SizeOf(Mask) div 2),'UL');
		end;
	Writeln(T);
	Writeln(T,'};');

	Writeln(T);
	Close(T);
End.