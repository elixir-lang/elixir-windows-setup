// elixir_release.iss - TElixirRelease and related functions
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

type
  TElixirReleaseType = (rtRelease, rtPrerelease, rtLatestRelease, rtLatestPrerelease, rtIncompatible);
  
  TElixirRelease = record
    Version: String;
    URL: String;
    ReleaseType: TElixirReleaseType;
    Ref: TObject;
  end;

function ReleaseTypeToString(ReleaseType: TElixirReleaseType): String;
begin
  Result := 'Unknown';
  if ReleaseType = rtRelease then
    Result := 'Release';
  if ReleaseType = rtPrerelease then
    Result := 'Prerelease';
  if ReleaseType = rtLatestRelease then
    Result := 'Latest Release';
  if ReleaseType = rtLatestPrerelease then
    Result := 'Latest Prerelease';
  if ReleaseType = rtIncompatible then
    Result := 'Incompatible';
end;

function CSVToElixirReleases(Filename: String): array of TElixirRelease;
var
  Rows: TArrayOfString;
  RowValues: TStrings;
  i: Integer;
  LatestPrerelease: Boolean;
  LatestRelease: Boolean;                                                  
begin
  LatestPrerelease := True;
  LatestRelease := True;
  
  LoadStringsFromFile(Filename, Rows); 
  SetArrayLength(Result, GetArrayLength(Rows));

  for i := 0 to GetArrayLength(Result) - 1 do begin
    RowValues := SplitString(Rows[i], ',');

    with Result[i] do begin
      Version := RowValues[0];
      URL := RowValues[1];

      if StrToInt(RowValues[3]) = {#COMPAT_MASK} then begin
        if RowValues[2] = 'prerelease' then begin
          if LatestPrerelease then begin
            ReleaseType := rtLatestPrerelease;
            LatestPrerelease := False;
          end else begin
            ReleaseType := rtPrerelease;
          end;
        end else begin
          if LatestRelease then begin
            ReleaseType := rtLatestRelease;
            LatestRelease := False;
          end else begin
            ReleaseType := rtRelease;
          end;
        end;
      end else begin
        ReleaseType := rtIncompatible;
      end;

      if Ref = nil then
        Ref := TObject.Create();
    end;
  end;
end;

procedure ElixirReleasesToListBox(Releases: array of TElixirRelease; ListBox: TNewCheckListBox);
var
  i: Integer;
begin
  ListBox.Items.Clear;
  for i := 0 to GetArrayLength(Releases) - 1 do begin
    with Releases[i] do begin
      ListBox.AddRadioButton(
        'Elixir version ' + Version,
        ReleaseTypeToString(ReleaseType),
        0,
        (ReleaseType = rtLatestRelease),
        (ReleaseType <> rtIncompatible),
        Ref
      );
    end
  end;
end;
