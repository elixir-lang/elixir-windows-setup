// elixir_lookup.iss - Functions for finding releases within TElixirRelease arrays and other structures
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

// Given an array of Elixir releases and a release type, return the first release in the array of that type
function FindFirstReleaseOfType(Releases: array of TElixirRelease; ReleaseType: TElixirReleaseType): TElixirRelease;
var
  i: Integer;
begin
  for i := 0 to GetArrayLength(Releases) - 1 do begin
    if Releases[i].ReleaseType = ReleaseType then begin
      Result := Releases[i];
      exit;
    end;
  end;
end;

// Given an array of Elixir releases and a reference object, return the first release in the array which
// points to the same object
function FindFirstReleaseMatchingRef(Releases: array of TElixirRelease; RefMatch: TObject): TElixirRelease;
var
  i: Integer;
begin
  for i := 0 to GetArrayLength(Releases) - 1 do begin
    if Releases[i].Ref = RefMatch then begin
      Result := Releases[i];
      exit;
    end;
  end;
end;

// Given an array of list boxes and an array of Elixir releases, search for a selected radio button that
// points to an Elixir release reference object, and return the Elixir release which shares that reference
// object
function FindSelectedRelease(ListBoxes: array of TNewCheckListBox; Releases: array of TElixirRelease): TElixirRelease;
var
  i, j: Integer;
begin
  for i := 0 to GetArrayLength(ListBoxes) - 1 do begin
    for j := 0 to ListBoxes[i].Items.Count - 1 do begin
      if ListBoxes[i].ItemObject[j] <> nil then begin
        Result := FindFirstReleaseMatchingRef(Releases, ListBoxes[i].ItemObject[j]);
        exit;
      end;
    end;
  end;
end;
