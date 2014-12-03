Program fourth_Dimension;
{$M 8192,0,0}

uses Dos,crt;

type
    cmd_lst_rec = record
                      index : word;
                      listed_command : string[11];
                  end;
    cmd_lst = array[1..255] of cmd_lst_rec;

var
   cursor_original_x,cursor_original_y,last_dos_error : word;
   current_path,command_interpretor_location : string;
   command_line : string[255];
   current_drive : byte;
   command_list : cmd_lst;
   error : boolean;
   current_text_background,current_text_foreground : word;

procedure error_check(message_code : word);
var finding : word;
begin
     finding := ioresult;
     if (doserror <> 0) or (finding <> 0) then error := true else error := false;
     case message_code of
          0 : if doserror <> 0 then writeln('Bad Command or File Name');
          1 : if doserror = 2 then writeln('File not Found.');
          1 : if doserror = 3 then writeln('Path not Found.');
          1 : if doserror = 5 then writeln('Access Denied.');
          1 : if doserror = 6 then writeln('Invalid Handle.');
          1 : if doserror = 8 then writeln('Not Enough Memory.');
          1 : if doserror = 10 then writeln('Invalid Enviroment.');
          1 : if doserror = 11 then writeln('Invaled Format.');
          1 : if doserror = 18 then writeln('No More Files.');
          2 : if finding <> 0 then writeln('I/O Error.');
          3 : writeln('Operation Completed Successfully.');
          4 : if finding <> 0 then writeln('Command Interpretor Not Found.');
          5 : writeln('You Must Enter a Path.');
          6 : ;
          7 : if last_dos_error = 2 then writeln('File not Found.');
          7 : if last_dos_error = 3 then writeln('Path not Found.');
          7 : if last_dos_error = 5 then writeln('Access Denied.');
          7 : if last_dos_error = 6 then writeln('Invalid Handle.');
          7 : if last_dos_error = 8 then writeln('Not Enough Memory.');
          7 : if last_dos_error = 10 then writeln('Invalid Enviroment.');
          7 : if last_dos_error = 11 then writeln('Invaled Format.');
          7 : if last_dos_error = 18 then writeln('No More Files.');

  end;
     last_dos_error := doserror;
     doserror := 0;
end;

procedure set_colors;
begin
     textbackground(current_text_background);
     textcolor(current_text_foreground);
end;

procedure close_box(x1,y1,x2,y2,cx,cy : word);
begin
     set_colors;
     window(x1,y1,x2,y2);
     clrscr;
     window(1,1,80,25);
     gotoxy(cx,cy);
end;

procedure line(x1,x2,y1,y2 : word;hor : boolean);
var x,y : word;
begin
     if hor = true then
        for x := x1 to x2 do begin gotoxy(x,y1);write('Í');end else
        for y := y1 to y2 do begin gotoxy(x1,y);write('º');end;
end;

procedure box(x1,y1,x2,y2,tc,tb : word);
begin
     textcolor(tc);
     textbackground(tb);
     window(x1,y1,x2,y2);
     clrscr;
     window(1,1,80,25);
     line(x1,x2,y1,y1,true);
     line(x1,x2,y2,y2,true);
     line(x1,x1,y1,y2,false);
     line(x2,x2,y1,y2,false);
     gotoxy(x1,y1);write('É');
     gotoxy(x1,y2);write('È');
     gotoxy(x2,y1);write('»');
     gotoxy(x2,y2);write('¼');
     window(x1+1,y1+1,x2-1,y2-1);
end;

procedure get_ver;
var
  Ver: Word;
begin
  Ver := DosVersion;
  writeln('Virtual OS : 4th Dimension v1.0');
  WriteLn('Boot OS : v',Lo(Ver),'.',Hi(Ver));
end;

procedure get_path;
begin
     writeln('The Current Command Interpretor is ',command_interpretor_location);
end;


