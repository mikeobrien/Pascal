program testgraph;

{StackSize, HeapMin, HeapMax}
{$M 3000,0,655360}

uses dos,crt,graph,drivers;

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

     r_button_rec = record
                  x1,y1,x2,y2 : word;
                  text_color : byte;
                  face_color : byte;
                  caption : string;
                  bitmap_file : string[13];
                  normal_state : boolean;
                  current_state : boolean;
                  end;
     a_scroll_bar_data = array[1..100] of string[12];
     r_scroll_bar_rec = record
                      x1,y1,x2,y2 : word;
                      textcolor : byte;
                      face_color : byte;
                      caption : string;
                      face_id : byte;
                      up_button_id : byte;
                      down_button_id : byte;
                      current_marker_pos : word;
                      current_list_pos : word;
                      scroll_bar_data : a_scroll_bar_data;
                      end;

     r_where = record
               x : word;
               y : word;
               end;
     r_event = record
               what : word;
               buttons : byte;
               double : boolean;
               where : r_where;
               where_screen_id : word;
               where_dialog_id : word;
               keypressed : char;
               end;
{     a_scroll_bar_rec = array[1..2] of r_scroll_bar_rec;}
     a_button_rec = array[1..90] of r_button_rec;
     a_screen_map = array[0..79,0..59] of word;
     a_bitmap = array[0..79,0..59] of byte;
var
   res : r_res;
   char_size : r_char_size;
   screen_size : r_screen_size;
   screen_map : a_screen_map;

   button_rec : a_button_rec;
   close_program : boolean;
   mouse_event : tevent;
   event : r_event;
   current_bitmap_color,finding : word;
   put_bitmap,text_screen,current_bitmap : a_bitmap;
   original_x,original_y : word;
{   scroll_bar_rec : a_scroll_bar_rec;}
   bitmap_file : file of a_bitmap;
   bitmap_filename : string;


procedure putbitmap(bitmapfile : string;x,y : word);
var z,zz : word;
begin
     {$I-}
      assign(bitmap_file,bitmapfile);
      reset(bitmap_file);
      read(bitmap_file,current_bitmap);
      finding := ioresult;
     {$I+}
     if finding = 0 then begin
      for z := 0 to 79 do for zz := 0 to 59 do if current_bitmap[z,zz] <> 16 then putpixel(z+x,zz+y,current_bitmap[z,zz]);
     close(bitmap_file);end;
end;


procedure plaque(state : boolean;x1,y1,x2,y2,background_color : integer);
var x,y : word;
begin
     if background_color = 16 then setcolor(3) else
     setcolor(background_color);
     x := 0;y := 0;
     setfillstyle(1,background_color);
     bar(x1,y1,x2,y2);
     {repeat
           rectangle(((x2-x1) div 2) + x1 - x,((y2-y1) div 2) + y1 - y,
                     ((x2-x1) div 2) + x1 + x,((y2-y1) div 2) + y1 + y);
           if x < ((x2-x1) div 2) then x := x + 1;
           if y < ((y2-y1) div 2) then y := y + 1;
     until (x = ((x2-x1) div 2)) and (y = ((y2-y1) div 2));}
     if state = true then begin
     setcolor(7);
     line(x1,y1,x1,y2-1);
     line(x1,y1,x2-1,y1);
     setcolor(15);
     line(x1+1,y1+1,x2-2,y1+1);
     line(x1+1,y1+1,x1+1,y2-2);
     setcolor(8);
     line(x2-1,y2-1,x1+1,y2-1);
     line(x2-1,y2-1,x2-1,y1+1);
     setcolor(0);
     line(x2,y2,x1,y2);
     line(x2,y2,x2,y1);

     end else
     begin
     setcolor(8);
     line(x1,y1,x1,y2-1);
     line(x1,y1,x2-1,y1);
     setcolor(0);
     line(x1+1,y1+1,x2-2,y1+1);
     line(x1+1,y1+1,x1+1,y2-2);
     setcolor(7);
     line(x2-1,y2-1,x1+1,y2-1);
     line(x2-1,y2-1,x2-1,y1+1);
     setcolor(15);
     line(x2,y2,x1,y2);
     line(x2,y2,x2,y1);
     end;
end;

