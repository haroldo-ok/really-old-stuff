ZXB-SMS 0.04 alpha
Copyright (c) 2011 Haroldo O. Pinheiro

This is a frontend that allows one to compile BASIC source code into a Sega Master System ROM.

It uses Boriel's ZX Basic to translate the source into Z80 assembly language, then translates it into a asm format that's compatible with WLA-Z80 and then, finally, it uses WLA to assemble and link the translated code, resulting into a ROM that can be executed by any Sega Master System emulator.

In order to compile, all you need to do is to go to the command line and invoke zxb-sms.exe, passing the name of the BASIC source code as a parameter.

To build the example source, simply go to the \example folder, and run build.bat (test.zxb is the BASIC source code; you can open it with any text file editor; test.rsc is the resource declaration, which can also be opened with any text editor).