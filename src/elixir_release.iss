// elixir_release.iss - TElixirRelease and related functions
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

type
  TElixirReleaseType = (rtRelease, rtPrerelease, rtLatestRelease, rtLatestPrerelease, rtIncompatible);
  
  TElixirRelease = record
    Version: String;
    URL: String;
    ReleaseType: TElixirReleaseType;
    Ref: TObject;
  end;

// Given an Elixir release type, return its string representation
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

// Given a filename to an elixir.csv file, return an array of Elixir releases corresponding to
// the data in the csv file.
function CSVToElixirReleases(Filename: String): array of TElixirRelease;
var
  Rows: TArrayOfString;
  RowValues: TStrings;
  i: Integer;
  LatestPrerelease: Boolean;
  LatestRelease: Boolean;                                                  
begin
  // Initialize as one-way flags
  LatestPrerelease := True;
  LatestRelease := True;
  
  // Read the file at Filename and store the lines in Rows
  LoadStringsFromFile(Filename, Rows); 
  // Match length of return array to number of rows
  SetArrayLength(Result, GetArrayLength(Rows) - 1);

  for i := 1 to GetArrayLength(Rows) - 1 do begin
    // Separate values at commas
    RowValues := SplitString(Rows[i], ',');

    with Result[i - 1] do begin
      // Store first and second values as the Version and URL respectively
      Version := RowValues[0];
      URL := RowValues[1];

      if StrToInt(RowValues[3]) = {#COMPAT_MASK} then begin
        // Release has a compatibility mask matching this installer
        if RowValues[2] = 'prerelease' then begin
          // Release is designated as a prerelease
          if LatestPrerelease then begin
            // This is the first prerelease found, so it's the latest prerelease
            ReleaseType := rtLatestPrerelease;
            LatestPrerelease := False;
          end else begin
            // This is not the latest prerelease
            ReleaseType := rtPrerelease;
          end;
        end else begin
          if LatestRelease then begin
            // This is the first release found, so it's the latest prerelease
            ReleaseType := rtLatestRelease;
            LatestRelease := False;
          end else begin
            // This is not the latest release
            ReleaseType := rtRelease;
          end;
        end;
      end else begin
        // Release can't be installed by this installer
        ReleaseType := rtIncompatible;
      end;

      // Assign this Elixir release a new reference object
      if Ref = nil then
        Ref := TObject.Create();
    end;
  end;
end;

// Given an array of Elixir release and a list box, populate the list box with radio buttons
// which describe and point to the releases in the Elixir release array
procedure ElixirReleasesToListBox(Releases: array of TElixirRelease; ListBox: TNewCheckListBox);
var
  i: Integer;
begin
  ListBox.Items.Clear;
  for i := 0 to GetArrayLength(Releases) - 1 do begin
    with Releases[i] do begin
      ListBox.AddRadioButton(
        'Elixir version ' + Version,      // Label next to radio button
        ReleaseTypeToString(ReleaseType), // Label right-justified in list box
        0,                                // All choices on the same level
        (ReleaseType = rtLatestRelease),  // Radio button selected by default if it's the latest release
        (ReleaseType <> rtIncompatible),  // Incompatible releases can't be selected
        Ref                               // Pointer to release's reference object
      );
    end
  end;
end;
