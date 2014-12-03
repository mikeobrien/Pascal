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
    r_inventory = record
                  ser_num : string[15];
                  name : string[15];
                  comment : string;
                  date : string;
                  move_out_name : string[15];
                  move_out_comment : string;
                  move_out_date : string;
                  end;
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
     a_scroll_bar_data = array[1..300] of string[12];
     r_scroll_bar_rec = record
                      x1,y1,x2,y2 : word;
                      textcolor : byte;
                      face_color : byte;
                      caption : string;
                      caption_length : byte;
                      face_id : byte;
                      up_button_id : byte;
                      down_button_id : byte;
                      current_marker_pos : word;
                      current_list_pos : word;
                      scroll_bar_data : string;
                      filter : string;
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
   selected_rec,number_of_recs : longint;
   res : r_res;
   char_size : r_char_size;
   screen_size : r_screen_size;
   screen_map : a_screen_map;
   inventory,inventory_temp : r_inventory;
   inventory_file,history_file,temp_file,temp_file2 : file of r_inventory;
   button_rec : a_button_rec;
   done,close_program,match,end_of_file : boolean;
   mouse_event : tevent;
   event : r_event;
   current_bitmap_color,finding : word;
   bitmap_buffer,current_bitmap : a_bitmap;
   original_x,original_y,size : word;
   scroll_bar_rec : r_scroll_bar_rec;
   bitmap_file : file of a_bitmap;
   bitmap_filename,text_style : string;
   p : pointer;
   data_path,date,uppercase,working_directory,data_directory : string;
   var d,m,y,dow : word;
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

procedure comp(filter,comp_string : string);
var x,y,z : word;temp_str : string;
begin
     temp_str := '';
     for x := 1 to length(filter) do temp_str := temp_str + comp_string[x];
     if filter = temp_str then match := true else match := false;
end;


procedure write_scroll_box_field(record_number,position : longint;highlight : boolean;filter : string);
var x,y,z,c : word;data_file,line1,line2 : string;
begin
     if text_style = 'norm' then c := 5 else c := 0;
     if record_number <> 0 then begin
     data_file := data_path;
     data_file := data_file + scroll_bar_rec.scroll_bar_data;
     
     assign(inventory_file,data_file);
     {$I-}
     reset(inventory_file);
     finding := ioresult;
     {$I+}
     if finding = 0 then begin
     z := 0;
     for x := 1 to record_number do
         begin
              match := false;
              repeat
                    z := z + 1;
                    if eof(inventory_file) = false then read(inventory_file,inventory_temp);
                    if filter <> '' then comp(filter,inventory_temp.ser_num) else match := true;
              until (match = true) or (eof(inventory_file));
         end;
     if eof(inventory_file) = true then end_of_file := true;
     if eof(inventory_file) = false then end_of_file := false;
     close(inventory_file);
     if highlight = true then selected_rec := z;
     if match = true then begin
        setfillstyle(1,1);
        if highlight = true then begin
        bar(scroll_bar_rec.x1*8+2,scroll_bar_rec.y1*8+(position * 24)
            ,scroll_bar_rec.x2*8-18,scroll_bar_rec.y1*8+23 + (position * 24));
        setcolor(15);
        end else begin
        setfillstyle(1,15);
        bar(scroll_bar_rec.x1*8+2,scroll_bar_rec.y1*8+(position * 24)
                                     ,scroll_bar_rec.x2*8-18,scroll_bar_rec.y1*8+23 + (position * 24));
        setcolor(15);
        end;
        if highlight = true then setcolor(14) else setcolor(4);
        outtextxy(scroll_bar_rec.x1*8+5,scroll_bar_rec.y1*8+2+(position * 24)-c,inventory_temp.ser_num);
        if highlight = true then setcolor(15) else setcolor(0);
        outtextxy(scroll_bar_rec.x1*8+5+(8*11),scroll_bar_rec.y1*8+2+(position * 24)-c,inventory_temp.date);
        outtextxy(scroll_bar_rec.x1*8+5+(8*27),scroll_bar_rec.y1*8+2+(position * 24)-c,inventory_temp.name);
        outtextxy(scroll_bar_rec.x1*8+5+(8*43),scroll_bar_rec.y1*8+2+(position * 24)-c,inventory_temp.comment);
        outtextxy(scroll_bar_rec.x1*8+5+(8*11),scroll_bar_rec.y1*8+14+(position * 24)-c,inventory_temp.move_out_date);
        outtextxy(scroll_bar_rec.x1*8+5+(8*27),scroll_bar_rec.y1*8+14+(position * 24)-c,inventory_temp.move_out_name);
        outtextxy(scroll_bar_rec.x1*8+5+(8*43),scroll_bar_rec.y1*8+14+(position * 24)-c,inventory_temp.move_out_comment);


     end;
     end;
     end else begin
     setfillstyle(1,15);
     bar(scroll_bar_rec.x1*8+2,scroll_bar_rec.y1*8+(position * 24)
                                     ,scroll_bar_rec.x2*8-18,scroll_bar_rec.y1*8+23 + (position * 24));
     end;
