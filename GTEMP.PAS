program testgraph;

{StackSize, HeapMin, HeapMax}
{M 3000,0,655360}

uses dos,crt,graph,drivers;

const
  drive : array[1..8] of string = ('A:','B:','C:','D:','E:','F:','G:','H:');
      startup_text : string = 'Super Boot Disk v1.0';
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
    a_scroll = array[1..5] of string;
        a_screen_bit  = array[1..20] of pointer;
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
        a_port = array[0..6] of word;
     	r_button_rec = record
                  x1,y1,x2,y2 : word;
                  text_color : byte;
                  face_color : byte;
                  caption : string;
                  caption_length : byte;
                  menu_option : boolean;
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
        item_rec = record
                   item,value : string[15];
                   end;
        a_scroll_data = array[1..20] of item_rec;
        r_scroll_rec = record
                       x1,y1,x2,y2 : word;
                       bc,tc,selection,control_id_1,control_id_2 : word;
                       data : a_scroll_data;
                       end;
     	a_button_rec = array[1..20] of r_button_rec;
     	a_screen_map = array[0..79,0..59] of word;
     	a_bitmap = array[0..79,0..59] of byte;
var
        settings_file : text;
        default_name : string;
        default_share : boolean;
        screen_bit : a_screen_bit;
 	res : r_res;
   	char_size : r_char_size;
   	screen_size : r_screen_size;
   	screen_map : a_screen_map;
        pass : boolean;
 	button_rec : a_button_rec;
 	mouse_event : tevent;
        port : a_port;
   	event : r_event;
 	finding : word;
        bitmap_file : file of a_bitmap;
 	current_bitmap : a_bitmap;
   	original_x,original_y : word;
 	text_style : string;
 	date,uppercase,working_directory,data_directory : string;
	d,m,y,dow : word;
        scroll_rec : r_scroll_rec;
        p,button,old_bit : pointer;
        done,first : boolean;
        scroll : a_scroll;
        first_name,last_name,node,teller_list,account_num,amount : string;
  tran_type : string;
  record_amt : integer;
  value,output_string : string;
  output : text;
   x,z : longint;
   ch : char;
   path : string;
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
      assign(bitmap_file,bitmapfile);
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
var size : word;
begin
     Size := ImageSize(x1,y1,x2,y2);
     GetMem(p, Size);
     GetImage(x1,y1,x2,y2,p^);
end;



procedure replace_screen(x,y : word);
begin
     hidemouse;
     x := x;
     y := y;
     PutImage(x, y, p^, NormalPut);
     showmouse;
end;

procedure paint_button(control_id : word;check_box : boolean);
var x : word;
begin
     if button_rec[control_id].menu_option = false then begin
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
     end
     else begin
          if button_rec[control_id].current_state = true then
          setfillstyle(1,button_rec[control_id].face_color) else
          setfillstyle(1,1);
          bar(button_rec[control_id].x1*8,
            button_rec[control_id].y1*8,
            button_rec[control_id].x2*8,
            button_rec[control_id].y2*8);
            if (button_rec[control_id].text_color = 1) and (button_rec[control_id].current_state = false)
               then setcolor(15) else
              setcolor(button_rec[control_id].text_color);
            outtextxy(button_rec[control_id].x1*8+4,
               button_rec[control_id].y1*8+4,
               button_rec[control_id].caption);
    end;
end;

procedure create_button(x1,y1,x2,y2,text_color,face_color,control_id : word;caption,bitmap : string;state,
          check_box,menu_item : boolean);
var x,y,z : word;
begin
     for x := (x1) to (x2-1) do for y := (y1) to (y2-1) do screen_map[x,y] := control_id;
     button_rec[control_id].menu_option := menu_item;
     button_rec[control_id].x1 := x1;
     button_rec[control_id].y1 := y1;
     button_rec[control_id].x2 := x2;
     button_rec[control_id].y2 := y2;
     button_rec[control_id].text_color := text_color;
     button_rec[control_id].face_color := face_color;
     button_rec[control_id].caption := caption;
     button_rec[control_id].current_state := state;
     button_rec[control_id].bitmap := bitmap;
     paint_button(control_id,check_box);
end;

procedure create_text_box(x1,y1,text_color,face_color,control_id,length : word;caption : string);
begin
     create_button(x1,y1,x1+length+2,y1+3,text_color,face_color,control_id,caption,'',false,false,false);
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

procedure press_button(control_id : word;paint,argument : boolean);
var argument_case : word;a : longint;
begin
     a := 0;
     if paint = true then begin
     hidemouse;
     button_state(control_id,false);
     paint_button(control_id,false);
     showmouse;end;
     get_event;
     hidemouse;
     showmouse;
     if argument = false then
     repeat
           get_event;
           
     until ((event.what = evmousemove) and (event.where_screen_id <> control_id)) or (event.what = evmousedown) else
     repeat
           get_event;
           
     until event.what = evmouseup;
     delay(100);
     if paint = true then begin
     hidemouse;
     button_state(control_id,true);
     paint_button(control_id,false);
     showmouse;
     end;
end;

