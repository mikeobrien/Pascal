PROGRAM BATCH_INPUT;
{$M 8192,0,0}
uses Dos,crt,drivers;
var
  Command: string[79];
  I,ox,oy,finding : WORD;
  ch : char;
  first_name,last_name,node,teller_list,account_num,amount : string;
  tran_type : string;
  record_amt : integer;
  value : string;
  event : tevent;

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
     textcolor(7);
     gotoxy(x1+1,y1);
     write('Name');
     gotoxy(x1+20,y1);
     write('Routing #');
     gotoxy(x1+30,y1);
     write('Account #');
     gotoxy(x1+42,y1);
     write('Source');
     gotoxy(x1+52,y1);
     write('Tran #');
     gotoxy(x1+61,y1);
     write('Action');
     gotoxy(x1+68,y1);
     write('Amount');
     window(x1+1,y1+1,x2-1,y2-1);
     textcolor(14);
end;

procedure get_rec_amount(filename : string);
var data_file : text;stuff : string;
begin
     assign(data_file,filename);
     {$I-}
     reset(data_file);
     finding := ioresult;
     {$I+}
     record_amt := 0;
     if finding = 0 then begin
        repeat
        readln(data_file,stuff);
        record_amt := record_amt +1;
        until eof(data_file);
        close(data_file);
     end else record_amt := 0;
end;

procedure get_record(filename : string;address : longint);
var counter : word;data_file : text;
begin
     get_rec_amount(filename);
     if record_amt <> 0 then begin
     assign(data_file,filename);
     {$I-}
     reset(data_file);
     finding := ioresult;
     {$I+}
     if finding = 0 then begin
     if address <= record_amt then for counter := 1 to address do readln(data_file,value);
     close(data_file);
     end;
     end;
end;

procedure get_data;
var rec,x,y,z : longint;tank : string;
begin
     get_rec_amount('namelist.txt');
     rec := random(record_amt);
     get_record('namelist.txt',rec);
     first_name := value;
     get_rec_amount('lastlist.txt');
     rec := random(record_amt);
     get_record('lastlist.txt',rec);
     first_name := first_name + ' ' + value;
     get_rec_amount('telrlist.txt');
     rec := random(record_amt);
     get_record('telrlist.txt',rec);
     teller_list := value;
     rec := random(2);
     if (rec = 1) or (teller_list = 'ATM') then tran_type := 'DEBIT' else tran_type := 'CREDIT';
     account_num := '';
     for z := 1 to 20 do
     begin
          x := random(9);
          str(x,tank);
          account_num := account_num+tank;
          if z = 9 then account_num := account_num+':';
     end;
     if teller_list <> 'ATM' then begin
     x := random(9999);str(x,tank);
     y := random(9999);str(y,node);
     node := node + tank;
     x := random(99);str(x,tank);
     z := random(100);
     if z > 90 then y := random(9999);
     if (z>80) and (z<90) then y := random(999);
     if (z>40) and (z<80) then y := random(99);
     if z < 40 then y := random(99);
     str(y,amount);if x < 10 then tank := tank + '0';
     amount := '$' + amount + '.' + tank;
     end
     else if teller_list = 'ATM' then begin
     z := random(100);
     if z > 90 then y := random(10);
     if (z>80) and (z<=90) then y := random(8);
     if (z>40) and (z<=80) then y := random(4);
     if z <= 40 then y := random(2);
     if y = 0 then y := 2;
     amount := '';
     str(y,amount);
     amount := '$' + amount + '0.00';
     end;

end;


begin
       initevents;
       hidemouse;
       randomize;
       tran_type := '';
       first_name := '';
       last_name := '';
       node := '';
       teller_list := '';
       account_num := '';
       amount := '';
       textcolor(14);textbackground(1);
       clrscr;
       textcolor(15);
       write('                  Chase Banks of New York - Brooklyn Branch');
       gotoxy(1,25);
       textcolor(14);
       write('Transaction Console  (c)1994 IBM Corp. All Rights Reserved');
       box(1,2,80,24,14,1);
       delay(2000);
       getmouseevent(event);
       oy := wherey;
       repeat
             get_data;
             gotoxy(1,oy);
             write(First_Name);
             gotoxy(20,oy);
             write(account_num);
             gotoxy(42,oy);
             write(teller_list);
             gotoxy(52,oy);
             write(node);
             gotoxy(61,oy);
             write(tran_type);
             gotoxy(68,oy);
             write(amount);
             i := random(3000);
             window(1,1,80,25);
             gotoxy(1,1);
             delay(i);
             window(2,3,78,23);
             gotoxy(1,oy);
             i := random(5);
             if i < 3 then begin
             window(1,1,80,25);
             gotoxy(72,25);
             textcolor(4);
             write('*COMM*');
             gotoxy(1,1);
             i := random(2000);
             delay(i);
             textcolor(1);
             gotoxy(72,25);
             write('*COMM*');
             textcolor(14);
             window(2,3,79,23);
             end;
             gotoxy(1,oy);
             writeln;
             oy := wherey;
             getmouseevent(event);

       until (keypressed = true) or (event.what = evmousemove);
end.
