gen_2_2 tileset1.pcx tileset1.til 64

rem fli2gspr -w 3 -h 3 -p test.pal player.fli player.til
rem fli2gspr -w 2 -h 2 -p enemy1.pal Blade.fli Blade.til
rem fli2gspr -w 2 -h 2 -p enemy1.pal Gunner.fli Gunner.til
rem fli2gspr -w 2 -h 2 -p enemy1.pal Zigger.fli Zigger.til
rem fli2gspr -w 2 -h 2 -p enemy2.pal explo.fli explo.til

pcx2gen Title1.pcx title1.til
pcx2gen Title2.pcx title2.til
pcx2gen Title3.pcx title3.til
pcx2gen GameOver.pcx gameover.til

move *.h ..\..\pal
