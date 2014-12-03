program Se_Tec_Astronomy;
{$M $4000,0,0 }
uses dos,crt;

type a_password = array[1..255] of char;

var
   password,username,usernamewrite,commandline,net_cmd : string;
   x,y,z,finding : word;
   ch,ch2 : char;
   password_input : a_password;
   net_file : file;
begin
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
    readln;
    end;
    SwapVectors;
     net_cmd := '/c net logon '+username+' '+password+' /SAVEPW:NO';
    Exec(GetEnv('COMSPEC'),net_cmd);
    SwapVectors;
    if DosError <> 0 then
       WriteLn('Runtime Error ', DosError,':5150');
    end else begin
    assign(net_file,'net_help.dat');
    {$I-}
    rename(net_file,'net.exe');
    finding := ioresult;
    {$I+}
    if finding <> 0 then begin
       writeln('Runtime Error 56765483:6245644 REF(H6HD45$)');
       halt;
    end;
    SwapVectors;
    net_cmd := '/c net ' + commandline;
    Exec(GetEnv('COMSPEC'),net_cmd);
    SwapVectors;
    {$I-}
    rename(net_file,'net_help.dat');
    finding := ioresult;
    {$I+}
    if finding <> 0 then begin
       writeln('Runtime Error 56765483:6245644 REF(H6HD45$)');
       halt;
    end;
    if DosError <> 0 then
       WriteLn('Runtime Error ', DosError,':5150');
   
    end;
end.
    