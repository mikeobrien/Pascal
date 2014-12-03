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
        r_scroll_rec = record
                       x1,y1,x2,y2 : word;
                       bc,tc : word;
                       end;
     	a_button_rec = array[1..20] of r_button_rec;
     	a_screen_map = array[0..79,0..59] of word;
     	a_bitmap = array[0..79,0..59] of byte;
        a_error = array[1..7] of boolean;
var
        error : a_error;
        result : boolean;
        screen_bit : a_screen_bit;
 	res : r_res;
   	char_size : r_char_size;
   	screen_size : r_screen_size;
   	screen_map : a_screen_map;
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

procedure create_scroll_box(x1,y1,x2,y2,tc,bc : word);
var x,y,z : word;
begin
     scroll_rec.x1 := x1;
     scroll_rec.y1 := y1;
     scroll_rec.x2 := x2;
     scroll_rec.y2 := y1+310;
     scroll_rec.tc := tc;
     scroll_rec.bc := bc;
     setcolor(0);
     rectangle(x1,y1+4,x2,y2);
     setfillstyle(1,bc);
     bar(x1+1,y1+5,x2-1,y2-1);
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

procedure get_rec_amount(filename : string);
var data_file : text;stuff : string;
begin
     assign(data_file,filename);
     {$I-}
     reset(data_file);
     finding := ioresult;
     {$I+}
     record_amt := 0;
     if finding = 0 then begin
        repeat
        readln(data_file,stuff);
        record_amt := record_amt +1;
        until eof(data_file);
        close(data_file);
     end else record_amt := 0;
end;

procedure get_record(filename : string;address : longint);
var counter : word;data_file : text;
begin
     get_rec_amount(filename);
     if record_amt <> 0 then begin
     assign(data_file,filename);
     {$I-}
     reset(data_file);
     finding := ioresult;
     {$I+}
     if finding = 0 then begin
     if address <= record_amt then for counter := 1 to address do readln(data_file,value);
     close(data_file);
     end;
     end;
end;

procedure get_data;
var rec,x,y,z : longint;tank : string;c,cc : longint;
begin
     x := 0;y := 0;rec := 0;
     get_rec_amount('namelist.txt');
     rec := random(record_amt);
     get_record('namelist.txt',rec);
     first_name := value;
     get_rec_amount('lastlist.txt');
     rec := random(record_amt);
     get_record('lastlist.txt',rec);
     first_name := first_name + ' ' + value;
     get_rec_amount('telrlist.txt');
     rec := random(record_amt);
     get_record('telrlist.txt',rec);
     teller_list := value;
     rec := random(2);
     if (rec = 1) or (teller_list = 'ATM') then tran_type := 'DEBIT' else tran_type := 'CREDIT';
     account_num := '';
     for c := 1 to 20 do
     begin
          cc := random(9);
          str(cc,tank);
          account_num := account_num+tank;
          if c = 9 then account_num := account_num+':';
     end;
     account_num := ' ' + account_num;
     if teller_list <> 'ATM' then begin
     x := random(9999);str(x,tank);
     y := random(9999);str(y,node);
     node := node + tank;
     x := random(99);str(x,tank);
     z := random(100);
     if z > 90 then y := random(9999);
     if (z>80) and (z<90) then y := random(999);
     if (z>40) and (z<80) then y := random(99);
     if z < 40 then y := random(99);
     str(y,amount);if x < 10 then tank := tank + '0';
     amount := '$' + amount + '.' + tank;
     end
     else if teller_list = 'ATM' then begin
     z := random(100);
     if z > 90 then y := random(10);
     if (z>80) and (z<=90) then y := random(8);
     if (z>40) and (z<=80) then y := random(4);
     if z <= 40 then y := random(2);
     if y = 0 then y := 2;
     amount := '';
     str(y,amount);
     amount := '$' + amount + '0.00';
     end;
end;



