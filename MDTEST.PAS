uses dos,crt;

procedure md(dir_path,last_drive : string;debug : boolean;ref : word);
var path,doserrorcode : string;finding : word;
begin
     if dir_path[1] = '\' then path := last_drive+dir_path else path := dir_path;
     {$I-}
     if dir_path <> '' then begin
                      mkdir(path);
                      end else if debug = true then writeln('No Directory Specified');
     finding := ioresult;
     {$I+}
     if (dir_path <> '') and (debug = true) then if (finding = 0) then writeln('Successfully created '+path);
     if (dir_path <> '') and (debug = true) then if finding <> 0 then writeln('Error creating '+path+' (',finding,')');
end;

begin
     md(paramstr(1),'D:',true,1);
end.