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

Function isEmptyDir
  # Stack ->                    # Stack: <directory>
  Exch $0                       # Stack: $0
  Push $1                       # Stack: $1, $0
  FindFirst $0 $1 "$0\*.*"
  strcmp $1 "." 0 _notempty
    FindNext $0 $1
    strcmp $1 ".." 0 _notempty
      ClearErrors
      FindNext $0 $1
      IfErrors 0 _notempty
        FindClose $0
        Pop $1                  # Stack: $0
        StrCpy $0 1
        Exch $0                 # Stack: 1 (true)
        goto _end
     _notempty:
       FindClose $0
       ClearErrors
       Pop $1                   # Stack: $0
       StrCpy $0 0
       Exch $0                  # Stack: 0 (false)
  _end:
FunctionEnd

Function Trim
Push $R1
Loop:
    StrCpy $R2 $R1 1 -1
    StrCmp $R2 "\" TrimRight
    Goto Done
TrimRight:
    StrCpy $R1 $R1 -1
    Goto Loop
Done:
    DetailPrint $R1
FunctionEnd

Function CopyPlugin
    ;StrCpy $1 $_PluginDir "" -1
    ;StrCmp $1 "\" 0 +2
    ;StrCpy $_PluginDir $_PluginDir -1
    
    ${If} $R0 != ""
    
    ${EndIf}
    
    ;${WordReplace} $R1 "\" "" "}*" $R2
    ;${WordReplace} $R0 "/" "\" "+" $R1
    ;${WordReplace} $R1 "\" "" "}*" $R2
    ;${WordReplace} $_PluginDir "/" "\" "+" $_PluginDir
    ;DetailPrint "--> $R2"
    
    ;${If} ${FileExists} $_PluginDir"\X-Plane.exe"
    ;    MessageBox MB_OK "Exists"
    ;${EndIf}

    ;IfFileExists "$_PluginDir\*.*" 0 +2
    ;    DetailPrint $_PluginDir
        
    ;IfFileExists $_PluginDir\*.* GoodPath BadPath
    ;BadPath:
        
    ;GoodPath:
    ;    DetailPrint "Exists"
    ;    SetOutPath "$_PluginDir\Resources\plugins\xPilot\Resources"
    ;    File /r ".\Plugin\Resources\*"
    ;    
    ;    SetOutPath "$_PluginDir\Resources\plugins\xPilot\win_x64"
    ;    File "..\Plugin\build\x64\Release\win_x64\xPilot.pdb"
    ;    File "..\Plugin\build\x64\Release\win_x64\xPilot.xpl"
FunctionEnd

${StrRep}

Section "xPilot Plugin" Section_Plugin

SectionIn RO

FileOpen $0 "$LOCALAPPDATA\x-plane_install_11.txt" "r"
loop:
    FileRead $0 $1
    StrCmp $1 "" eof parse
parse:
    StrCpy $R0 $1
    ${StrRep} $R1 $R0 "/" "\" ; replace slashes
    DetailPrint "$R0 -> $R1"
    Goto check
check:
    StrCpy $R2 $R1 1 -1 ; get last character
    StrCmp $R2 "\" trim done ; if slash, goto trim
trim:
    StrCpy $R1 $R1 -1 ; copy all but last character
    Goto check
done:
    DetailPrint $R1
    Goto loop
eof:
    FileClose $0

;FileOpen $0 $LOCALAPPDATA\x-plane_install_11.txt r
;loop:
;    FileRead $0 $1
;    StrCmp $1 "" eof clean
;    
;clean:
;    StrCpy $2 $1 1 -1
;    StrCmp $2 "/" trim_right
;    StrCmp $2 "\" trim_right
;    Goto done
;trim_right:
;    StrCpy $1 $1 -1
;    Goto clean
;done:
;    ;DetailPrint $2
;    Goto loop
;
;    ;Push $1
;    ;Push "/"
;    ;Call StrSlash
;    ;Pop $R0
;
;    ;StrCpy $_PluginDir $1
;
;    ;Push $1
;    ;Call Trim
;    ;Pop $R0
;
;    ;DetailPrint $R0
;
;    ;Push $1
;    ;Call CopyPlugin
;
;    ;Goto loop
;eof:
;    FileClose $0

SectionEnd

Section "xPilot Pilot Client" SecCopyUI

SectionIn RO

SetOutPath "$INSTDIR"

Delete "$INSTDIR\*.dll"
Delete "$INSTDIR\*.pdb"
Delete "$INSTDIR\*.exe"
Delete "$INSTDIR\AppConfig.xml"

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

Section "Uninstall"

; delete plugin
FileOpen $0 $LOCALAPPDATA\x-plane_install_11.txt r
LOOP:
IfErrors exit_loop
FileRead $0 $1
    Push $1
    Push "/"
    Call un.StrSlash
    Pop $R0
    
    Push $_PluginDir
    StrCpy $_PluginDir "$R0"
    Call un.DeletePlugin
    Pop $_PluginDir
Goto LOOP
exit_loop:
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

RMDir /r "$INSTDIR\NetworkLogs"
RMDir /r "$INSTDIR\PluginLogs"
RMDir /r "$INSTDIR\Sounds"

Delete "$INSTDIR\Uninstall.exe"

StrCpy $0 "$INSTDIR"
Call un.DeleteDirIfEmpty

SectionEnd