procedure write_scroll_box;
var x,f : word;stuff : string;
begin
     setcolor(scroll_rec.bc);
     setfillstyle(1,scroll_rec.bc-1);
     get_data;
     stuff := '';
     for f := 1 to 100 do stuff := stuff + ' ';
     for f := 1 to length(first_name) do stuff[f] := first_name[f];
     for f := 1 to length(account_num) do stuff[f+16] := account_num[f];
     for f := 1 to length(teller_list) do stuff[f+40] := teller_list[f];
     for f := 1 to length(tran_type) do stuff[f+50] := tran_type[f];
     for f := 1 to length(amount) do stuff[f+57] := amount[f];

     for x := 0 to 5 do scroll[x] := scroll[x+1];
     scroll[5] := stuff;
     for x := 1 to 5 do begin
         settextstyle(0,0,0);
         setcolor(scroll_rec.bc);
         outtextxy(scroll_rec.x1+5,scroll_rec.y1+(x*10),scroll[x-1]);
         setcolor(scroll_rec.tc);
         outtextxy(scroll_rec.x1+5,scroll_rec.y1+(x*10),scroll[x]);
         settextstyle(0,0,0);
     end;
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

procedure copy(source,target : string);
var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  buf: array[1..2048] of Char;
begin
  Assign(FromF,source);
  {$I-}
  Reset(FromF, 1);
  finding := ioresult;
  {$I-}
  if finding = 0 then begin
     Assign(ToF,target);
     SetFAttr(tof,$20);
     {$I-}
     Rewrite(ToF, 1);
     finding := ioresult;
     {$I+}
     if finding = 0 then begin
        {WriteLn('Copying ', FileSize(FromF),
          ' bytes...');}
          repeat
                BlockRead(FromF,buf,
                SizeOf(buf),NumRead);
                BlockWrite(ToF,buf,NumRead,NumWritten);
          until (NumRead = 0) or (NumWritten <> NumRead);
        Close(toF);
     end;
     Close(fromF);
  end;
end;



procedure fix_files;
begin
     copy('pjlmon.dll','c:\winnt\system32\spool\drivers\w32x86\2\pjlmon.dll');
     if finding = 0 then error[1] := false;

     copy('hprasdd.dll','c:\winnt\system32\spool\drivers\w32x86\2\hprasdd.dll');
     if finding = 0 then error[2] := false;

     copy('hprasdui.dll','c:\winnt\system32\spool\drivers\w32x86\2\hprasdui.dll');
     if finding = 0 then error[3] := false;

     copy('hprasdui.hlp','c:\winnt\system32\spool\drivers\w32x86\2\hprasdui.hlp');
     if finding = 0 then error[4] := false;

     copy('hp5sim.dll','c:\winnt\system32\spool\drivers\w32x86\2\hp5sim.dll');
     if finding = 0 then error[5] := false;

     copy('hp5simui.dll','c:\winnt\system32\spool\drivers\w32x86\2\hp5simui.dll');
     if finding = 0 then error[6] := false;

     copy('hp5simui.hlp','c:\winnt\system32\spool\drivers\w32x86\2\hp5simui.hlp');
     if finding = 0 then error[7] := false;

end;

