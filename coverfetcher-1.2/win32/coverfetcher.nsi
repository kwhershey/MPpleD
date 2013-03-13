!define VERSION "1.2"
Name "Cover Fetcher"
OutFile "..\coverfetcher-${VERSION}.exe"
InstallDir "$PROGRAMFILES\Cover Fetcher"
InstallDirRegKey HKLM "Software\Benjamin Johnson\Cover Fetcher" "Install_Dir"
SetCompressor lzma

!define MULTIUSER_EXECUTIONLEVEL Highest
!include MultiUser.nsh
RequestExecutionLevel highest

Page license
Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

LicenseData ..\COPYING

; ----------------------------------------

Section "!Cover Fetcher"
	SectionIn RO

	SetOutPath $INSTDIR
	File ..\coverfetcher.exe
	File ..\qt-mt3.dll
	File ..\mingwm10.dll
	File /oname=COPYING.txt	..\COPYING
	WriteRegStr HKLM "Software\Benjamin Johnson\Cover Fetcher" "Install_Dir" "$INSTDIR"

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Cover Fetcher" "DisplayName" "Cover Fetcher"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Cover Fetcher" "UninstallString" "$INSTDIR\uninstall.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Cover Fetcher" "NoModify" 1
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Cover Fetcher" "NoRepair" 1
	WriteUninstaller "uninstall.exe"
SectionEnd

Section "Create Start menu shortcut"
	CreateShortCut "$SMPROGRAMS\Cover Fetcher.lnk" "$INSTDIR\coverfetcher.exe" "" "$INSTDIR\coverfetcher.exe" 0 SW_SHOWNORMAL "" "A simple last.fm cover fetcher."
SectionEnd

Section "Create desktop shortcut"
	CreateShortCut "$DESKTOP\Cover Fetcher.lnk" "$INSTDIR\coverfetcher.exe" "" "$INSTDIR\coverfetcher.exe" 0 SW_SHOWNORMAL "" "A simple last.fm cover fetcher."
SectionEnd

Section "Uninstall"
	DeleteRegKey HKLM "Software\Benjamin Johnson\Cover Fetcher"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Cover Fetcher"

	RMDir /r "$INSTDIR"

	Delete "$SMPROGRAMS\Cover Fetcher.lnk"
	Delete "$DESKTOP\Cover Fetcher.lnk"
SectionEnd

; ----------------------------------------

Function .onInit
	!insertmacro MULTIUSER_INIT
FunctionEnd

Function un.onInit
	!insertmacro MULTIUSER_UNINIT
FunctionEnd

; vim: set nowrap :