end;


procedure get_record_count(filter : string);
var data_file : string;z : word;
begin
     data_file := data_path;
     data_file := data_file + scroll_bar_rec.scroll_bar_data;
     assign(inventory_file,data_file);
     {$I-}
     reset(inventory_file);
     finding := ioresult;
     {$I+}
     if finding = 0 then begin
     z := 0;
     repeat
     match := false;
     repeat
           if eof(inventory_file) = false then read(inventory_file,inventory_temp);
           if filter <> '' then comp(filter,inventory_temp.ser_num) else match := true;
     until (match = true) or (eof(inventory_file));
     z := z + 1;
     until eof(inventory_file);
     close(inventory_file);
     number_of_recs := z;
     end else

         number_of_recs := 0;
end;

procedure update_scroll_box(filter : string;reset : boolean);
var x,y,z : word;
begin
     setfillstyle(1,15);
        {bar(scroll_bar_rec.x1*8+2,scroll_bar_rec.y1*8+24
            ,scroll_bar_rec.x2*8-18,scroll_bar_rec.y1*8+23 + (11 * 24));}
     if reset = true then begin
        scroll_bar_rec.current_marker_pos := 1;
        scroll_bar_rec.current_list_pos := 1;
        scroll_bar_rec.filter := filter;
     end;
     x := 0;
     y := scroll_bar_rec.current_marker_pos - scroll_bar_rec.current_list_pos;
         repeat
               y := y + 1;
               x := x + 1;
               if x = scroll_bar_rec.current_list_pos then
               write_scroll_box_field(y,x,true,filter) else
               write_scroll_box_field(y,x,false,filter);
         until (end_of_file = true) or (x = 11);
     if x < 11 then for y := x to 11 do write_scroll_box_field(0,y,false,'');
end;

procedure move_out_stock(name,comment : string);
var x,y,z : word;data_file : string;
begin
     get_record_count('');
     if number_of_recs > 0 then begin
     assign(history_file,data_path+'history.dat');
     assign(inventory_file,data_path+scroll_bar_rec.scroll_bar_data);
     assign(temp_file,data_path+'temp.$$$');
     {$I-}
     reset(inventory_file);
     finding := ioresult;
     {$I+}
     rewrite(temp_file);
     x := 0;
     if finding = 0 then begin
          repeat
            x := x + 1;
            read(inventory_file,inventory);
            if x <> selected_rec then write(temp_file,inventory) else begin
               end;
          until eof(inventory_file);
          erase(inventory_file);
          close(inventory_file);
          if (x > 1) then begin rename(temp_file,scroll_bar_rec.scroll_bar_data);end else
                begin erase(temp_file);end;
          close(temp_file);
     end;
     {$I-}
     reset(history_file);
     finding := ioresult;
     {$I+}
     update_scroll_box(scroll_bar_rec.filter,true);
     end;
end;