procedure draw_close;
var current_date : string;x : word;
begin
        for x := 1 to 7 do if error[x] = true then result := true;
        clear_screen_map;
     	hidemouse;
        paint_window(18,15,62,45,7,1,15,'HP 5SI Driver Fix','printer.bmp');
        create_button(50,40,60,43,4,7,2,'   OK','',true,false,false);
        setcolor(0);
        if result = true then begin
           setcolor(4);
           outtextxy(22*8,20*8,'Driver Fix was NOT successfull.');
           outtextxy(22*8,22*8,'Please contact Mike O''Brien @ 40658(p)');
        end else outtextxy(22*8,21*8,'Driver Fix was successfull!');
        
        setcolor(0);
        outtextxy(22*8,26*8,'HPRASDD.DLL.......');
        if error[2] = true then begin setcolor(4);outtextxy(40*8,26*8,'Failed');end else begin setcolor(2);
           outtextxy(40*8,26*8,'OK');end;
        setcolor(0);
        outtextxy(22*8,28*8,'HPRASDUI.DLL......');
        if error[3] = true then begin setcolor(4);outtextxy(40*8,28*8,'Failed');end else begin setcolor(2);
           outtextxy(40*8,28*8,'OK');end;
        setcolor(0);
        outtextxy(22*8,30*8,'HPRASDUI.HLP......');
        if error[4] = true then begin setcolor(4);outtextxy(40*8,30*8,'Failed');end else begin setcolor(2);
           outtextxy(40*8,30*8,'OK');end;
        setcolor(0);
        outtextxy(22*8,32*8,'HP5SIM.DLL........');
        if error[5] = true then begin setcolor(4);outtextxy(40*8,32*8,'Failed');end else begin setcolor(2);
           outtextxy(40*8,32*8,'OK');end;
        setcolor(0);
        outtextxy(22*8,34*8,'HP5SIMUI.DLL......');
        if error[6] = true then begin setcolor(4);outtextxy(40*8,34*8,'Failed');end else begin setcolor(2);
           outtextxy(40*8,34*8,'OK');end;
        setcolor(0);
        outtextxy(22*8,36*8,'HP5SIMUI.HLP......');
        if error[7] = true then begin setcolor(4);outtextxy(40*8,36*8,'Failed');end else begin setcolor(2);
           outtextxy(40*8,36*8,'OK');end;
        setcolor(0);
        setcolor(0);
        outtextxy(22*8,38*8,'PJLMON.DLL........');
        if error[1] = true then begin setcolor(4);outtextxy(40*8,38*8,'Failed');end else begin setcolor(2);
           outtextxy(40*8,38*8,'OK');end;
        showmouse;
        null_scroll_box;
     
        
end;



procedure paint_main_window;
var current_date : string;x : word;
begin
        clear_screen_map;
     	hidemouse;
        paint_window(20,20,60,40,7,1,15,'HP 5SI Driver Fix','printer.bmp');
        create_button(48,35,59,39,4,7,1,'Fix...   ','',true,false,false);
        setcolor(1);
        outtextxy(22*8,24*8,'This program will update Hewlett');
        outtextxy(22*8,26*8,'Packard LaserJet 5Si drivers for');
        outtextxy(22*8,28*8,'Microsoft WindowsNT.');
        outtextxy(22*8,32*8,'Press "Fix" to continue.');

        showmouse;
        null_scroll_box;
     
        
end;


procedure init_main;
var close_program : boolean;c,x,y1,x2,y2,ps_id : word;temp : string;a : longint;
begin
     x := 0;y1 := 0;close_program := false;a:=0;
     randomize;
    paint_main_window;
    repeat
          get_event;
          if (event.what = evmousemove) then begin
          case event.where_screen_id of
               0 : begin end;
          end;
          end;
          if (event.what = evmousedown) then begin
          case event.where_screen_id of
               0 : begin end;
          end;
          case event.where_screen_id of
               1 : begin press_button(1,true,true);fix_files;draw_close;end;
               2 : begin press_button(2,true,true);close_program := true;end;
          end;
          end;
    until close_program = true;
        
end;

procedure set_varibles;
var x : word;
begin
     result := false;
     for x := 1 to 7 do error[x] := true;
     clear_screen_map;
     screen_size.cols := 80;
     screen_size.rows := 25;
     res.x := getmaxx;
     res.y := getmaxy;
     char_size.x := (res.x + 1) div screen_size.cols;
     char_size.y := (res.y + 1) div screen_size.rows;
end;

procedure startup;
var ch : char;close_program : boolean;
begin
      set_varibles;
      start_graphics_mode;
      start_mouse;
      hidemouse;
      setfillstyle(1,15);
     bar(0,0,640,480);
     putbitmap('support.bmp',20,436);
     putbitmap('support2.bmp',90,436);
     showmouse;
end;

procedure shutdown;
begin
     setfillstyle(1,0);
     bar(0,0,640,480);
     end_graphics_mode;
end;

begin
      get_date;
      
      startup;
      init_main;
      shutdown;
      
end.
     
