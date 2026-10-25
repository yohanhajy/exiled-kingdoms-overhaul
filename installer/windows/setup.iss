; ==============================================================================
; Exiled Kingdoms Overhaul — Official Windows Inno Setup Script
; Generates a professional, trusted Windows installer (Setup.exe)
; ==============================================================================

#define MyAppName "Exiled Kingdoms Overhaul"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Exiled Kingdoms Overhaul Team"
#define MyAppURL "https://github.com/yohanhajy/exiled-kingdoms-overhaul"

[Setup]
AppId={{5E06DD3B-769A-40C2-ABF6-8BE3977927A3}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={code:GetDefaultSteamPath}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
DirExistsWarning=no
EnableDirDoesntExistWarning=yes
PrivilegesRequired=lowest
OutputDir=..\..\release
OutputBaseFilename=ExiledKingdomsOverhaul-Setup-v{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName={#MyAppName} v{#MyAppVersion}
UninstallDisplayIcon={app}\exiledkingdoms.exe
CreateUninstallRegKey=yes

[Languages]
Name: "portuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
portuguese.WelcomeLabel2=Este assistente instalará o mod {#MyAppName} v{#MyAppVersion} no seu jogo Exiled Kingdoms na Steam.%n%nMelhorias inclusas:%n• Movimento Suave e Contínuo em 360°%n• Visual Exclusivo de Armaduras e Escudos Coloridos%n• Correção Anatômica de Escudos e Armas%n• Instalação 100%% Segura e Não-Destrutiva (sem alterar arquivos originais)
english.WelcomeLabel2=This wizard will install the {#MyAppName} v{#MyAppVersion} mod into your Exiled Kingdoms game on Steam.%n%nFeatures included:%n• Smooth 360° Continuous Movement%n• Colored Armor and Shield Custom Sprites%n• Anatomical Weapon & Offhand Visual Fixes%n• 100%% Safe & Non-Destructive Modding (vanilla JAR left untouched)

[Files]
Source: "..\..\mods\*"; DestDir: "{app}\mods"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\README.md"; DestDir: "{app}"; DestName: "MOD_README.txt"; Flags: ignoreversion

[Code]
// Helper function to resolve Steam installation path from Windows Registry
function GetDefaultSteamPath(Param: String): String;
var
  SteamPath: String;
  GamePath: String;
begin
  // 1. Try Current User Registry (Standard for modern Windows Steam clients)
  if RegQueryStringValue(HKEY_CURRENT_USER, 'Software\Valve\Steam', 'SteamPath', SteamPath) then
  begin
    GamePath := SteamPath + '\steamapps\common\Exiled Kingdoms';
    StringChange(GamePath, '/', '\');
    if FileExists(GamePath + '\exiledkingdoms.jar') then
    begin
      Result := GamePath;
      Exit;
    end;
  end;

  // 2. Try 64-bit / 32-bit Local Machine Registry
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Valve\Steam', 'InstallPath', SteamPath) or
     RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\Valve\Steam', 'InstallPath', SteamPath) then
  begin
    GamePath := SteamPath + '\steamapps\common\Exiled Kingdoms';
    StringChange(GamePath, '/', '\');
    if FileExists(GamePath + '\exiledkingdoms.jar') then
    begin
      Result := GamePath;
      Exit;
    end;
  end;

  // 3. Common Drive Paths Fallback
  if FileExists('C:\Program Files (x86)\Steam\steamapps\common\Exiled Kingdoms\exiledkingdoms.jar') then
  begin
    Result := 'C:\Program Files (x86)\Steam\steamapps\common\Exiled Kingdoms';
    Exit;
  end;

  if FileExists('D:\SteamLibrary\steamapps\common\Exiled Kingdoms\exiledkingdoms.jar') then
  begin
    Result := 'D:\SteamLibrary\steamapps\common\Exiled Kingdoms';
    Exit;
  end;

  // Default path suggestion if not yet installed in a standard location
  Result := 'C:\Program Files (x86)\Steam\steamapps\common\Exiled Kingdoms';
end;

// Validation on directory page
function NextButtonClick(CurPageID: Integer): Boolean;
var
  JarFile: String;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    JarFile := ExpandConstant('{app}\exiledkingdoms.jar');
    if not FileExists(JarFile) then
    begin
      if MsgBox('Aviso: O arquivo "exiledkingdoms.jar" não foi encontrado nesta pasta:' + #13#10#13#10 +
                ExpandConstant('{app}') + #13#10#13#10 +
                'Tem certeza de que selecionou a pasta correta da Steam onde o Exiled Kingdoms está instalado?' + #13#10#13#10 +
                'Deseja prosseguir mesmo assim?',
                mbConfirmation, MB_YESNO) = IDNO then
      begin
        Result := False;
      end;
    end;
  end;
end;

// Post-installation: Safe, non-destructive config.json patching
procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigFile: String;
  BackupFile: String;
  ConfigContent: AnsiString;
  ConfigStr: String;
  TargetStr: String;
  ReplacementStr: String;
begin
  if CurStep = ssPostInstall then
  begin
    ConfigFile := ExpandConstant('{app}\config.json');
    BackupFile := ExpandConstant('{app}\config.json.bak');

    if FileExists(ConfigFile) then
    begin
      // 1. Create clean backup if not present
      if not FileExists(BackupFile) then
      begin
        CopyFile(ConfigFile, BackupFile, True);
      end;

      // 2. Read config.json
      if LoadStringFromFile(ConfigFile, ConfigContent) then
      begin
        ConfigStr := String(ConfigContent);
        // Only inject if not already present
        if Pos('"mods/"', ConfigStr) = 0 then
        begin
          TargetStr := '"exiledkingdoms.jar"';
          ReplacementStr := '"mods/",' + #13#10 + '    "exiledkingdoms.jar"';
          StringChange(ConfigStr, TargetStr, ReplacementStr);
          ConfigContent := AnsiString(ConfigStr);
          SaveStringToFile(ConfigFile, ConfigContent, False);
        end;
      end;
    end;
  end;
end;

// Uninstallation: Clean reversion to 100% vanilla
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ConfigFile: String;
  BackupFile: String;
  ModsDir: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    ConfigFile := ExpandConstant('{app}\config.json');
    BackupFile := ExpandConstant('{app}\config.json.bak');
    ModsDir := ExpandConstant('{app}\mods');

    // 1. Restore pristine config.json
    if FileExists(BackupFile) then
    begin
      CopyFile(BackupFile, ConfigFile, False);
      DeleteFile(BackupFile);
    end;

    // 2. Remove injected mods directory completely
    if DirExists(ModsDir) then
    begin
      DelTree(ModsDir, True, True, True);
    end;
  end;
end;