procedure scroll_scroll_box(direction,update : boolean;filter : string);
var x,y,z,cmp,clp : word;
begin
     get_record_count(filter);
     if direction = true then begin
         if scroll_bar_rec.current_marker_pos < number_of_recs  then
         begin
         scroll_bar_rec.current_marker_pos := scroll_bar_rec.current_marker_pos + 1;
         if scroll_bar_rec.current_list_pos < 11 then
            scroll_bar_rec.current_list_pos := scroll_bar_rec.current_list_pos + 1;
         end;
         update_scroll_box(filter,update);
     end else begin
     
     if scroll_bar_rec.current_marker_pos > 1 then
            scroll_bar_rec.current_marker_pos := scroll_bar_rec.current_marker_pos - 1;

         if scroll_bar_rec.current_list_pos > 1 then
            scroll_bar_rec.current_list_pos := scroll_bar_rec.current_list_pos - 1;
         update_scroll_box(filter,update);
     end;
end;



procedure create_scroll_box(x1,y1,x2,y2,textcolor,face_color,up_button_id,down_button_id : word;caption,
          scroll_bar_data : string);
var x,y,z,c : word;ch : char;
begin
     if text_style = 'norm' then c := 5 else c := 0;
     scroll_bar_rec.x1 := x1;
     scroll_bar_rec.y1 := y1;
     scroll_bar_rec.x2 := x2;
     scroll_bar_rec.y2 := y2;
     scroll_bar_rec.textcolor := textcolor;
     scroll_bar_rec.face_color := face_color;
     scroll_bar_rec.caption := caption;
     scroll_bar_rec.up_button_id := up_button_id;
     scroll_bar_rec.down_button_id := down_button_id;
     scroll_bar_rec.current_marker_pos := 0;
     scroll_bar_rec.current_list_pos := 0;
     scroll_bar_rec.filter := '';
     scroll_bar_rec.scroll_bar_data := scroll_bar_data;
     plaque(false,x1*8,y1*8,x2*8,y2*8,face_color);
     setfillstyle(1,8);
     bar(x2*8-16,y1*8+2,x2*8-1,y2*8-2);
     setcolor(0);
     line(x2*8-17,y1*8+2,x2*8-17,y2*8-2);
     line(x2*8,y1*8+2,x2*8,y2*8-2);
     create_button(x2-2,y1,x2,y1+2,0,7,up_button_id,'','up.bmp',true,false);
     create_button(x2-2,y2-2,x2,y2,0,7,down_button_id,'','down.bmp',true,false);
     plaque(true,x1*8+2,y1*8+2,x1*8+90,y1*8+23,7);
     setcolor(5);
     outtextxy(x1*8+10,y1*8+9-c,'Last Name');
     plaque(true,x1*8+91,y1*8+2,x1*8+220,y1*8+23,7);
     setcolor(5);
     outtextxy(x1*8+99,y1*8+9-c,'First Name');
     plaque(true,x1*8+221,y1*8+2,x1*8+348,y1*8+23,7);
     setcolor(5);
     outtextxy(x1*8+229,y1*8+9-c,'Phone Number');
     plaque(true,x1*8+349,y1*8+2,x2*8-18,y1*8+23,7);
     setcolor(5);
     outtextxy(x1*8+358,y1*8+9-c,'Address');
     scroll_bar_rec.filter := caption;
     update_scroll_box('',true);
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

procedure scroll_box(control_id : word);
begin

end;

procedure paint_main_window;
var current_date : string;
begin
     hidemouse;
     setfillstyle(1,3);
     bar(1,1,640,480);
     {--Create Buttons--}
     paint_window(25,12,56,45,7,1,15,'Inventory Manager','wt.bmp');
     create_button(29,17,52,22,1,7,1,'Move INTO stock','movein.bmp',true,false);
     create_button(29,24,52,29,1,7,2,'Move OUT of stock','moveout.bmp',true,false);
     create_button(29,31,52,36,1,7,3,'View History','history.bmp',true,false);
     create_button(26,39,40,44,1,7,4,'Settings','settings.bmp',true,false);
     create_button(41,39,55,44,1,7,5,'Exit','exit.bmp',true,false);
     showmouse;
end;

