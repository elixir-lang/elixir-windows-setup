// TElixirRelease.iss - TElixirRelease and related functions
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
  TElixirRelease = record
    Version: String;
    URL: String;
    ReleaseType: String;
  end;

// Given a filename to an elixir.csv file, return an array of Elixir releases corresponding to
// the data in the csv file.
function CSVToElixirReleases(Filename: String): array of TElixirRelease;
var
  Rows: TArrayOfString;
  RowValues: TStrings;
  i: Integer;
begin
  // Read the file at Filename and store the lines in Rows
  if LoadStringsFromFile(Filename, Rows) then begin
    // Match length of return array to number of rows
    SetArrayLength(Result, GetArrayLength(Rows) - 1);

    for i := 1 to GetArrayLength(Rows) - 1 do begin
      // Separate values at commas
      RowValues := SplitString(Rows[i], ',');

      with Result[i - 1] do begin
        // Store first and second values as the Version and URL respectively
        Version := RowValues[0];
        URL := RowValues[1];

        // Store release type unless incompatible with installer
        if StrToInt(RowValues[3]) = {#COMPAT_MASK} then begin
          ReleaseType := RowValues[2];
        end else begin
          ReleaseType := 'incompatible';
        end;
      end;
    end;
  end else begin
    SetArrayLength(Result, 0);
  end;
end;
