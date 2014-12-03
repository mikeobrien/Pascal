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
                  normal_state : boolean;
                  current_state : boolean;
                  end;
     a_scroll_bar_data = array[1..300] of string[12];
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
     a_scroll_bar_rec = array[1..2] of r_scroll_bar_rec;
     a_button_rec = array[1..100] of r_button_rec;
     a_screen_map = array[0..79,0..59] of word;
     a_dialog_map = array[0..79,0..59] of word;
     a_bitmap = array[0..79,0..59] of byte;
var
   res : r_res;
   char_size : r_char_size;
   screen_size : r_screen_size;
   screen_map : a_screen_map;
   dialog_map : a_dialog_map;
   button_rec : a_button_rec;
   close_program : boolean;
   mouse_event : tevent;
   event : r_event;
   current_bitmap_color : word;
   bitmap_buffer : a_bitmap;
   original_x,original_y : word;
   scroll_bar_rec : a_scroll_bar_rec;

procedure plaque(state : boolean;x1,y1,x2,y2,background_color : word);
var x,y : word;
begin
     if background_color = 16 then setcolor(3) else
     setcolor(background_color);
     x := 0;y := 0;
     repeat
           rectangle(((x2-x1) div 2) + x1 - x,((y2-y1) div 2) + y1 - y,
                     ((x2-x1) div 2) + x1 + x,((y2-y1) div 2) + y1 + y);
           if x < ((x2-x1) div 2) then x := x + 1;
           if y < ((y2-y1) div 2) then y := y + 1;
     until (x = ((x2-x1) div 2)) and (y = ((y2-y1) div 2));
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
     if button_rec[control_id].current_state = true then
     outtextxy(button_rec[control_id].x1*8+5,
               button_rec[control_id].y1*8+5,
               button_rec[control_id].caption) else
     outtextxy(button_rec[control_id].x1*8+7,
               button_rec[control_id].y1*8+7,
               button_rec[control_id].caption);

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

procedure create_button(x1,y1,x2,y2,text_color,face_color,control_id : word;caption : string;state,check_box : boolean);
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
     {--Background--}
     plaque(true,0,0,640,480,7);
     {--Bitmap--}
     setcolor(8);
     outtextxy(20,10,'Zoom');
     plaque(false,20,20,508,388,15);
     {--Actual Size Box--}
     setcolor(8);
     outtextxy(518,10,'Thumbnail');
     plaque(false,518,20,602,84,0);
     {--Create Buttons--}
     setcolor(8);
     outtextxy(65*8-2,13*8-12,'Palette');
     plaque(true,65*8-3,13*8-3,73*8+3,40*8+3,7);
     create_button(65,13,68,15,11,current_bitmap_color,1,'',false,false);
     create_button(69,13,73,16,8,0,2,'',false,false);
     create_button(65,16,69,19,8,1,3,'',false,false);
     create_button(69,16,73,19,8,2,4,'',false,false);
     create_button(65,19,69,22,8,3,5,'',false,false);
     create_button(69,19,73,22,8,4,6,'',false,false);
     create_button(65,22,69,25,8,5,7,'',false,false);
     create_button(69,22,73,25,8,6,8,'',false,false);
     create_button(65,25,69,28,8,7,9,'',false,false);
     create_button(69,25,73,28,7,8,10,'',false,false);
     create_button(65,28,69,31,8,9,11,'',false,false);
     create_button(69,28,73,31,8,10,12,'',false,false);
     create_button(65,31,69,34,8,11,13,'',false,false);
     create_button(69,31,73,34,8,12,14,'',false,false);
     create_button(65,34,69,37,8,13,15,'',false,false);
     create_button(69,34,73,37,8,14,16,'',false,false);
     create_button(65,37,69,40,8,15,17,'',false,false);
     create_button(69,37,73,40,11,3,18,'TP',false,false);
     create_button(2,55,13,59,1,7,19,'New     F1',true,false);
     create_button(14,55,25,59,1,7,20,'Save    F2',true,false);
     create_button(26,55,37,59,1,7,21,'Save As F3',true,false);
     create_button(38,55,49,59,1,7,22,'Open    F4',true,false);
     create_button(50,55,61,59,1,7,23,'Exit   ESC',true,false);
     create_button(65,43,66,44,0,15,24,'Auto Return',true,true);
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
     event.where_dialog_id := dialog_map[event.where.x,event.where.y];
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

procedure editor_cursor(state : boolean);
begin
     setcolor(15);
     rectangle(original_x*6+25,original_y*6+25,original_x*6+31,original_y*6+31);
     if state = true then setcolor(1) else setcolor(15);
     rectangle(event.where.x*6+25,event.where.y*6+25,event.where.x*6+31,event.where.y*6+31);
     original_x := event.where.x;
     original_y := event.where.y;
