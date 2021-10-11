unit SysTrayG;

interface

uses
  SysUtils, Windows, ShellAPI, Messages, Classes, Graphics;

const
  FR_WSSYSTRAY = WM_USER+115;

var
  NID: TNotifyIconData;

function AddSysTrayPlease(Handle: HWND; aInstance: Cardinal):LongBool;
function DelateSysTrayPlease:LongBool;

implementation


{AddSysTrayPlease}

function AddSysTrayPlease(Handle: HWND; aInstance : Cardinal):LongBool;
begin
  with NID do
    begin
      cbSize:=Sizeof(TNotifyIconData);
      Wnd := Handle;
      uID := 12345;
      UFlags := NIF_MESSAGE+NIF_ICON+NIF_TIP;
      SzTip := 'Windows Sorting';
      HIcon := LoadIcon(aInstance, 'MAINICON');
      uCallBackMessage := FR_WSSYSTRAY;//определяемое пользователем сообщение
  end;
  Result := Shell_NotifyIcon(NIM_ADD,@NID);
end;


{DelateSysTrayPlease}

function DelateSysTrayPlease:LongBool;
begin
  Result := Shell_NotifyIcon(NIM_DELETE,@NID);
end;

end.
 