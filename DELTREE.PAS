uses Dos;
const
  ReadOnly  = $01;
  Hidden    = $02;
  SysFile   = $04;
  VolumeID  = $08;
  Directory = $10;
  Archive   = $20;

var
   f: file;
   DirInfo: SearchRec;
   path,current_dir,prev_dir : string;

procedure set_file_attr(filename : string);
begin
     Assign(f,filename);
     SetFAttr(f, Archive);
end;

procedure delete(filename : string;attribute : word);
begin
     if attribute <> directory then set_file_attr(filename);
     assign(f,filename);
     if attribute <> directory then
     begin
          erase(f);
          writeln('Deleting ',filename);
     end;
end;

procedure delete_directory_files(directory_path : string);
begin
    FindFirst(directory_path+'*.*', Archive, DirInfo);
    {delete(directory_path+dirinfo.name,dirinfo.attr);}
    while DosError = 0 do
    begin
         delete(directory_path+dirinfo.name,dirinfo.attr);
         FindNext(DirInfo);
    end;
end;

procedure change_directory(directory_path : string);
begin
    FindFirst(directory_path+'*.*', Archive, DirInfo);
    prev_dir := current_dir;
    repeat
         if (dirinfo.name <> '..') or (dirinfo.name <> '.') then current_dir := fexpand(dirinfo.name);
         FindNext(DirInfo);
    until (doserror <> 0) or (((dirinfo.name <> '..') or (dirinfo.name <> '.')) and (dirinfo.attr = directory));
    if prev_dir <> current_dir then chdir(current_dir);
end;


begin
  write('Enter the path : ');
  readln(path);
  current_dir := path;
  {repeat}
  delete_directory_files(current_dir);
  change_directory(current_dir);
  delete_directory_files(current_dir);
{  until current_dir = path;}
end.
