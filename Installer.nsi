;xPilot Installer
;--------------------------------

Unicode True

!include MUI2.nsh
!include x64.nsh
!include LogicLib.nsh
!include WordFunc.nsh
!include StrFunc.nsh

!system "GetProductVersion.exe"
!include "Version.txt"

Var _PluginDir
${StrRep}

;--------------------------------

Name "xPilot"
BrandingText "xPilot v${Version}"
OutFile ".\Output\xPilot-Setup-${Version}.exe"
InstallDir "$LOCALAPPDATA\xPilot"

;--------------------------------
;Pages

!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TEXT "This program will guide you through the installation of xPilot.$\r$\n$\r$\nxPilot and X-Plane must be closed before continuing."
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

!define MUI_WELCOMEPAGE_TEXT "This program will uninstall the xPilot Pilot Client and the xPilot plugin from all X-Plane installations on this computer.$\r$\n$\r$\n** NOTICE ** CSL models installed in Resources\plugins\xPilot\Resources\CSL will be deleted."
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

;---------------------------------
;Function

Function .onInit  
	Push $INSTDIR
	ReadRegStr $INSTDIR HKLM "Software\xPilot" "Client"
	StrCmp $INSTDIR "" 0 +2
	Pop $INSTDIR
FunctionEnd

;--------------------------------
;Installer Sections

Function TrimLineFeed
	Exch $R1 ; Original string
	Push $R2
Loop:
	StrCpy $R2 "$R1" 1
	StrCmp "$R2" " " TrimLeft
	StrCmp "$R2" "$\r" TrimLeft
	StrCmp "$R2" "$\n" TrimLeft
	StrCmp "$R2" "$\t" TrimLeft
	GoTo Loop2
TrimLeft:	
	StrCpy $R1 "$R1" "" 1
	Goto Loop
Loop2:
	StrCpy $R2 "$R1" 1 -1
	StrCmp "$R2" " " TrimRight
	StrCmp "$R2" "$\r" TrimRight
	StrCmp "$R2" "$\n" TrimRight
	StrCmp "$R2" "$\t" TrimRight
	GoTo Done
TrimRight:	
	StrCpy $R1 "$R1" -1
	Goto Loop2
Done:
	Pop $R2
	Exch $R1
FunctionEnd

Function CopyPlugin
${If} $_PluginDir != ""
    IfFileExists "$_PluginDir\Resources\*.*" Valid Invalid
    Valid:
        DetailPrint "Valid X-Plane Path Found: $_PluginDir"
        
        SetOutPath "$_PluginDir\Resources\plugins\xPilot\Resources"
        DetailPrint "Copying Resources..."
        File /r ".\Plugin\Resources\*"
        
        SetOutPath "$_PluginDir\Resources\plugins\xPilot\win_x64"
        DetailPrint "Copying Plugin..."
        File "..\Plugin\build\x64\Release\win_x64\xPilot.pdb"
        File "..\Plugin\build\x64\Release\win_x64\xPilot.xpl"
    Invalid:
${EndIf}
FunctionEnd

Section "xPilot Plugin" Section_Plugin

SectionIn RO

FileOpen $0 "$LOCALAPPDATA\x-plane_install_11.txt" "r"
loop:
    FileRead $0 $1
    StrCmp $1 "" eof parse
parse:
    Push $1
    Call TrimLineFeed ; remove trailing line feeds
    Pop $R0
    ${StrRep} $R1 $R0 "/" "\" ; replace slashes
    Goto check
check:
    StrCpy $R2 $R1 1 -1 ; get last character
    StrCmp $R2 "\" trim done ; if slash, goto trim
trim:
    StrCpy $R1 $R1 -1 ; copy all but last character
    Goto check
done:
    StrCpy $_PluginDir $R1
    Call CopyPlugin
    Goto loop
eof:
    FileClose $0

SectionEnd

Section "xPilot Pilot Client" SecCopyUI

SectionIn RO

SetOutPath "$INSTDIR"

