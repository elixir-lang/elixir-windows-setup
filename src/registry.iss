// registry.iss - Friendlier interface with registry values
// Copyright 2014 Chris Hyndman
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

function FuncRegGetSubkeyNames(RootKey: Integer; SubKeyName: String): TArrayOfString;
begin
  RegGetSubkeyNames(RootKey, SubKeyName, Result);
end;

function FuncRegQueryStringValue(RootKey: Integer; SubKeyName, ValueName: String): String;
begin
  Result := ''
  RegQueryStringValue(RootKey, SubKeyName, ValueName, Result);
end;

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
