// util.iss - Useful helper functions
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

function Tmp(Path: String): String;
begin
  Result := ExpandConstant('{tmp}\') + Path;
end;

function SplitStringRec(Str: String; Delim: String; StrList: TStringList): TStringList;
var
  StrHead: String;
  StrTail: String;
  DelimPos: Integer;
begin
  DelimPos := Pos(Delim, Str);
  if DelimPos = 0 then begin
    StrList.Add(Str);
    Result := StrList;
  end else begin
    StrHead := Str;
    StrTail := Str;

    Delete(StrHead, DelimPos, Length(StrTail));
    Delete(StrTail, 1, DelimPos);   

    StrList.Add(StrHead);
    Result := SplitStringRec(StrTail, Delim, StrList);
  end;
end;

function SplitString(Str: String; Delim: String): TStringList;
begin
  Result := SplitStringRec(Str, Delim, TStringList.Create);
end;

function GetURLFilePartRec(URL: String): String;
var
  SlashPos: Integer;
begin
  SlashPos := Pos('/', URL);
  if SlashPos = 0 then begin
    Result := URL;
  end else begin;
    Delete(URL, 1, SlashPos);
    Result := GetURLFilePartRec(URL);
  end;
end;

function GetURLFilePart(URL: String): String;
begin
  Delete(URL, 1, Pos('://', URL) + 2);
  Result := GetURLFilePartRec(URL);
end;

function CompareVersions(VerL, VerR: String): Integer;
var
  VerLExplode: TStrings;
  VerRExplode: TStrings;
  i: Integer;
  MinCount: Integer;
begin
  Result := 0;
  VerLExplode := SplitString(VerL, '.');
  VerRExplode := SplitString(VerR, '.');

  if VerLExplode.Count < VerRExplode.Count then begin
    MinCount := VerLExplode.Count;
  end else begin
    MinCount := VerRExplode.Count;
  end;

  for i := 0 to MinCount - 1 do begin
    if StrToIntDef(VerLExplode[i], 0) < StrToIntDef(VerRExplode[i], 0) then begin
      Result := 1;
      exit;
    end else if StrToIntDef(VerLExplode[i], 0) > StrToIntDef(VerLExplode[i], 0) then begin
      Result := -1;
      exit;
    end;
  end;
end;

function GetLatestVersion(Versions: TArrayOfString): String;
var
  i: Integer;
begin
  Result := Versions[0];
  for i := 0 to GetArrayLength(Versions) - 1 do begin
    if CompareVersions(Result, Versions[i]) = 1 then
      Result := Versions[i];
  end;
end;
