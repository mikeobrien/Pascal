program testgraph;


{StackSize, HeapMin, HeapMax}
{$M 20000,0,220360}

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
    r_boot_ini = record
             dir0,dir1,dir2,dir3 : string;
             name,dept,shellfile,size,ramdrive : string;
             
             runprogram0,runprogram1,runprogram2,runprogram3 : string;
             cmdline0,cmdline1,cmdline2,cmdline3 : string;
             copyfrom0,copyfrom1,copyfrom2,copyfrom3 : string;
             copyto0,copyto1,copyto2,copyto3 : string;
             ntusername,ntdomain,ntcomputername,ntloginscript,ntnetfileslocation : string;
             nwusername,nwloginserver,nwnetfileslocation : string;

             end;
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
        a_scroll_data = array[1..30] of item_rec;
        r_scroll_rec = record
                       x1,y1,x2,y2 : word;
                       size,bc,tc,localpos,globalpos,control_id_1,control_id_2 : word;
                       data : a_scroll_data;
                       menu : boolean;
                       end;
     	a_button_rec = array[1..31] of r_button_rec;
     	a_screen_map = array[0..79,0..59] of word;
     	a_bitmap = array[0..79,0..59] of byte;
        r_debug_rec = record
                    dir0,dir1,dir2,dir3 : string;
                    copy0,copy1,copy2,copy3 : string;
                    exe0,exe1,exe2,exe3 : string;
        end;
        a_scroll_rec = array[1..4] of r_scroll_rec;
        a_mapping = array['a'..'z'] of string;
var
        scroll_rec : a_scroll_rec;
        ntmapping,nwmapping : a_mapping;
        debug,errorstat : boolean;
        runtimeerror : string;
        last_drive : string;
        debug_rec : r_debug_rec;
        D: DirStr;
        boot_ini : r_boot_ini;
        settings_file : text;
        default_name,exit_error : string;
        default_share : boolean;
        screen_bit : a_screen_bit;
 	res : r_res;
        screensize : word;
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
{        scroll_rec : r_scroll_rec;}
        p,button,old_bit : pointer;
        done,first : boolean;
        scroll : a_scroll;
        first_name,last_name,node,teller_list,account_num,amount : string;
  tran_type : string;
  record_amt : integer;
  value,output_string : string;
  output : text;
  doserrorcode : word;
   ch : char;
   path : string;


procedure clear_screen_map;
var x,y : word;
begin
     for x := 1 to 80 do for y := 1 to 60 do screen_map[x,y] := 0;

end;

procedure delayms(length : longint);
var h,m,s,hundold,hundnew : word;counter : longint;
begin
    GetTime(h,m,s,hundold);
    counter := 0;
    repeat
          gettime(h,m,s,hundnew);
          if hundold <> hundnew then begin hundold := hundnew;counter := counter + 1;end;
    until (counter = length) or (keypressed = true)

end;

procedure delays(length : longint);
var h,m,snew,sold,hund : word;counter : longint;
begin
    GetTime(h,m,sold,hund);
    counter := 0;
    repeat
          gettime(h,m,snew,hund);
          if sold <> snew then begin sold := snew;counter := counter + 1;end;
    until (counter = length) or (keypressed = true);

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
var 	d,m,y,dow : word;
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
     screenSize := ImageSize(x1,y1,x2,y2);
     GetMem(p, screenSize);
     GetImage(x1,y1,x2,y2,p^);
     screensize := size;
end;



procedure replace_screen(x,y : word);
begin
     hidemouse;
     x := x;
     y := y;
     PutImage(x, y, p^, NormalPut);
     FreeMem(p,screensize);
     showmouse;
end;

procedure paint_button(control_id : word;check_box : boolean);
var x : word;
begin
     if button_rec[control_id].menu_option = false then begin
        if text_style = 'norm' then x := 0 else x := 3;
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
     create_button(x1,y1,x1+length+2,y1+2,text_color,face_color,control_id,caption,'',false,false,false);
     button_rec[control_id].caption_length := length;
end;



procedure button_state(control_id : word;state : boolean);
begin
     button_rec[control_id].current_state := state;
end;

