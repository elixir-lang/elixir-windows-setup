// erlang_env.iss - Functions relating to Erlang's environment properties
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

function GetErlangPath(Of64Bit: Boolean; PrefVersion: String): String;
var
  Versions: TArrayOfString;
  Path: String;
  KeyPath: String;
begin
  Result := '';

  if Of64Bit then begin
    KeyPath := 'SOFTWARE\Wow6432Node\Ericsson\Erlang';
  end else begin
    KeyPath := 'SOFTWARE\Ericsson\Erlang';
  end;

  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, KeyPath, Versions) then begin
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, KeyPath + '\' + PrefVersion, '', Path) then begin
      Result := Path;
    end else if RegQueryStringValue(HKEY_LOCAL_MACHINE, KeyPath + '\' + Versions[GetArrayLength(Versions) - 1], '', Path) then begin
      Result := Path;
    end;
  end;
end;

function ErlangInPath: Boolean;
var
  _int: Integer;
begin
  Result := Exec('erl.exe', '+V', '', SW_HIDE, ewWaitUntilTerminated, _int);
end;

procedure AppendErlangPath(Of64Bit: Boolean; PrefVersion: String);
var
  Path: String;
  RegValue: String;
begin
  Path := GetErlangPath(Of64Bit, PrefVersion);
  if not (Path = '') then begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', RegValue);
    if Pos(Path, RegValue) = 0 then begin
      RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', RegValue + ';' + Path + '\bin');
    end;
  end;
end;
