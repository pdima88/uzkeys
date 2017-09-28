unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, ComCtrls, StdCtrls, Windows, MouseAndKeyInput, LCLType, Grids, LazUTF8,
  registry,
  winsendkeys;

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
    btnOK: TButton;
    Button2: TButton;
    IdleTimer1: TIdleTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblGithub: TLabel;
    lblMailto: TLabel;
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
    StringGrid1: TStringGrid;
    trayIcon: TTrayIcon;
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblGithubClick(Sender: TObject);
    procedure lblMailtoClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuHelpClick(Sender: TObject);
    procedure mnuLatCyrClick(Sender: TObject);
    procedure mnuStartupClick(Sender: TObject);
    procedure trayIconDblClick(Sender: TObject);
  private
    Started: Boolean;
    CanQuit: Boolean;
    reg: TRegistry;
    procedure HKMessage(var Msg: TMessage); message WM_HOTKEY;
    procedure SendVK(Data: PtrInt);
  public
    procedure RegisterStartup(AStartup: Boolean);
    procedure RegisterHotKeys;
    procedure UnregisterHotKeys;
    procedure TryRegisterHotKey(HK: THotKeyId; KMod, VK: Cardinal;
      errMsg: String; var err: String);
    procedure Quit;
  end;
const APP_REG_KEY = 'Software\pdima88\uzkeys\';
const STARTUP_REG_KEY = 'Software\Microsoft\Windows\CurrentVersion\Run\';
const STARTUP_REG_VALUE = 'uzkeys';

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.trayIconDblClick(Sender: TObject);
begin
  Visible := not IsVisible;
end;

procedure TfrmMain.HKMessage(var Msg: TMessage);
begin
  Application.QueueAsyncCall(@SendVK, Msg.wParam);
end;

procedure TfrmMain.SendVK(Data: PtrInt);
var s: UnicodeString; i: Integer; us: String;
    CAPS: Boolean; dia1, dia2: String;
    hk: THotKeyId;
begin
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

procedure TfrmMain.RegisterStartup(AStartup: Boolean);
begin
  reg.Access := KEY_WRITE;
  if reg.OpenKey(STARTUP_REG_KEY, True) then
  begin
       if AStartup then reg.WriteString(STARTUP_REG_VALUE, ParamStr(0))
       else reg.DeleteValue(STARTUP_REG_VALUE);
       reg.CloseKey;
  end;
  reg.Access := KEY_READ;
end;

procedure TfrmMain.RegisterHotKeys;
var err: String; Cyr, Lat: Integer;
begin
  err := ''; Cyr := 0; Lat := 0;
  if mnuLat.Checked then
  begin
    TryRegisterHotKey(hkLatApostrophe, MOD_ALT, VkKeyScan('`'), 'Alt+`', err);
    TryRegisterHotKey(hkLatO, MOD_ALT, VkKeyScan('o'), 'Alt+O', err);
    TryRegisterHotKey(hkLatShiftO, MOD_ALT + MOD_SHIFT, VkKeyScan('o'), 'Alt+Shift+O', err);
    TryRegisterHotKey(hkLatG, MOD_ALT, VkKeyScan('g'), 'Alt+G', err);
    TryRegisterHotKey(hkLatShiftG, MOD_ALT + MOD_SHIFT, VkKeyScan('g'), 'Alt+Shift+G', err);
    Lat := 1;
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
    Cyr := 1;
  end;
  reg.Access := KEY_WRITE;
  if reg.OpenKey(APP_REG_KEY, True) then
  begin
    reg.WriteInteger('Cyr', Cyr);
    reg.WriteInteger('Lat', Lat);
    reg.CloseKey;
  end;
  reg.Access := KEY_READ;
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

procedure TfrmMain.Quit;
begin
  CanQuit := True;
  Close;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  trayIcon.Visible := True;
  reg := TRegistry.Create(KEY_READ);
  reg.RootKey := HKEY_CURRENT_USER;
  if reg.OpenKey(STARTUP_REG_KEY, False) then
  begin
    if reg.ValueExists(STARTUP_REG_VALUE) and
       (Trim(LowerCase(reg.ReadString(STARTUP_REG_VALUE))) = Trim(LowerCase(ParamStr(0)))) then
    begin
      mnuStartup.Checked := True;
    end;
    reg.CloseKey;
  end;
  if not reg.KeyExists(APP_REG_KEY) then
  begin
    reg.Access:= KEY_WRITE;
    if reg.OpenKey(APP_REG_KEY, True) then
    begin
         reg.WriteInteger('Cyr', 1);
         reg.WriteInteger('Lat', 1);
         reg.CloseKey;
    end;
    reg.Access := KEY_READ;
  end;
  if reg.OpenKey(APP_REG_KEY, False) then
  begin
    if Reg.ReadInteger('Cyr') <> 0 then mnuCyr.Checked := True;
    if reg.ReadInteger('Lat') <> 0 then mnuLat.Checked := True;
    Reg.CloseKey;
  end;

  RegisterHotKeys;

  if ParamStr(1) = 'startup' then
  begin
    mnuStartup.Checked := True;
    RegisterStartup(True);
  end;
end;

procedure TfrmMain.btnOKClick(Sender: TObject);
begin
  Hide;
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if CanQuit then
  begin
    UnregisterHotKeys;
    CloseAction := caFree;
  end else begin
    CloseAction := caHide;
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  if not Started then
  begin
    Hide;
    Started := True;
  end;
end;

procedure TfrmMain.lblGithubClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://github.com/pdima88/uzkeys','','',0);
end;

procedure TfrmMain.lblMailtoClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'mailto:pdima88@gmail.com?subject=Uzkeys%200.1','','',0);
end;

procedure TfrmMain.mnuExitClick(Sender: TObject);
begin
  Quit;
end;

procedure TfrmMain.mnuHelpClick(Sender: TObject);
begin
  Show;
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

procedure TfrmMain.mnuStartupClick(Sender: TObject);
begin
  mnuStartup.Checked := not mnuStartup.Checked;
  RegisterStartup(mnuStartup.Checked);
end;

end.

