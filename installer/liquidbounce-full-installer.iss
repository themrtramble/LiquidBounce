; ============================================================
; LiquidBounce Boosted - FULL Installer
; Bundles: LiquidLauncher + Boosted JAR + Mod Dependencies
; Built with Inno Setup 6
; ============================================================

[Setup]
AppName=LiquidBounce Boosted (Full Client)
AppVersion=0.40.1
AppPublisher=MrTramble
AppPublisherURL=https://github.com/themrtramble/LiquidBounce
AppSupportURL=https://github.com/themrtramble/LiquidBounce/issues
AppUpdatesURL=https://github.com/themrtramble/LiquidBounce/releases
DefaultDirName={localappdata}\LiquidBounceBoosted
DefaultGroupName=LiquidBounce Boosted
DisableProgramGroupPage=no
DisableReadyPage=no
OutputBaseFilename=LiquidBounce-Boosted-FullInstaller
OutputDir=Output
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
PrivilegesRequired=lowest
Uninstallable=yes
UninstallDisplayName=LiquidBounce Boosted Full Client
WizardStyle=modern
ShowLanguageDialog=auto
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; ===== LiquidLauncher installer (bundled) =====
Source: "LiquidLauncher-setup.exe"; DestDir: "{tmp}"; Flags: ignoreversion deleteafterinstall nocompression; Check: ShouldInstallLauncher

; ===== Boosted LiquidBounce JAR (stored in LocalAppData for refresh script) =====
Source: "liquidbounce-boosted.jar"; DestDir: "{localappdata}\LiquidBounceBoosted"; DestName: "liquidbounce-boosted.jar"; Flags: ignoreversion

; ===== Mod dependencies (Fabric API + Fabric Kotlin from FabricMC Maven) =====
Source: "mods\*.jar"; DestDir: "{code:GetModsFolder}"; Flags: ignoreversion recursesubdirs

; ===== Boosted JAR also goes to mods folder as LiquidBounce.jar =====
Source: "liquidbounce-boosted.jar"; DestDir: "{code:GetModsFolder}"; DestName: "LiquidBounce.jar"; Flags: ignoreversion overwritereadonly; BeforeInstall: BackupExistingJar

; ===== Helper scripts =====
Source: "refresh-boosted.bat"; DestDir: "{localappdata}\LiquidBounceBoosted"; Flags: ignoreversion
Source: "launch-boosted.bat"; DestDir: "{localappdata}\LiquidBounceBoosted"; Flags: ignoreversion

[Icons]
Name: "{group}\LiquidBounce Boosted (Launch)"; Filename: "{localappdata}\LiquidBounceBoosted\launch-boosted.bat"; WorkingDir: "{localappdata}\LiquidBounceBoosted"; IconFilename: "{tmp}\LiquidLauncher-setup.exe"; Comment: "Launch LiquidBounce with boosted KillAura"
Name: "{group}\Refresh Boosted JAR"; Filename: "{localappdata}\LiquidBounceBoosted\refresh-boosted.bat"; WorkingDir: "{localappdata}\LiquidBounceBoosted"; Comment: "Re-apply boosted JAR if launcher overwrote it"
Name: "{group}\Uninstall LiquidBounce Boosted"; Filename: "{uninstallexe}"
Name: "{userdesktop}\LiquidBounce Boosted"; Filename: "{localappdata}\LiquidBounceBoosted\launch-boosted.bat"; WorkingDir: "{localappdata}\LiquidBounceBoosted"; Comment: "Launch LiquidBounce with boosted KillAura"
Name: "{userdesktop}\Refresh Boosted JAR"; Filename: "{localappdata}\LiquidBounceBoosted\refresh-boosted.bat"; WorkingDir: "{localappdata}\LiquidBounceBoosted"; Comment: "Re-apply boosted JAR if launcher overwrote it"

[Run]
; Step 1: Install LiquidLauncher (silent install to LocalAppData)
Filename: "{tmp}\LiquidLauncher-setup.exe"; Parameters: "/SILENT /CURRENTUSER /DIR=""{localappdata}\Programs\LiquidLauncher"""; Description: "Installing LiquidLauncher..."; Check: ShouldInstallLauncher; StatusMsg: "Installing LiquidLauncher (official launcher by CCBlueX)..."; Flags: waituntilterminated

; Step 2: Pre-create the mods folder structure & apply boosted JAR
Filename: "{localappdata}\LiquidBounceBoosted\refresh-boosted.bat"; Description: "Applying boosted JAR..."; StatusMsg: "Setting up boosted LiquidBounce.jar..."; Flags: postinstall runhidden waituntilterminated

[UninstallRun]
; Restore official jar if backup exists
Filename: "{cmd}"; Parameters: "/c if exist ""{code:GetModsFolder}\LiquidBounce-official-backup.jar"" copy /Y ""{code:GetModsFolder}\LiquidBounce-official-backup.jar"" ""{code:GetModsFolder}\LiquidBounce.jar"""