procedure paint_button(control_id : word;check_box : boolean);
begin
     if check_box = false then begin
     plaque(button_rec[control_id].current_state,
            button_rec[control_id].x1*8,
            button_rec[control_id].y1*8,
            button_rec[control_id].x2*8,
            button_rec[control_id].y2*8,
            button_rec[control_id].face_color);
            setcolor(button_rec[control_id].text_color);
     if button_rec[control_id].current_state = true then begin
     outtextxy(button_rec[control_id].x1*8+5,
               button_rec[control_id].y1*8+5,
               button_rec[control_id].caption);
               if button_rec[control_id].bitmap_file <>  'none' then putbitmap(button_rec[control_id].bitmap_file,
                  button_rec[control_id].x1+5,button_rec[control_id].y1+5);end
                else
     outtextxy(button_rec[control_id].x1*8+7,
               button_rec[control_id].y1*8+7,
               button_rec[control_id].caption);
               if button_rec[control_id].bitmap_file <>  'none' then putbitmap(button_rec[control_id].bitmap_file,
                  button_rec[control_id].x1+7,button_rec[control_id].y1+7);
               end;
     if check_box = true then begin
     plaque(false,
            button_rec[control_id].x1*8-2,
            button_rec[control_id].y1*8-2,
            button_rec[control_id].x2*8+2,
            button_rec[control_id].y2*8+2,
            button_rec[control_id].face_color);
     
     setcolor(button_rec[control_id].text_color);
     outtextxy(button_rec[control_id].x2*8+7,
               button_rec[control_id].y1*8+2,
               button_rec[control_id].caption);
     if button_rec[control_id].current_state = true then
     begin
          setcolor(0);
          line(button_rec[control_id].x1*8,
            button_rec[control_id].y1*8,
            button_rec[control_id].x2*8,
            button_rec[control_id].y2*8);
          line(button_rec[control_id].x2*8,
            button_rec[control_id].y1*8,
            button_rec[control_id].x1*8,
            button_rec[control_id].y2*8);
     end;
     if button_rec[control_id].current_state = false then
     begin
          setcolor(15);
          line(button_rec[control_id].x1*8,
            button_rec[control_id].y1*8,
            button_rec[control_id].x2*8,
            button_rec[control_id].y2*8);
          line(button_rec[control_id].x2*8,
            button_rec[control_id].y1*8,
            button_rec[control_id].x1*8,
            button_rec[control_id].y2*8);
     end;
     
     end;
end;

procedure create_button(x1,y1,x2,y2,text_color,face_color,control_id : word;caption,bitmap_file : string;
          state,check_box : boolean);
var x,y,z : word;
begin
     for x := (x1) to (x2) do for y := (y1) to (y2) do screen_map[x,y] := control_id;
     button_rec[control_id].x1 := x1;
     button_rec[control_id].y1 := y1;
     button_rec[control_id].x2 := x2;
     button_rec[control_id].y2 := y2;
     button_rec[control_id].text_color := text_color;
     button_rec[control_id].face_color := face_color;
     button_rec[control_id].caption := caption;
     button_rec[control_id].bitmap_file := bitmap_file;
     button_rec[control_id].normal_state := state;
     button_rec[control_id].current_state := state;
     paint_button(control_id,check_box);
end;

procedure button_state(control_id : word;state : boolean);
begin
     button_rec[control_id].current_state := state;
end;

procedure scroll_box(control_id : word);
begin

end;

procedure paint_main_window;
begin
     hidemouse;


     
     create_button(65,13,68,15,11,current_bitmap_color,1,'','none',false,false);
     
     create_button(2,55,13,59,1,7,19,'New     F1','none',true,false);

     create_button(65,43,66,44,0,15,24,'Auto Return','none',true,true);
     showmouse;
end;

procedure get_event;
var ch : char;
begin
     GetMouseEvent(mouse_event);
     if keypressed = true then ch := readkey;
     event.what := mouse_event.what;
     event.buttons := mouse_event.buttons;
     event.double := mouse_event.double;
     event.where.x := mouse_event.where.x;
     event.where.y := mouse_event.where.y;
     event.where_screen_id := screen_map[event.where.x,event.where.y];
     
     event.keypressed := ch;
end;

procedure press_button(control_id : word;paint : boolean);
begin
     if paint = true then begin
     hidemouse;
     button_state(control_id,false);
     paint_button(control_id,false);
     showmouse;end;
     repeat
           get_event;
     until event.what = evMouseup;
     delay(100);
     if paint = true then begin
     hidemouse;
     button_state(control_id,true);
     paint_button(control_id,false);
     showmouse;
     end;
end;

procedure paint_check_box(control_id : word);
begin
     hidemouse;
     if button_rec[control_id].current_state = true then begin
        button_rec[control_id].current_state := false;
        paint_button(control_id,true);
     end else
     if button_rec[control_id].current_state = false then begin
        button_rec[control_id].current_state := true;
        paint_button(control_id,true);
     end;
     showmouse;
end;



procedure exit_program;
var ch : char;
begin
    close_program := true;
end;

procedure paint_pixel(x,y,pixel_color : word);
begin
     if pixel_color = 15 then begin
     setcolor(0);
     circle(x,y,2);
     SetFillStyle(1,pixel_color);
     floodfill(x,y,pixel_color);
     putpixel(520+x,22+y,15);
     end else if pixel_color = 16 then begin
     setcolor(1);
     circle(x,y,2);
     SetFillStyle(1,15);
     floodfill(x,y,1);
     setcolor(15);
     circle(x,y,2);
     putpixel(520+x,22+y,0);
     end else begin
     setcolor(pixel_color);
     circle(x,y,4);
     SetFillStyle(1,pixel_color);
     floodfill(x,y,pixel_color);

     end;

