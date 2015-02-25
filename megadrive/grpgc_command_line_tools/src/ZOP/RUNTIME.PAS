{
I have not found this type of unit in the SWAG and thought you might
wish to include it. It has been useful to me.

Brent Herring
Systems Analyst
University of Central Arkansas
brenth@cc1.uca.edu
}

Unit RunTime;

{
  Including this unit in your program should replace all the runtime
  errors with messages that are a bit more helpful than "Runtime
  error 202". Especially helpful when trying to help someone else
  debug a program that you wrote (as if you would write a program
  with a mistake).
}

INTERFACE

Function Hex(Value:byte):string;
function ReturnError(Num: byte):string; {Haroldo/2003}

IMPLEMENTATION

var OldExit:pointer;

{====================================================================}
Function Hex(Value:byte):string;

const HexTable:array[0..15] of Char=('0','1','2','3','4','5','6','7',
                                     '8','9','A','B','C','D','E','F');

var HexStr : string;

begin
  HexStr[2]:=HexTable[Value and $0F];        { Convert low nibble }
  HexStr[1]:=HexTable[Value and $F0 div 16]; { Convert high nibble }
  HexStr[0]:=#2; { Set Stringlength }
  Hex:=HexStr;
end;

function ReturnError(Num: byte):string; {Haroldo/2003}
	begin
		case Num of { Pick the appropriate message }
			2:ReturnError:='File not found';
			3:ReturnError:='Path not found';
			4:ReturnError:='Too many open files';
			5:ReturnError:='File access denied';
			6:ReturnError:='Invalid file handle';
			8:ReturnError:='Insufficient memory';
		   12:ReturnError:='Invalid file access code';
		   15:ReturnError:='Invalid drive number';
		   16:ReturnError:='Cannot remove current directory';
		   17:ReturnError:='Cannot rename across drives';
		  100:ReturnError:='Disk read error';
		  100:ReturnError:='Disk write error';
		  102:ReturnError:='File not assigned';
		  103:ReturnError:='File not open';
		  104:ReturnError:='File not open for input';
		  105:ReturnError:='File not open for output';
		  106:ReturnError:='Invalid numeric format';
		  150:ReturnError:='Disk is write-protected';
		  151:ReturnError:='Unknown unit';
		  152:ReturnError:='Drive not ready';
		  153:ReturnError:='Unknown command';
		  154:ReturnError:='CRC error in data';
		  155:ReturnError:='Bad drive request structure length';
		  156:ReturnError:='Disk seek error';
		  157:ReturnError:='Unknown media type';
		  158:ReturnError:='Sector not found';
		  159:ReturnError:='Printer out of paper';
		  160:ReturnError:='Device write fault';
		  161:ReturnError:='Device read fault';
		  162:ReturnError:='Hardware failure';
		  200:ReturnError:='Division by zero';
		  201:ReturnError:='Range check error';
		  202:ReturnError:='Stack overflow error';
		  203:ReturnError:='Heap overflow error';
		  204:ReturnError:='Invalid pointer operation';
		  205:ReturnError:='Floating-point overflow';
		  206:ReturnError:='Floating-point underflow';
		  207:ReturnError:='Invalid floating-point operation';
		  208:ReturnError:='Overlay manager not installed';
		  209:ReturnError:='Overlay file read error';
		  210:ReturnError:='Object not initialized';
		  211:ReturnError:='Call to abstract method';
		  212:ReturnError:='Stream register error';
		  213:ReturnError:='Collection index out of range';
		  214:ReturnError:='Collection overflow error';
		end;
	end;

{====================================================================}
{ Try to handle all possible errors }

Procedure RunTimeExitProc;Far;

var Message : string;

begin
  if ErrorAddr<>Nil then { If error occurs }
	begin
	  Message := ReturnError(ExitCode) + ' '; { Pick the appropriate message }
	  writeln('Error:',ExitCode,
			  ' Segment:',Hex(Hi(seg(ErrorAddr^)))+Hex(Lo(seg(ErrorAddr^))),
			  ' Offset:',Hex(Hi(ofs(ErrorAddr^)))+Hex(Lo(ofs(ErrorAddr^))),
              ' ',Message);
{      ErrorAddr:=nil;}
{      ExitCode:=1;   { End program with errorlevel 1 } {Haroldo 2003-05-06 - Removed}
	end;
  ExitProc:=OldExit; { Restore the original exit procedure }
end;
{====================================================================}
begin
  OldExit:=ExitProc;          { Save the original exit procedure }
  ExitProc:=@RunTimeExitProc; { Insert the RunTime exit procedure }
end.
