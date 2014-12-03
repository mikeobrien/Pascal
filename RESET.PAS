program reset_partition;
{$M 4000,0,0 }
uses dos,crt;

var
   inifile : text;
   cmdline,programfile : string;
   ch : char;
   finding,x,y : word;

procedure line(x1,x2,y1,y2 : word;hor : boolean);
begin
     if hor = true then
        for x := x1 to x2 do begin gotoxy(x,y1);write('Í');end else
        for y := y1 to y2 do begin gotoxy(x1,y);write('º');end;
end;

procedure box(x1,y1,x2,y2,tc,tb : word);
begin
     textcolor(tc);
     textbackground(tb);
     window(x1,y1,x2,y2);
     clrscr;
     window(1,1,80,25);
     line(x1,x2,y1,y1,true);
     line(x1,x2,y2,y2,true);
     line(x1,x1,y1,y2,false);
     line(x2,x2,y1,y2,false);
     gotoxy(x1,y1);write('É');
     gotoxy(x1,y2);write('È');
     gotoxy(x2,y1);write('»');
     gotoxy(x2,y2);write('¼');
     window(x1+1,y1+1,x2-1,y2-1);

end;

procedure getini;
begin
     assign(inifile,'reset.dat');
     {$I-}
     reset(inifile);
     finding := ioresult;
     {$I+}
     if finding <> 0 then begin
                          rewrite(inifile);
                          writeln(inifile,'d:\ghost\ghost.exe');
                          writeln(inifile,' -clone,mode=pload,src=d:\image\mm66.gho:1,dst=1:1 -sure -rb');
                          close(inifile);
                          reset(inifile);
                          end;
     readln(inifile,programfile);
     readln(inifile,cmdline);
     close(inifile);
end;

procedure runghost;
begin

SwapVectors;
Exec(Programfile, CmdLine);
SwapVectors;
end;

procedure main;
begin
     window(1,1,80,25);
     textcolor(15);
     textbackground(0);
     clrscr;
     getini;
     box(12,10,68,17,14,1);
     gotoxy(12,2);
     write('Do you want to reset the Machine?');
     gotoxy(8,3);
     write('Press R to reset or any key to continue.');
     x := 11;
     window(1,1,80,25);
     repeat
     x := x -1;
     gotoxy(40,15);
     write(x,' ');
     gotoxy(1,1);
     delay(7000);
     until (x = 0) or (keypressed = true);
     
     textcolor(15);
     textbackground(0);

     clrscr;
     if keypressed = true then ch := readkey;
     if (ch = 'r') or (ch = 'R') then runghost;
     
end;

begin
     main;
end.

