..\..\..\..\bin\gen_2_2 tileset1.pcx ..\..\temp\tileset1.til 16
..\..\..\..\bin\gen_2_2 tileset2.pcx ..\..\temp\tileset2.til 42
..\..\..\..\bin\gen_2_2 player.pcx ..\..\temp\player.til 32
..\..\..\..\bin\gen_2_4 char1.pcx ..\..\temp\char1.til 12

..\..\..\..\bin\rdc c ..\..\temp\tileset1.tlc ..\..\temp\tileset1.til
..\..\..\..\bin\rdc c ..\..\temp\tileset2.tlc ..\..\temp\tileset2.til
..\..\..\..\bin\rdc c ..\..\temp\player.tlc ..\..\temp\player.til
..\..\..\..\bin\rdc c ..\..\temp\char1.spr ..\..\temp\char1.til
..\..\..\..\bin\rdc c ..\..\temp\char2.spr ..\..\temp\char1.til

..\..\..\..\bin\palmake ..\..\temp\bkg.plt bkg.pal
..\..\..\..\bin\palmake ..\..\temp\bkg2.plt tileset2.pal
..\..\..\..\bin\palmake ..\..\temp\interfc.plt interfc.pal
..\..\..\..\bin\palmake ..\..\temp\player.plt player.pal

..\..\..\..\bin\atrmake ..\..\temp\tileset2.atr tileset2.txt

copy interfc.til ..\..\temp\
