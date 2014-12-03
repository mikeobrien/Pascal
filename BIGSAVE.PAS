program bigsave;
uses dos,crt,drivers;

type r_info = record
                  another_disk : boolean;
                  original_filename,id : string;
            end;

var
   filename : string;
   source,target : file of char;
   info_file : file of r_info;
   info : r_info;
   ch : char;
   x,y,z,finding : word;
   source_size,source_loc,disk_free : longint;
   P: PathStr;
   D: DirStr;
   N: NameStr;
   E: ExtStr;


begin
     write('Enter the source filename :');
     readln(filename);
     assign(source,filename);
     FSplit(filename, D, N, E);
     info.original_filename := n + e;
     randomize;
     {$I-}
     reset(filename);
     finding := ioresult;
     {$I+}
     if finding <> 0 then begin writeln('File Not Found.');halt;end;
     source_size := filesize(source);
     finding = 0;
     source_loc := 0;
     repeat
        repeat
           if finding = 0 then write('Please insert a floppy disk and press any key.') else
              begin
                 writeln('No disk in Drive. Press <ESC> to abort.');
                 write('Please insert a floppy disk and press any key.');
              end;
           ch := readkey;
           if ch = #27 then begin close(source);halt;end;
           assign(target,'a:\multiple.dsk');
           {$I-}
           rewrite(target);
           finding := ioresult;
           {$I+}
        until finding = 0;
        disk_size := DiskFree(1)
        if (source_size - source_loc) < disk_size then info.another_disk := false else
                        info.another_disk := false;


