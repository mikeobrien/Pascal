program make_dictionary;

uses dos,crt;

const cr : array[0..9] of char = ('0','1','2','3','4','5','6','7','8','9');

var
   a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z : longint;
   ch : char;
   output,dummy : string;
   dictionary : text;

begin
     writeln('Creating 10 charicter Numeric Dictionary...');
     assign(dictionary,'numeric.dic');
     rewrite(dictionary);
     {--Single Digit--}
     for a := 0 to 9 do writeln(dictionary,cr[a]);
     {--Double Digit--}
     for a := 0 to 9 do
     for b := 0 to 9 do writeln(dictionary,cr[a]+cr[b]);
     {--Triple Digit--}
     for a := 0 to 9 do
     for b := 0 to 9 do
     for c := 0 to 9 do writeln(dictionary,cr[a]+cr[b]+cr[c]);
     {--4 Digit--}
     for a := 0 to 9 do
     for b := 0 to 9 do
     for c := 0 to 9 do
     for d := 0 to 9 do writeln(dictionary,cr[a]+cr[b]+cr[c]+cr[d]);
     {--5 Digit--}
     for a := 0 to 9 do
     for b := 0 to 9 do
     for c := 0 to 9 do
     for d := 0 to 9 do
     for e := 0 to 9 do writeln(dictionary,cr[a]+cr[b]+cr[c]+cr[d]+cr[e]);
     {--6 Digit--}
     for a := 0 to 9 do
     for b := 0 to 9 do
     for c := 0 to 9 do
     for d := 0 to 9 do
     for e := 0 to 9 do
     for f := 0 to 9 do writeln(dictionary,cr[a]+cr[b]+cr[c]+cr[d]+cr[e]+cr[f]);
     {--7 Digit--}
     for a := 0 to 9 do
     for b := 0 to 9 do
     for c := 0 to 9 do
     for d := 0 to 9 do
     for e := 0 to 9 do
     for f := 0 to 9 do
     for g := 0 to 9 do writeln(dictionary,cr[a]+cr[b]+cr[c]+cr[d]+cr[e]+cr[f]+cr[g]);
     {--8 Digit--}
     for a := 0 to 9 do
     for b := 0 to 9 do
     for c := 0 to 9 do
     for d := 0 to 9 do
     for e := 0 to 9 do
     for f := 0 to 9 do
     for g := 0 to 9 do
     for h := 0 to 9 do writeln(dictionary,cr[a]+cr[b]+cr[c]+cr[d]+cr[e]+cr[f]+cr[g]+cr[h]);
     {--9 Digit--}
     for a := 0 to 9 do
     for b := 0 to 9 do
     for c := 0 to 9 do
     for d := 0 to 9 do
     for e := 0 to 9 do
     for f := 0 to 9 do
     for g := 0 to 9 do
     for h := 0 to 9 do
     for i := 0 to 9 do writeln(dictionary,cr[a]+cr[b]+cr[c]+cr[d]+cr[e]+cr[f]+cr[g]+cr[h]+cr[i]);
     {--10 Digit--}
     for a := 0 to 9 do
     for b := 0 to 9 do
     for c := 0 to 9 do
     for d := 0 to 9 do
     for e := 0 to 9 do
     for f := 0 to 9 do
     for g := 0 to 9 do
     for h := 0 to 9 do
     for i := 0 to 9 do
     for j := 0 to 9 do writeln(dictionary,cr[a]+cr[b]+cr[c]+cr[d]+cr[e]+cr[f]+cr[g]+cr[h]+cr[i]+cr[j]);
     writeln('Done.');
     close(dictionary);
end.

