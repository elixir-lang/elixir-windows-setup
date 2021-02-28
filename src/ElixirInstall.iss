// ElixirInstall.iss - Functions relating to existing installations of Elixir
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

function GetPreviousUninsExe: String;
var
  UninsPath: String;
begin
  UninsPath := '';
  Result := '';
  if RegQueryStringValue(HKLM, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Elixir_is1', 'UninstallString', UninsPath) then begin
    Result := RemoveQuotes(UninsPath);
  end else if RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Elixir_is1', 'UninstallString', UninsPath) then begin
    Result := RemoveQuotes(UninsPath);
  end else if RegQueryStringValue(HKCU, 'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Elixir_is1', 'UninstallString', UninsPath) then begin
    Result := RemoveQuotes(UninsPath);
  end else if RegQueryStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\Elixir_is1', 'UninstallString', UninsPath) then begin
    Result := RemoveQuotes(UninsPath);
  end;
end;

function GetPreviousAppPath: String;
begin
  Result := RemoveBackslashUnlessRoot(ExtractFilePath(GetPreviousUninsExe));
end;

function CheckPreviousVersionExists: Boolean;
begin
  Result := (GetPreviousUninsExe <> '');
end;
