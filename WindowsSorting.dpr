program WindowsSorting;

uses
  Forms,
  Windows,
  Main in 'Main.pas' {Form1},
  SysTrayG in 'SysTrayG.pas';

{$R *.res}

begin
  SetLength(WinHandles, 1);
  WinHandles[0] := FindWindow('TForm1', 'Windows Sortng');
  {if WinHandles[0] > 0
  then
    begin
      ShowWindow(WinHandles[0], SW_SHOW);
      SetForegroundWindow(WinHandles[0]);
      Halt;
    end;} 
  SetLength(WinHandles, 0);
  Application.Initialize;
  Application.Title := 'Windows Sorting';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