procedure paint_add_window;
var x : word;
begin
     if text_style = 'norm' then x := 5 else x := 0 ;
     hidemouse;
     clear_screen_map;
     {--Create Buttons--}
     paint_window(20,12,63,50,7,1,15,'Add Entry','window.bmp');
     create_button(38,44,49,48,1,7,1,'Cancel','',true,false);
     create_button(50,44,61,48,1,7,2,'Add','',true,false);
     setcolor(0);
     outtextxy(22*8+2,19*8-2-x,'Last Name:');
     create_text_box(22,20,4,7,3,10,'');
     setcolor(0);
     outtextxy(43*8+2,19*8-2-x,'First Name:');
     create_text_box(43,20,4,7,4,15,'');
     setcolor(0);
     outtextxy(22*8+2,25*8-2-x,'Home Phone:');
     create_text_box(22,26,4,7,5,15,'');
     setcolor(0);
     outtextxy(43*8+2,25*8-2-x,'Work Phone:');
     create_text_box(43,26,4,7,6,15,'');
     setcolor(0);
     outtextxy(22*8+2,31*8-2-x,'Street Address:');
     create_text_box(22,32,4,7,7,30,'');
     setcolor(0);
     outtextxy(22*8+2,37*8-2-x,'City/State/Zip:');
     create_text_box(22,38,4,7,8,30,'');

     showmouse;
end;

procedure paint_move_window;
var x : word;
begin
     if text_style = 'norm' then x := 5 else x := 0;
     hidemouse;
     clear_screen_map;
     {--Create Buttons--}
     paint_window(20,12,63,46,7,1,15,'Phone Book','wt.bmp');
     create_button(38,40,49,44,1,7,1,'Cancel','',true,false);
     create_button(50,40,61,44,1,7,2,'Move OUT','',true,false);
     setcolor(0);
     outtextxy(22*8+2,19*8-2-x,'Contact:');
     create_text_box(22,20,4,7,3,15,'');
     setcolor(0);
     outtextxy(22*8+2,27*8-2-x,'Comments:');
     create_text_box(22,28,4,7,4,30,'');

     showmouse;
end;

procedure paint_settings_window;
var x : word;
begin
     if text_style = 'norm' then x := 5 else x := 0;
     hidemouse;
     clear_screen_map;
     {--Create Buttons--}
     paint_window(20,12,63,46,7,1,15,'Settings','window.bmp');
     create_button(38,40,49,44,1,7,1,'Cancel','',true,false);
     create_button(50,40,61,44,1,7,2,'Save','',true,false);
     setcolor(0);
     outtextxy(22*8+2,19*8-2-x,'Working Directory: (c:\inventor)');
     create_text_box(22,20,4,7,3,30,working_directory);
     setcolor(0);
     outtextxy(22*8+2,27*8-2-x,'Data Directory: (c:\inventor\)');
     create_text_box(22,28,4,7,4,30,data_path);
     if text_style = 'norm' then create_button(24,35,25,36,0,15,5,'Bold Text','',false,true) else
     create_button(24,35,25,36,0,15,5,'Bold Text','',true,true);
     showmouse;
end;


procedure paint_view_window;
var x : word;
begin
     if text_style = 'norm' then x := 5 else x := 0;
     hidemouse;
     clear_screen_map;
     {--Create Buttons--}
     paint_window(0,0,80,60,7,1,15,'Phone Book','window.bmp');
     create_button(60,55,71,59,1,7,1,'Exit','',true,false);
     create_button(48,55,59,59,1,7,2,'Delete','',true,false);
     create_button(36,55,47,59,1,7,6,'Add','',true,false);
     create_button(24,55,35,59,1,7,7,'Settings','',true,false);
     setcolor(0);
     outtextxy(2*8+2,4*8-2-x,'Filter:');
     create_text_box(2,5,4,7,3,15,'');
     create_scroll_box(2,12,78,50,1,15,4,5,'Current Inventory','inventor.dat');

     showmouse;
end;

procedure paint_history_window;
var x : word;
begin
     if text_style = 'norm' then x := 5 else x := 0;
     hidemouse;
     clear_screen_map;
     {--Create Buttons--}
     paint_window(0,0,80,60,7,1,15,'Inventory History','wt.bmp');
     create_button(60,55,71,59,1,7,1,'Done','',true,false);
     setcolor(0);
     outtextxy(2*8+2,4*8-2-x,'Filter:');
     create_text_box(2,5,4,7,3,15,'');
     create_scroll_box(2,12,78,50,1,15,4,5,'Inventory History','history.dat');
     update_scroll_box('',true);
     showmouse;
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



