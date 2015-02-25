{
Zop compiler
by Haroldo de Oliveira Pinheiro

You may do wathever you want with these sources, as long as
you give proper credit.
}
program Zop;
	uses RunTime, Utils, ZopUnit, ZopCompiler, ZopLinker;

	var Data        : PChar;
		Header      : PChar;
		LinkerInfo	: ZopLinkerInfo;
		InFileName  : string;
		OutFileName : string;
		Size		: longint;
		HeaderSize	: word;
		F			: File;
Begin
	if ParamCount < 2 then
		begin
			Writeln('ZOP v0.05 by Haroldo de Oliveira Pinheiro');
			Writeln('USAGE: ZOP <dest binary> <sourcecode>');
			Halt(255);
		end;

	Writeln('ZOP v1.0 by Haroldo de Oliveira Pinheiro');

	InFileName  := ParamStr(2);
	OutFileName := ParamStr(1);

	if not FileExists(InFileName) then
		begin
			Writeln('File "', InFileName, '" not found.');
			Halt(255);
		end;

	GetMem(Data, ZOP_MAX_PROGSIZE);
	ZopLinkInfoInit(LinkerInfo);

	Writeln('Compiling ', InFileName, '...');
	Size := ZopCompile(Data^, LinkerInfo, InFileName);

	Writeln('Resolving internal references...');
	ZopResolveInternalRefs(Data^, LinkerInfo);

	Writeln('Building header...');
	HeaderSize := ZopBuildHeader(Data^, Header, LinkerInfo);

	Writeln('Writing ', OutFileName, ' to disk...');
	Assign(F, OutFileName);
	Rewrite(F, 1);
	BlockWrite(F, Header^, HeaderSize);
	BlockWrite(F, Data^, Size);
	Close(F);

	Writeln('Done.');
End.