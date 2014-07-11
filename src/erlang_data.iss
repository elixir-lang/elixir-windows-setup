// erlang_data.iss - TErlangData and related functions
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

function CSVToErlangData(Filename: String): TErlangData;
var
  Rows: TArrayOfString;
  RowValues: TStrings;
begin
  LoadStringsFromFile(Filename, Rows);
  RowValues := SplitString(Rows[0], ',');

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
end;
