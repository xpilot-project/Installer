;xPilot Installer
;--------------------------------

Unicode True

!include MUI2.nsh
!include x64.nsh
!include LogicLib.nsh
!include StrFunc.nsh

!system "GetProductVersion.exe"
!include "Version.txt"

;--------------------------------

Name "xPilot"
BrandingText "xPilot v${Version}"
OutFile ".\Output\xPilot-Setup-${Version}.exe"
InstallDir "$LOCALAPPDATA\xPilot"
RequestExecutionLevel Admin

Var XPLANE_PATH
Var XPLANE_PATH_TEMP

;--------------------------------
;Pages

!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TEXT "This program will guide you through the installation of xPilot.$\r$\n$\r$\nxPilot and X-Plane must be closed before continuing."
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_COMPONENTS

!define MUI_PAGE_HEADER_TEXT "xPilot Pilot Client Installation"
!define MUI_PAGE_HEADER_SUBTEXT "Choose folder to install the xPilot Pilot Client"
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "xPilot Pilot Client Install Location"
!define MUI_DIRECTORYPAGE_TEXT_TOP "The setup will install the xPilot Pilot Client in the following folder.$\r$\n$\r$\nIt is recommended you leave it set to the local application data folder to prevent permission issues.$\r$\n$\r$\nTo install in a different folder, click Browse and select another folder."
!insertmacro MUI_PAGE_DIRECTORY

Page custom pgXplanePath pgXplanePathLeave

!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN "$INSTDIR\xPilot.exe"
!define MUI_FINISHPAGE_RUN_CHECKED
!define MUI_FINISHPAGE_RUN_TEXT "Start xPilot"
!insertmacro MUI_PAGE_FINISH

!define MUI_WELCOMEPAGE_TEXT "This program will uninstall the xPilot Pilot Client. You will need to manually remove the xPilot plugin and its respective resource files from X-Plane."
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

	Push $XPLANE_PATH
	ReadRegStr $XPLANE_PATH HKLM "Software\xPilot" "XPlane"
	StrCmp $XPLANE_PATH "" 0 +2
	Pop $XPLANE_PATH
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

Function pgXplanePath
    !insertmacro MUI_HEADER_TEXT "X-Plane 11 Path" "Browse to the folder where X-Plane 11 is installed."
    nsDialogs::Create 1018

    ${NSD_CreateLabel} 0 0 100% 12u "Select the X-Plane 11 folder where X-Plane.exe is located."

    ${NSD_CreateGroupBox} 0 20u 100% 40u "X-Plane 11 Folder"
    Pop $0

    ${NSD_CreateDirRequest} 15 37u 76% 13u "$XPLANE_PATH"
    Pop $XPLANE_PATH_TEMP

    ${NSD_CreateBrowseButton} 81% 37u 15% 13u "Browse..."
    Pop $0
    ${NSD_OnClick} $0 OnDirBrowse

    ${NSD_CreateLabel} 0 120 100% 12u "**Advanced Users**"
    ${NSD_CreateLabeL} 0 145 100% 25u "If X-Plane is not installed on this machine, leave the folder path empty then click 'Install' to skip installing the xPilot plugin."
    ${NSD_CreateLabel} 0 180 100% 25u "The xPilot plugin files are in the xPilot Client Application folder if you need to manually install the plugin on another machine."

    nsDialogs::Show
FunctionEnd

Function OnDirBrowse
    ${NSD_GetText} $XPLANE_PATH_TEMP $0
    nsDialogs::SelectFolderDialog "Select X-Plane 11 Folder" "$0"
    Pop $0
    ${If} $0 != error
        ${NSD_SetText} $XPLANE_PATH_TEMP "$0"
    ${EndIf}
FunctionEnd

Function pgXplanePathLeave
    ${NSD_GetText} $XPLANE_PATH_TEMP $XPLANE_PATH
    ${If} $XPLANE_PATH != ""
        ; validate path
        IfFileExists "$XPLANE_PATH\X-Plane.exe" valid invalid
        invalid:
            MessageBox MB_YESNO "The X-Plane folder path you specified does not appear to be a valid. Selecting the wrong path can prevent the xPilot plugin from being installed properly.$\r$\n$\r$\nDo you want to use this folder path anyways?" IDYES true IDNO false
            true:
            goto valid
            false:
            Abort
        valid:
    ${EndIf}
FunctionEnd

Section "xPilot Plugin" SecPlugin
    SectionIn RO
    
    ${If} $XPLANE_PATH != ""
        ; fix path formatting
        Push $XPLANE_PATH
        Push "/"
        Call StrSlash
        Pop $R0
        StrCpy $XPLANE_PATH $R0

        ; copy plugin files
        SetOutPath "$XPLANE_PATH\Resources\plugins\xPilot"

        File /r ".\Plugin\*"

        SetOutPath "$XPLANE_PATH\Resources\plugins\xPilot\win_x64"

        File "..\Plugin\build\x64\Release\win_x64\xPilot.xpl"
        File "..\Plugin\build\x64\Release\win_x64\xPilot.pdb"
        
        WriteRegStr HKLM "Software\xPilot" "XPlane" $XPLANE_PATH
    ${EndIf}
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

SetOutPath "$INSTDIR\Plugin\xPilot"
File /r ".\Plugin\*"

SetOutPath "$INSTDIR\Plugin\xPilot\win_x64"
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

Section "Uninstall"

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