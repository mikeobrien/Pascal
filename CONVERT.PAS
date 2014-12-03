program convert_td;
uses dos,crt;

type
    r_directory = record
                        last_name : string[20];
                        first_name : string[23];
                        work_description : string[20];
                        work_phone : string[13];
                        status : string[2];
                        room : string[8];
                        room_phone : string[6];
                  end;


var
   directory,dummy : r_directory;
   source : file of char;
   l,x,y,z,finding : word;
   ch : char;
   input,source_file,target_file : string;
   target : file of r_directory;


procedure read_write(length : byte);
begin
     {$I-}
     input := '';
      for x := 1 to length do
          begin
               read(source,ch);
               input := input + ch;
          end;
     {$I+}
     finding :=  ioresult;
     if input = '                    ' then finding := 1;
    

end;

begin

     l := 0;
     write('Enter the Source : ');
     readln(source_file);
     write('Enter the Target : ');
     readln(target_file);
     assign(source,source_file);
     assign(target,target_file);
     reset(source);
     rewrite(target);

     y := wherex;z := wherey;
     repeat
         l := l + 1;
         gotoxy(y,z);write(l,' Records Processed.');
         read_write(20);
         if finding = 0 then begin
         directory.last_name := input;
         read_write(23);
         directory.first_name := input;
         read_write(20);
         directory.work_description := input;
         read_write(13);
         directory.work_phone := input;
         read_write(2);
         directory.status := input;
         read_write(8);
         directory.room := input;
         read_write(6);
         directory.room_phone := input;
         write(target,directory);
         end;
     until EOF(source);
     close(target);
     close(source);
     writeln;
     writeln('Complete.');
end.
