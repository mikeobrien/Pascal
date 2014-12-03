
uses DOS;
const
  msg : String = 'Hello, world!$';
var
  regs : Registers;
  sernum : string[20];
  p : pointer;
begin
  regs.ax := $e819;
  p := addr(sernum);
  regs.si := p;

  Intr($15,regs); { Call DOS }
end.