procedure exit_program;
var ch : char;
begin
    close_program := true;
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
        working_directory := 'c:\phonebk';
        data_path := 'c:\phonebk\';
        text_style := 'bold';
        save_settings;
     end else begin
     readln(settings_file,working_directory);
     readln(settings_file,data_path);
     readln(settings_file,text_style);
     close(settings_file);
     end;
end;

procedure save_rec(last_name,first_name,home_phone,work_phone,s_address,csz : string);
var data_file : string;
begin
     inventory_temp.ser_num := '``12w2kdccwoek';
     assign(inventory_file,data_path+'inventor.dat');
     {$I-}
     reset(inventory_file);
     finding := ioresult;
     {$I+}
     if finding <> 0 then begin
        rewrite(inventory_file);
     end else
     begin
     repeat
           read(inventory_file,inventory_temp);
     until (EOF(inventory_file));
     end;
     inventory.ser_num := last_name;
     inventory.name := home_phone;
     inventory.comment := s_address;
     inventory.move_out_name := work_phone;
     inventory.move_out_comment := csz;
     inventory.move_out_date := '';
     get_date;
     inventory.date := first_name;
     write(inventory_file,inventory);
     close(inventory_file);
     done := true;
end;

procedure add_rec;
var text_box,default : boolean;
begin
     default := true;
     event.where_screen_id := 3;
     event.buttons := 1;
     paint_add_window;
     repeat
           if default = false then
           repeat
           get_event;
           until ((event.buttons = 1) or (event.buttons = 2)) and (event.what = evmousedown);
           if event.buttons = 1 then
           repeat
           text_box := false;
           case event.where_screen_id of
               1 : begin press_button(1,true);done := true;end;
               2 : begin press_button(2,true);save_rec(
                 button_rec[3].caption,button_rec[4].caption,button_rec[5].caption
                 ,button_rec[6].caption,button_rec[7].caption,button_rec[8].caption);end;
               3 : begin edit_text_box(3,true);
                         text_box := true;
                         default := false;end;
               4 : begin edit_text_box(4,true);text_box := true;default := false;end;
               5 : begin edit_text_box(5,false);text_box := true;default := false;end;
               6 : begin edit_text_box(6,false);text_box := true;default := false;end;
               7 : begin edit_text_box(7,false);text_box := true;default := false;end;
               8 : begin edit_text_box(8,false);text_box := true;default := false;end;
           end;
           until text_box = false;
     until done = true;
     paint_view_window;
end;

procedure move_rec;
var text_box,default : boolean;
begin
     default := true;
     event.where_screen_id := 3;
     event.buttons := 1;
     paint_move_window;
     {capture_screen(20*8,12*8,63*8,46*8);}
     repeat
           if default = false then
           repeat
           get_event;
           until ((event.buttons = 1) or (event.buttons = 2)) and (event.what = evmousedown);
           if event.buttons = 1 then
           repeat
           text_box := false;
           case event.where_screen_id of
               1 : begin press_button(1,true);done := true;end;
               2 : begin press_button(2,true);
                         done := true;end;
               3 : begin edit_text_box(3,true);
                         text_box := true;
                         default := false;end;
               4 : begin edit_text_box(4,true);text_box := true;default := false;end;
           end;
           until text_box = false;
     until done = true;
     paint_view_window;
end;

