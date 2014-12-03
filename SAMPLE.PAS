program testgraph;

{StackSize, HeapMin, HeapMax}
{M 3000,0,655360}

uses dos,crt,graph,drivers;

const
  day : array [1..31] of String[2] =
    ('1','2','3','4','5','6','7','8','9','10','11','12','13','14',
     '15','16','17','18','19','20','21','22','23','24','25','26','27','28'
     ,'29','30','31');
  month : array[1..12] of string[2] =
     ('1','2','3','4','5','6','7','8','9','10','11','12');
  year : array[1998..2010] of string[4] =
     ('1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008'
     ,'2009','2010');


type
	r_res = record
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
                  caption_length : byte;
                  normal_state : boolean;
                  current_state : boolean;
                  bitmap : string[15];
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
               keypressed : boolean;
               key : char;
               end;
     	a_button_rec = array[1..20] of r_button_rec;
     	a_screen_map = array[0..79,0..59] of word;
     	a_bitmap = array[0..79,0..59] of byte;
var
 	res : r_res;
   	char_size : r_char_size;
   	screen_size : r_screen_size;
   	screen_map : a_screen_map;
 	button_rec : a_button_rec;
 	mouse_event : tevent;
   	event : r_event;
 	finding : word;
 	current_bitmap : a_bitmap;
   	original_x,original_y : word;
 	text_style : string;
 	date,uppercase,working_directory,data_directory : string;
	d,m,y,dow : word;

procedure clear_screen_map;
var x,y : word;
begin
     for x := 1 to 80 do for y := 1 to 60 do screen_map[x,y] := 0;

end;

procedure make_uppercase(S: string);
var
  I: Integer;
begin
  for I := 1 to Length(S) do
  if (S[I] >= 'a') and (S[I] <= 'z') then
  Dec(S[I], 32);
  uppercase := S;
end;


procedure get_date;
begin
     {GetDate(var Year, Month, Day, DayOfWeek: Word)}
     getdate(y,m,d,dow);
     date := month[m];
     date := date + '/' + day[d];
     date := date + '/' + year[y];
end;




procedure plaque(state : boolean;x1,y1,x2,y2,background_color : word);
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

