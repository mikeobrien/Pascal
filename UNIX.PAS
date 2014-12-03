program unix;

uses dos,crt;

var
   x,y,z : word;
   ch : char;
   command : string;
begin
     textcolor(15);
     textbackground(0);
     clrscr;
     writeln('SCO UNIX v5.0');
     writeln;
     writeln('Initializing Network Interface Card...');
     delay(500);
     writeln('     3COM 3C509B COMBO (RJ45 Enabled)');
     writeln('     INT10     I/O300h');
     writeln;
     delay(1000);
     writeln('Initializing TCP/IP');
     writeln('    IP Address: 10.1.9.1');
     writeln('    Subnet Mask: 255.255.248.0');
     writeln('    Default Gateway: 10.116.8.1');
     writeln('    MAC Address: 45679823987');
     writeln;
     writeln('Binding TCP/IP to host adaptor.');
     delay(500);
     writeln('  45679823987 (3C509) bound to TCP/IP protocol');
     writeln('Mouse driver : GENERIC PS/2(223) loaded');
     writeln('NetBios for UNIX v2.4.8');
     writeln;
     writeln('Initiating auto logon for ADMINISTRATOR');
     writeln;
     repeat
           write('[administrator@root] ');
           readln(command);
     until command = ''

end.