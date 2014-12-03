uses dos,crt;
var x : word;test_file : text;test_string : string;
begin
     assign(test_file,'test.$$$');
     repeat
     rewrite(test_file);
     test_string := '                                                           ';
     for x := 1 to 1000 do write(test_file,test_string);
     close(test_file);
     until keypressed = true;
end.