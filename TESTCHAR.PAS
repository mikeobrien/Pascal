uses crt;
var x,z : word;ch : char;
begin
     repeat
     ch := readkey;
     for x := 1 to 225 do if ch = chr(x) then z := x;
     writeln(z);
     until ch = #27;
end.