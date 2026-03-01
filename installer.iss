#define MyAppName "PvzFusionAccountManager"
#define MyAppVersion "1.0.1"
#define MyAppPublisher "Lukbessolutions"
#define MyAppExeName "pvz_fusion_acc_manager.exe"

[Setup]
AppId={{B2B399B8-981F-4613-B5EA-DC2E97F8A3FF}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppPublisher}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputBaseFilename=installer
Compression=lzma
SolidCompression=yes
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
WizardStyle=modern dark polar
SetupIconFile=resources\icons\app_icon.ico

[Files]
Source: "resources\icons\app_icon.ico"; DestDir: "{app}"
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\app_icon.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent


[Code]
var
  DeleteUserData: Boolean;

function InitializeUninstall(): Boolean;
begin
  Result := True;

  if MsgBox(
    'Do you also want to delete user data?' + #13#10#13#10 +
    'This deletes all accounts. Your last played state will remain.',
    mbConfirmation, MB_YESNO) = IDYES
  then
    DeleteUserData := True
  else
    DeleteUserData := False;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DataDir: String;
begin
  if (CurUninstallStep = usUninstall) and DeleteUserData then
  begin
    DataDir := ExpandConstant('{localappdata}\lukbessolutions\{#MyAppName}');
    DelTree(DataDir, True, True, True);
  end;
end;