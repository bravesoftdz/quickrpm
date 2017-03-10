unit rpm;

interface

uses classes;

// queries rpm db and gets package or package list with that name
// where version and platform name is separated with # sign
// in order to process  it further with less ambiguity because "-" sign is ambiguous in rpm package names
procedure get_package (package: string; var packages : TStringList);
// queries rpm db and returns content of the specified package
procedure get_package_content (package: string; var content : TStringList);
// extracts package version from name
function  extract_info (package: string; var pname : string; var pversion : string; var parch : string) : string;

implementation
uses strutils, baseunix, unix;
const cmd_content = 'rpm -ql';
      cmd_list_all = 'rpm -qa --qf "%{n}#%{v}#%{arch}\n"'; //get version and platform divided by # sign

procedure get_package_content (package: string; var content : TStringList);
var f : textfile;
str : string;
begin
content := TStringList.Create;
//writeln ('running ' + cmd_content + ' ' + package);
unix.popen (f, cmd_content + ' ' + package, 'r' );

if fpgeterrno<>0 then
     writeln ('error from POpen : errno : ', fpgeterrno);

//reset (f);
repeat
   readln (f, str);
 //  writeln ('DEBUG ' + str);
   content.Add (str);
until eof(f);

close (f);

end; //get_package_content



procedure get_package (package: string; var packages : TStringList);
var f : textfile;
str : string;
begin

unix.popen (f, cmd_list_all + ' | grep ' + package, 'r');
packages := TStringList.Create;

repeat
   readln (f, str);
   packages.Add(str);
until eof(f);
close (f);
end; //get_package

function  extract_info (package: string; var pname : string; var pversion : string; var parch : string) : string;
var str : string;
i, j : integer;
begin

i := strutils.RPos('#', package);

parch := strutils.RightStr(package, length(package) - i);
//writeln ('parch '); writeln (parch);
j := strutils.RPosex ('#', package, i - 1);
//writeln (j);
pversion := strutils.MidStr(package, j + 1, i - j - 1);
//writeln (pversion);
pname := strutils.LeftStr(package, j - 1);
//writeln (pname);
end;

end.

