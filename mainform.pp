unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, ComCtrls, StdCtrls, Windows, MouseAndKeyInput, LCLType, LazUTF8;

type
  THotKeyId = (
     hkLatApostrophe = 13880,
     hkLatO = 13881,
     hkLatShiftO = 13882,
     hkLatG = 13883,
     hkLatShiftG = 13884,
     hkCyrY = 13885,
     hkCyrShiftY = 13886,
     hkCyrK = 13887,
     hkCyrShiftK = 13888,
     hkCyrF = 13889,
     hkCyrShiftF = 13890,
     hkCyrX = 13891,
     hkCyrShiftX = 13892
     //hkInsertWin = 13893
);

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    IdleTimer1: TIdleTimer;
    Memo1: TMemo;
    mnuSep0: TMenuItem;
    mnuStartup: TMenuItem;
    mnuLat: TMenuItem;
    mnuCyr: TMenuItem;
    mnuSep2: TMenuItem;
    mnuExit: TMenuItem;
    mnuSep3: TMenuItem;
    mnuHelp: TMenuItem;
    mnuTray: TPopupMenu;
    trayIcon: TTrayIcon;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IdleTimer1StartTimer(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure mnuLatCyrClick(Sender: TObject);
    procedure mnuLatClick(Sender: TObject);
    procedure trayIconDblClick(Sender: TObject);
  private
    Started: Boolean;
    KeyMsgQueue: array[0..999] of THotKeyId;
    QueueLen: Integer;
    QueueHead: Integer;
    QueueTail: Integer;
    procedure AddKeyToQueue(hk: THotKeyId);
    function PopKeyFromQueue(var hk: THotKeyId): Boolean;
    procedure HKMessage(var Msg: TMessage); message WM_HOTKEY;
    procedure OnIdle(Sender: TObject; var Done: Boolean);
    procedure SendVK(Data: PtrInt);
  public
    procedure RegisterHotKeys;
    procedure UnregisterHotKeys;
    procedure TryRegisterHotKey(HK: THotKeyId; KMod, VK: Cardinal;
      errMsg: String; var err: String);
  end;

var
  frmMain: TfrmMain;

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

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.mnuLatClick(Sender: TObject);
begin

end;

procedure TfrmMain.trayIconDblClick(Sender: TObject);
begin
  Visible := not IsVisible;
end;

procedure TfrmMain.AddKeyToQueue(hk: THotKeyId);
begin
  if QueueLen < 1000 then
  begin
    Inc(QueueLen);
    QueueTail := (QueueTail + 1) mod 1000;
    KeyMsgQueue[QueueTail] := hk;
  end;
end;

function TfrmMain.PopKeyFromQueue(var hk: THotKeyId): Boolean;
begin
  Result := False;
  if QueueLen > 0 then
  begin
    hk := KeyMsgQueue[QueueHead];
    Result := True;
    QueueHead := (QueueHead + 1) mod 1000;
    Dec(QueueLen);
  end;
end;

procedure TfrmMain.HKMessage(var Msg: TMessage);
begin
  Memo1.Lines.Add(IntToStr(Msg.lParam) + ' ' + IntToStr(Msg.wParam));
  (*if (Msg.wParam >= Cardinal(Low(THotKeyId))) and (Msg.wParam <= Cardinal(High(THotKeyId))) then begin
    AddKeyToQueue(THotKeyId(Msg.wParam));
  end;*)
  Application.QueueAsyncCall(@SendVK, Msg.wParam);
end;

procedure TfrmMain.OnIdle(Sender: TObject; var Done: Boolean);
var hk: THotKeyId;
begin
  if PopKeyFromQueue(hk) then
  begin
    KeyInput.Unapply([ssAlt]);
    //KeyInput.Press('ЎЎқ');
    KeyInput.Press('TEST');
    //keybd_event(VkKeyScan('o'), 0, KEYEVENTF_KEYUP, 0);
    //keybd_event(VkKeyScan('k'),0 ,KEYEVENTF_KEYUP, 0);
  end;
end;

procedure SendKeys(const S: UnicodeString);
var
  InputEvents: PInput;
  I, J: Integer;
begin
  if S = '' then Exit;
  GetMem(InputEvents, SizeOf(TInput) * (Length(S) * 2 + 4));

  try
    J := 0;
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
    if I = 0 then
    begin
      J := GetLastError;
    end;
  finally
    FreeMem(InputEvents);
  end;
end;

procedure TfrmMain.SendVK(Data: PtrInt);
var s: UnicodeString; i: Integer; us: String;
    CAPS: Boolean; dia1, dia2: String;
    hk: THotKeyId;
begin
  //KeyInput.Unapply([ssAlt]);
  //KeyInput.Press('ЎЎқ');
  //KeyInput.Press('TEST');
  //SendMessage(GetActiveWindow, WM_IME_KEYDOWN, Ord('s'), 0);
  //SendMessage(GetActiveWindow, WM_IME_KEYDOWN, Ord('t'), 0);
  //keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, 0);
  //SendMessage(GetActiveWindow, WM_SYSKEYUP, VK_MENU, 0);

  //keybd_event(VK_MENU, 0, KEYEVENTF_EXTENDEDKEY, 0);
  dia1 := 'ʻ';
  dia2 := 'ʼ';
  CAPS := ((GetKeyState(VK_CAPITAL) and 1) <> 0);
  if (Data >= Integer(Low(THotKeyId))) and (Data <= Integer(High(THotKeyId))) then
  begin
    hk := THotKeyId(Data);
    case hk of
      hkLatApostrophe: us := dia2;
      hkLatO,hkLatShiftO:
        begin
          if hk = hkLatShiftO then CAPS := not CAPS;
          if CAPS then us := 'O' else us := 'o';
          us := us + dia1;
        end;
      hkLatG,hkLatShiftG:
        begin
          if hk = hkLatShiftG then CAPS := not CAPS;
          if CAPS then us := 'G' else us := 'g';
          us := us + dia1;
        end;
      hkCyrY,hkCyrShiftY:
        begin
          if hk = hkCyrShiftY then CAPS := not CAPS;
          if CAPS then us := 'Ў' else us := 'ў';
        end;
      hkCyrK,hkCyrShiftK:
        begin
          if hk = hkCyrShiftK then CAPS := not CAPS;
          if CAPS then us := 'Қ' else us := 'қ';
        end;
      hkCyrF,hkCyrShiftF:
        begin
          if hk = hkCyrShiftF then CAPS := not CAPS;
          if CAPS then us := 'Ғ' else us := 'ғ';
        end;
      hkCyrX,hkCyrShiftX:
        begin
          if hk = hkCyrShiftX then CAPS := not CAPS;
          if CAPS then us := 'Ҳ' else us := 'ҳ';
        end;
    end;
    if us <> '' then
    begin
      s := UTF8ToUTF16(us);
      SendKeys(s);
    end;
  end;

end;

procedure TfrmMain.RegisterHotKeys;
var err: String;
begin
  err := '';
  if mnuLat.Checked then
  begin
    TryRegisterHotKey(hkLatApostrophe, MOD_ALT, VkKeyScan('`'), 'Alt+`', err);
    TryRegisterHotKey(hkLatO, MOD_ALT, VkKeyScan('o'), 'Alt+O', err);
    TryRegisterHotKey(hkLatShiftO, MOD_ALT + MOD_SHIFT, VkKeyScan('o'), 'Alt+Shift+O', err);
    TryRegisterHotKey(hkLatG, MOD_ALT, VkKeyScan('g'), 'Alt+G', err);
    TryRegisterHotKey(hkLatShiftG, MOD_ALT + MOD_SHIFT, VkKeyScan('g'), 'Alt+Shift+G', err);
  end;
  if mnuCyr.Checked then
  begin
    TryRegisterHotKey(hkCyrY, MOD_ALT, VkKeyScan('e'), 'Alt+У', err);
    TryRegisterHotKey(hkCyrShiftY, MOD_ALT + MOD_SHIFT, VkKeyScan('e'), 'Alt+Shift+У', err);
    TryRegisterHotKey(hkCyrK, MOD_ALT, VkKeyScan('r'), 'Alt+К', err);
    TryRegisterHotKey(hkCyrShiftK, MOD_ALT + MOD_SHIFT, VkKeyScan('r'), 'Alt+Shift+К', err);
    TryRegisterHotKey(hkCyrF, MOD_ALT, VkKeyScan('u'), 'Alt+Г', err);
    TryRegisterHotKey(hkCyrShiftF, MOD_ALT + MOD_SHIFT, VkKeyScan('u'), 'Alt+Shift+Г', err);
    TryRegisterHotKey(hkCyrX, MOD_ALT, VkKeyScan('['), 'Alt+Х', err);
    TryRegisterHotKey(hkCyrShiftX, MOD_ALT + MOD_SHIFT, VkKeyScan('['), 'Alt+Shift+Х', err);
  end;
  if err <> '' then
  begin
    MessageDlg('Не удалось зарегистрировать горячие клавиши: '+err, mtWarning, [mbOK], 0);
  end;
end;

procedure TfrmMain.UnregisterHotKeys;
var I: THotKeyId;
begin
  for I := Low(THotKeyId) to High(THotKeyId) do
  begin
    UnregisterHotKey(Handle, Integer(I));
  end;
  (* UnregisterHotKey(Handle, Integer(hkLatShiftO));
  UnregisterHotKey(Handle, Integer(hkLatG);
  UnregisterHotKey(Handle, hkLatShiftG);
  UnregisterHotKey(Handle, hkCyrY);
  UnregisterHotKey(Handle, hkCyrShiftY);
  UnregisterHotKey(Handle, hkCyrK);
  UnregisterHotKey(Handle, hkCyrShiftK);
  UnregisterHotKey(Handle, hkCyrF);
  UnregisterHotKey(Handle, hkCyrShiftF);
  UnregisterHotKey(Handle, hkCyrX);
  UnregisterHotKey(Handle, hkCyrShiftX);*)
end;

procedure TfrmMain.TryRegisterHotKey(HK: THotKeyId; KMod, VK: Cardinal;
  errMsg: String; var err: String);
var r: Boolean;
begin
  r := RegisterHotKey(Handle, Integer(HK), KMod, VK);
  if not r then
  begin
    if err <> '' then err := err + ', ';
    err := err + errMsg;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  trayIcon.Visible := True;
  Application.OnIdle := TIdleEvent(@OnIdle);
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  RegisterHotKeys;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  UnregisterHotKeys;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  if not Started then
  begin
    Hide;
    Started := True;
  end;
end;

procedure TfrmMain.IdleTimer1StartTimer(Sender: TObject);
begin

end;

procedure TfrmMain.IdleTimer1Timer(Sender: TObject);
begin

end;

procedure TfrmMain.mnuLatCyrClick(Sender: TObject);
begin
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    UnregisterHotKeys;
    RegisterHotKeys;
  end;
end;

end.

