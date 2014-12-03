uses dos,crt;

type
    r_boot_ini = record
             dir0,dir1,dir2,dir3 : string;
             name,dept,shellfile,size,ramdrive : string;

             runprogram0,runprogram1,runprogram2,runprogram3 : string;
             cmdline0,cmdline1,cmdline2,cmdline3 : string;
             copyfrom0,copyfrom1,copyfrom2,copyfrom3 : string;
             copyto0,copyto1,copyto2,copyto3 : string;
             end;
var boot_ini : r_boot_ini;

procedure set_ini_value(search_key,search_value,write_string : string);
var temp_file,ini_file : text;pos,pos2,x,location,y,z : word;chd,ch : char;value,value2 : string;existkey : boolean;
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
        writeln('This is the search string:'+search_value);
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
          writeln('This is whats pulled from the file:'+value);ch := readkey;
          writeln('This is the value minus the rest:'+value2);ch := readkey;
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

begin
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

     set_ini_value('bootloader','dir0','test2'{boot_ini.dir0});
      set_ini_value('bootloader','dir1','another2'{boot_ini.dir1});
      {set_ini_value('bootloader','dir2',boot_ini.dir2);
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
     set_ini_value('bootloader','copyto','thestuff');}
end.