Delete "$INSTDIR\AppConfig.xml" ; remove legacy configuration file

File "..\Pilot-Client\bin\Release\Appccelerate.EventBroker.dll"
File "..\Pilot-Client\bin\Release\Appccelerate.EventBroker.xml"
File "..\Pilot-Client\bin\Release\AsyncIO.dll"
File "..\Pilot-Client\bin\Release\AsyncIO.pdb"
File "..\Pilot-Client\bin\Release\Castle.Core.dll"
File "..\Pilot-Client\bin\Release\Castle.Core.xml"
File "..\Pilot-Client\bin\Release\GeoVR.Client.dll"
File "..\Pilot-Client\bin\Release\GeoVR.Client.pdb"
File "..\Pilot-Client\bin\Release\GeoVR.Connection.dll"
File "..\Pilot-Client\bin\Release\GeoVR.Connection.pdb"
File "..\Pilot-Client\bin\Release\GeoVR.Shared.dll"
File "..\Pilot-Client\bin\Release\GeoVR.Shared.pdb"
File "..\Pilot-Client\bin\Release\Gma.System.MouseKeyHook.dll"
File "..\Pilot-Client\bin\Release\KeyMouseHook.dll"
File "..\Pilot-Client\bin\Release\MessagePack.CryptoDto.dll"
File "..\Pilot-Client\bin\Release\MessagePack.CryptoDto.pdb"
File "..\Pilot-Client\bin\Release\NaCl.Core.dll"
File "..\Pilot-Client\bin\Release\NaCl.Core.pdb"
File "..\Pilot-Client\bin\Release\NaCl.dll"
File "..\Pilot-Client\bin\Release\NaCl.xml"
File "..\Pilot-Client\bin\Release\NAudio.dll"
File "..\Pilot-Client\bin\Release\NAudio.xml"
File "..\Pilot-Client\bin\Release\NetMQ.dll"
File "..\Pilot-Client\bin\Release\NetMQ.xml"
File "..\Pilot-Client\bin\Release\Newtonsoft.Json.dll"
File "..\Pilot-Client\bin\Release\Newtonsoft.Json.xml"
File "..\Pilot-Client\bin\Release\Ninject.dll"
File "..\Pilot-Client\bin\Release\Ninject.Extensions.Factory.dll"
File "..\Pilot-Client\bin\Release\Ninject.Extensions.Factory.xml"
File "..\Pilot-Client\bin\Release\Ninject.xml"
File "..\Pilot-Client\bin\Release\RestSharp.dll"
File "..\Pilot-Client\bin\Release\RestSharp.xml"
File "..\Pilot-Client\bin\Release\SevenZipSharp.dll"
File "..\Pilot-Client\bin\Release\SevenZipSharp.pdb"
File "..\Pilot-Client\bin\Release\SharpDX.DirectInput.dll"
File "..\Pilot-Client\bin\Release\SharpDX.DirectInput.pdb"
File "..\Pilot-Client\bin\Release\SharpDX.DirectInput.xml"
File "..\Pilot-Client\bin\Release\SharpDX.dll"
File "..\Pilot-Client\bin\Release\SharpDX.pdb"
File "..\Pilot-Client\bin\Release\System.Buffers.dll"
File "..\Pilot-Client\bin\Release\System.Memory.dll"
File "..\Pilot-Client\bin\Release\System.Numerics.Vectors.dll"
File "..\Pilot-Client\bin\Release\System.Runtime.CompilerServices.Unsafe.dll"
File "..\Pilot-Client\bin\Release\Vatsim.Fsd.Connector.dll"
File "..\Pilot-Client\bin\Release\Vatsim.Fsd.Connector.pdb"
File "..\Pilot-Client\bin\Release\xPilot.exe"
File "..\Pilot-Client\bin\Release\xPilot.exe.config"
File "..\Pilot-Client\bin\Release\xPilot.pdb"
File "..\Pilot-Client\bin\Release\XPlaneConnector.dll"

