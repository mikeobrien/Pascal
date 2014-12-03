PROGRAM BATCH_INPUT;
{$M 8192,0,0}
uses Dos,crt;
var
  Command: string[79];
  I,x,y : WORD;
  ch : char;

begin
  
       writeln('Is the NIC configured?');
       writeln('F1 to configure');
       writeln('ENTER to continue');
       repeat
             ch := readkey;
       until (ch = #59) or (ch = #13);
       if ch = #59 then command := 'loadcfg';
       if ch = #13 then halt;
       Command := '/C ' + Command;
       SwapVectors;
       Exec(GetEnv('COMSPEC'), Command);
       SwapVectors;
       if DosError <> 0 then
       WriteLn('Could not execute COMMAND.COM');
  
end.