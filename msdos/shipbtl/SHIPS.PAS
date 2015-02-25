unit Ships;
interface
	const
		MaxStars=100;
		MinZoom=0.15;
		MaxZoom=1;
	type
		StarRec=record
					X,Y:real;
					Z:byte;
				end;
	var Xc,Yc:real;
		Stars:array[0..Pred(MaxStars)] of StarRec;
	procedure DrawShip(X,Y:real;Rot:byte;Zoom:real;ID:byte);
	procedure DrawShot(X,Y:real;Rot:byte;Zoom:real;ID:byte);
	procedure InitStars;
	procedure DrawStars(Zoom:real);
implementation
	uses RotateDraw,Screen;
	procedure DrawShip(X,Y:real;Rot:byte;Zoom:real;ID:byte);
		begin
			RotPix(128+Round((X-Xc)*Zoom),96+Round((Y-Yc)*Zoom),Rot,Zoom,ID);
		end;
	procedure DrawShot(X,Y:real;Rot:byte;Zoom:real;ID:byte);
		var sX,sY:longint;
		begin
			Zoom:=Abs(Zoom);
			sX:=128+Round((X-Xc)*Zoom);
			sY:=96+Round((Y-Yc)*Zoom);
			if (sX >= 23*Zoom) and (sX < 256-(23*Zoom)) and
			   (sY >= 23*Zoom) and (sY < 194-(23*Zoom)) then
				RotPix16(sX,sY,Rot,Zoom,ID);
		end;
	procedure InitStars;
		var i:word;
		begin
			Randomize;
			for i:=0 to Pred(MaxStars) do
				begin
					Stars[i].Z:=Random(16)+1;
					Stars[i].X:=Random(256);
					Stars[i].Y:=Random(194);
				end;
        end;
	procedure DrawStars(Zoom:real);
		var i:word;
			X,Y:real;
			Xt,Yt:real;
			Xo,Yo:real;
			Color:integer;
			AmpFactor:real;
		begin
			Xo:=(Xc-(Trunc(Xc/256)*256))*0.1;
			Yo:=(Yc-(Trunc(Yc/194)*194))*0.1;
			AmpFactor:=(Zoom/MinZoom)*0.2;
			for i:=0 to Pred(MaxStars) do
				begin
					X:=Stars[i].X-(Xo*Stars[i].Z*0.2);
					X:=X-(Trunc(X/256)*256);
					if X < 0 then
						X:=255+X;
					X:=((X-128)*Stars[i].Z*Ampfactor)+128;
					Y:=Stars[i].Y-(Yo*Stars[i].Z*0.2);
					Y:=Y-(Trunc(Y/194)*194);
					if Y < 0 then
						Y:=193+Y;
					Y:=((Y-97)*Stars[i].Z*Ampfactor)+97;
					Color:=31-Round(Stars[i].Z*Zoom*3);
					if Color < 15 then
						Color:=15;
					if (X >= 0) and (X <= 255) and (Y >=0) and (Y <= 193) then
						ScrBuf^[Round(Y),Round(X)]:=Color;
				end;
		end;
End.