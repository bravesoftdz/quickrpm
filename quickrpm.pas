uses classes, strutils, sysutils,
rpm;

var 
   package : string;

procedure help;

begin
writeln ('usage: ');
writeln ('quickrpm <packagename>');
writeln ('quickrpm will create rpm of the installed package you specified');
end;

procedure params;
begin

 if paramcount < 1 then begin
    help;
    halt;
 end;
 package := paramstr(1);
end;

procedure deps;
begin
// here we have to check for rpm and tar like deps

end;

function fix_name (s : string) : string;
begin
fix_name := strutils.AnsiReplaceStr(s, '#', '.');
end;

function is_number(s : string) : boolean;
var
     i : integer;
     isnum : boolean;
begin
i := 0;
isnum := true;
repeat
   inc(i);
   if not (s[i] in ['0' .. '9' ]) then isnum := false;

until (i = length(s)) or (isnum = false);
is_number := isnum
end;

function choose_one (const packages : TStringList): string;
var
   i : integer;
   correct : boolean;
   str, str1 : string;
begin

writeln ('Found more than one instance of package' + package);
writeln ('Please choose one of the following:');
writeln;
i := 0;
repeat
write (i); write (' : '); 
// replace # with - for nice output
str :=  fix_name( packages[i]);
writeln (str);
inc(i);
until i = packages.Count;

correct := false;
repeat
    readln ( str1 );
    correct := false;
    if is_number(str1) then begin

       if (sysutils.strtoint(str1) >= packages.Count) 
       or (sysutils.strtoint(str1) < 0) then
       begin
           writeln ('please use only digits between 0 and ' + sysutils.inttostr(packages.Count - 1));
           correct := false; 
       end
      else
       begin
           correct := true;
       end;
    end
   else //if not number
    begin
       writeln (' not number, try again');
    end;
until correct = true;

choose_one := packages[sysutils.strtoint(str1)]

end; //choose_one

procedure work;
var
   packages, content : TStringList;
   chosen_package, pname, pversion, parch : string;
   i : integer;
begin

   rpm.get_package(package, packages);
   if packages.Count > 1 then begin
      chosen_package := choose_one(packages)
   end
  else
   begin
      chosen_package := packages[0]
   end;

//  writeln ('chosen '); writeln (chosen_package);    

   
rpm.extract_info (chosen_package, pname, pversion, parch);

rpm.get_package_content (pname + '-' + pversion + '.' + parch, content);

{
i := 0;

repeat
writeln(content[i]);
inc (i);

until i = content.Count;
}


end; //work



begin
params;
deps;
work;

end.

