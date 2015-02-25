unit Joystick;
{FightX Game System - Rotinas de joystick e teclado}
{programado por Haroldo de Oliveira Pinheiro}
interface
    const
        _JOY_UP   = $01;
        _JOY_DOWN = $02;
        _JOY_LEFT = $04;
        _JOY_RIGHT= $08;
        _JOY_BTN1 = $10;
        _JOY_BTN2 = $20;
    function GetKeyJoyState(Up,Down,Left,Right,Btn1,Btn2:byte):byte;
    function ReadLeftJoy:byte;
    function ReadRightJoy:byte;
implementation
    uses Keybd;
    function GetKeyJoyState(Up,Down,Left,Right,Btn1,Btn2:byte):byte;
        var State:byte;
        begin
            State:=0;
            if Keys[Up] then
                State:=State or $01;
            if Keys[Down] then
                State:=State or $02;
            if Keys[Left] then
                State:=State or $04;
            if Keys[Right] then
                State:=State or $08;
            if Keys[Btn1] then
                State:=State or $10;
            if Keys[Btn2] then
                State:=State or $20;
            GetKeyJoyState:=State;
        end;
    function ReadLeftJoy:byte;
        begin
            ReadLeftJoy:=GetKeyJoyState(scUp,scDown,scLeft,scRight,scCtrl,scAlt);
        end;
    function ReadRightJoy:byte;
        begin
            ReadRightJoy:=GetKeyJoyState(scU,scJ,scH,scK,scS,scD);
        end;
End.