File "Vatsim.Fsd.ClientAuth.dll"
File "7zxa.dll"

SetOutPath "$INSTDIR\Sounds"
File "Sounds\Alert.wav"
File "Sounds\Broadcast.wav"
File "Sounds\Buzzer.wav"
File "Sounds\DirectRadioMessage.wav"
File "Sounds\Error.wav"
File "Sounds\NewMessage.wav"
File "Sounds\PrivateMessage.wav"
File "Sounds\RadioMessage.wav"
File "Sounds\SelCal.wav"

SetOutPath "$INSTDIR\Plugin"
File "..\Plugin\build\x64\Release\win_x64\xPilot.pdb"
File "..\Plugin\build\x64\Release\win_x64\xPilot.xpl"

WriteUninstaller "$INSTDIR\Uninstall.exe"
WriteRegStr HKLM "Software\xPilot" "Client" $INSTDIR

SectionEnd

Section "Start Menu Shortcuts" MenuShortcuts
	createDirectory "$SMPROGRAMS\xPilot"
	createShortCut "$SMPROGRAMS\xPilot\xPilot.lnk" "$INSTDIR\xPilot.exe"
	createShortCut "$SMPROGRAMS\xPilot\Uninstall xPilot.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Desktop Shortcut" DesktopShortcut
    CreateShortcut "$desktop\xPilot.lnk" "$INSTDIR\xPilot.exe"
SectionEnd

;--------------------------------
;Uninstaller Section

${UnStrRep}

Function un.DeleteDirIfEmpty
  FindFirst $R0 $R1 "$0\*.*"
  strcmp $R1 "." 0 NoDelete
   FindNext $R0 $R1
   strcmp $R1 ".." 0 NoDelete
    ClearErrors
    FindNext $R0 $R1
    IfErrors 0 NoDelete
     FindClose $R0
     Sleep 1000
     RMDir "$0"
  NoDelete:
   FindClose $R0
FunctionEnd

Function un.DeletePlugin
${IF} $_PluginDir != ""
    RMDir /r "$_PluginDir\Resources\plugins\xPilot"
${ENDIF}
FunctionEnd

Function un.TrimLineFeed
	Exch $R1 ; Original string
	Push $R2
Loop:
	StrCpy $R2 "$R1" 1
	StrCmp "$R2" " " TrimLeft
	StrCmp "$R2" "$\r" TrimLeft
	StrCmp "$R2" "$\n" TrimLeft
	StrCmp "$R2" "$\t" TrimLeft
	GoTo Loop2
TrimLeft:	
	StrCpy $R1 "$R1" "" 1
	Goto Loop
Loop2:
	StrCpy $R2 "$R1" 1 -1
	StrCmp "$R2" " " TrimRight
	StrCmp "$R2" "$\r" TrimRight
	StrCmp "$R2" "$\n" TrimRight
	StrCmp "$R2" "$\t" TrimRight
	GoTo Done
TrimRight:	
	StrCpy $R1 "$R1" -1
	Goto Loop2
Done:
	Pop $R2
	Exch $R1
FunctionEnd

Section "Uninstall"

FileOpen $0 "$LOCALAPPDATA\x-plane_install_11.txt" "r"
loop:
    FileRead $0 $1
    StrCmp $1 "" eof parse
parse:
    Push $1
    Call un.TrimLineFeed ; remove trailing line feeds
    Pop $R0
    ${UnStrRep} $R1 $R0 "/" "\" ; replace slashes
    Goto check
check:
    StrCpy $R2 $R1 1 -1 ; get last character
    StrCmp $R2 "\" trim done ; if slash, goto trim
trim:
    StrCpy $R1 $R1 -1 ; copy all but last character
    Goto check
done:
    StrCpy $_PluginDir $R1
    Call un.DeletePlugin
    Goto loop
eof:
    FileClose $0