procedure putbitmap(bitmapfile : string;x,y : word);
var z,zz : word;
begin
     {$I-}
      assign(bitmap_file,working_directory+'\'+bitmapfile);
      reset(bitmap_file);
      read(bitmap_file,current_bitmap);
      finding := ioresult;
     {$I+}
     if finding = 0 then begin
      for z := 0 to 79 do for zz := 0 to 59 do if current_bitmap[z,zz] <> 16 then putpixel(z+x,zz+y,current_bitmap[z,zz]);
     close(bitmap_file);end;
end;

procedure paint_window(x1,y1,x2,y2,face_color,title_bar_color,title_bar_textcolor : word;title_bar_text,bitmap : string);
var x : word;
begin
     if text_style = 'norm' then x := 0 else x := 5;
     plaque(true,x1*8,y1*8,x2*8,y2*8,face_color);
     setcolor(title_bar_textcolor);
     setfillstyle(1,title_bar_color);
     bar(x1*8+3,y1*8+3,x2*8-3,y1*8+20);
     if bitmap = '' then outtextxy(x1*8+10,y1*8+7,title_bar_text) else
     begin
          putbitmap(bitmap,x1*8+6,y1*8+4);
          outtextxy(x1*8+27,y1*8+2+x,title_bar_text);
     end;
end;

     

procedure capture_screen(x1,y1,x2,y2 : word);
begin
     Size := ImageSize(x1,y1,x2,y2);
     GetMem(P, Size);
     GetImage(x1,y1,x2,y2,P^);
end;

procedure replace_screen(x,y : word);
begin
     hidemouse;
     PutImage(x, y, P^, NormalPut);
     showmouse;
end;

procedure paint_button(control_id : word;check_box : boolean);
var x : word;
begin
     if text_style = 'norm' then x := 0 else x := 5;
     if check_box = false then begin
     plaque(button_rec[control_id].current_state,
            button_rec[control_id].x1*8,
            button_rec[control_id].y1*8,
            button_rec[control_id].x2*8,
            button_rec[control_id].y2*8,
            button_rec[control_id].face_color);
            setcolor(button_rec[control_id].text_color);
     if button_rec[control_id].current_state = true then begin
     if button_rec[control_id].bitmap <> '' then begin
     putbitmap(button_rec[control_id].bitmap,
               button_rec[control_id].x1*8+5,
               button_rec[control_id].y1*8+5);
     outtextxy(button_rec[control_id].x1*8+39,
               button_rec[control_id].y1*8+x,
               button_rec[control_id].caption);end else
     outtextxy(button_rec[control_id].x1*8+5,
               button_rec[control_id].y1*8+x,
               button_rec[control_id].caption);end else
     if button_rec[control_id].bitmap <> '' then begin
     putbitmap(button_rec[control_id].bitmap,
               button_rec[control_id].x1*8+7,
               button_rec[control_id].y1*8+7);
     outtextxy(button_rec[control_id].x1*8+41,
               button_rec[control_id].y1*8+2+x,
               button_rec[control_id].caption);end else
     outtextxy(button_rec[control_id].x1*8+7,
               button_rec[control_id].y1*8+2+x,
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
     if text_style = 'bold' then outtextxy(button_rec[control_id].x2*8+7,
               button_rec[control_id].y1*8+1,
               button_rec[control_id].caption) else
               outtextxy(button_rec[control_id].x2*8+7,
               button_rec[control_id].y1*8-5,
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

procedure create_button(x1,y1,x2,y2,text_color,face_color,control_id : word;caption,bitmap : string;state,check_box : boolean);
var x,y,z : word;
begin
     for x := (x1) to (x2-1) do for y := (y1) to (y2-1) do screen_map[x,y] := control_id;
     button_rec[control_id].x1 := x1;
     button_rec[control_id].y1 := y1;
     button_rec[control_id].x2 := x2;
     button_rec[control_id].y2 := y2;
     button_rec[control_id].text_color := text_color;
     button_rec[control_id].face_color := face_color;
     button_rec[control_id].caption := caption;
     button_rec[control_id].normal_state := state;
     button_rec[control_id].current_state := state;
     button_rec[control_id].bitmap := bitmap;
     paint_button(control_id,check_box);
end;

procedure create_text_box(x1,y1,text_color,face_color,control_id,length : word;caption : string);
begin
     create_button(x1,y1,x1+length+2,y1+3,text_color,face_color,control_id,caption,'',true,false);
     button_rec[control_id].caption_length := length;
end;



procedure button_state(control_id : word;state : boolean);
begin
     button_rec[control_id].current_state := state;
end;

procedure get_event;
var ch : char;
begin
     GetMouseEvent(mouse_event);
     if keypressed = true then begin
        event.key := readkey;
        event.keypressed := true;
        end else event.keypressed := false;
     event.what := mouse_event.what;
     event.buttons := mouse_event.buttons;
     event.double := mouse_event.double;
     event.where.x := mouse_event.where.x;
     event.where.y := mouse_event.where.y;
     event.where_screen_id := screen_map[event.where.x,event.where.y];
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

procedure edit_text_box(control_id : word;upper_case : boolean);
var input : string;x,c : word;
begin
     hidemouse;
     button_state(control_id,false);
     c := button_rec[control_id].face_color;
     button_rec[control_id].face_color := 15;
     paint_button(control_id,false);
     showmouse;
     repeat
           get_event;
           if event.keypressed = true then begin
              hidemouse;
              if (event.key > chr(31)) and (event.key < chr(254)) and
              (length(button_rec[control_id].caption) < button_rec[control_id].caption_length) then begin
              button_rec[control_id].caption := button_rec[control_id].caption +
                   event.key;
              if upper_case = true then begin
              make_uppercase(button_rec[control_id].caption);
              button_rec[control_id].caption := uppercase;
              end;
              paint_button(control_id,false);end;
              if (event.key = #8) and
              (length(button_rec[control_id].caption) > 0) then begin
              input := '';
              for x := 1 to length(button_rec[control_id].caption) - 1 do input := input + 
              button_rec[control_id].caption[x];
              button_rec[control_id].caption := input;
              if upper_case = true then begin
              make_uppercase(button_rec[control_id].caption);
              button_rec[control_id].caption := uppercase;
              end;
              paint_button(control_id,false);end;
              showmouse;
           end;
     until (event.where_screen_id <> control_id) and (event.buttons = 1);
     hidemouse;
     if upper_case = true then begin
     make_uppercase(button_rec[control_id].caption);
     button_rec[control_id].caption := uppercase;
     end;
     button_state(control_id,true);
     button_rec[control_id].face_color := c;
     paint_button(control_id,false);
     showmouse;
     done := false;
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
     RestoreCrtMode;
end;

procedure start_mouse;
begin
     initevents;
     showmouse;
end;




procedure save_settings;
var settings_file : text;
begin
     assign(settings_file,'inventor.ini');
     rewrite(settings_file);
     writeln(settings_file,working_directory);
     writeln(settings_file,data_path);
     writeln(settings_file,text_style);
     close(settings_file);
end;

procedure get_settings;
var settings_file : text;
begin
     assign(settings_file,'inventor.ini');
     {$I-}
     reset(settings_file);
     finding := ioresult;
     {$I+}
     if finding <> 0 then begin
        working_directory := 'c:\inventor\';
        data_path := 'c:\inventor\';
        text_style := 'bold';
        save_settings;
     end else begin
     readln(settings_file,working_directory);
     readln(settings_file,data_path);
     readln(settings_file,text_style);
     close(settings_file);
     end;
end;

procedure paint_main_window;
var current_date : string;
begin
     	hidemouse;
     	{--Create Window--}
     	paint_window(25,12,56,45,7,1,15,'Inventory Manager','wt.bmp');
	{--Create Buttons--}     
	create_button(29,17,52,22,1,7,1,'Button1','window.bmp',true,false);
	showmouse;
end;


procedure init_main;
begin
     paint_main_window;

     repeat
           repeat
           get_event;
           until ((event.buttons = 1) or (event.buttons = 2)) and (event.what = evmousedown);
           if event.buttons = 1 then
           case event.where_screen_id of
               1 : begin press_button(1,true);add_rec;end;
               2 : begin press_button(2,true);view_rec;end;
               3 : begin press_button(3,true);view_history;end;
               4 : begin press_button(4,true);settings;end;
               5 : begin press_button(5,true);close_program := true;end;
           end;
           if (event.keypressed = true) and (event.key = #27) then close_program := true;
     until close_program = true;
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
end;

procedure paint_splash_screen;
var x : word;
begin
     if text_style = 'norm' then x := 5 else x := 0;
     setfillstyle(1,3);
     floodfill(50,50,1);
     plaque(true,180,200,470,300,7);
     setcolor(1);
     outtextxy(225,220-x,'Support Inventory Manager');
     setcolor(8);
     outtextxy(215,275-x,'Wallkill Information Systems');
end;


procedure startup;
begin
      get_settings;
      set_varibles;
      chdir(working_directory);
      start_graphics_mode;
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
     