end;

procedure clear_bitmap_buffer;
var x,y : word;
begin
     for x := 0 to 79 do for y := 0 to 59 do bitmap_buffer[x,y] := 16;
end;

procedure paint_pixel(x,y,pixel_color : word);
begin
     if pixel_color = 15 then begin
     setcolor(0);
     circle(x*6+28,y*6+28,2);
     SetFillStyle(1,pixel_color);
     floodfill(x*6+28,y*6+28,pixel_color);
     putpixel(520+x,22+y,15);
     end else if pixel_color = 16 then begin
     setcolor(1);
     circle(x*6+28,y*6+28,2);
     SetFillStyle(1,15);
     floodfill(x*6+28,y*6+28,1);
     setcolor(15);
     circle(x*6+28,y*6+28,2);
     putpixel(520+x,22+y,0);
     end else begin
     setcolor(pixel_color);
     circle(x*6+28,y*6+28,2);
     SetFillStyle(1,pixel_color);
     floodfill(x*6+28,y*6+28,pixel_color);
     putpixel(520+x,22+y,pixel_color);
     end;

end;

procedure refresh_bitmap;
var x,y : word;
begin
     plaque(false,20,20,508,388,15);
     for x := 0 to 79 do for y := 0 to 59 do begin
         if bitmap_buffer[x,y] <> 16 then paint_pixel(x,y,bitmap_buffer[x,y]);
     end;
end;

procedure create_pixel(x,y,pixel_color : word);
begin
     paint_pixel(x,y,pixel_color);
     bitmap_buffer[x,y] := pixel_color;
end;


procedure editor_session;
begin
     hidemouse;
     editor_cursor(true);
     repeat
           repeat
                 get_event;
           until (event.what = evmousemove) or (event.what = evmousedown) or (event.what = evmouseup);
           if event.what = evmousemove then editor_cursor(true);
           if event.buttons = 1 then begin
              create_pixel(event.where.x,event.where.y,current_bitmap_color);
              end;
     until event.buttons = 2;
     editor_cursor(false);
     showmouse;

end;

procedure update_palette(x : word);
begin
     current_bitmap_color := x;
     button_rec[1].face_color := current_bitmap_color;
     if x = 16 then button_rec[1].caption := 'TP';
     paint_button(1,false);
     if x = 16 then button_rec[1].caption := '';
     press_button(event.where_screen_id,false);
     if button_rec[24].current_state = true then event.buttons := 2;
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
                2 : update_palette(0);
                3 : update_palette(1);
                4 : update_palette(2);
                5 : update_palette(3);
                6 : update_palette(4);
                7 : update_palette(5);
                8 : update_palette(6);
                9 : update_palette(7);
                10 : update_palette(8);
                11 : update_palette(9);
                12 : update_palette(10);
                13 : update_palette(11);
                14 : update_palette(12);
                15 : update_palette(13);
                16 : update_palette(14);
                17 : update_palette(15);
                18 : update_palette(16);
                19 : begin press_button(19,true);refresh_bitmap;end;
                20 : press_button(20,true);
                21 : press_button(21,true);
                22 : press_button(22,true);
                23 : begin press_button(23,true);exit_program;end;
                24 : paint_check_box(24);
           end;
           if event.buttons = 2 then editor_session;
     until close_program = true;
end;

procedure clear_screen_map;
var x,y : word;
begin
     for x := 1 to 80 do for y := 1 to 60 do screen_map[x,y] := 0;
     for x := 1 to 80 do for y := 1 to 60 do dialog_map[x,y] := 0;
end;

procedure set_varibles;
begin
     clear_bitmap_buffer;
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
     CloseGraph;
end;

procedure paint_splash_screen;
begin
     setfillstyle(1,3);
     floodfill(50,50,1);
     plaque(true,180,200,470,300,7);
     setcolor(1);
     outtextxy(255,220,'The Sprite Painter');
     setcolor(8);
     outtextxy(190,275,'(c)1998 Sietel Information Systems');
     outtextxy(225,285,'Written By Michael O''Brien');
end;

procedure start_mouse;
begin
     setcolor(4);
     outtextxy(273,250,'Initalizing...');
     initevents;
     setcolor(7);
     outtextxy(273,250,'Initalizing...');
end;

procedure startup;
begin
      start_graphics_mode;
      set_varibles;
      paint_splash_screen;
      start_mouse;
      delay(15000);
end;

procedure shutdown;
begin
     end_graphics_mode;
end;

begin
      startup;
      start_paint;
      shutdown;
end.
     