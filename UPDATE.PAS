program update;

var x,y,z : word;
    input,output : text;
    ,out : string;

procedure no_quotes;
begin
     for x := 1 to len
begin
     assign(input,'drive.txt');
     assign(output,'CD_info.txt');
     reset(input);
     rewrite(output);
     writeln(output,'Drive Information for WCDROM4');
     writeln(output,'');
     writeln(output,'Share           CD-ROM                      Contact             Date');
     writeln('----------------------------------------------------------------------------------');
     repeat
        read
     until EOF(input);
     close(input);
     close(output);
end.