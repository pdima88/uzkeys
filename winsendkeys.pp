unit winsendkeys;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows;

const
  {$EXTERNALSYM INPUT_MOUSE}
  INPUT_MOUSE = 0;
  {$EXTERNALSYM INPUT_KEYBOARD}
  INPUT_KEYBOARD = 1;
  {$EXTERNALSYM INPUT_HARDWARE}
  INPUT_HARDWARE = 2;

const
  {$EXTERNALSYM KEYEVENTF_EXTENDEDKEY}
  KEYEVENTF_EXTENDEDKEY = 1;
  {$EXTERNALSYM KEYEVENTF_KEYUP}
  KEYEVENTF_KEYUP       = 2;
  {$EXTERNALSYM KEYEVENTF_UNICODE}
  KEYEVENTF_UNICODE     = 4;
  {$EXTERNALSYM KEYEVENTF_SCANCODE}
  KEYEVENTF_SCANCODE    = 8;

type
  PMouseInput = ^TMouseInput;
  {$EXTERNALSYM tagMOUSEINPUT}
  tagMOUSEINPUT = record
    dx: Longint;
    dy: Longint;
    mouseData: DWORD;
    dwFlags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;
  TMouseInput = tagMOUSEINPUT;

  PKeybdInput = ^TKeybdInput;
  {$EXTERNALSYM tagKEYBDINPUT}
  tagKEYBDINPUT = record
    wVk: WORD;
    wScan: WORD;
    dwFlags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;
  TKeybdInput = tagKEYBDINPUT;

  PHardwareInput = ^THardwareInput;
  {$EXTERNALSYM tagHARDWAREINPUT}
  tagHARDWAREINPUT = record
    uMsg: DWORD;
    wParamL: WORD;
    wParamH: WORD;
  end;
  THardwareInput = tagHARDWAREINPUT;

  PInput = ^TInput;
  {$EXTERNALSYM tagINPUT}
  tagINPUT = record
    Itype: DWORD;
    case Integer of
      0: (mi: TMouseInput);
      1: (ki: TKeybdInput);
      2: (hi: THardwareInput);
  end;
  TInput = tagINPUT;

{$EXTERNALSYM SendInput}
function SendInput(cInputs: UINT; var pInputs: TInput; cbSize: Integer): UINT; stdcall; external 'user32.dll' name 'SendInput';

procedure SendKeys(const S: UnicodeString);

implementation

procedure SendKeys(const S: UnicodeString);
var
  InputEvents: PInput;
  I, J: Integer;

  procedure AddLRAltSeq;
  begin
        InputEvents[J].Itype := INPUT_KEYBOARD;
    InputEvents[J].ki.wVk := VK_LMENU;
    InputEvents[J].ki.wScan := 0;
    InputEvents[J].ki.dwFlags := 0;
    InputEvents[J].ki.time := 0;
    InputEvents[J].ki.dwExtraInfo := 0;
    Inc(J);
    InputEvents[J].Itype := INPUT_KEYBOARD;
    InputEvents[J].ki.wVk := VK_LMENU;
    InputEvents[J].ki.wScan := 0;
    InputEvents[J].ki.dwFlags := KEYEVENTF_KEYUP;
    InputEvents[J].ki.time := 0;
    InputEvents[J].ki.dwExtraInfo := 0;
    Inc(J);
     InputEvents[J].Itype := INPUT_KEYBOARD;
    InputEvents[J].ki.wVk := VK_RMENU;
    InputEvents[J].ki.wScan := 0;
    InputEvents[J].ki.dwFlags := 0;
    InputEvents[J].ki.time := 0;
    InputEvents[J].ki.dwExtraInfo := 0;
    Inc(J);
    InputEvents[J].Itype := INPUT_KEYBOARD;
    InputEvents[J].ki.wVk := VK_RMENU;
    InputEvents[J].ki.wScan := 0;
    InputEvents[J].ki.dwFlags := KEYEVENTF_KEYUP;
    InputEvents[J].ki.time := 0;
    InputEvents[J].ki.dwExtraInfo := 0;
    Inc(J);
  end;

begin
  if S = '' then Exit;
  GetMem(InputEvents, SizeOf(TInput) * (Length(S) * 2 + 4));

  try
    J := 0;
    AddLRAltSeq;
    for I := 1 to Length(S) do
    begin
      InputEvents[J].Itype := INPUT_KEYBOARD;
      InputEvents[J].ki.wVk := 0;
      InputEvents[J].ki.wScan := Ord(S[I]);
      InputEvents[J].ki.dwFlags := KEYEVENTF_UNICODE;
      InputEvents[J].ki.time := 0;
      InputEvents[J].ki.dwExtraInfo := 0;
      Inc(J);
      InputEvents[J].Itype := INPUT_KEYBOARD;
      InputEvents[J].ki.wVk := 0;
      InputEvents[J].ki.wScan := Ord(S[I]);
      InputEvents[J].ki.dwFlags := KEYEVENTF_UNICODE or KEYEVENTF_KEYUP;
      InputEvents[J].ki.time := 0;
      InputEvents[J].ki.dwExtraInfo := 0;
      Inc(J);
    end;
    I := SendInput(J, InputEvents[0], SizeOf(TInput));
    //SendMessage(GetActiveWindow, WM_ACTIVATE, WA_CLICKACTIVE, 0);
    if I = 0 then
    begin
      J := GetLastError;
    end;
  finally
    FreeMem(InputEvents);
  end;
end;

end.

