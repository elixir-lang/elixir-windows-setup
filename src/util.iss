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

// Wrapper function for returning a path relative to {tmp}
function Tmp(Path: String): String;
begin
  Result := ExpandConstant('{tmp}\') + Path;
end;

// Recursive function called by SplitString
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

// Given a string and a delimiter, returns the strings separated by the delimiter
// as a TStringList object
function SplitString(Str: String; Delim: String): TStringList;
begin
  Result := SplitStringRec(Str, Delim, TStringList.Create);
end;

// Recursive function called by GetURLFilePart
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

// Given a URL to a file, returns the filename portion of the URL
function GetURLFilePart(URL: String): String;
begin
  Delete(URL, 1, Pos('://', URL) + 2);
  Result := GetURLFilePartRec(URL);
end;

// Given two software version strings (ex. '1.5.0'), returns:
//    1 if the second version is later than the first
//   -1 if the second version is earlier than the first
//    0 if equivalent
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

// Given an array of strings representing software versions, returns
// the latest of those versions
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
