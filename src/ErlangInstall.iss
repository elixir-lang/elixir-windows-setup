// ErlangInstall.iss - Functions relating to existing installations of Erlang
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

// Given a Boolean where true -> 64bit and false -> 32bit, returns
// the path of the latest Erlang installation of that architecture
function GetLatestErlangPathOfArch(Of64Bit: Boolean): String;
var
  ERTSVersions: TArrayOfString;
  SubKeyName: String;
begin
  Result := '';

  if Of64Bit then begin
    SubKeyName := 'SOFTWARE\Wow6432Node\Ericsson\Erlang';
  end else begin
    SubKeyName := 'SOFTWARE\Ericsson\Erlang';
  end;

  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, SubKeyName, ERTSVersions) then begin
    if GetArrayLength(ERTSVersions) <> 0 then
      RegQueryStringValue(HKEY_LOCAL_MACHINE, SubKeyName + '\' + GetLatestVersion(ERTSVersions), '', Result);
  end;
end;

// Returns the path of the latest Erlang installation, preferring
// 64-bit over 32-bit
function GetLatestErlangPath: String;
begin
  Result := '';
  if IsWin64 then
    Result := GetLatestErlangPathOfArch(True);
  if Result = '' then
    Result := GetLatestErlangPathOfArch(False);
end;