Delete "$SMPROGRAMS\xPilot\xPilot.lnk"
Delete "$SMPROGRAMS\xPilot\Uninstall xPilot.lnk"
Delete "$DESKTOP\xPilot.lnk"
RMDir  "$SMPROGRAMS\xPilot"

Delete "$INSTDIR\Appccelerate.EventBroker.dll"
Delete "$INSTDIR\Appccelerate.EventBroker.xml"
Delete "$INSTDIR\AsyncIO.dll"
Delete "$INSTDIR\AsyncIO.pdb"
Delete "$INSTDIR\Castle.Core.dll"
Delete "$INSTDIR\Castle.Core.xml"
Delete "$INSTDIR\GeoVR.Client.dll"
Delete "$INSTDIR\GeoVR.Client.pdb"
Delete "$INSTDIR\GeoVR.Connection.dll"
Delete "$INSTDIR\GeoVR.Connection.pdb"
Delete "$INSTDIR\GeoVR.Shared.dll"
Delete "$INSTDIR\GeoVR.Shared.pdb"
Delete "$INSTDIR\Gma.System.MouseKeyHook.dll"
Delete "$INSTDIR\KeyMouseHook.dll"
Delete "$INSTDIR\MessagePack.CryptoDto.dll"
Delete "$INSTDIR\MessagePack.CryptoDto.pdb"
Delete "$INSTDIR\NaCl.Core.dll"
Delete "$INSTDIR\NaCl.Core.pdb"
Delete "$INSTDIR\NaCl.dll"
Delete "$INSTDIR\NaCl.xml"
Delete "$INSTDIR\NAudio.dll"
Delete "$INSTDIR\NAudio.xml"
Delete "$INSTDIR\NetMQ.dll"
Delete "$INSTDIR\NetMQ.xml"
Delete "$INSTDIR\Newtonsoft.Json.dll"
Delete "$INSTDIR\Newtonsoft.Json.xml"
Delete "$INSTDIR\Ninject.dll"
Delete "$INSTDIR\Ninject.Extensions.Factory.dll"
Delete "$INSTDIR\Ninject.Extensions.Factory.xml"
Delete "$INSTDIR\Ninject.xml"
Delete "$INSTDIR\RestSharp.dll"
Delete "$INSTDIR\RestSharp.xml"
Delete "$INSTDIR\SevenZipSharp.dll"
Delete "$INSTDIR\SevenZipSharp.pdb"
Delete "$INSTDIR\SharpDX.DirectInput.dll"
Delete "$INSTDIR\SharpDX.DirectInput.pdb"
Delete "$INSTDIR\SharpDX.DirectInput.xml"
Delete "$INSTDIR\SharpDX.dll"
Delete "$INSTDIR\SharpDX.pdb"
Delete "$INSTDIR\System.Buffers.dll"
Delete "$INSTDIR\System.Memory.dll"
Delete "$INSTDIR\System.Numerics.Vectors.dll"
Delete "$INSTDIR\System.Runtime.CompilerServices.Unsafe.dll"
Delete "$INSTDIR\Vatsim.Fsd.Connector.dll"
Delete "$INSTDIR\Vatsim.Fsd.Connector.pdb"
Delete "$INSTDIR\xPilot.exe"
Delete "$INSTDIR\xPilot.exe.config"
Delete "$INSTDIR\xPilot.pdb"
Delete "$INSTDIR\XPlaneConnector.dll"

Delete "$INSTDIR\Vatsim.Fsd.ClientAuth.dll"
Delete "$INSTDIR\7zxa.dll"
Delete "$INSTDIR\AppConfig.json"
Delete "$INSTDIR\TypeCodes.json"
Delete "$INSTDIR\Bluebell.7z"

RMDir /r "$INSTDIR\NetworkLogs"
RMDir /r "$INSTDIR\PluginLogs"
RMDir /r "$INSTDIR\Sounds"
RMDir /r "$INSTDIR\Plugin"

Delete "$INSTDIR\Uninstall.exe"

StrCpy $0 "$INSTDIR"
Call un.DeleteDirIfEmpty

SectionEnd