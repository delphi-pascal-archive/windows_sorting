unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, CheckLst, ComCtrls, ToolWin,
  SysTrayG, Menus, ImgList;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    WinBox: TCheckListBox;
    UpBtn: TBitBtn;
    DownBtn: TBitBtn;
    RefrashBtn: TBitBtn;
    ApplyBtn: TBitBtn;
    CloseBtn: TBitBtn;
    WBPopup: TPopupMenu;
    PMin: TMenuItem;
    PMax: TMenuItem;
    PLine: TMenuItem;
    PClose: TMenuItem;
    procedure CloseBtnClick(Sender: TObject);
    procedure RefrashBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure WinBoxClickCheck(Sender: TObject);
    procedure UpBtnClick(Sender: TObject);
    procedure DownBtnClick(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure WinBoxKeyPress(Sender: TObject; var Key: Char);
    procedure WinBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PCloseClick(Sender: TObject);
    procedure PMaxClick(Sender: TObject);
    procedure PMinClick(Sender: TObject);
  private
    function FillWinBox: Boolean;
    function AddWindow(Wnd: HWND; Number: Byte): Boolean;
    procedure MoveItems(Index, Step: Integer);
    procedure FRWSSysTray(var message: TMessage); message FR_WSSYSTRAY;
    procedure WMSysCommand(var message: TMessage); message WM_SYSCOMMAND;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  WinHandles: array of HWND;
  CloseNum: ^Byte;

implementation

{$R *.dfm}

{IsWindowGood}

function IsWindowGood(Wnd: HWND): string;
var
  WinText: string;
begin
  SetLength(WinText, 255);
  if (Wnd <> Application.Handle) and
     (GetWindow(Wnd, gw_Owner) = 0) and 
     (GetWindowText(Wnd, PChar(WinText), 255) <> 0)
  then SetLength(WinText, StrLen(PChar(WinText)))
  else WinText := '';
  if WinText = 'Program Manager' then WinText := '';
  Result := WinText;
end;


{AddWindow}

function TForm1.AddWindow(Wnd: HWND; Number: Byte): Boolean;
var
  WinText: ShortString;
begin
  WinText := IsWindowGood(Wnd);
  if WinText <> ''
  then
    begin
      SetLength(WinHandles, Length(WinHandles) + 1);
      WinHandles[Number] := Wnd;
      WinBox.Items.Add(WinText);
      WinBox.Checked[Number] := IsWindowVisible(Wnd);
      Result := True;
    end
  else Result := False;
end;


{FillWinBox}

function TForm1.FillWinBox: Boolean;
var
  Wnd: HWND;
  Handles: array of HWND;
  i, j: Byte;
begin
  //сохраним дескрипторы скрытых программой окон
  SetLength(Handles, 0);
  j := 0;
  while j < WinBox.Count do
  begin
    if not WinBox.Checked[j]
    then
      begin
        SetLength(Handles, Length(Handles) + 1);
        Handles[Length(Handles) - 1] := WinHandles[j];
      end;
    j := j + 1;
  end;
  //добавим видимые окна
  WinBox.Items.Clear;
  SetLength(WinHandles,0);
  Wnd := GetWindow(Handle, GW_HWNDFIRST);
  i := 0;
  while Wnd > 0 do
  begin
    if IsWindowVisible(Wnd) then
      if AddWindow(Wnd, i) then i := i + 1;
    Wnd := GetWindow(Wnd, GW_HWNDNEXT);
  end;
  //добавим невидимые окна
  j := 0;
  while j < Length(Handles) do
  begin
    if not IsWindowVisible(Handles[j])then
      if AddWindow(Handles[j], i) then i := i + 1;
    j := j + 1;
  end;
end;


{MoveItems}

procedure TForm1.MoveItems(Index, Step: Integer);
var
  Wnd: HWND;
  WinText: ShortString;
begin
  Wnd := WinHandles[Index];
  WinText := WinBox.Items.Strings[Index];
  WinHandles[Index] := WinHandles[Index + Step];
  WinBox.Items.Strings[Index] := WinBox.Items.Strings[Index + Step];
  WinHandles[Index + Step] := Wnd;
  WinBox.Items.Strings[Index + Step] := WinText;
  WinBox.ItemIndex := Index + Step;
end;


{PopupEnd}

procedure PopupEnd;
begin
  Form1.FillWinBox;
  Dispose(CloseNum);
end;



(******************************************************************************)
(*                            ОБРАБОТКА СОБЫТИЙ                               *)
(******************************************************************************)


{WinBoxClickCheck}

procedure TForm1.WinBoxClickCheck(Sender: TObject);
var
  i: Byte;
begin
  i := WinBox.ItemIndex;
  if WinBox.Checked[i]
  then ShowWindow(WinHandles[i], SW_MINIMIZE)
  else ShowWindow(WinHandles[i], SW_HIDE);
  SetForegroundWindow(Handle);
end;


{WinBoxKeyPress}

procedure TForm1.WinBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key =  Chr(VK_RETURN)
  then
    begin
      WinBox.Checked[WinBox.ItemIndex] := not WinBox.Checked[WinBox.ItemIndex];
      WinBoxClickCheck(Application);
    end;
end;


{WinBoxMouseUp}

procedure TForm1.WinBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  APoint: TPoint;
  ARect: TRect;
  Index: integer;
begin
  if Button = mbRight then
  begin
    APoint.X := X;
    APoint.Y := Y;
    Index := WinBox.ItemAtPos(APoint, True);
    if Index > -1 then
    begin
      WinBox.ItemIndex := Index;
      GetCursorPos(APoint);
      New(CloseNum);
      CloseNum^ := Index;
      WBPopup.Popup(APoint.X, APoint.Y);
    end;
  end;
end;


{UpBtnClick}

procedure TForm1.UpBtnClick(Sender: TObject);
var
  i: Integer;
begin
  i := WinBox.ItemIndex;
  if i < 1 then Exit;
  MoveItems(i, -1);
end;


{DownBtnClick}

procedure TForm1.DownBtnClick(Sender: TObject);
var
  i: Integer;
begin
  i := WinBox.ItemIndex;
  if (i >= WinBox.Count - 1) or (i = -1) then Exit;
  MoveItems(i, 1);
end;


{ApplyBtnClick}

procedure TForm1.ApplyBtnClick(Sender: TObject);
var
  i: Byte;
begin
  i := 0;
  while i <= WinBox.Count - 1 do
  begin
    ShowWindow(WinHandles[i], SW_HIDE);
    i := i + 1;
  end;
  i := 0;
  while i <= WinBox.Count - 1 do
  begin
    if WinBox.Checked[i]
    then ShowWindow(WinHandles[i], SW_MINIMIZE);
    i := i + 1;
  end;
  SetForegroundWindow(Handle);
end;


{RefrashBtnClick}

procedure TForm1.RefrashBtnClick(Sender: TObject);
begin
  FillWinBox;
end;


{CloseBtnClick}

procedure TForm1.CloseBtnClick(Sender: TObject);
begin
  Close;
end;


{PCloseClick}

procedure TForm1.PCloseClick(Sender: TObject);
var
  WName: String;
begin
  WName := WinBox.Items.Strings[CloseNum^];
  with CreateMessageDialog('Закрыть окно ' + WName + ' ?',mtConfirmation ,[mbYes, mbNo]) do
  begin
    Caption := Form1.Caption;
    ShowModal;
    if ModalResult = mrYes
    then PostMessage(WinHandles[CloseNum^],WM_CLOSE,0,0);
  end;
  PopupEnd;
end;


{PMaxClick}

procedure TForm1.PMaxClick(Sender: TObject);
begin
  ShowWindow(WinHandles[CloseNum^], SW_RESTORE);
  SetForegroundWindow(WinHandles[CloseNum^]);
  SetForegroundWindow(Form1.Handle);
  PopupEnd;
end;


{PMinClick}

procedure TForm1.PMinClick(Sender: TObject);
begin
  ShowWindow(WinHandles[CloseNum^], SW_MINIMIZE);
  PopupEnd;
end;


{FormActivate}

procedure TForm1.FormActivate(Sender: TObject);
begin
  FillWinBox;
  AddSysTrayPlease(Handle, hInstance);
  ShowWindow(Application.Handle, SW_HIDE);
end;


{FormCloseQuery}

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i: Integer;
begin
  i := 0;
  while i <= WinBox.Count - 1 do
  begin
    if not WinBox.Checked[i]
    then ShowWindow(WinHandles[i], SW_MINIMIZE);
    i := i + 1;
  end;
  DelateSysTrayPlease;
  CanClose := True;
end;


{FRWSSysTray}

procedure TForm1.FRWSSysTray(var message: TMessage);
var
  FPoint: TPoint;
begin
  if (message.LParam = WM_LBUTTONUP) or (message.LParam = WM_RBUTTONUP)
  then
    begin
      ShowWindow(Handle,SW_SHOW);
      SetForegroundWindow(Handle);
    end;
end;


{WMSysCommand}

procedure TForm1.WMSysCommand(var message: TMessage);
begin
  if message.WParam = SC_MINIMIZE
  then ShowWindow(Handle, SW_HIDE)
  else inherited;
end;

end.