procedure get_event;
var ch : char;
begin
     event.key := chr(0);
     event.keypressed := false;
     GetMouseEvent(mouse_event);
     if keypressed = true then begin
        event.key := readkey;
        {
        repeat
              event.key := readkey;
        until keypressed = false;
        }
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
     event.keypressed := false;
     event.key := ' ';
     hidemouse;
     button_state(control_id,false);
     command_line := button_rec[control_id].caption;
     c := button_rec[control_id].face_color;
     button_rec[control_id].face_color := 15;
     if mask <> chr(32) then for x := 1 to length(command_line) do button_rec[control_id].caption[x] := mask;
     paint_button(control_id,false);
     setcolor(5);
     rectangle(button_rec[control_id].x1*8-3,
               button_rec[control_id].y1*8-3,
               button_rec[control_id].x2*8+3,
               button_rec[control_id].y2*8+3);
     
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
                      (button_rec[control_id].y1*8)+3,
                      (button_rec[control_id].x1*8)+(length(button_rec[control_id].caption) * 8) + 8,
                      (button_rec[control_id].y1*8)+13);
              end else begin
                  setcolor(button_rec[control_id].face_color);
                  line((button_rec[control_id].x1*8)+(length(button_rec[control_id].caption) * 8) + 8,
                      (button_rec[control_id].y1*8)+3,
                      (button_rec[control_id].x1*8)+(length(button_rec[control_id].caption) * 8) + 8,
                      (button_rec[control_id].y1*8)+13);
              end;
              showmouse;
           end;
           if event.keypressed = true then begin
            if (event.key <> #13) and (event.key <> #75)  and (event.key <> #77)
                and (event.key <> #72)  and (event.key <> #80) then begin
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
           end;
     until ((event.where_screen_id <> control_id) and (event.buttons = 1))
           or ((event.key = #13) or (event.key = #75)  or (event.key = #77)
                or (event.key = #72)  or (event.key = #80));
     pass := true;
     hidemouse;
     if upper_case = true then begin
     make_uppercase(button_rec[control_id].caption);
     button_rec[control_id].caption := uppercase;
     end;
     button_state(control_id,false);
     paint_button(control_id,false);
     if mask <> chr(32) then button_rec[control_id].caption := command_line;
          setcolor(7);
     rectangle(button_rec[control_id].x1*8-3,
               button_rec[control_id].y1*8-3,
               button_rec[control_id].x2*8+3,
               button_rec[control_id].y2*8+3);

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

procedure select_check_box(control_id : word);
begin
     setcolor(5);
     hidemouse;
     rectangle(button_rec[control_id].x1*8-3,
        button_rec[control_id].y1*8-3,
        button_rec[control_id].x2*8+3,
        button_rec[control_id].y2*8+3);
     showmouse;
     setcolor(1);
     repeat
           get_event;
           if ((event.where_screen_id = control_id) and (event.buttons = 1)) or
              (event.key = ' ') then paint_check_box(control_id);
     until ((event.where_screen_id <> control_id) and (event.buttons = 1)) or
           ((event.key = #75) or (event.key = #77) or (event.key = #72) or (event.key = #80)
           or (event.key = #13));
     setcolor(7);
     hidemouse;
     rectangle(button_rec[control_id].x1*8-3,
        button_rec[control_id].y1*8-3,
        button_rec[control_id].x2*8+3,
        button_rec[control_id].y2*8+3);
     setcolor(1);
     showmouse;
end;

procedure null_scroll_box(index : word);
var x : word;
begin
     for x := 1 to 30 do scroll_rec[index].data[x].item := '';
     for x := 1 to 30 do scroll_rec[index].data[x].value := '';
end;

procedure paint_scroll_box(index : word);
var x,y,z : word;
begin
     if scroll_rec[index].menu = false then begin
        plaque(false,scroll_rec[index].x1*8+1,scroll_rec[index].y1*8+6,scroll_rec[index].x2*8+2,scroll_rec[index].y2*8+2,
           scroll_rec[index].bc);
        setfillstyle(1,7);
        bar(scroll_rec[index].x2*8-16,scroll_rec[index].y1*8+9,scroll_rec[index].x2*8,scroll_rec[index].y2*8-2);
        paint_button(scroll_rec[index].control_id_1,false);
        paint_button(scroll_rec[index].control_id_2,false);
     end else begin
         setfillstyle(1,scroll_rec[index].bc);
         bar(scroll_rec[index].x1*8,
             scroll_rec[index].y1*8,
             scroll_rec[index].x2*8,
             scroll_rec[index].y2*8+9);
     end;
     y:=0;
     for x := (scroll_rec[index].globalpos-scroll_rec[index].localpos)+1 to
            (scroll_rec[index].globalpos-scroll_rec[index].localpos)+
              scroll_rec[index].size do begin
         setcolor(scroll_rec[index].tc);
         setfillstyle(1,1);
         if scroll_rec[index].menu = true then begin
         if x = scroll_rec[index].localpos then begin
            bar(scroll_rec[index].x1*8,scroll_rec[index].y1*8+(y*12)+1,scroll_rec[index].x2*8,
                  scroll_rec[index].y1*8+(y*12)+13);
            setcolor(15);
         end;
         outtextxy(scroll_rec[index].x1*8+4,scroll_rec[index].y1*8+4+(y*12),scroll_rec[index].data[y+1].item);
         end else begin
         if x = scroll_rec[index].localpos then begin
            bar(scroll_rec[index].x1*8+3,scroll_rec[index].y1*8+(y*12)+8,scroll_rec[index].x2*8-17,
                 scroll_rec[index].y1*8+(y*12)+20);
            setcolor(15);
         end;
         outtextxy(scroll_rec[index].x1*8+7,scroll_rec[index].y1*8+11+(y*12),scroll_rec[index].data[y+1].item);
         
         end;
         y := y+1;
     end;


end;

procedure create_scroll_box(x1,y1,x2,y2,tc,bc,control_id_1,control_id_2,index : word;menu : boolean);
var x,y,z : word;
begin
     if x2-x1 < 3 then x2 := x1 + 3;
     null_scroll_box(index);
     scroll_rec[index].size := x2-x1;
     scroll_rec[index].menu := menu;
     scroll_rec[index].globalpos := 1;
     scroll_rec[index].localpos := 1;
     scroll_rec[index].x1 := x1;
     scroll_rec[index].y1 := y1;
     scroll_rec[index].x2 := x2;
     scroll_rec[index].y2 := y2;
     scroll_rec[index].tc := tc;
     scroll_rec[index].bc := bc;
     scroll_rec[index].control_id_1 := control_id_1;
     scroll_rec[index].control_id_2 := control_id_2;
     create_button(x2-2,y1+1,x2,y1+3,0,7,control_id_1,chr(30),'',true,false,false);
     create_button(x2-2,y2-2,x2,y2,0,7,control_id_2,chr(31),'',true,false,false);
     paint_scroll_box(index);
end;

procedure scroll_scroll_box(up : boolean;index : word);
begin

    if (up = true) and (scroll_rec[index].data[scroll_rec[index].globalpos].item <> '') then begin
       if (scroll_rec[index].localpos = 1) and  (scroll_rec[index].globalpos > 1) then scroll_rec[index].globalpos :=
            scroll_rec[index].globalpos-1;
       if (scroll_rec[index].localpos > 1) then begin scroll_rec[index].localpos := scroll_rec[index].localpos-1;
                               scroll_rec[index].globalpos := scroll_rec[index].globalpos-1;end;
    end else if (scroll_rec[index].data[scroll_rec[index].globalpos+1].item <> '') then begin
       if (scroll_rec[index].localpos = scroll_rec[index].size) and  (scroll_rec[index].globalpos <30) then
           scroll_rec[index].globalpos :=
                                 scroll_rec[index].globalpos+1;
       if (scroll_rec[index].localpos < scroll_rec[index].size) then begin scroll_rec[index].localpos :=
            scroll_rec[index].localpos+1;
                               scroll_rec[index].globalpos := scroll_rec[index].globalpos+1;end;
    end;
    paint_scroll_box(index);
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

procedure tlabel(x,y,color : word;caption : string);
begin
     setcolor(color);
     outtextxy(x*8,y*8+4,caption);
end;



procedure writeconfigsys;
var ini_file,config_file : text;data : string;
begin
              assign(ini_file,'config.sys');
              assign(config_file,'config.ini');
              rewrite(ini_file);
              writeln(ini_file,'REM >>CREATED BY BOOT LOADER v5.0<<');
              {$I-}
              reset(config_file);
              readln(config_file,data);
              finding := ioresult;
              {$I+}
              
              if finding <> 0 then
                 begin
                      rewrite(config_file);
                      writeln(config_file,'LASTDRIVE=Z');
                 end else
              close(config_file);
              reset(config_file);
              repeat
                       readln(config_file,data);
                       writeln(ini_file,data);
              until EOF(config_file);
              close(config_file);
               if boot_ini.ramdrive = 'yes' then writeln(ini_file,'DEVICE=RAMDRIVE.SYS '+boot_ini.size+ ' /A');
              close(ini_file);
end;


function get_ini_value(search_key,search_value : string) : string;
var the_ini_file : text;chd : char;file_data,key,value : string;xc : word;
begin
     search_key := '['+search_key+']';
     assign(the_ini_file,'boot.ini');
     {$I-}
     reset(the_ini_file);
     finding := ioresult;
     {$I+}
     
     repeat
           readln(the_ini_file,file_data);
           
     until (EOF(the_ini_file)) or (file_data = search_key);
     if file_data = search_key then begin
       repeat
           readln(the_ini_file,file_data);
           key := '';value := '';chd := 'l';
           for xc := 1 to length(file_data) do begin
                      if file_data[xc] <> '=' then
                      begin
                         if chd <> '=' then key := key + file_data[xc];
                         if chd = '=' then value := value + file_data[xc];
                      end else chd := '=';
           end;
       until (EOF(the_ini_file)) or (key = search_value) or (file_data = '[end]');
       if key = search_value then get_ini_value := value else value := '';
     end else get_ini_value := '';
     close(the_ini_file);
end;

procedure set_ini_value(search_key,search_value,write_string : string);
var temp_file,ini_file : text;pos,pos2,x,location,y,z : word;chd : char;value,value2 : string;existkey : boolean;
begin
     location := 0;value2 := '';
     assign(ini_file,'boot.ini');
     assign(temp_file,'temp.$$$');

     reset(ini_file);
     repeat
           location := location + 1;
           readln(ini_file,value);
     until (eof(ini_file)) or (value = '['+search_key+']');
     chd := ' ';
     if value = '['+search_key+']' then begin
        existkey := true;
        repeat
          location := location + 1;
          readln(ini_file,value);
          value2 := '';chd := ' ';
          for x := 1 to length(value) do begin
                      if value[x] <> '=' then
                      begin
                         if chd <> '=' then value2 := value2 + value[x];
                      end else chd := '=';
                      end;
          until (eof(ini_file)) or (value = '[end]') or (value2 = search_value);
          if value2 <> search_value then location := 0;

     end  else existkey := false;
     close(ini_file);
     reset(ini_file);
     rewrite(temp_file);
     if existkey = false then begin
          repeat
              readln(ini_file,value);
              writeln(temp_file,value);
          until eof(ini_file);
          writeln(temp_file,'['+search_key+']');
          writeln(temp_file,search_value+'='+write_string);
          writeln(temp_file,'[end]');
          erase(ini_file);
          close(ini_file);
          rename(temp_file,'boot.ini');
          close(temp_file);
     end else begin
          
          if location = 0 then begin
             repeat
                   readln(ini_file,value);
                   writeln(temp_file,value);
             until value = '['+search_key+']';
             writeln(temp_file,search_value+'='+write_string);
             repeat
                   readln(ini_file,value);
                   writeln(temp_file,value);
             until eof(ini_file);
             
          end else begin
             pos2 := 0;
             repeat
               pos2 := pos2 + 1;
               readln(ini_file,value);
               if pos2 = location then writeln(temp_file,search_value+'='+write_string) else
                  writeln(temp_file,value);
             until eof(ini_file);
          end;
       
     erase(ini_file);
       close(ini_file);
       rename(temp_file,'boot.ini');

       close(temp_file);
     end;
     

end;


function current_ram_drive : string;
const drives : array[1..10] of string[2] = ('A:','B:','C:','D:','E:','F:','G:','H:','I:','J:');
var stuff : file;x : word;
begin
     x := 2;
     repeat
           x := x +1;
           assign(stuff,drives[x]+'\test.$$$');
           {$I-}
           rewrite(stuff);
           finding := ioresult;
           {$I+}
           if finding = 0 then begin close(stuff);erase(stuff);end;
     until finding <> 0;
     current_ram_drive := drive[x-1];
end;


procedure cool_text(ctx,cty : word;caption : string;animation : boolean);
var x,y,z : word;
begin
     for x := 1 to length(caption) do
         begin
              if (caption[x] <> ' ') and (animation = true) then begin
              capture_screen(ctx+60+(x*16),cty+60,ctx+150+(x*16),cty+180);
              settextstyle(defaultfont,horizdir,12);
              outtextxy(ctx+60+(x*16),cty+60,caption[x]);
{              delayms(1);}
              replace_screen(ctx+60+(x*16),cty+60);
              capture_screen(ctx+30+(x*16),cty+30,ctx+150+(x*16),cty+180);
              settextstyle(defaultfont,horizdir,8);
              outtextxy(ctx+30+(x*16),cty+30,caption[x]);
 {             delayms(1);}
              replace_screen(ctx+30+(x*16),cty+30);
              delayms(1);
              end;
              settextstyle(defaultfont,horizdir,2);
              outtextxy(ctx+(x*16),cty,caption[x]);
         end;
end;

procedure status_back(x1,y1,x2,y2,pos : word);
var ch : char;
begin
     setfillstyle(1,4);
     bar(x1,y1,x1+(pos),y2);
     setfillstyle(1,15);
     bar(x1+pos,y1,x2,y2);

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


procedure status_bar(x,y,percentdone,percent : word;caption : string);
var xc,rn : word;
begin
     percent := percent * 2;percentdone := percentdone *2;
     setcolor(0);

     outtextxy(x+2,y-13,caption);
     status_back(x,y-2,x+203,y+22,percentdone);
     setcolor(4);
     randomize;
     {for xc := 1 to percentdone do begin line(x+xc,y,x+xc,y+20);line(x+xc+1,y,x+xc+1,y+20);end;}
     for xc := percentdone to percent do begin rn := random(19);if rn = 1 then delayms(1);line(x+xc,y,x+xc,y+20);
         line(x+xc+1,y,x+xc+1,y+20);end;
     setcolor(15);
     if percent = 200 then begin
     setcolor(7);
     outtextxy(x+2,y-13,caption);
     end;

end;



procedure paint_debug_screen(paint : boolean);
var ch : char;
begin
              hidemouse;
              if paint = true then begin
                 setfillstyle(1,1);
                 bar(0,0,640,480);
                 setcolor(15);
                 outtextxy(2,3,'Boot Loader v5.0');
                 paint_window(10,5,70,50,4,4,15,'Boot Loader Debug','');
                 end;
                 setcolor(14);
                 outtextxy(11*8,33*8,'Error Codes:');
                 setcolor(14);
                 outtextxy(11*8,35*8,'2 - File not found');
                 outtextxy(11*8,36*8,'3 - Path not found');
                 outtextxy(11*8,37*8,'5 - Access denied');
                 outtextxy(11*8,38*8,'6 - Invaled handle');
                 outtextxy(11*8,39*8,'8 - Not enough memory');
                 outtextxy(11*8,40*8,'10 - Invalid enviroment');
                 outtextxy(11*8,41*8,'11 - Invalid format');
                 outtextxy(11*8,42*8,'18 - No more files');
                 setcolor(15);
                 outtextxy(28*8,48*8,'Press Any Key To Continue');
                 
                     setcolor(15);
              outtextxy(11*8,8*8,'Registered to '+boot_ini.name);
              outtextxy(11*8,9*8,'Boot Application '+boot_ini.dept);
              if boot_ini.ramdrive = 'yes' then begin
              outtextxy(11*8,11*8,'RamDrive '+last_drive);
              outtextxy(11*8,12*8,'Ramdrive Size '+boot_ini.size);
              end else outtextxy(11*8,11*8,'No RamDrive Present');

              outtextxy(11*8,10*8,'Shell File '+last_drive+boot_ini.shellfile);
              outtextxy(11*8,(14)*8,debug_rec.dir0);
              outtextxy(11*8,(15)*8,debug_rec.dir1);
              outtextxy(11*8,(16)*8,debug_rec.dir2);
              outtextxy(11*8,(17)*8,debug_rec.dir3);

              outtextxy(11*8,(19)*8,debug_rec.copy0);
              outtextxy(11*8,(20)*8,debug_rec.copy1);
              outtextxy(11*8,(21)*8,debug_rec.copy2);
              outtextxy(11*8,(22)*8,debug_rec.copy3);

              outtextxy(11*8,(24)*8,debug_rec.exe0);
              outtextxy(11*8,(25)*8,debug_rec.exe1);
              outtextxy(11*8,(26)*8,debug_rec.exe2);
              outtextxy(11*8,(27)*8,debug_rec.exe3);
              showmouse;
end;


procedure splash_screen(animate,startup : boolean);
var ramdriveletter : string;
begin
     hidemouse;
     setfillstyle(1,9);
     bar(0,0,640,480);
     setcolor(15);
     SetTextStyle(DefaultFont, HorizDir,1);
     outtextxy(2,3,'Boot Loader v5.0');
     paint_window(20,15,60,40,7,7,15,'','');

     if startup = true then setcolor(15) else setcolor(9);
     outtextxy(200,470,'            ESC = Bypass Startup files  F10 = Setup');

     if animate = true then delayms(15);
     if animate = true then begin
             setcolor(1);
             outtextxy(23*8+16,20*8-2,'Slackware Software Presents...');
             delayms(20);
             setcolor(7);
             outtextxy(23*8+16,20*8-2,'Slackware Software Presents...');
     end;
     settextstyle(defaultfont,horizdir,2);
     setcolor(4);
     event.keypressed := true;
     cool_text(23*8,19*8,'Super Boot Disk',animate);
     settextstyle(defaultfont,horizdir,1);
     setcolor(1);
     outtextxy(25*8,24*8,boot_ini.dept);
     setcolor(1);
     outtextxy(25*8,25*8+3,'Registered to '+boot_ini.name);
     ramdriveletter := current_ram_drive;
     if boot_ini.ramdrive = 'yes' then outtextxy(25*8,26*8+6,'RamDrive '+ramdriveletter+'  '+boot_ini.size+'Kb') else
        outtextxy(25*8,26*8+6,'No RamDrive present.');
     showmouse;
end;


procedure paint_bootloader_window;
var current_date : string;x : word;ser_num : string;b_ramdrive : boolean;
begin
        clear_screen_map;
     	
        hidemouse;
        paint_window(1,1,79,59,7,1,15,'Boot Loader Settings','');

        setcolor(1);
        setfillstyle(1,1);
        bar(60*8+2,2*8,79*8-3,4*8+4);
        pieslice(60*8+1,4*8-3,180,270,7);
        create_button(61,2,69,4,4,7,29,'Cancel','',true,false,false);
        create_button(70,2,78,4,1,7,30,'Save','',true,false,false);
        
        setcolor(0);
        box(3,5,39,20,1,7,'Create Directorys:');
        create_text_box(5,6,1,15,1,30,boot_ini.dir0);
        create_text_box(5,9,1,15,2,30,boot_ini.dir1);
        create_text_box(5,12,1,15,3,30,boot_ini.dir2);
        create_text_box(5,15,1,15,4,30,boot_ini.dir3);

        box(41,6,77,20,1,7,'Registration/Enviroment Info:');
        setcolor(5);
        outtextxy(42*8,7*8+4,'Name');
        create_text_box(47,7,1,15,5,26,boot_ini.name);
        setcolor(5);
        outtextxy(42*8,8*10+4,'Application');
        create_text_box(54,10,1,15,6,19,boot_ini.dept);
        setcolor(0);
        outtextxy(42*8,8*13+4,'Shell File');
        create_text_box(53,13,1,15,7,20,boot_ini.shellfile);
        setcolor(0);
        outtextxy(55*8,8*16+8,'Size (Kb)');
        outtextxy(44*8+3,8*16+8,'RAMDrive');
        create_text_box(65,16,1,15,9,8,boot_ini.size);
        if boot_ini.ramdrive = 'yes' then b_ramdrive := true else b_ramdrive := false;
        create_button(42,17,43,18,1,15,8,'','',B_RAMDRIVE,true,false);


        box(3,41,77,58,1,7,'Run Programs/ZIP Installs...');
        setcolor(0);
        outtextxy(5*8,43*8,'Program Name:');
        create_text_box(5,45,1,15,10,30,boot_ini.runprogram0);
        create_text_box(5,48,1,15,12,30,boot_ini.runprogram1);
        create_text_box(5,51,1,15,14,30,boot_ini.runprogram2);
        create_text_box(5,54,1,15,16,30,boot_ini.runprogram3);

        setcolor(0);
        outtextxy(39*8,43*8,'Command Line:');
        create_text_box(39,45,1,15,11,34,boot_ini.cmdline0);
        create_text_box(39,48,1,15,13,34,boot_ini.cmdline1);
        create_text_box(39,51,1,15,15,34,boot_ini.cmdline2);
        create_text_box(39,54,1,15,17,34,boot_ini.cmdline3);

        box(3,22,77,39,1,7,'Copy Files...');
        setcolor(0);
        outtextxy(5*8,24*8,'From:');
        create_text_box(5,26,1,15,18,30,boot_ini.copyfrom0);
        create_text_box(5,29,1,15,20,30,boot_ini.copyfrom1);
        create_text_box(5,32,1,15,23,30,boot_ini.copyfrom2);
        create_text_box(5,35,1,15,25,30,boot_ini.copyfrom3);

        setcolor(0);
        outtextxy(39*8,24*8,'To:');
        create_text_box(39,26,1,15,19,34,boot_ini.copyto0);
        create_text_box(39,29,1,15,22,34,boot_ini.copyto1);
        create_text_box(39,32,1,15,24,34,boot_ini.copyto2);
        create_text_box(39,35,1,15,26,34,boot_ini.copyto3);



	showmouse;
        null_scroll_box(1);
     
        
end;

procedure paint_settings_menu;
begin
     paint_window(30,20,50,32,7,1,15,'Setup','');


     create_scroll_box(31,23,48,30,0,7,50,51,1,true);
     scroll_rec[1].data[1].item := 'Bootloader';
     scroll_rec[1].data[2].item := 'Net Login';
     scroll_rec[1].data[3].item := 'Boot Menu';
     scroll_rec[1].data[4].item := 'Debug Startup';
     scroll_rec[1].data[5].item := 'Exit';
     paint_scroll_box(1);
end;

procedure paint_net_logon_menu;
begin
     hidemouse;
     paint_window(1,1,79,59,7,1,15,'Network Logon Options','');
     box(2,5,77,31,1,7,'Windows NT Logon');
     box(2,32,77,58,1,7,'Novell Netware Logon');
     tlabel(4,7,0,'Username:');
     create_text_box(13,7,1,15,1,21,boot_ini.ntusername);
     tlabel(4,11,0,'Domain:');
     create_text_box(11,11,1,15,2,23,boot_ini.ntdomain);
     tlabel(4,15,0,'Computer name:');
     create_text_box(18,15,1,15,3,16,boot_ini.ntcomputername);
     tlabel(4,19,0,'Login script (UNC path):');
     create_text_box(4,21,1,15,4,30,boot_ini.ntloginscript);
     tlabel(4,25,0,'Network files location:');
     create_text_box(4,27,1,15,5,30,boot_ini.ntloginscript);
     tlabel(37,6,0,'Mapping:');
     create_text_box(45,6,1,15,6,28,'');
     create_scroll_box(37,8,75,16,0,15,50,51,1,false);
     paint_scroll_box(1);
     tlabel(37,17,0,'Network cards:');
     create_scroll_box(37,18,65,29,0,15,52,53,2,false);
     paint_scroll_box(2);
     create_button(67,18,75,21,0,7,7,'Add','',true,false,false);
     create_button(67,22,75,25,0,7,8,'Edit','',true,false,false);
     create_button(67,26,75,29,0,7,9,'Delete','',true,false,false);

     tlabel(4,35,0,'Username:');
     create_text_box(13,35,1,15,10,21,boot_ini.ntusername);
     tlabel(4,39,0,'Login Server:');
     create_text_box(17,39,1,15,11,17,boot_ini.ntdomain);
     tlabel(4,43,0,'Network Files Location:');
     create_text_box(4,45,1,15,12,30,boot_ini.ntloginscript);
     tlabel(37,33,0,'Mapping:');
     create_text_box(45,33,1,15,13,28,'');
     create_scroll_box(37,35,75,43,0,15,55,56,3,false);
     paint_scroll_box(3);
     tlabel(37,44,0,'Network cards:');
     create_scroll_box(37,45,65,56,0,15,57,58,4,false);
     paint_scroll_box(4);
     create_button(67,45,75,48,0,7,14,'Add','',true,false,false);
     create_button(67,49,75,52,0,7,15,'Edit','',true,false,false);
     create_button(67,53,75,56,0,7,16,'Delete','',true,false,false);

     create_button(5,53,15,56,4,7,17,'Cancel','',true,false,false);
     create_button(17,53,27,56,1,7,18,'Save','',true,false,false);


     showmouse;
end;


procedure init_net_logon_menu;
begin
     paint_net_logon_menu;
     ch := readkey;
end;

procedure save_bootloader_settings;
var ini_file,config_file : text;data : string;
begin
     writeconfigsys;
              boot_ini.dir0 := button_rec[1].caption;
              boot_ini.dir1 := button_rec[2].caption;
              boot_ini.dir2 := button_rec[3].caption;
              boot_ini.dir3 := button_rec[4].caption;

              boot_ini.name := button_rec[5].caption;
              boot_ini.dept := button_rec[6].caption;
              boot_ini.shellfile := button_rec[7].caption;
              if button_rec[8].current_state = true then boot_ini.ramdrive := 'yes' else boot_ini.ramdrive := 'no';
              boot_ini.size := button_rec[9].caption;

              boot_ini.runprogram0 := button_rec[10].caption;
              boot_ini.runprogram1 := button_rec[12].caption;
              boot_ini.runprogram2 := button_rec[14].caption;
              boot_ini.runprogram3 := button_rec[16].caption;

              boot_ini.cmdline0 := button_rec[11].caption;
              boot_ini.cmdline1 := button_rec[13].caption;
              boot_ini.cmdline2 := button_rec[15].caption;
              boot_ini.cmdline3 := button_rec[17].caption;

              boot_ini.copyfrom0 := button_rec[18].caption;
              boot_ini.copyfrom1 := button_rec[20].caption;
              boot_ini.copyfrom2 := button_rec[23].caption;
              boot_ini.copyfrom3 := button_rec[25].caption;

              boot_ini.copyto0 := button_rec[19].caption;
              boot_ini.copyto1 := button_rec[22].caption;
              boot_ini.copyto2 := button_rec[24].caption;
              boot_ini.copyto3 := button_rec[26].caption;
      set_ini_value('bootloader','dir0',boot_ini.dir0);
      set_ini_value('bootloader','dir1',boot_ini.dir1);
      set_ini_value('bootloader','dir2',boot_ini.dir2);
      set_ini_value('bootloader','dir3',boot_ini.dir3);

      set_ini_value('bootloader','name',boot_ini.name);
      set_ini_value('bootloader','dept',boot_ini.dept);
      set_ini_value('bootloader','shellfile',boot_ini.shellfile);
      set_ini_value('bootloader','ramdrive',boot_ini.ramdrive);
      set_ini_value('bootloader','size',boot_ini.size);

      set_ini_value('bootloader','runprogram0',boot_ini.runprogram0);
      set_ini_value('bootloader','runprogram1',boot_ini.runprogram1);
      set_ini_value('bootloader','runprogram2',boot_ini.runprogram2);
      set_ini_value('bootloader','runprogram3',boot_ini.runprogram3);

      set_ini_value('bootloader','cmdline0',boot_ini.cmdline0);
      set_ini_value('bootloader','cmdline1',boot_ini.cmdline1);
      set_ini_value('bootloader','cmdline2',boot_ini.cmdline2);
      set_ini_value('bootloader','cmdline3',boot_ini.cmdline3);

      set_ini_value('bootloader','copyfrom0', boot_ini.copyfrom0);
      set_ini_value('bootloader','copyfrom1',boot_ini.copyfrom1);
      set_ini_value('bootloader','copyfrom2',boot_ini.copyfrom2);
      set_ini_value('bootloader','copyfrom3',boot_ini.copyfrom3);

      set_ini_value('bootloader','copyto0',boot_ini.copyto0);
      set_ini_value('bootloader','copyto1',boot_ini.copyto1);
      set_ini_value('bootloader','copyto2',boot_ini.copyto2);
      set_ini_value('bootloader','copyto3',boot_ini.copyto3);
              
end;




procedure get_bootloader_settings;
var ini_file,config_file : text;data : string;
begin
     assign(ini_file,'boot.ini');
     {$I-}
     reset(ini_file);
     finding := ioresult;
     {$I+}
     if finding <> 0 then begin

     rewrite(ini_file);
     writeln(ini_file,'[bootloader]');
     writeln(ini_file,'dir0='+boot_ini.dir0);
     writeln(ini_file,'dir1='+boot_ini.dir1);
     writeln(ini_file,'dir2='+boot_ini.dir2);
     writeln(ini_file,'dir3='+boot_ini.dir3);

     writeln(ini_file,'name='+boot_ini.name);
     writeln(ini_file,'dept='+boot_ini.dept);
     writeln(ini_file,'shellfile='+boot_ini.shellfile);
     writeln(ini_file,'ramdrive='+boot_ini.ramdrive);
     writeln(ini_file,'size='+boot_ini.size);

     writeln(ini_file,'runprogram0='+boot_ini.runprogram0);
     writeln(ini_file,'runprogram1='+boot_ini.runprogram1);
     writeln(ini_file,'runprogram2='+boot_ini.runprogram2);
     writeln(ini_file,'runprogram3='+boot_ini.runprogram3);

     writeln(ini_file,'cmdline0='+boot_ini.cmdline0);
     writeln(ini_file,'cmdline1='+boot_ini.cmdline1);
     writeln(ini_file,'cmdline2='+boot_ini.cmdline2);
     writeln(ini_file,'cmdline3='+boot_ini.cmdline3);

     writeln(ini_file,'copyfrom0='+boot_ini.copyfrom0);
     writeln(ini_file,'copyfrom1='+boot_ini.copyfrom1);
     writeln(ini_file,'copyfrom2='+boot_ini.copyfrom2);
     writeln(ini_file,'copyfrom3='+boot_ini.copyfrom3);

     writeln(ini_file,'copyto0='+boot_ini.copyto0);
     writeln(ini_file,'copyto1='+boot_ini.copyto1);
     writeln(ini_file,'copyto2='+boot_ini.copyto2);
     writeln(ini_file,'copyto3='+boot_ini.copyto3);
     writeln(ini_file,'[end]');
     writeln(ini_file,'[ntlogon]');
     writeln(ini_file,'ntusername='+boot_ini.ntusername);
     writeln(ini_file,'ntdomain='+boot_ini.ntdomain);
     writeln(ini_file,'ntcomputername='+boot_ini.ntcomputername);
     writeln(ini_file,'ntloginscript='+boot_ini.ntloginscript);
     writeln(ini_file,'ntnetfileslocation='+boot_ini.ntnetfileslocation);
     writeln(ini_file,'[end]');
     writeln(ini_file,'[nwlogon]');
     writeln(ini_file,'nwusername='+boot_ini.nwusername);
     writeln(ini_file,'nwloginserver='+boot_ini.nwloginserver);
     writeln(ini_file,'nwnetfileslocation='+boot_ini.nwnetfileslocation);
     writeln(ini_file,'[end]');
     writeln(ini_file,'[ntmappings]');
     for ch := 'a' to 'z' do writeln(ini_file,ch+'=');
     writeln(ini_file,'[end]');
     writeln(ini_file,'[nwmappings]');
     for ch := 'a' to 'z' do writeln(ini_file,ch+'=');
     writeln(ini_file,'[end]');
     end;
     close(ini_file);

              boot_ini.dir0 := get_ini_value('bootloader','dir0');
              boot_ini.dir1 := get_ini_value('bootloader','dir1');
              boot_ini.dir2 := get_ini_value('bootloader','dir2');
              boot_ini.dir3 := get_ini_value('bootloader','dir3');

              boot_ini.name := get_ini_value('bootloader','name');
              boot_ini.dept := get_ini_value('bootloader','dept');
              boot_ini.shellfile := get_ini_value('bootloader','shellfile'); 
              boot_ini.ramdrive := get_ini_value('bootloader','ramdrive');
              boot_ini.size := get_ini_value('bootloader','size');

              boot_ini.runprogram0 := get_ini_value('bootloader','runprogram0');
              boot_ini.runprogram1 := get_ini_value('bootloader','runprogram1');
              boot_ini.runprogram2 := get_ini_value('bootloader','runprogram2');
              boot_ini.runprogram3 := get_ini_value('bootloader','runprogram3');

              boot_ini.cmdline0 := get_ini_value('bootloader','cmdline0');
              boot_ini.cmdline1 := get_ini_value('bootloader','cmdline1');
              boot_ini.cmdline2 := get_ini_value('bootloader','cmdline2');
              boot_ini.cmdline3 := get_ini_value('bootloader','cmdline3');

              boot_ini.copyfrom0 := get_ini_value('bootloader','copyfrom0');
              boot_ini.copyfrom1 := get_ini_value('bootloader','copyfrom1');
              boot_ini.copyfrom2 := get_ini_value('bootloader','copyfrom2');
              boot_ini.copyfrom3 := get_ini_value('bootloader','copyfrom3');

              boot_ini.copyto0 := get_ini_value('bootloader','copyto0');
              boot_ini.copyto1 := get_ini_value('bootloader','copyto1');
              boot_ini.copyto2 := get_ini_value('bootloader','copyto2');
              boot_ini.copyto3 := get_ini_value('bootloader','copyto3');
              
end;

procedure init_bootloader_main;
var tab,save,close_program : boolean;c,bc,x,y1,x2,y2,ps_id,tabcounter : word;temp : string;a : longint;
begin
    get_bootloader_settings;
    x := 0;y1 := 0;close_program := false;
    pass := false;a:=0;bc := 2;
    tab := false;
    tabcounter := 1;
    randomize;
    paint_bootloader_window;
    pass := true;
    event.what := evmousedown;
    event.where_screen_id := 1;
    save := true;
    if save = true then begin
              setcolor(15);
              rectangle(button_rec[28+bc].x1*8-1,
                            button_rec[28+bc].y1*8-1,
                            button_rec[28+bc].x2*8+1,
                            button_rec[28+bc].y2*8+1);

              end;
    repeat
          if pass = false then get_event;
          pass := false;
          if (event.what = evmousemove) then begin
             case event.where_screen_id of
               0 : begin end;
               
             end;
          end;
          if tab = true then begin
             tab := false;
             case tabcounter of
               1 : begin edit_text_box(1,true,' ');end;
               2 : begin edit_text_box(2,true,' ');end;
               3 : begin edit_text_box(3,true,' ');end;
               4 : begin edit_text_box(4,true,' ');end;
               5 : begin edit_text_box(5,true,' ');end;
               6 : begin edit_text_box(6,true,' ');end;
               7 : begin edit_text_box(7,true,' ');end;
               8 : begin select_check_box(8);end;
               9 : begin edit_text_box(9,true,' ');end;
               10: begin edit_text_box(18,true,' ');end;
               11 : begin edit_text_box(19,true,' ');end;
               12 : begin edit_text_box(20,true,' ');end;
               13 : begin edit_text_box(22,true,' ');end;
               14 : begin edit_text_box(23,true,' ');end;
               15 : begin edit_text_box(24,true,' ');end;
               16 : begin edit_text_box(25,true,' ');end;
               17 : begin edit_text_box(26,true,' ');end;
               18 : begin edit_text_box(10,true,' ');end;
               19 : begin edit_text_box(11,true,' ');end;
               20 : begin edit_text_box(12,true,' ');end;
               21 : begin edit_text_box(13,true,' ');end;
               22 : begin edit_text_box(14,true,' ');end;
               23 : begin edit_text_box(15,true,' ');end;
               24 : begin edit_text_box(16,true,' ');end;
               25 : begin edit_text_box(17,true,' ');end;
               end;

          end;
          if (event.what = evmousedown) or (event.keypressed = true) then begin
             case event.where_screen_id of
               1 : begin edit_text_box(1,true,' ');tabcounter := 1;end;
               2 : begin edit_text_box(2,true,' ');tabcounter := 2;end;
               3 : begin edit_text_box(3,true,' ');tabcounter := 3;end;
               4 : begin edit_text_box(4,true,' ');tabcounter := 4;end;
               5 : begin edit_text_box(5,true,' ');tabcounter := 5;end;
               6 : begin edit_text_box(6,true,' ');tabcounter := 6;end;
               7 : begin edit_text_box(7,true,' ');tabcounter := 7;end;
               9 : begin edit_text_box(9,true,' ');tabcounter := 9;end;
               10 : begin edit_text_box(10,true,' ');tabcounter := 18;end;
               11 : begin edit_text_box(11,true,' ');tabcounter := 19;end;
               12 : begin edit_text_box(12,true,' ');tabcounter := 20;end;
               13 : begin edit_text_box(13,true,' ');tabcounter := 21;end;
               14 : begin edit_text_box(14,true,' ');tabcounter := 22;end;
               15 : begin edit_text_box(15,true,' ');tabcounter := 23;end;
               16 : begin edit_text_box(16,true,' ');tabcounter := 24;end;
               17 : begin edit_text_box(17,true,' ');tabcounter := 25;end;
               18 : begin edit_text_box(18,true,' ');tabcounter := 10;end;
               19 : begin edit_text_box(19,true,' ');tabcounter := 11;end;
               20 : begin edit_text_box(20,true,' ');tabcounter := 12;end;
               22 : begin edit_text_box(22,true,' ');tabcounter := 13;end;
               23 : begin edit_text_box(23,true,' ');tabcounter := 14;end;
               24 : begin edit_text_box(24,true,' ');tabcounter := 15;end;
               25 : begin edit_text_box(25,true,' ');tabcounter := 16;end;
               26 : begin edit_text_box(26,true,' ');tabcounter := 17;end;


             end;
             if event.keypressed = true then begin
                case event.key of
                     #13 : close_program := true;
                     #75 : begin
                         save := false;
                         if bc > 1 then begin
                         bc := bc -1;
                         setcolor(1);
                        
                         rectangle(button_rec[29].x1*8-1,
                            button_rec[29].y1*8-1,
                            button_rec[29].x2*8+1,
                            button_rec[29].y2*8+1);
                         rectangle(button_rec[30].x1*8-1,
                            button_rec[30].y1*8-1,
                            button_rec[30].x2*8+1,
                            button_rec[30].y2*8+1);
                         setcolor(15);
                          
                         rectangle(button_rec[28+bc].x1*8-1,
                            button_rec[28+bc].y1*8-1,
                            button_rec[28+bc].x2*8+1,
                            button_rec[28+bc].y2*8+1);


                         end;
                         end;
                     #77 : begin

                         if bc = 2 then save := true;
                         if bc < 2 then begin
                         bc := bc +1;
                         setcolor(1);
                         
                            
                         rectangle(button_rec[29].x1*8-1,
                            button_rec[29].y1*8-1,
                            button_rec[29].x2*8+1,
                            button_rec[29].y2*8+1);
                         rectangle(button_rec[30].x1*8-1,
                            button_rec[30].y1*8-1,
                            button_rec[30].x2*8+1,
                            button_rec[30].y2*8+1);
                         setcolor(15);
                          
                         rectangle(button_rec[28+bc].x1*8-1,
                            button_rec[28+bc].y1*8-1,
                            button_rec[28+bc].x2*8+1,
                            button_rec[28+bc].y2*8+1);
                         
                         
                         end;
                         end;
                         
                     #80 : if tabcounter < 25 then begin
                              tab := true;
                              tabcounter := tabcounter + 1;
                           end else begin tabcounter := 1;tab := true;end;
                     #72 : if tabcounter > 1 then begin
                              tab := true;
                              tabcounter := tabcounter - 1;
                           end else begin tabcounter := 26;tab := true;end;
                     #27 : close_program := true;
                end;
             end;
             case event.where_screen_id of
               29 : begin close_program := true;save := false;press_button(29,true,true);end;
               30 : begin close_program := true;save := true;press_button(30,true,true);end;
               8 : begin select_check_box(8);tabcounter := 8;end;
             end;
          end;

    until close_program = true;
    if save = true then save_bootloader_settings;
    ch := #68;
end;





procedure init_settings_menu;
var done : boolean;
begin
     repeat
     splash_screen(false,false);
     paint_settings_menu;
    repeat
         get_event;
         if event.keypressed = true then
         case event.key of
             #72 : scroll_scroll_box(true,1);
             #80 : scroll_scroll_box(false,1);

            end;
    until (event.key = #27) or (event.key = #13);
    if event.keypressed = true then
            case event.key of
             #13 : case scroll_rec[1].globalpos of
                        1 : init_bootloader_main;
                        2 : init_net_logon_menu;
                        4 : begin debug := true;done:= true;end;
                        5 : done := true;
                   end;
            end;
    until (event.key = #27) or (done = true);

end;


procedure makedirectory(directory : string);
begin
     while doserror = 0 do
     mkdir(directory);
     if doserror <> 0 then doserrorcode := doserror;
end;


procedure Copy(source,target,last_drive : string;debug : boolean;ref : word);
{ Simple copy program w/NO error checking }
var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  buf: array[1..2048] of Char;
  path : string;
begin
     hidemouse;
  if source[1] = '\' then source := last_drive+source;
  if target[1] = '\' then target := last_drive+target;
  showmouse;
  finding := 0;
  if (source <> '') and (target <> '') then begin
 
  {$I-}
  Assign(FromF, source);
  Reset(FromF, 1);
  finding := ioresult;
  {$I+}
  if finding = 0 then begin
  Assign(ToF, target);
  {$I-}
  Rewrite(ToF, 1);
  finding := ioresult;
  {$I+}
  if finding = 0 then begin
  setcolor(15);
  
  repeat
    BlockRead(FromF,buf,
              SizeOf(buf),NumRead);
    BlockWrite(ToF,buf,NumRead,NumWritten);
  until (NumRead = 0) or
        (NumWritten <> NumRead);
  Close(ToF);
  end;
  Close(FromF);
  end;
  end;
  str(finding,path);
  hidemouse;
  if (finding <> 0) then runtimeerror := 'Error Copying '+source+' to '+target+' ('+path+')';
  if (finding = 0) and (source <> '') and (target <> '') then runtimeerror := 'Successfully copied '+source+' to '+target;
  if (source = '') and (target = '') then runtimeerror := 'No File(s) specified';
  showmouse;
  if finding <> 0 then errorstat := true;
end;

procedure md(dir_path,last_drive : string;debug : boolean;ref : word);
var path,errorcode : string;
begin
     finding := 0;
     hidemouse;
     if dir_path[1] = '\' then path := last_drive+dir_path else path := dir_path;
     {$I-}
     if dir_path <> '' then begin
                      mkdir(path);
                      doserrorcode := doserror;
                      end else runtimeerror := 'No Directory Specified';
     finding := ioresult;
     {$I+}
     str(finding,errorcode);
     if (dir_path <> '') then if (finding = 0) then runtimeerror := 'Successfully created '+path;
     if (dir_path <> '') then if finding <> 0 then runtimeerror := 'Error creating '+path+' ('+errorcode+')';
     showmouse;
     if finding <> 0 then errorstat := true;
end;

procedure run(application,cmdline : string;debug : boolean);
var command : string;hhh : char;
begin
  if application <> '' then begin
     if application[1] = '\' then application := last_drive+application;
     if cmdline[1] = '\' then cmdline := last_drive+cmdline;
     setfillstyle(1,0);
     hidemouse;
     bar(0,0,640,480);
     SwapVectors;
     exec(application,cmdline);
     showmouse;
     SwapVectors;
  if debug = true then begin
     paint_window(25,30,55,33,7,1,15,'Press Any Key To Continue.','');hhh := readkey;end;
  end;
  str(doserror,command);
  if DosError <> 0 then runtimeerror := 'Error running '+application+' '+cmdline+' ('+command+')';
  if (doserror = 0) and (application <> '') then runtimeerror := 'Successfully ran '+application+' '+cmdline;
  if application = '' then runtimeerror := 'No application specified';
  repeat
     if keypressed = true then hhh := readkey;
  until keypressed = false;

end;


procedure bolt(x,color : word);
begin
     setcolor(color);
     line(290+x,70+x,240+x,180-x);
     line(240+x,180-x,290+x,182-x);
     line(290+x,182-x,250+x,290-x);
     line(250+x,290-x,306+x,292-x);
     line(306+x,292-x,250+x,430-x);
     line(250+x,430-x,355-x,270+x);
     line(355-x,270+x,310-x,267+x);
     line(310-x,267+x,360-x,165+x);
     line(360-x,165+x,305-x,159+x);
     line(305-x,159+x,345-x,75+x);
     line(345-x,75+x,290+x,70+x);
end;


procedure init_boot_loader;
var ch2:char;done,first_time : boolean;path : string;x : word;
P: PathStr;

N: NameStr;
E: ExtStr;
begin
     first_time := true;
     showmouse;
     repeat
     if first_time = true then splash_screen(true,true) else splash_screen(false,true);
     first_time := false;
     ch2 := '3';
     delays(2);
     done := true;
     if keypressed = true then repeat ch2 := readkey; until keypressed = false;
     if ch2 = #68 then begin init_settings_menu;done := false;end;
     if ch2 = #27 then begin end_graphics_mode;clrscr;halt;end;
     if (ch2 = #59) or (debug = true) then begin debug := true;done := true;end else debug := false;
     until done = true;
          setcolor(9);
     outtextxy(200,470,'            ESC = Bypass Startup files  F10 = Setup');
     writeconfigsys;
     setcolor(15);
     last_drive := current_ram_drive;
     if debug = true then paint_debug_screen(true);
     if debug = false then status_bar(27*8,34*8,1,25,'Creating Directorys...');
     md(boot_ini.dir0,last_drive,debug,1);debug_rec.dir0 := runtimeerror;
     if debug = true then paint_debug_screen(false);
     if debug = false then status_bar(27*8,34*8,25,50,'Creating Directorys...');
     md(boot_ini.dir1,last_drive,debug,2);debug_rec.dir1 := runtimeerror;
     if debug = true then paint_debug_screen(false);
     if debug = false then status_bar(27*8,34*8,50,75,'Creating Directorys...');
     md(boot_ini.dir2,last_drive,debug,3);debug_rec.dir2 := runtimeerror;
     if debug = true then paint_debug_screen(false);
     if debug = false then status_bar(27*8,34*8,75,100,'Creating Directorys...');
     md(boot_ini.dir3,last_drive,debug,4);debug_rec.dir3 := runtimeerror;
     if debug = true then paint_debug_screen(false);
     delayms(5);
     if debug = false then status_bar(27*8,34*8,1,25,'Copying Files...');
     copy(boot_ini.copyfrom0,boot_ini.copyto0,last_drive,debug,1);debug_rec.copy0 := runtimeerror;
     if debug = true then paint_debug_screen(false);
     if debug = false then status_bar(27*8,34*8,25,50,'Copying Files...');
     copy(boot_ini.copyfrom1,boot_ini.copyto1,last_drive,debug,2);debug_rec.copy1 := runtimeerror;
     if debug = true then paint_debug_screen(false);
     if debug = false then status_bar(27*8,34*8,50,75,'Copying Files...');
     copy(boot_ini.copyfrom2,boot_ini.copyto2,last_drive,debug,3);debug_rec.copy2 := runtimeerror;
     if debug = true then paint_debug_screen(false);
     if debug = false then status_bar(27*8,34*8,75,100,'Copying Files...');
     copy(boot_ini.copyfrom3,boot_ini.copyto3,last_drive,debug,4);debug_rec.copy3 := runtimeerror;
     if debug = true then paint_debug_screen(false);
     delayms(5);
     if debug = false then status_bar(27*8,34*8,1,25,'Running Programs...');
     run(boot_ini.runprogram0,boot_ini.cmdline0,debug);debug_rec.exe0 := runtimeerror;
     if debug = true then paint_debug_screen(true);
     if debug = false then begin splash_screen(false,false);status_bar(27*8,34*8,25,50,'Running Programs...');end;
     run(boot_ini.runprogram1,boot_ini.cmdline1,debug);debug_rec.exe1 := runtimeerror;
     if debug = true then paint_debug_screen(true);
     if debug = false then begin splash_screen(false,false);status_bar(27*8,34*8,50,75,'Running Programs...');end;
     run(boot_ini.runprogram2,boot_ini.cmdline2,debug);debug_rec.exe2 := runtimeerror;
     if debug = true then paint_debug_screen(true);
     if debug = false then begin splash_screen(false,false);status_bar(27*8,34*8,75,100,'Running Programs...');end;
     run(boot_ini.runprogram3,boot_ini.cmdline3,debug);debug_rec.exe3 := runtimeerror;
     if debug = true then paint_debug_screen(true);
     if debug = true then ch := readkey;
     splash_screen(false,false);
     FSplit(last_drive+boot_ini.shellfile, D, N, E);
     path := '';
     for x := 1 to length(d)-1 do path := path + d[x];
     {$I-}
     chdir(path);
     {$I+}
     run(boot_ini.shellfile,'',false);exit_error := runtimeerror;
     splash_screen(false,false);
     delayms(5);
     setfillstyle(1,9);
     bar(0,0,640,480);
     setcolor(15);
     SetTextStyle(DefaultFont, HorizDir,1);
     outtextxy(2,3,'Boot Loader v5.0');
     delayms(15);

end;




procedure set_varibles;
var x : char;
begin
     for x := 'a' to 'z' do ntmapping[x] := '';
     for x := 'a' to 'z' do nwmapping[x] := '';
     errorstat := false;
     clear_screen_map;
     screen_size.cols := 80;
     screen_size.rows := 25;
     res.x := getmaxx;
     res.y := getmaxy;
     char_size.x := (res.x + 1) div screen_size.cols;
     char_size.y := (res.y + 1) div screen_size.rows;
     boot_ini.dir0 := '';
     boot_ini.dir1 := '';
     boot_ini.dir2 := '';
     boot_ini.dir3 := '';

     boot_ini.name := '';
     boot_ini.dept := '';
     boot_ini.shellfile := '';
     boot_ini.ramdrive := 'yes';
     boot_ini.size := '4096';

     boot_ini.runprogram0 := '';
     boot_ini.runprogram1 := '';
     boot_ini.runprogram2 := '';
     boot_ini.runprogram3 := '';

     boot_ini.cmdline0 := '';
     boot_ini.cmdline1 := '';
     boot_ini.cmdline2 := '';
     boot_ini.cmdline3 := '';

     boot_ini.copyfrom0 := '';
     boot_ini.copyfrom1 := '';
     boot_ini.copyfrom2 := '';
     boot_ini.copyfrom3 := '';

     boot_ini.copyto0 := '';
     boot_ini.copyto1 := '';
     boot_ini.copyto2 := '';
     boot_ini.copyto3 := '';
     boot_ini.ntusername := '';
     boot_ini.ntdomain := '';
     boot_ini.ntcomputername := '';
     boot_ini.ntloginscript := '';
     boot_ini.ntnetfileslocation := '';
     boot_ini.nwusername := '';
     boot_ini.nwloginserver := '';
     boot_ini.nwnetfileslocation := '';

     debug_rec.dir0  := '';
     debug_rec.dir1  := '';
     debug_rec.dir2  := '';
     debug_rec.dir3  := '';
     debug_rec.copy0  := '';
     debug_rec.copy1  := '';
     debug_rec.copy2  := '';
     debug_rec.copy3  := '';
     debug_rec.exe0  := '';
     debug_rec.exe1  := '';
     debug_rec.exe2  := '';
     debug_rec.exe3  := '';

end;

procedure startup;
begin
     set_varibles;
     start_mouse;
     start_graphics_mode;
     get_bootloader_settings;
end;

procedure shutdown;
begin
     end_graphics_mode;
     if exit_error[1] <> 'S' then writeln('Shell File : ',exit_error);
end;

begin
      startup;
      init_boot_loader;
      shutdown;
end.
     
