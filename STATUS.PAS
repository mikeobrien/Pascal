uses crt,views;
var x,y : word;
ch : char;
begin
textcolor(14);
textbackground(1);
clrscr;
gotoxy(17,11);Write('Loading...');
gotoxy(17,12);write('旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커');
gotoxy(17,13);write('�                                                  �');
gotoxy(17,14);write('읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸');
repeat
for x := 1 to 50 do begin
gotoxy(17+x,13);
write('�');
end;
randomize;
for x := 1 to 50 do begin
gotoxy(17+x,13);
write('�');
y := random(10000);
delay(y);
if keypressed = true then ch := readkey;
if ch = #59 then halt;
end;
until ch = #59;
textbackground(0);
clrscr;

end.