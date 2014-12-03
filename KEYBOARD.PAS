program electronic_keyboard;
uses dos,crt;
var ch : char;
begin
     repeat
           if keypressed = true then
           begin
           ch := readkey;
           sound(ord(ch)*10);
           repeat
           until keypressed <> true;
           nosound;
           end;
     until ch = #27;
end.