procedure edit_text_box(control_id : word;upper_case : boolean;mask : char);
var input,command_line : string;x,c : word;cur : longint;cur_state : boolean;
begin
     hidemouse;
     button_state(control_id,false);
     command_line := button_rec[control_id].caption;
     c := button_rec[control_id].face_color;
     button_rec[control_id].face_color := 15;
     if mask <> chr(32) then for x := 1 to length(command_line) do button_rec[control_id].caption[x] := mask;
     paint_button(control_id,false);
     showmouse;
     cur := 80000;cur_state := true;
     
     repeat
           get_event;
           cur := cur + 1;
           if cur = 80001 then begin
              hidemouse;
              cur := 0;
              if cur_state = true then cur_state := false else cur_state := true;
              if cur_state = true then begin
                 setcolor(0);
                 line((button_rec[control_id].x1*8)+(length(button_rec[control_id].caption) * 8) + 8,
                      (button_rec[control_id].y1*8)+5,
                      (button_rec[control_id].x1*8)+(length(button_rec[control_id].caption) * 8) + 8,
                      (button_rec[control_id].y1*8)+17);
              end else begin
                  setcolor(button_rec[control_id].face_color);
                  line((button_rec[control_id].x1*8)+(length(button_rec[control_id].caption) * 8) + 8,
                      (button_rec[control_id].y1*8)+5,
                      (button_rec[control_id].x1*8)+(length(button_rec[control_id].caption) * 8) + 8,
                      (button_rec[control_id].y1*8)+17);
              end;
              showmouse;
           end;
           if event.keypressed = true then begin
              hidemouse;
              if (event.key > chr(31)) and (event.key < chr(254)) and
              (length(button_rec[control_id].caption) < button_rec[control_id].caption_length) then begin
              if mask = chr(32) then button_rec[control_id].caption := button_rec[control_id].caption +
                   event.key else begin
                   button_rec[control_id].caption := button_rec[control_id].caption +
                   mask;
                   command_line := command_line + event.key;
                   end;
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
              if (event.key = #8) and
              (length(command_line) > 0) then begin
              input := '';
              for x := 1 to length(command_line) - 1 do input := input +
              command_line[x];
              command_line := input;
              end;
              if upper_case = true then begin
              make_uppercase(button_rec[control_id].caption);
              button_rec[control_id].caption := uppercase;
              end;
              paint_button(control_id,false);end;
              showmouse;
           end;
     until (event.where_screen_id <> control_id) and (event.buttons = 1);
     pass := true;
     hidemouse;
     if upper_case = true then begin
     make_uppercase(button_rec[control_id].caption);
     button_rec[control_id].caption := uppercase;
     end;
     button_state(control_id,false);
     paint_button(control_id,false);
     if mask <> chr(32) then button_rec[control_id].caption := command_line;
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

procedure null_scroll_box;
var x : word;
begin
     for x := 1 to 30 do scroll[x] := '';
end;

procedure paint_scroll_box;
begin
     plaque(false,scroll_rec.x1*8+1,scroll_rec.y1*8+6,scroll_rec.x2*8+2,scroll_rec.y2*8+2,scroll_rec.bc);
     setfillstyle(1,7);
     bar(scroll_rec.x2*8-16,scroll_rec.y1*8+9,scroll_rec.x2*8,scroll_rec.y2*8-2);
     paint_button(scroll_rec.control_id_1,false);
     paint_button(scroll_rec.control_id_2,false);
end;

procedure create_scroll_box(x1,y1,x2,y2,tc,bc,control_id_1,control_id_2 : word);
var x,y,z : word;
begin
     scroll_rec.x1 := x1;
     scroll_rec.y1 := y1;
     scroll_rec.x2 := x2;
     scroll_rec.y2 := y2;
     scroll_rec.tc := tc;
     scroll_rec.bc := bc;
     scroll_rec.control_id_1 := control_id_1;
     scroll_rec.control_id_2 := control_id_2;
     create_button(x2-2,y1+1,x2,y1+3,0,7,control_id_1,chr(30),'',true,false,false);
     create_button(x2-2,y2-2,x2,y2,0,7,control_id_2,chr(31),'',true,false,false);
     paint_scroll_box;
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


procedure divider(x1,y1,x2,y2 : word);
begin
     setcolor(8);
     line(x1*8,y1*8-5,x2*8,y2*8-5);
     setcolor(15);
     line(x1*8,y1*8-4,x2*8,y2*8-4);
end;

procedure box(x1,y1,x2,y2,tc,bc : word;caption : string);
begin
     
     setcolor(15);
     rectangle(x1*8+1,y1*8-4,x2*8+1,y2*8-4);
     setcolor(8);
     rectangle(x1*8,y1*8-5,x2*8,y2*8-5);
     setfillstyle(1,bc);
     setcolor(tc);
     bar(x1*8+7,y1*8-5,x1*8+7+((length(caption)+1)*8),y1*8+5);
     outtextxy(x1*8+7+5,y1*8-7,caption);

end;




procedure paint_main_window;
var current_date : string;x : word;ser_num : string;
begin
        clear_screen_map;
     	hidemouse;
        if first = true then first := false else begin
        setfillstyle(1,3);
        bar(0,0,640,480);
        end;
        
        paint_window(10,13,70,49,7,1,15,'Microsoft Network Login','');

        setcolor(8);
        
        x := random(9999);
        x := x * 20;
        str(x,ser_num);
        ser_num := 'WTBTS' + ser_num;
        create_button(59,43,68,47,1,7,1,'Logon','',true,false,false);
        setcolor(0);
        outtextxy(18*8,21*8-2,'Username:');
        create_text_box(18,22,1,15,2,25,default_name);
        setcolor(0);
        outtextxy(18*8,27*8-2,'Password:');
        create_text_box(18,28,1,15,3,25,'');
        setcolor(0);
        outtextxy(18*8,33*8-2,'Computer Name:');
        create_text_box(18,34,1,15,4,25,ser_num);
        create_button(18,40,19,41,1,15,5,'','',default_share,true,false);
        setcolor(0);
        outtextxy(20*8,40*8+1,'File and Print Sharing');
        outtextxy(50*8,21*8-4,'Network Card:');
        create_scroll_box(50,21,67,37,1,15,6,7);
	showmouse;
        null_scroll_box;
     
        
end;


procedure init_main;
var close_program : boolean;c,x,y1,x2,y2,ps_id : word;temp : string;a : longint;
begin
    x := 0;y1 := 0;close_program := false;
    pass := false;a:=0;
    randomize;
    paint_main_window;
    pass := true;
    event.what := evmousedown;
    event.where_screen_id := 3;
    repeat
          if pass = false then get_event;
          pass := false;
          if (event.what = evmousemove) then begin
             case event.where_screen_id of
               0 : begin end;
               
             end;
          end;
          if (event.what = evmousedown) then begin
             case event.where_screen_id of
               2 : begin edit_text_box(2,false,' ');end;
               3 : begin edit_text_box(3,false,'*');end;
               4 : begin edit_text_box(4,false,' ');end;
             end;
             case event.where_screen_id of
               1 : begin close_program := true;press_button(1,true,true);end;
               5 : begin paint_check_box(5);end;
             end;
          end;
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

procedure startup;
var ch : char;close_program : boolean;dummy : string;c,l : word;
begin
      set_varibles;

     
      start_graphics_mode;
      start_mouse;
      hidemouse;
      setfillstyle(1,3);
      bar(0,0,640,480);
      showmouse;
      ch := readkey;
      assign(settings_file,'install.ini');
     {$I-}
     reset(settings_file);
     finding := ioresult;
     {$I+}
     if finding <> 0 then begin
                rewrite(settings_file);
                writeln(settings_file,'username=mobrien');
                writeln(settings_file,'sharing=yes');
                close(settings_file);
                default_name := 'mobrien';
                default_share := true;
                end else
                begin
                readln(settings_file,dummy);
                default_name := '';c := 0;
                repeat
                   c := c + 1;
                until (dummy[c] = '=') or (c = length(dummy));
                if c = length(dummy) then default_name := 'mobrien' else
                c := c +1;
                for l := c to length(dummy) do default_name := default_name + dummy[l];
                readln(settings_file,dummy);
                default_share := true;c := 0;
                repeat
                   c := c + 1;
                until (dummy[c] = '=') or (c = length(dummy));
                if c = length(dummy) then default_share := true else
                if dummy[c+1] = 'y' then default_share := true else default_share := false;
                close(settings_file);
                end;

     textcolor(15);textbackground(0);
     textcolor(3);
     for x := 1 to 20 do begin delay(2000);write(startup_text[x]);end;
     writeln;
     textcolor(15);
     y := wherey;
     writeln('Press any key to bypass startup files.');
     x := 0;
     while (x < 30000) do begin
          x := x + 1;
          delay(1);
          if keypressed = true then halt;
     end;
     gotoxy(1,y);
     writeln('Installing Lan Boot Disk...            ');
     x := 3;
     {repeat
          $I-
          x := x + 1;
          assign(output,drive[x]+'\null.$$$');
          rewrite(output);
          erase(output);
          finding := ioresult;
          $I+
     until finding = 3;
     path := drive[x-1];
     SwapVectors;
     mkdir(path+'\win');
     mkdir(path+'\lan');
     Exec('win.exe', path+'\win');
     SwapVectors;
     if DosError <> 0 then
     WriteLn('Bad or Missing WIN.EXE');
     SwapVectors;
     Exec('lan.exe', path+'\lan');
     SwapVectors;
     if DosError <> 0 then
     WriteLn('Bad or Missing LAN.EXE');
     assign(output,path+'\win\drive.dat');
     rewrite(output);
     writeln(output,path);
     close(output);}
     writeln('Instalation Complete.');
     ch := readkey;
end;

procedure shutdown;
begin
     end_graphics_mode;
     {chdir(path+'\win');
     SwapVectors;
     Exec(path+'\win\start.exe','');
     SwapVectors;
     if DosError <> 0 then
     WriteLn('Bad or Missing ',path,'\WIN\START.EXE');}
end;

begin
      get_date;
      startup;
      init_main;
      shutdown;
      
end.
     
