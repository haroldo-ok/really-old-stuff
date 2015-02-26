Changes

Second Revision
---------------
This revision changes the code to support Maccer by Michael Hope. Maccer is a
front end for ggasm (asz80) that add Macro support as well as binary includes
(INCBIN). Also the code has been updated to support updating the sprite table
during the VBlank interrupt. Also the hexidecimal numbers have been changed to
0x1234. This is much better (if you're a C programmer),

Maccer can be downloaded from http://www.pcmedia.co.nz/~michaelh

First Revision
--------------
This is a small update which moves the start of user code up to 0x0080,
allowing room for interrupt vector and reset routines.

Initial
-------
This is an assembler and linker for the Game Gear modified by Charles Doty
(cdoty@pcisys.net). The assembler and linker were written by Alan Baldwin
(baldwin@shop-pdp.kent.edu). The linker is a modified version of the version
released by Pascal Felber (felber@di.epfl.ch) and included in the GBDK.

I've also included the documents that came with the assembler and linker. The
filename is asmlnk.doc.

The linker has three options not listed in the above document. The '--' option
allows the linker to be operated by the command line. (This was added by
Pascal Felber.). The -G option generates a GameGear binary file. This is only
preliminary support for the GameGear. The generated file will probably not
work on a real Game Gear, due to not having a checksum. This will be added
shortly. The -yo# option allows specifying the number of banks in the
rom.(also added by Pascal Felber) This must be used to generate a correct
rom. Also functionality related to the S19 and IHX options have been removed.
The original -g option must use the smaller case g as the GameGear option uses
the upper case G.

I've also included some source code to demonstrate the use of the assembler
and linker. The source code demonstrates using tiles, maps, palettes, and
sprites. This source code is a work in progress, and is distributed only
to show how to use the assembler and linker. The files routines.asm and
routines.inc contain routines that are used to set up tiles, maps, palettes,
and sprites. These routines are free for any use (including commercial). I
would appreciate a mention somewhere in your product or documentation.



Files:
ggasm.exe    -- (aka asz80.exe). Z-80 assembler.
gglink.exe   -- Game Gear Linker.
frogs.gg     -- Compiled version of the source code.
mk.bat       -- Batch file that will compile the demo.
frogs.asm    -- Sample program.
header.asm   -- Absolute block that defines Interrupt and reset locations.
routines.asm -- Game Gear related routines.
routines.inc -- Include file needed for the routines.
defines.inc  -- Include file for game and system defines
*.bin        -- Tiles, sprites, maps, and palettes in binary format.
asmlnk.doc   -- Documentation for the assembler and linker.
readme.txt   -- This file.


Please e-mail me (cdoty@pcisys.net) If you find any problems with the
linker or sample program.

