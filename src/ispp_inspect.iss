; ispp_inspect.iss - ISPP macros for scripted constants to inspect any arbitrary value
; Copyright (c) Chris Hyndman
;
;   Licensed under the Apache License, Version 2.0 (the "License");
;   you may not use this file except in compliance with the License.
;   You may obtain a copy of the License at
;
;       http://www.apache.org/licenses/LICENSE-2.0
;
;   Unless required by applicable law or agreed to in writing, software
;   distributed under the License is distributed on an "AS IS" BASIS,
;   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;   See the License for the specific language governing permissions and
;   limitations under the License.

; Creates a syntax-legal function name from the value to inspect
#define StrInspectFuncName(str Value) 'Const_' + StringChange(Value, '.', '__')

; Creates a function which returns the value specified
#define StrInspectFuncDef(str Value) 'function ' + StrInspectFuncName(Value) + '(Param: String): String; begin Result := ' + Value + '; end; '

; This variable stores the functions for expanding in the translation
#define StrInspectAllFuncs = ''

; Creates a function for the value specified, if it doesn't already exist, and returns the scripted constant syntax for use
; in non-[Code] sections
#define StrInspectScriptConst(str Value) \
  Pos(StrInspectFuncDef(Value), StrInspectAllFuncs) == 0 ? \
  StrInspectAllFuncs = StrInspectAllFuncs + StrInspectFuncDef(Value) : 0, \
  '{code:' + StrInspectFuncName(Value) + '}'
