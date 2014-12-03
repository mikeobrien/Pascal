program td;

uses dos,crt,views,drivers;
type screen = array[0..1999] of word;
    r_directory = record
                        last_name : string[20];
                        first_name : string[23];
                        work_description : string[20];
                        work_phone : string[13];
                        status : string[2];
                        room : string[8];
                        room_phone : string[6];
                  end;
    a_list = array[1..500] of r_directory;

var
directory : r_directory;
rec_dump : a_list;
X,Y,Z,cur_highlite_pos,cur_pos : WORD;
image : ^screen;
storage : screen;
ch : char;
date_time,textbox,test : string;
xpos,rec_amount : word;
name_view,phone_view : boolean;

procedure draw_screen;
begin
     textbackground(0);textcolor(14);
     clrscr;
     write('й');
     image := ptr($B800,0);
     storage := image^;
     clrscr;
     storage[1999] := storage[0];
     image^ := storage;
     gotoxy(1,1);
     for x := 1 to 24 do
write('Г                                                                              Г');
     gotoxy(1,1);
     for x := 1 to 79 do write('Ф');
     gotoxy(1,25);
     for x := 1 to 79 do write('Ф');
     
     gotoxy(1,1);write('к');
     gotoxy(80,1);write('П');
     gotoxy(1,25);write('Р');
     gotoxy(1,3);write('У');
     gotoxy(80,3);write('Д');
     gotoxy(2,3);
     for x := 1 to 78 do write('Ф');
     gotoxy(3,2);write('Telephone Directory');
     gotoxy(6,25);write(' F1=Help  F2=Name Order  F3=Home/Work Phone  F4=Directories  ESC=QUIT ');
     textcolor(2);
     for x := 1 to 18 do begin gotoxy(80,x+6);write('А');end;
     gotoxy(60,2);write('By Last, First name');
     gotoxy(3,4);write('Search:');
     gotoxy(3,6);write('Name (last, first)       Work Phones     Work Description     Room     Rm Ph');
     gotoxy(11,4);textcolor(1);
     write('лллллллллллллллллллл');
     gotoxy(11,4);
     xpos := 11;


end;

procedure end_draw_screen;
begin
     textbackground(0);textcolor(7);
     clrscr;
     write('й');
     image := ptr($B800,0);
     storage := image^;
     clrscr;
     storage[1999] := storage[0];
     image^ := storage;
     gotoxy(1,1);
     for x := 1 to 24 do
write('Г                                                                              Г');
     gotoxy(1,1);
     for x := 1 to 79 do write('Ф');
     gotoxy(1,25);
     for x := 1 to 79 do write('Ф');
     
     gotoxy(1,1);write('к');
     gotoxy(80,1);write('П');
     gotoxy(1,25);write('Р');
     gotoxy(1,3);write('У');
     gotoxy(80,3);write('Д');
     gotoxy(2,3);
     for x := 1 to 78 do write('Ф');
     gotoxy(3,2);write('Telephone Directory');
     gotoxy(6,25);write(' F1=Help  F2=Name Order  F3=Home/Work Phone  F4=Directories  ESC=QUIT ');
     textcolor(7);
     for x := 1 to 18 do begin gotoxy(80,x+6);write('А');end;
     gotoxy(60,2);write('By Last, First name');
     gotoxy(3,4);write('Search:');
     gotoxy(3,6);write('Name (last, first)       Work Phones     Work Description     Room     Rm Ph');
     gotoxy(1,1);


end;

procedure update_date;
var Year, Month, Day, DayOfWeek: Word;
Hour, Minute, Second, Sec100: Word;
dumb,dummy,m,d,y,h,min,sec,a_p : string;

begin
    GetDate(year,month,day,dayofweek);
    GetTime(hour,minute,second,sec100);
    str(year,dummy);
    y := dummy[3];y := y + dummy[4];

    str(month,m);
    str(day,d);
    if hour < 12 then begin a_p := 'am';str(hour,h);end;
    if hour = 12 then begin a_p := 'pm';str(hour,h);end;
    if (hour > 12) and (hour < 24) then begin a_p := 'pm';str(hour-12,h);end;
    if hour = 24 then begin a_p := 'am';str(12,h);end;
    if minute > 9 then str(minute,min) else begin str(minute,dumb);min := '0';min := min + dumb;end;
    if second > 9 then str(second,sec) else begin str(second,dumb);sec := '0';sec := sec + dumb;end;

    dummy := m+'/'+d+'/'+y+' '+h+':'+min+':'+sec+a_p;
    if dummy <> date_time then begin date_time := dummy;textcolor(2);gotoxy(35,4);write(date_time:44);gotoxy(11,4);end;
    gotoxy(xpos,4);