procedure settings;
var text_box,default : boolean;style : string;
begin
     default := true;style := text_style;
     event.where_screen_id := 3;
     event.buttons := 1;
     paint_settings_window;
     {capture_screen(20*8,12*8,63*8,46*8);}
     repeat
           if default = false then
           repeat
           get_event;
           until ((event.buttons = 1) or (event.buttons = 2)) and (event.what = evmousedown);
           if event.buttons = 1 then
           repeat
           text_box := false;
           case event.where_screen_id of
               1 : begin press_button(1,true);done := true;end;
               2 : begin press_button(2,true);
                   working_directory := button_rec[3].caption;
                   data_path := button_rec[4].caption;
                   text_style := style;
                   save_settings;
                   done := true;end;
               3 : begin edit_text_box(3,true);
                         text_box := true;
                         default := false;end;
               4 : begin edit_text_box(4,true);text_box := true;default := false;end;
               5 : begin paint_check_box(5);if style = 'bold' then style := 'norm' else style := 'bold';end;
           end;
           until text_box = false;
     until done = true;
     if text_style = 'bold' then SetTextStyle(0, HorizDir,1)
     else settextstyle(2,horizdir,5);
     paint_view_window;
end;


procedure filter_text_box(control_id : word;upper_case : boolean);
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
              make_uppercase(button_rec[control_id].caption);
              button_rec[control_id].caption := uppercase;
              scroll_bar_rec.filter := UPPERCASE;
              update_scroll_box(button_rec[control_id].caption,true);
              paint_button(control_id,false);end;
              if (event.key = #8) and
              (length(button_rec[control_id].caption) > 0) then begin
              input := '';
              for x := 1 to length(button_rec[control_id].caption) - 1 do input := input + 
              button_rec[control_id].caption[x];
              button_rec[control_id].caption := input;
              make_uppercase(button_rec[control_id].caption);
              button_rec[control_id].caption := uppercase;
              scroll_bar_rec.filter := UPPERCASE;
              update_scroll_box(button_rec[control_id].caption,true);
              paint_button(control_id,false);
              
              end;
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
end;


procedure view_rec;
var text_box,default : boolean;
begin
     default := true;
     event.where_screen_id := 3;
     event.buttons := 1;
     paint_view_window;
     repeat
           if default = false then
           repeat
           get_event;
           until ((event.buttons = 1) or (event.buttons = 2)) and (event.what = evmousedown);
           if event.buttons = 1 then
           repeat
           text_box := false;
           done := false;
           case event.where_screen_id of
               1 : begin press_button(1,true);done := true;end;
               2 : begin press_button(2,true);move_out_stock('','');done := false;end;
               3 : begin filter_text_box(3,true);
                         text_box := true;
                         default := false;end;
               4 : begin press_button(4,true);scroll_scroll_box(false,false,scroll_bar_rec.filter);end;
               5 : begin press_button(5,true);scroll_scroll_box(true,false,scroll_bar_rec.filter);end;
               6 : begin press_button(6,true);add_rec;done := false;end;
               7 : begin press_button(7,true);settings;done := false;end;
           end;
           until text_box = false;
     until done = true;
end;

procedure view_history;
var text_box,default : boolean;
begin
     default := true;
     event.where_screen_id := 3;
     event.buttons := 1;
     paint_history_window;

     repeat
           if default = false then
           repeat
           get_event;
           until ((event.buttons = 1) or (event.buttons = 2)) and (event.what = evmousedown);
           if event.buttons = 1 then
           repeat
           text_box := false;
           done := false;
           case event.where_screen_id of
               1 : begin press_button(1,true);done := true;end;
               3 : begin filter_text_box(3,true);
                         text_box := true;
                         default := false;end;
               4 : begin press_button(4,true);scroll_scroll_box(false,false,scroll_bar_rec.filter);end;
               5 : begin press_button(5,true);scroll_scroll_box(true,false,scroll_bar_rec.filter);end;
           end;
           until text_box = false;
     until done = true;
     paint_main_window;
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
     
     bitmap_buffer := current_bitmap;
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
     if text_style = 'bold' then SetTextStyle(0, HorizDir,1)
     else settextstyle(2,horizdir,5);
end;

procedure end_graphics_mode;
begin
     RestoreCrtMode;
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

procedure start_mouse;
begin
     setcolor(4);
     initevents;
     setcolor(7);
     
     showmouse;
end;

procedure startup;
begin
      get_settings;
      set_varibles;
      chdir(working_directory);
      start_graphics_mode;
      start_mouse;

end;

procedure shutdown;
begin
     end_graphics_mode;
end;

begin
      startup;
      view_rec;
      shutdown;
end.
     