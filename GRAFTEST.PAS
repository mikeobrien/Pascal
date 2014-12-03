program testgraph;

uses dos,crt,graph;

type r_res = record
                   x : integer;
                   y : integer;
             end;
     r_char_size = record
                 x : integer;
                 y : integer;
             end;
     r_screen_size = record
                 cols : integer;
                 rows : integer;
             end;

var
   xx,yy,x,y,z,zz : word;
   ch : char;
   res : r_res;
   char_size : r_char_size;
   screen_size : r_screen_size;
   direction : boolean;
procedure writeg(x,y : word;text_ : string);
begin
     outtextxy(x*(char_size.x-1),y*(char_size.y-1),text_);
end;

procedure start_graphics_mode;
var graphics_error_code,graphics_driver,graphics_mode : integer;
begin
     graphics_driver := detect;
     InitGraph(graphics_driver,graphics_mode,'');
     graphics_error_code := graphresult;
     if graphics_error_code <> grok then
        begin
             writeln('Graphics Error(',graphics_error_code,')');
             writeln('Driver = ',graphics_driver,' / Mode = ',graphics_mode);
             halt;
        end;
end;

procedure map_screen;
begin
     setcolor(4);
     for xx := 1 to screen_size.cols do for yy := 1 to screen_size.rows do
     rectangle(((xx*char_size.x)-char_size.x)+1,((yy*char_size.y)-char_size.y)+1,
               (xx*char_size.x),(yy*char_size.y));
end;

procedure set_varibles;
begin
     screen_size.cols := 80;
     screen_size.rows := 25;
     res.x := getmaxx;
     res.y := getmaxy;
     char_size.x := (res.x + 1) div screen_size.cols;
     char_size.y := (res.y + 1) div screen_size.rows
end;

begin
      start_graphics_mode;
      randomize;
      zz := 2;xx := 0;direction := true;
      repeat
           x := random(640);
           y := random(480);
           z := random(zz);
           if z <> 0 then putpixel(x,y,z);
           ch := ' ';
           if keypressed = true then ch := readkey;
           if (ch = #72) and (zz < 16) then zz := zz + 1;
           if (ch = #80) and (zz > 2) then zz := zz - 1;
           xx := xx + 1;
           if x = 1000 then begin
              xx := 0;
              if zz = 1 then direction := true;
              if zz = 15 then direction := false;
              if direction = true then zz := zz + 1;
              if direction = false then zz := zz -1;
           end;
      until ch = #27;
      CloseGraph;
      restorecrtmode;
   
end.
     