end;
{
last_name : string;
                        first_name : string;
                        work_description : string;
                        work_phone : string;
                        status : string;
                        room : string;
                        room_phone : string;
}
procedure write_rec(highlight : boolean;ypos : word;dummy : r_directory);
begin
    
    if highlight = false then begin textcolor(3);textbackground(0);
                 window(3,ypos,79,ypos);clrscr;window(1,1,80,25);end else begin textcolor(14);textbackground(1);
                 window(3,ypos,79,ypos);clrscr;window(1,1,80,25);end;
    gotoxy(3,ypos);
    if name_view = false then write(dummy.last_name,', ',dummy.first_name) else
       write(dummy.first_name,' ',dummy.last_name);
    gotoxy(28,ypos);
    if phone_view = false then begin
       write(dummy.work_phone);
       gotoxy(44,ypos);
       write(dummy.work_description);
       gotoxy(65,ypos);
       write(dummy.room);
       gotoxy(74,ypos);
       write(dummy.room_phone);
    end else begin
       write(dummy.room_phone);
       gotoxy(35,ypos);
       write(dummy.room);
       gotoxy(45,ypos);
       write(dummy.work_phone);
       gotoxy(60,ypos);
       write(dummy.work_description);
    end;
    textcolor(2);textbackground(0);
    gotoxy(xpos,4);
end;


{
last_name : string;
                        first_name : string;
                        work_description : string;
                        work_phone : string;
                        status : string;
                        room : string;
                        room_phone : string;
}

procedure display_dump;
begin
     y := 6;
     rec_amount := 0;
     repeat
       rec_amount := rec_amount + 1;
     until (rec_dump[rec_amount].first_name = '') or (rec_amount = 501);
     rec_amount := rec_amount - 1;
     for x := cur_pos to (cur_pos + 17) do begin
         y := y + 1;
         if rec_dump[x].first_name <> '' then if x <> cur_highlite_pos then
            write_rec(false,y,rec_dump[x]) else write_rec(true,y,rec_dump[x]);

     end;
     textcolor(2);textbackground(0);
end;


procedure query;
begin

end;


procedure process_key;
var dummy : string;ch2 : char;
begin
     ch := readkey;
     if keypressed = true then ch := readkey;
     dummy := '';
     if ch = #72 then begin if (cur_highlite_pos = cur_pos) and (cur_pos > 1) then begin cur_pos := cur_pos - 1;
        cur_highlite_pos := cur_highlite_pos - 1;end else
        if (cur_pos <> 1) or (cur_highlite_Pos <> 1) then cur_highlite_pos := cur_highlite_pos - 1;display_dump;end;
     if ch = #80 then if cur_highlite_pos < rec_amount then begin if (cur_highlite_pos = cur_pos + 17) and (cur_pos < 30)
     then begin cur_pos := cur_pos + 1;
        cur_highlite_pos := cur_highlite_pos + 1;end else
        if (cur_pos <> 30) or (cur_highlite_Pos = 18) then cur_highlite_pos := cur_highlite_pos + 1;display_dump;end;
     if ch = #60 then
        if name_view = true then begin
            name_view := false;
            gotoxy(3,6);
            textcolor(2);
            write('Name (last, first) ');
            gotoxy(60,2);
            write('By Last, First name ':19);
            gotoxy(11,4);
        end else begin
            name_view := true;
            gotoxy(3,6);
            textcolor(2);
            write('Name (first last) ');
            gotoxy(60,2);
            write(' By First Last name':18);
            gotoxy(11,4);
        end;
     if ch = #61 then
        if phone_view = true then begin
            phone_view := false;
            gotoxy(3,6);
            textcolor(2);
            gotoxy(28,6);write('Work Phones     Work Description     Room     Rm Ph');

            gotoxy(11,4);
        end else begin
            phone_view := true;
            gotoxy(3,6);
            textcolor(2);
            gotoxy(28,6);write('Rm Ph  Room      Work Phones    Work Description   ');

            gotoxy(11,4);
        end;
     if ( (ch > chr(33)) or (ch < chr(126)) ) and (ch <> #72) and (ch <> #80) and (ch <> #13) and (ch <> #27) and
        (ch <> #59) and
         (ch <> #60) and (ch <> #61) and
      (ch <> #62) and (length(textbox) < 20) and (ch <> #13) then
        begin textbox := textbox + ch;
        textbackground(1);textcolor(14);gotoxy(11,4);write(textbox);textbackground(0);textcolor(2);query;end;

     if (ch = #8) and (length(textbox) > 0) then begin
     if length(textbox) > 1 then for x := 1 to (length(textbox)-2) do dummy := dummy + textbox[x] else
     textbox := '';
     textbox := dummy;
     gotoxy(11,4);textcolor(1);
     write('лллллллллллллллллллл');
     textcolor(14);
     gotoxy(11,4);
     textbackground(1);
     write(textbox);
     textbackground(0);
     query;
     end;
     xpos := wherex;
     if keypressed = true then ch2 := readkey;
end;

{
last_name : string;
                        first_name : string;
                        work_description : string;
                        work_phone : string;
                        status : string;
                        room : string;
                        room_phone : string;
}

begin
     rec_amount := 30;
     cur_highlite_pos := 1;
     cur_pos := 1;
     draw_screen;
     ch := ' ';
     textbox := '';
     name_view := false;
     phone_view := false;
     for x := 1 to 500 do begin
     rec_dump[x].first_name := '';
     rec_dump[x].last_name := '';
     rec_dump[x].work_description := '';
     rec_dump[x].work_phone := '';
     rec_dump[x].status := '';
     rec_dump[x].room := '';
     rec_dump[x].room_phone := '';
     end;
     repeat
     update_date;
     if keypressed = true then process_key;
     until ch = #27;
     end_draw_screen;
     delay(4000);
end.