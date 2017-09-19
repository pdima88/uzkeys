unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, ComCtrls, StdCtrls, Windows;

type

  { TfrmMain }

  TfrmMain = class(TForm)
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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuLatClick(Sender: TObject);
    procedure trayIconDblClick(Sender: TObject);
  private
    Started: Boolean;
  public
    procedure RegisterHotKeysLat;
    procedure RegisterHotKeysCyr;
  end;

var
  frmMain: TfrmMain;

type THotKeyId = (
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
     hkCyrShiftX = 13892,
     hkInsertWin = 13893
);


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

procedure TfrmMain.RegisterHotKeysLat;
var r: Boolean; err: String;
begin
  err := '';
  r := RegisterHotKey(Handle, Integer(hkLatO), MOD_ALT, VkKeyScan('o'));
  if not r then
  begin
    if err <> '' then err := err + ', ';
    err := err + 'Alt+O';
  end;
end;

procedure TfrmMain.RegisterHotKeysCyr;
begin

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  trayIcon.Visible := True;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  if not Started then
  begin
    Hide;
    Started := True;
  end;
end;

end.

