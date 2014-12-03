PROGRAM BATCH_INPUT;
{$M 8192,0,0}
uses Dos,crt;
var
  Command: string[79];
  I,x,y,ox,oy : WORD;
  ch,driveletter : char;
  cmdline,drive : string;
  currdrive : byte;

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

begin
       {$I-}
       drive := 'misc';
       ChDir('c:\misc');
       if IOResult <> 0 then drive := '';
       {$I+}
       WriteLn('Type ''EXIT'' to return to Windows.');
       ox := wherex;oy := wherey;
       textcolor(15);textbackground(0);
       repeat
       currdrive := 0;cmdline := '';
       GetDir(currdrive,cmdline);
       write(cmdline,'>');
       readln(command);
       Command := '/C ' + Command;
       SwapVectors;
       Exec(GetEnv('COMSPEC'), Command);
       SwapVectors;
       if DosError <> 0 then WriteLn('Bad Command or File Name');
       until (command = '/C exit');

end.
