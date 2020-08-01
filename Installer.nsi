;xPilot Installer
;--------------------------------
;Include Modern UI

!include "MUI2.nsh"

; We want to stamp the version of the installer into its exe name.
; We will get the version number from the app itself.
!system "ExtractVersionInfo.exe"
!include "Version.txt"

!include "x64.nsh"

;--------------------------------
;Configuration

;General

var DATAINSTDIR

Name "xPilot"
BrandingText "xPilot"
OutFile ".\Output\xPilot-Setup-${Version}.exe"
InstallDir "$LOCALAPPDATA\xPilot"

;--------------------------------
;Modern UI Configuration

!define MUI_ABORTWARNING

;--------------------------------
;Pages

!define MUI_WELCOMEPAGE_TEXT "This installer will guide you through the installation of xPilot."
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS

!define MUI_DIRECTORYPAGE_VARIABLE $DATAINSTDIR
!define MUI_PAGE_HEADER_TEXT "xPilot Plugin Installation"
!define MUI_PAGE_HEADER_SUBTEXT "Choose your root X-Plane folder"
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "X-Plane Root Folder"
!define MUI_DIRECTORYPAGE_TEXT_TOP "Please locate the root folder of your X-Plane installation. This is the same folder where the X-Plane executable lives."
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckXPlaneDirectory
!insertmacro MUI_PAGE_DIRECTORY

!define MUI_PAGE_HEADER_TEXT "xPilot Pilot Client Installation"
!define MUI_PAGE_HEADER_SUBTEXT "Choose folder to install xPilot pilot client"
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "xPilot Pilot Client Install Location"
!define MUI_DIRECTORYPAGE_TEXT_TOP "The setup will install the xPilot Pilot Client in the following folder. It is recommended you leave it set to the local application data folder to prevent permission issues. To install in a different folder, click Browse and select another folder."	
!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN "$INSTDIR\xPilot.exe"
!define MUI_FINISHPAGE_RUN_CHECKED
!define MUI_FINISHPAGE_RUN_TEXT "Start xPilot"
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages

!insertmacro MUI_LANGUAGE "English"

;---------------------------------
;Function

Function CheckXPlaneDirectory
IfFileExists $DATAINSTDIR\X-Plane.exe found not_found
	not_found:
	MessageBox MB_YESNO "The location you specified doesn't appear to be a valid X-Plane root folder. The root folder should be the location of X-Plane.exe. This can prevent the required plugin from being installed correctly. Do you want to continue anyways?" IDYES true IDNO false
	true:
	goto found
	false:
	Abort
	found:
FunctionEnd

Function .onInit
	;set client install location
	Push $INSTDIR
	ReadRegStr $INSTDIR HKLM "Software\xPilot" "Client"
	StrCmp $INSTDIR "" 0 +2
	Pop $INSTDIR
	
	;set xplane root folder
	Push $DATAINSTDIR
	ReadRegStr $DATAINSTDIR HKLM "Software\xPilot" "XPlane"
	StrCmp $DATAINSTDIR "" 0 +2
	Pop $DATAINSTDIR
FunctionEnd

;--------------------------------
;Installer Sections

Section "xPilot Plugin" SecCopyPlugin

SectionIn RO

SetOutPath "$DATAINSTDIR\Resources\plugins\xPilot"

File /r ".\Plugin\*"

SetOutPath "$DATAINSTDIR\Resources\plugins\xPilot\win_x64"

File /r "..\Plugin\build\x64\Release\win_x64\xPilot.xpl"

WriteRegStr HKLM "Software\xPilot" "XPlane" $DATAINSTDIR

SectionEnd

Section "xPilot Pilot Client" SecCopyUI

SectionIn RO

SetOutPath "$INSTDIR"

Delete "$INSTDIR\*.dll"
Delete "$INSTDIR\*.pdb"
Delete "$INSTDIR\*.exe"
Delete "$INSTDIR\AppConfig.xml"

File /r "..\Pilot-Client\bin\Release\*"

File /r ".\Sounds"

File "Vatsim.Fsd.ClientAuth.dll"

WriteUninstaller "$INSTDIR\Uninstall.exe"

WriteRegStr HKLM "Software\xPilot" "Client" $INSTDIR

SectionEnd

Section "Start Menu Shortcuts" MenuShortcuts
	# Start Menu
	createDirectory "$SMPROGRAMS\xPilot"
	createShortCut "$SMPROGRAMS\xPilot\xPilot.lnk" "$INSTDIR\xPilot.exe"
	createShortCut "$SMPROGRAMS\xPilot\Uninstall xPilot.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Desktop Shortcut" DesktopShortcut
    # Desktop Shortcut
    CreateShortcut "$desktop\xPilot.lnk" "$INSTDIR\xPilot.exe"
SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

Delete "$SMPROGRAMS\xPilot\xPilot.lnk"
Delete "$SMPROGRAMS\xPilot\Uninstall xPilot.lnk"
Delete "$DESKTOP\xPilot.lnk"
RMDir "$SMPROGRAMS\xPilot"
RMDir /r "$INSTDIR"

SectionEnd