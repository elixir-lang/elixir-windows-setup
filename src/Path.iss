// Path.iss - Manipulate the PATH variable
// Copyright (c) Chris Hyndman
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

[Code]

const
  PathVarRegRoot = HKEY_LOCAL_MACHINE;
  PathVarRegPath = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';
  
function ContainsPath(Dir: String): Boolean;
var
  RegValue: String;
begin
  Result := False;
  if Dir <> '' then begin
    RegQueryStringValue(PathVarRegRoot, PathVarRegPath, 'Path', RegValue);
    if Pos(Dir, RegValue) <> 0 then
      Result := True;
  end;
end;

// Given a directory path, appends the directory to the system's Path environment variable,
// if it doesn't already exist
procedure AppendPath(Dir: String);
var
  RegValue: String;
begin
  if Dir <> '' then begin
    RegQueryStringValue(PathVarRegRoot, PathVarRegPath, 'Path', RegValue);
    if Pos(Dir, RegValue) = 0 then begin
      RegWriteStringValue(PathVarRegRoot, PathVarRegPath, 'Path', RegValue + ';' + Dir);
    end;
  end;
end;

// Given a directory path, deletes the directory from the system's Path environment variable,
// if it exists
procedure DeletePath(Dir: String);
var
  RegValue: String;
  DirIdx: Integer;
begin
  if Dir <> '' then begin
    RegQueryStringValue(PathVarRegRoot, PathVarRegPath, 'Path', RegValue);
    DirIdx := Pos(Dir, RegValue);
    if DirIdx <> 0 then begin
      if DirIdx = 1 then begin
        Delete(RegValue, 1, Length(Dir) + 1);
      end else begin
        Delete(RegValue, DirIdx - 1, Length(Dir) + 1);
      end;
      RegWriteStringValue(PathVarRegRoot, PathVarRegPath, 'Path', RegValue);
    end;
  end;
end;
