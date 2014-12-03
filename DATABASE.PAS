program product_info;

uses dos,crt;

var ch : char;

procedure twindow(x1,y1,x2,y2 : word);
var  x,y : word;
begin
     window(x1,y1,x2,y2);
     window(1,1,80,25);
     gotoxy(x1,y1);
     textcolor(14);
     textbackground(4);
     write('Ú');
     for x := 1 to (x2-x1-1) do write('Ä');write('¿');
     
     for x := 1 to (y2-y1-1) do begin
                                     gotoxy(x1,y1+x);
                                     write('³');
                                     for y := 1 to (x2-x1-1) do write(' ');
                                     write('³');
                                end;
     gotoxy(x1,y2);
     
     write('À');
     for x := 1 to (x2-x1-1) do write('Ä');write('Ù');
     window(x1+1,y1+1,x2-1,y2-1);
end;

procedure set_background_clear;
begin
     textbackground(1);
     textcolor(14);
     clrscr;
     window(1,25,80,25);
     textbackground(7);
     clrscr;
     write(' Exit  Memory  Processors  Misc  Custom  Data');
     window(1,1,80,25);
end;

procedure set_background_exit;
begin
     textbackground(1);
     textcolor(14);
     clrscr;
     window(1,25,80,25);
     textbackground(7);
     clrscr;
     write(' ');textbackground(4);
     write('Exit');textbackground(7);write('  Memory  Processors  Misc  Custom  Data');
     twindow(2,22,20,24);
     gotoxy(2,2);
     write('  Exit?(Y/N)');
     window(1,1,80,25);
end;

procedure set_background_memory;
begin
     textbackground(1);
     textcolor(14);
     clrscr;
     window(1,25,80,25);
     textbackground(7);
     clrscr;
     write(' Exit  ');textbackground(4);
     write('Memory');textbackground(7);write('  Processors  Misc  Custom  Data');
     twindow(1,1,80,24);
     window(1,1,80,25);
end;

procedure set_background_processor;
begin
     textbackground(1);
     textcolor(14);
     clrscr;
     window(1,25,80,25);
     textbackground(7);
     clrscr;
     write(' Exit  Memory  ');textbackground(4);
     write('Processors');textbackground(7);write('  Misc  Custom  Data');
     twindow(1,1,80,24);
     window(1,1,80,25);
end;

procedure set_background_misc;
begin
     textbackground(1);
     textcolor(14);
     clrscr;
     window(1,25,80,25);
     textbackground(7);
     clrscr;
     write(' Exit  Memory  Processors  ');textbackground(4);
     write('Misc');textbackground(7);write('  Custom  Data');
     twindow(1,1,80,24);
     window(1,1,80,25);
end;

procedure set_background_custom;
begin
     textbackground(1);
     textcolor(14);
     clrscr;
     window(1,25,80,25);
     textbackground(7);
     clrscr;
     write(' Exit  Memory  Processors  Misc  ');textbackground(4);
     write('Custom');textbackground(7);write('  Data');
     twindow(1,1,80,24);
     window(1,1,80,25);
end;

procedure set_background_data;
begin
     textbackground(1);
     textcolor(14);
     clrscr;
     window(1,25,80,25);
     textbackground(7);
     clrscr;
     write(' Exit  Memory  Processors  Misc  Custom  ');textbackground(4);
     write('Data');textbackground(7);
     twindow(1,1,80,24);
     window(1,1,80,25);
end;

begin
     set_background_clear;
     ch := readkey;
     set_background_exit;
     ch := readkey;
     set_background_memory;
     ch := readkey;
     set_background_processor;
     ch := readkey;
     set_background_misc;
     ch := readkey;
     set_background_custom;
     ch := readkey;
     set_background_data;
     ch := readkey;


end.