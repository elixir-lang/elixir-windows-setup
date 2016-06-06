// TErlangData.iss - TErlangData and related functions
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
  TErlangData = record
    OTPVersion: String;
    ERTSVersion: String;
    URL32: String;
    URL64: String;
    Exe32: String;
    Exe64: String;
    Name32: String;
    Name64: String;
  end;

// Given a filename to an erlang.csv file, returns the latest OTP release in
// the file as a TErlangData record
function CSVToErlangData(Filename: String): TErlangData;
var
  Rows: TArrayOfString;
  RowValues: TStrings;
begin
  if LoadStringsFromFile(Filename, Rows) then begin
    RowValues := SplitString(Rows[1], ',');

    with Result do begin
      OTPVersion  := RowValues[0];
      ERTSVersion := RowValues[1];
      URL32       := RowValues[2];
      URL64       := RowValues[3];

      Exe32       := GetURLFilePart(URL32);
      Exe64       := GetURLFilePart(URL64);
      Name32      := 'OTP ' + OTPVersion + ' (32-bit)';
      Name64      := 'OTP ' + OTPVersion + ' (64-bit)';
    end;
  end else begin
    with Result do begin
      OTPVersion  := '';
      ERTSVersion := '';
      URL32       := '';
      URL64       := '';

      Exe32       := '';
      Exe64       := '';
      Name32      := '';
      Name64      := '';
    end;
  end;
end;