procedure set_interpretor_path(location : string);
var check_file : file;
begin
     if location <> '' then begin
     assign(check_file,location);
     {$I-}
     reset(check_file);
     close(check_file);
     {$I+}
     error_check(4);
     if error = false then
        begin
             command_interpretor_location := location;
             error_check(3);
             get_path;
        end;
     end else error_check(5);

end;


procedure call_interpreter(int_command : string);
begin
     int_command := '/C ' + int_command;
     swapvectors;
     exec(command_interpretor_location, int_command);
     swapVectors;
     error_check(0);
end;

procedure init_command_list;
var x : word;
begin
     for x := 1 to 255 do command_list[x].listed_command := 'NULL';
     command_list[1].listed_command := 'setpath';
     command_list[1].index := 1;
     command_list[2].listed_command := 'getpath';
     command_list[2].index := 2;
     command_list[3].listed_command := 'ver';
     command_list[3].index := 3;
     command_list[4].listed_command := 'debug';
     command_list[4].index := 255;

end;


procedure interpret_command;
var x : word;
    command,argument : string;
    end_command,listed,debug_input : boolean;
begin
     command_line := command_line + chr(1);
     command := '';argument := '';end_command := false;x := 0;
     repeat
              x := x + 1;
              if (end_command = true) and (command_line[x] <> chr(1)) then
                 argument := argument + command_line[x];
              if (command_line[x] <> ' ') and (end_command = false) and (command_line[x] <> chr(1)) then
                 command := command + command_line[x] else
                 end_command := true;
              
     until (x = 255) or (command_line[x] = chr(1));
     x := 0;listed := false;
     repeat
           x := x + 1;
           if command = command_list[x].listed_command then listed := true;
     until (x = 255) or (listed = true) or (command_list[x].listed_command = 'NULL');
     if command_list[x].index = 255 then if argument = 'on' then debug_input := true else debug_input := false;
     if debug_input = true then writeln('-',command,'- -',argument,'-');
     case command_list[x].index of
          1 : set_interpretor_path(argument);
          2 : get_path;
          3 : get_ver;
          
     end;
     if listed <> true then call_interpreter(command_line);
     if debug_input = true then begin error_check(7);error_check(2);end;
end;


procedure interface_manager;
begin
     repeat
       set_colors;
       current_drive := 0;current_path := '';
       GetDir(current_drive,current_path);
       write(current_path,'>');
       readln(command_line);
       interpret_command;
     until (command_line = ('exit' + chr(1)));
end;

procedure login;
var name,password : string;
    x,y : word;
begin
     x := wherex;y := wherey;
     box(25,7,55,12,14,1);
     writeln;
     gotoxy(5,2);
     writeln('Enter Your Login Name');
     gotoxy(7,3);
     readln(name);
     box(25,7,55,12,14,1);
     gotoxy(6,2);
     writeln('Enter Your Password');
     gotoxy(8,3);
     readln(password);
     close_box(25,7,55,12,x,y);
     set_colors;
end;

procedure set_varibles;
begin
     init_command_list;
     current_drive := 0;
     command_interpretor_location := '';
     error := false;
     doserror := 0;
     current_text_background := 0;
     current_text_foreground := 7;
     cursor_original_x := wherex;
     cursor_original_y := wherey;
end;

procedure paint_startup;
begin
     set_colors;
     clrscr;
     writeln;
     WriteLn('Starting 4th Dimension...');
end;

procedure startup_interpretor;
begin
     GetDir(current_drive,command_interpretor_location);
     command_interpretor_location := command_interpretor_location + '\command.com';
     set_interpretor_path(command_interpretor_location);
     if error = true then command_interpretor_location := 'Not Avalible.';
end;

procedure startup;
begin
     set_varibles;
     paint_startup;
     startup_interpretor;
     login;
end;

procedure shutdown;
begin
     writeln('Exiting 4th Dimension.');
end;

begin
       startup;
       interface_manager;
       shutdown;
end.
