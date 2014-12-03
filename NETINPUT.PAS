PROGRAM BATCH_INPUT;
{$M 8192,0,0}
uses Dos,crt;
var
  Command: string[79];
  I,x,y,ox,oy : WORD;
  ch : char;

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
       ox := wherex;oy := wherey;
       box(20,7,50,16,14,1);
       textcolor(14);
       writeln('Enter the NIC type:');
       textcolor(15);
       writeln('1=AMD NIC');
       writeln('2=3C509 NIC');
       writeln('ESC=Abort');
       repeat
             ch := readkey;
       until (ch = '1') or (ch = '2') or (ch = #27);
       if ch = '1' then command := 'loadnet amd';
       if ch = '2' then command := 'loadnet 3c509';
       if ch = #27 then begin window(20,7,50,16);
       textbackground(0);
       clrscr;
       window(1,1,80,25);
       gotoxy(ox,oy);
       writeln;halt;end;


      {

       writeln('Is the NIC configured?');
       writeln('F1 to configure');
       writeln('ENTER to continue');
       repeat
             ch := readkey;
       until (ch = #59) or (ch = #13);
       if ch = #59 then command := 'loadcfg';
       if ch = #13 then halt;}
       

       Command := '/C ' + Command;
       SwapVectors;
       Exec(GetEnv('COMSPEC'), Command);
       SwapVectors;
       if DosError <> 0 then
       WriteLn('Could not execute COMMAND.COM');
       window(20,7,50,16);
       textbackground(0);
       clrscr;
       window(1,1,80,25);
       gotoxy(ox,oy);
       writeln;
end.
