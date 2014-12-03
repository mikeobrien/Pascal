program pointer;


uses crt;
{ Example for Dispose and New }

type
  write_stuff = object
    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z : longInt;

    procedure write_to_screen(xx,yy : word);
    end;
    p_write_stuff = ^write_stuff;
    procedure write_stuff.write_to_screen(xx,yy : word);
    begin
    writeln('fghdfghdfgh',xx,yy);
    x := xx;
    y := yy;
    end;
  

type
list_of_objects = array[1..150,1..100] of p_write_stuff;
var
  p_writestuff : p_write_stuff;
  write_things : write_stuff;
  write_other_things : list_of_objects;
  ch : char;
  x,lll : word;
begin
  clrscr;
  write_things.write_to_screen(1,2);
  writeln(write_things.x,write_things.y);
  write_other_things[1,1]^.write_to_screen(1,2);
  write(write_other_things[1,1]^.x);
  ch := readkey;
end.


