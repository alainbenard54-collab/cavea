; SPDX-License-Identifier: Apache-2.0
; Copyright 2026 Alain Benard
;
; Script Inno Setup — Cavea
;
; Usage local :
;   iscc windows\packaging\cavea.iss
; Output :
;   windows\packaging\output\Cavea-{version}-windows-setup.exe

#define MyAppName      "Cavea"
#define MyAppVersion   "1.0.0"
#define MyAppPublisher "Alain Benard"
#define MyAppURL       "https://github.com/alainbenard54-collab/cavea"
#define MyAppExeName   "cavea.exe"

[Setup]
; AppId : GUID fixe — NE PAS MODIFIER entre les versions (utilisé par Windows pour les mises à jour et la désinstallation)
AppId={{6F3C2A1B-D4E5-4F8A-9B0C-1D2E3F4A5B6C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=..\..\LICENSE
OutputDir=output
OutputBaseFilename=Cavea-{#MyAppVersion}-windows-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; Windows 10 version 1809 (Build 17763) minimum
MinVersion=10.0.17763
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "french";  MessagesFile: "compiler:Languages\French.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; Contenu complet du build Flutter Release (inclut flutter_assets/, data/, dlls...)
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}";                         Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}";   Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}";                   Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Proposé (décoché par défaut) à la fin de l'installation
Filename: "{app}\{#MyAppExeName}"; \
  Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; \
  Flags: nowait postinstall skipifsilent unchecked

[Code]

{ ── Désinstallation : proposer la suppression des données de configuration ── }

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ConfigPath: String;
  Msg: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    { SharedPreferences Flutter Windows → %APPDATA%\Cavea\Cavea }
    ConfigPath := ExpandConstant('{userappdata}\Cavea\Cavea');
    if DirExists(ConfigPath) then
    begin
      Msg :=
        'Voulez-vous supprimer les données de configuration de Cavea ?' + #13#10 +
        '(mode de synchronisation, chemin de la cave, préférences)' + #13#10#13#10 +
        'Note : votre fichier cave.db ne sera pas touché,' + #13#10 +
        'il reste à son emplacement habituel.' + #13#10#13#10 +
        '────────────────────────────────────────' + #13#10#13#10 +
        'Do you want to delete Cavea''s configuration data?' + #13#10 +
        '(sync mode, cellar path, preferences)' + #13#10#13#10 +
        'Note: your cave.db file will not be affected,' + #13#10 +
        'it stays in its usual location.';
      if MsgBox(Msg, mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then
      begin
        DelTree(ConfigPath, True, True, True);
        { Supprime le dossier parent %APPDATA%\Cavea s'il est vide }
        RemoveDir(ExpandConstant('{userappdata}\Cavea'));
      end;
    end;
  end;
end;
