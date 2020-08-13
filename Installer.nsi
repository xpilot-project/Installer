;xPilot Installer
;--------------------------------
;Include Modern UI

!include "MUI2.nsh"

; We want to stamp the version of the installer into its exe name.
; We will get the version number from the app itself.
!system "GetProductVersion.exe"
!include "Version.txt"

!include "x64.nsh"

;--------------------------------
;Configuration

;General

Name "xPilot"
BrandingText "xPilot v${Version}"
OutFile ".\Output\xPilot-Setup-${Version}.exe"
InstallDir "$LOCALAPPDATA\xPilot"

;--------------------------------
;Modern UI Configuration

!define MUI_ABORTWARNING

;--------------------------------
;Pages

!define MUI_WELCOMEPAGE_TEXT "This program will guide you through the installation of xPilot."
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS

!define MUI_PAGE_HEADER_TEXT "xPilot Pilot Client Installation"
!define MUI_PAGE_HEADER_SUBTEXT "Choose folder to install the xPilot Pilot Client"
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "xPilot Pilot Client Install Location"
!define MUI_DIRECTORYPAGE_TEXT_TOP "The setup will install the xPilot Pilot Client in the following folder.$\r$\n$\r$\nIt is recommended you leave it set to the local application data folder to prevent permission issues.$\r$\n$\r$\nTo install in a different folder, click Browse and select another folder."	
!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN "$INSTDIR\xPilot.exe"
!define MUI_FINISHPAGE_RUN_CHECKED
!define MUI_FINISHPAGE_RUN_TEXT "Start xPilot"
!insertmacro MUI_PAGE_FINISH

!define MUI_WELCOMEPAGE_TEXT "This program will uninstall the xPilot Pilot Client and the xPilot plugin from all X-Plane installations on this computer.$\r$\n$\r$\n** IMPORTANT ** CSL models installed in Resources\plugins\xPilot\Resources\CSL will be deleted."
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages

!insertmacro MUI_LANGUAGE "English"

;---------------------------------
;Function

Function CheckXplaneRunning
  FindProcDLL::FindProc "X-Plane.exe"
  IntCmp $R0 1 do_abort proceed proceed
do_abort:
  MessageBox MB_OK|MB_ICONEXCLAMATION "You must close X-Plane before installing."
  Abort
proceed:
  Return
FunctionEnd

Function StrSlash
  Exch $R3 ; $R3 = needle ("\" or "/")
  Exch
  Exch $R1 ; $R1 = String to replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R4 ; $R4 = not $R3 ("/" or "\")
  Push $R6
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R6 $R1
  StrCpy $R4 "\"
  StrCmp $R3 "/" loop
  StrCpy $R4 "/"  
loop:
  StrCpy $R7 $R1 1
  StrCpy $R1 $R1 $R6 1
  StrCmp $R7 $R3 found
  StrCpy $R2 "$R2$R7"
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R4
  Pop $R2
  Pop $R1
  Exch $R3
FunctionEnd

Function un.StrSlash
  Exch $R3 ; $R3 = needle ("\" or "/")
  Exch
  Exch $R1 ; $R1 = String to replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R4 ; $R4 = not $R3 ("/" or "\")
  Push $R6
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R6 $R1
  StrCpy $R4 "\"
  StrCmp $R3 "/" loop
  StrCpy $R4 "/"  
loop:
  StrCpy $R7 $R1 1
  StrCpy $R1 $R1 $R6 1
  StrCmp $R7 $R3 found
  StrCpy $R2 "$R2$R7"
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R4
  Pop $R2
  Pop $R1
  Exch $R3
FunctionEnd

Function .onInit
    call CheckXplaneRunning
    
	;set client install location
	Push $INSTDIR
	ReadRegStr $INSTDIR HKLM "Software\xPilot" "Client"
	StrCmp $INSTDIR "" 0 +2
	Pop $INSTDIR
FunctionEnd

;--------------------------------
;Installer Sections

Section "xPilot Plugin" SecCopyPlugin

SectionIn RO

FileOpen $0 $LOCALAPPDATA\x-plane_install_11.txt r
 LOOP:
  IfErrors exit_loop
  FileRead $0 $1
  
  ; Replace slashes
  Push $1
  Push "/"
  Call StrSlash
  Pop $R0
  
  ; If path is not empty, copy plugin files
  ${If} $R0 != ""
  SetOutPath $R0"\Resources\plugins\xPilot"
  File /r ".\Plugin\*"
  
  SetOutPath $R0"\Resources\plugins\xPilot\win_x64"
  File "..\Plugin\build\x64\Release\win_x64\xPilot.xpl"
  File "..\Plugin\build\x64\Release\win_x64\xPilot.pdb"
  ${EndIf}
Goto LOOP
  exit_loop:
FileClose $0

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
File "7zxa.dll"

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

; delete plugin
FileOpen $0 $LOCALAPPDATA\x-plane_install_11.txt r
 LOOP:
  IfErrors exit_loop
  FileRead $0 $1
  
  ; Replace slashes
  Push $1
  Push "/"
  Call un.StrSlash
  Pop $R0
  
  ${If} $R0 != ""
  RMDir /r $R0"\Resources\plugins\xPilot"
  ${EndIf}
Goto LOOP
  exit_loop:
FileClose $0

Delete "$SMPROGRAMS\xPilot\xPilot.lnk"
Delete "$SMPROGRAMS\xPilot\Uninstall xPilot.lnk"
Delete "$DESKTOP\xPilot.lnk"
RMDir "$SMPROGRAMS\xPilot"
RMDir /r "$INSTDIR"

SectionEnd