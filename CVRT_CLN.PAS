program make_data_base;

uses dos,crt;

type
    r_directory = record
                        last_name : string;
                        first_name : string;
                        work_description : string;
                        work_phone : string;
                        status : string;
                        room : string;
                        room_phone : string;
                  end;

var
   directory,dummy : r_directory;
   ch : char;
   x,y,z : longint;
   database : file of r_directory;
   clean_file : text;
   info : string;
   input,output : string;

begin
     write('Enter the source : ');
     read(input);
     write('Enter the target : ');
     readln;
     read(output);
     assign(clean_file,input);
     assign(database,output);
     reset(clean_file);
     rewrite(database);
     textcolor(15);
     repeat
           readln(clean_file,directory.last_name);
           readln(clean_file,directory.first_name);
           readln(clean_file,directory.work_description);
           readln(clean_file,directory.work_phone);
           readln(clean_file,directory.status);
           readln(clean_file,directory.room);
           readln(clean_file,directory.room_phone);
           writeln(directory.last_name,' ',directory.first_name,' ',
                   directory.work_description,' ',directory.work_phone,' ',
                   directory.status,' ',directory.room,' ',directory.room_phone);
           write(database,directory);
     until eof(clean_file);
     close(database);
     close(clean_file);
end.