[UninstallDelete]
Type: filesandordirs; Name: "{localappdata}\LiquidBounceBoosted"

[Code]
var
  ModsFolder: string;
  InstallLauncher: Boolean;

function GetModsFolder(Param: string): string;
begin
  if ModsFolder = '' then
  begin
    if DirExists(ExpandConstant('{userappdata}\CCBlueX\LiquidLauncher\data\gameDir\nextgen\mods')) then
      ModsFolder := ExpandConstant('{userappdata}\CCBlueX\LiquidLauncher\data\gameDir\nextgen\mods')
    else if DirExists(ExpandConstant('{userappdata}\.minecraft\mods')) then
      ModsFolder := ExpandConstant('{userappdata}\.minecraft\mods')
    else
      ModsFolder := ExpandConstant('{userappdata}\CCBlueX\LiquidLauncher\data\gameDir\nextgen\mods');
  end;
  Result := ModsFolder;
end;

function ShouldInstallLauncher(): Boolean;
begin
  // Install launcher if LiquidLauncher.exe doesn't already exist
  Result := not FileExists(ExpandConstant('{localappdata}\Programs\LiquidLauncher\LiquidLauncher.exe'));
end;

procedure BackupExistingJar;
var
  ExistingJar: string;
  BackupJar: string;
begin
  ExistingJar := GetModsFolder('') + '\LiquidBounce.jar';
  BackupJar := GetModsFolder('') + '\LiquidBounce-official-backup.jar';

  if FileExists(ExistingJar) and not FileExists(BackupJar) then
  begin
    RenameFile(ExistingJar, BackupJar);
    Log('Backed up existing LiquidBounce.jar to: ' + BackupJar);
  end;
end;

function InitializeSetup(): Boolean;
var
  LiquidLauncherPath: string;
  DefaultMCPath: string;
begin
  LiquidLauncherPath := ExpandConstant('{userappdata}\CCBlueX\LiquidLauncher\data\gameDir\nextgen\mods');
  DefaultMCPath := ExpandConstant('{userappdata}\.minecraft\mods');

  if DirExists(LiquidLauncherPath) then
    Log('Detected LiquidLauncher mods folder: ' + LiquidLauncherPath)
  else if DirExists(DefaultMCPath) then
    Log('Detected default .minecraft mods folder: ' + DefaultMCPath)
  else
    Log('No existing mods folder detected. Will create one after LiquidLauncher install: ' + LiquidLauncherPath);

  Result := True;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  Memo: string;
  LauncherStatus: string;
begin
  Memo := 'Installation Summary:' + NewLine + NewLine;

  Memo := Memo + '  Install Location:' + NewLine;
  Memo := Memo + '    ' + ExpandConstant('{localappdata}\LiquidBounceBoosted') + NewLine + NewLine;

  Memo := Memo + '  Mods Folder (auto-detected):' + NewLine;
  Memo := Memo + '    ' + GetModsFolder('') + NewLine + NewLine;

  if ShouldInstallLauncher() then
    LauncherStatus := 'Will install (official CCBlueX v0.6.1)'
  else
    LauncherStatus := 'Already installed - skipping';

  Memo := Memo + '  LiquidLauncher:' + NewLine;
  Memo := Memo + '    ' + LauncherStatus + NewLine + NewLine;

  Memo := Memo + '  Components to Install:' + NewLine;
  Memo := Memo + '    - LiquidLauncher (official CCBlueX)' + NewLine;
  Memo := Memo + '    - Boosted LiquidBounce.jar (MrTramble edition)' + NewLine;
  Memo := Memo + '    - Fabric API' + NewLine;
  Memo := Memo + '    - Fabric Kotlin' + NewLine;
  Memo := Memo + '    - Mod Menu, Sodium, Lithium' + NewLine;
  Memo := Memo + '    - ViaFabricPlus, ExploitPreventer, ImmediatelyFast' + NewLine + NewLine;

  Memo := Memo + '  Desktop Shortcuts:' + NewLine;
  Memo := Memo + '    - LiquidBounce Boosted (one-click launch)' + NewLine;
  Memo := Memo + '    - Refresh Boosted JAR (re-apply if launcher overwrites)' + NewLine + NewLine;

  Memo := Memo + 'IMPORTANT: After install, disable auto-update in LiquidLauncher' + NewLine;
  Memo := Memo + 'settings to prevent the launcher from replacing the boosted JAR.' + NewLine;

  Result := Memo;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ModsDir: string;
begin
  if CurStep = ssPostInstall then
  begin
    ModsDir := GetModsFolder('');
    if not DirExists(ModsDir) then
    begin
      Log('Creating mods folder: ' + ModsDir);
      CreateDir(ModsDir);
    end;
  end;
end;
