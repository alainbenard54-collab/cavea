; Cavea — Installateur Windows
; Script Inno Setup 6.x
;
; AVANT DE COMPILER :
;   1. Exécuter depuis la racine du projet :
;        flutter build windows --release
;   2. Ouvrir ce fichier dans Inno Setup Compiler (menu File > Open)
;   3. Compiler : Build > Compile  (ou Ctrl+F9)
;   → Le fichier CaveaSetup-x.y.z.exe est créé dans installer\output\
;
; POUR UNE NOUVELLE VERSION :
;   1. Mettre à jour MyAppVersion ci-dessous
;   2. Mettre à jour la version dans pubspec.yaml (même valeur)
;   3. flutter build windows --release
;   4. Recompiler ce script

#define MyAppName      "Cavea"
#define MyAppVersion   "0.1.0"
#define MyAppPublisher "Alain Benard"
#define MyAppURL       "https://github.com/alainbenard54-collab/cavea"
#define MyAppExeName   "cavea.exe"

[Setup]
; AppId : identifiant unique de l'installation Windows.
; IMPORTANT : ne jamais modifier après la première diffusion publique.
; Windows s'en sert pour détecter une installation existante à mettre à jour.
AppId={{6F3E8A4B-2C1D-4E7F-9A5B-3D0C8F962BA7}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=output
OutputBaseFilename=CaveaSetup-{#MyAppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; Windows 10 minimum (exigence Flutter desktop)
MinVersion=10.0
; 64 bits uniquement (Flutter Windows = x64)
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible
; Licence affichée à l'utilisateur pendant l'installation
LicenseFile=..\LICENSE
; Icône dans Ajout/Suppression de programmes
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
; SourceDir = racine du projet (un niveau au-dessus de installer/)
SourceDir=..

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "Créer une icône sur le &Bureau"; GroupDescription: "Icônes supplémentaires :"

[Files]
; Tout le contenu du build Flutter Release (exe + DLL Flutter/Windows + données)
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Lancer {#MyAppName}"; Flags: nowait postinstall skipifsilent
