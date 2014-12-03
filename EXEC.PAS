{$M $4000,0,10000}
uses dos,crt,graph;


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

procedure run(application,cmdline : string;debug : boolean);
var command : string;
begin
  if application <> '' then begin
     
     command := '/C ' + application + ' '+cmdline;
     SwapVectors;
     {Exec(GetEnv('COMSPEC'), command);}
     exec(application,cmdline);
     SwapVectors;
  end;
  str(doserror,command);
  if DosError <> 0 then writeln('Error running '+application+' '+cmdline+' ('+command+')');
  if (doserror = 0) and (application <> '') then writeln('Successfully ran '+application+' '+cmdline);
  if application = '' then writeln('No application specified');
  readln;

end;
begin
readln;
{     start_graphics_mode;
     run('d:\dos620.exe','d:\dostest',true);
     end_graphics_mode;   }
end.