end;




procedure percentile(x,y,speed : word);
var xx : word;
begin
     plaque(false,x+1,y,x+204,y+30,15);
     setcolor(4);
     for xx := 1 to 200 do begin
         delay(speed);
         hidemouse;
         line(xx+2+x,y+2,xx+2+x,y+28);
         showmouse;
         end;
end;




procedure start_paint;
begin
     paint_main_window;
     repeat
           repeat
           get_event;
           until ((event.buttons = 1) or (event.buttons = 2)) and (event.what = evmousedown);
           if event.buttons = 1 then
           case event.where_screen_id of
             1 : writeln;
           end;
           
     until event.buttons = 1;
end;

procedure clear_screen_map;
var x,y : word;
begin
     for x := 1 to 80 do for y := 1 to 60 do screen_map[x,y] := 0;

end;

procedure set_varibles;
begin
     
     
     clear_screen_map;
     screen_size.cols := 80;
     screen_size.rows := 25;
     res.x := getmaxx;
     res.y := getmaxy;
     char_size.x := (res.x + 1) div screen_size.cols;
     char_size.y := (res.y + 1) div screen_size.rows;
     close_program := false;
     current_bitmap_color := 1;
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

procedure end_graphics_mode;
begin
     restorecrtmode;
end;

      

procedure login_screen;
var ch : char;wrong : boolean;x,y,z,a : word;password : string;
begin
     textcolor(7);textbackground(0);
     clrscr;
     gotoxy(49,1);
     write('  rÑdcvà llï t êwsqÅ Ütymg òsÖfR');
     gotoxy(59,2);
     write('    Ütmsp Ä jswîq çk è');
     gotoxy(69,3);
     writeln('   ...ëdwÇhF');
     delay(8000);
     gotoxy(54,4);
     write('   [18400001:6720578] flsâè');
     delay(10000);
     gotoxy(73,5);
     write('  ÅlgsïC');
     x := 75;y := 5;
     for z := 1 to 15 do begin gotoxy(x-z,y);write('.');gotoxy(1,1);delay(2000);end;
     gotoxy(66,6);
     write('   ...îjsuá hÅF');
     delay(9000);
     gotoxy(75,7);
     write('swÜhåG');
     randomize;
     x := wherex;y := wherey;
     for z := 1 to 100 do begin gotoxy(70,7);write('%',z);a := random(2000);gotoxy(1,1);delay(a);end;
     gotoxy(67,8);
     write(' .tndã Åsw çdö');
     delay(10000);
     start_graphics_mode;
     initevents;
     hidemouse;
     setfillstyle(1,3);
     bar(1,1,640,480);
     showmouse;
     repeat
     hidemouse;
     plaque(true,170,200,475,300,7);
     putbitmap('keys.bmp',180,210);
     putbitmap('aribic_a.bmp',385,215);
     putbitmap('aribic_j.bmp',374,215);
     putbitmap('aribic_d.bmp',360,215);
     putbitmap('aribic_j.bmp',340,215);
     putbitmap('aribic_f.bmp',330,215);
     plaque(false,238,240,410,265,15);
     x := 0;password := '';
     ch := ' ';
     showmouse;
     repeat
           if keypressed = true then begin
           hidemouse;
           ch := readkey;
           if (x <> 14) and (ch <> #13) and (ch <> #8) then begin
              x := x + 1;
              paint_pixel(400-x*10,252,4);
              password := password + ch;
           end;
           if (ch = #8) and (x > 0) then begin
              paint_pixel(400-x*10,252,15);
              x := x - 1;
             end;
           showmouse;
           end;
     until ch = #13;

     wrong := false;
     if password <> 'bigshow' then begin
     plaque(true,170,200,475,300,7);
     putbitmap('aribic_j.bmp',320,235);
     putbitmap('aribic_f.bmp',310,235);
     putbitmap('x.bmp',340,240);
     putbitmap('x.bmp',290,240);
     sound(1000);
     delay(1500);
     nosound;
     delay(10000);
     wrong := true;
     end;
     until wrong = false;
     plaque(true,170,200,475,300,7);
     putbitmap('aribic_j.bmp',374,215);
     putbitmap('aribic_d.bmp',390,215);
     putbitmap('aribic_j.bmp',380,215);
     percentile(225,240,200);
     delay(2000);
     plaque(true,170,200,475,300,7);
     setfillstyle(1,3);
     floodfill(200,200,4);
     delay(1500);
     
end;

procedure start_mouse;
begin
     initevents;
end;

procedure startup;
begin
      set_varibles;
      
      login_screen;
      
end;

procedure shutdown;
begin
     end_graphics_mode;
     
end;

begin
      startup;
      {start_paint;}
      shutdown;
end.
     