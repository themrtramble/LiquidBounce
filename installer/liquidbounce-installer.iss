; ============================================================
; LiquidBounce Boosted Installer
; Built with Inno Setup 6
; ============================================================

[Setup]
AppName=LiquidBounce Boosted (MrTramble Edition)
AppVersion=0.40.1
AppPublisher=MrTramble
AppPublisherURL=https://github.com/themrtramble/LiquidBounce
AppSupportURL=https://github.com/themrtramble/LiquidBounce/issues
AppUpdatesURL=https://github.com/themrtramble/LiquidBounce/releases
DefaultDirName={code:GetDefaultModsFolder}
DisableProgramGroupPage=yes
DisableReadyPage=no
OutputBaseFilename=LiquidBounce-Boosted-Installer
OutputDir=Output
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
PrivilegesRequired=lowest
Uninstallable=yes
UninstallDisplayName=LiquidBounce Boosted
SetupIconFile=
WizardStyle=modern
ShowLanguageDialog=auto

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; The boosted JAR - installed to mods folder as LiquidBounce.jar
Source: "liquidbounce-boosted.jar"; DestDir: "{app}"; DestName: "LiquidBounce.jar"; Flags: ignoreversion overwritereadonly; BeforeInstall: BackupExistingJar
; Backup copy stored in LocalAppData for the refresh script
Source: "liquidbounce-boosted.jar"; DestDir: "{localappdata}\LiquidBounceBoosted"; DestName: "liquidbounce-boosted.jar"; Flags: ignoreversion
; Refresh helper script (re-applies boosted JAR if launcher overwrote it)
Source: "refresh-boosted.bat"; DestDir: "{localappdata}\LiquidBounceBoosted"; Flags: ignoreversion

[Icons]
Name: "{userdesktop}\LiquidBounce Boosted - Refresh"; Filename: "{localappdata}\LiquidBounceBoosted\refresh-boosted.bat"; WorkingDir: "{localappdata}\LiquidBounceBoosted"; Comment: "Re-applies boosted LiquidBounce.jar (run if LiquidLauncher replaced it)"
Name: "{userdesktop}\LiquidBounce Boosted - Restore Official"; Filename: "{cmd}"; Parameters: "/c if exist ""{app}\LiquidBounce-official-backup.jar"" copy /Y ""{app}\LiquidBounce-official-backup.jar"" ""{app}\LiquidBounce.jar"""; Comment: "Restores official LiquidBounce.jar from backup"

[Run]
Filename: "{localappdata}\LiquidBounceBoosted\refresh-boosted.bat"; Description: "Apply boosted JAR now"; Flags: postinstall skipifsilent runhidden

[Code]
function GetDefaultModsFolder(Param: string): string;
var
  LiquidLauncherPath: string;
  DefaultMCPath: string;
  PrismPath: string;
  ATLauncherPath: string;
begin
  LiquidLauncherPath := ExpandConstant('{userappdata}\CCBlueX\LiquidLauncher\data\gameDir\nextgen\mods');
  DefaultMCPath := ExpandConstant('{userappdata}\.minecraft\mods');
  PrismPath := ExpandConstant('{userappdata}\PrismLauncher\instances');
  ATLauncherPath := ExpandConstant('{userappdata}\ATLauncher\instances');

  if DirExists(LiquidLauncherPath) then
    Result := LiquidLauncherPath
  else if DirExists(DefaultMCPath) then
    Result := DefaultMCPath
  else
    Result := DefaultMCPath;
end;

procedure BackupExistingJar;
var
  ExistingJar: string;
  BackupJar: string;
begin
  ExistingJar := ExpandConstant('{app}\LiquidBounce.jar');
  BackupJar := ExpandConstant('{app}\LiquidBounce-official-backup.jar');

  if FileExists(ExistingJar) and not FileExists(BackupJar) then
  begin
    RenameFile(ExistingJar, BackupJar);
    Log('Backed up existing LiquidBounce.jar to: ' + BackupJar);
  end;
end;

function InitializeSetup(): Boolean;
var
  LiquidLauncherPath: string;
  DefaultPath: string;
  DetectedPath: string;
begin
  LiquidLauncherPath := ExpandConstant('{userappdata}\CCBlueX\LiquidLauncher\data\gameDir\nextgen\mods');
  DefaultPath := ExpandConstant('{userappdata}\.minecraft\mods');

  if DirExists(LiquidLauncherPath) then
  begin
    DetectedPath := LiquidLauncherPath;
    Log('Detected LiquidLauncher mods folder: ' + DetectedPath);
  end
  else if DirExists(DefaultPath) then
  begin
    DetectedPath := DefaultPath;
    Log('Detected default .minecraft mods folder: ' + DetectedPath);
  end
  else
  begin
    DetectedPath := DefaultPath;
    Log('No existing mods folder detected. Will create: ' + DetectedPath);
  end;

  Result := True;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  Memo: String;
begin
  Memo := '';
  Memo := Memo + 'Installation Summary:' + NewLine + NewLine;
  Memo := Memo + '  Target folder: ' + ExpandConstant('{app}') + NewLine + NewLine;
  Memo := Memo + '  Action: Install LiquidBounce.jar (boosted)' + NewLine;

  if FileExists(ExpandConstant('{app}\LiquidBounce.jar')) then
    Memo := Memo + '  Backup: Existing LiquidBounce.jar will be saved as LiquidBounce-official-backup.jar' + NewLine;

  Memo := Memo + NewLine + '  After install:' + NewLine;
  Memo := Memo + '  - Desktop shortcut "Refresh" to re-apply if launcher overwrites' + NewLine;
  Memo := Memo + '  - Desktop shortcut "Restore Official" to revert to official version' + NewLine;
  Memo := Memo + NewLine + 'IMPORTANT: Disable auto-update in LiquidLauncher settings' + NewLine;
  Memo := Memo + 'to prevent it from replacing the boosted JAR!' + NewLine;

  Result := Memo;
end;
