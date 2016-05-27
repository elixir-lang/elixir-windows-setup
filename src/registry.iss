// registry.iss - Friendlier interface with registry values
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

// Wrapper for RegGetSubkeyNames so it acts like a function
function FuncRegGetSubkeyNames(RootKey: Integer; SubKeyName: String): TArrayOfString;
begin
  RegGetSubkeyNames(RootKey, SubKeyName, Result);
end;

// Wrapper for RegQueryStringValue so it acts like a function
function FuncRegQueryStringValue(RootKey: Integer; SubKeyName, ValueName: String): String;
begin
  Result := '';
  RegQueryStringValue(RootKey, SubKeyName, ValueName, Result);
end;

// Given a directory path, appends the directory to the system's Path environment variable,
// if it doesn't already exist
procedure AppendPath(Dir: String);
var
  RegValue: String;
begin
  if Dir <> '' then begin
    RegValue := FuncRegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path');
    if Pos(Dir, RegValue) = 0 then begin
      RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', RegValue + ';' + Dir);
    end;
  end;
end;
