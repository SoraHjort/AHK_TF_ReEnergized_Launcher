﻿WinClose, % "ahk_id " Instances%A_Index%

;@Ahk2Exe-SetMainIcon matrix.ico
FileInstall, imgs/TFLaunchGUI.png, imgs/TFLaunchGUI.png
FileInstall, imgs/matrixdim.png, imgs/matrixdim.png
FileInstall, imgs/matrix.ico, imgs/matrix.ico

#SingleInstance off
SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2
;Script by Sora Hjort

version := 20220630.162500

nil := ""

Launch = %1%

menu, tray, nostandard
menu, tray, add, E&xit,FIN


;	Restart script in admin mode if needed.

	full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" %1% /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %1%
    }
    ExitApp
}




;Version Check

FileReadLine, VerFile, ./version, 1

If (VerFile <= version)
    {
    FileDelete, ./version
    FileAppend, %version%, ./version 
    }
    
;Read the ini and fix any erroneous values.
ini = %A_ScriptDir%\TFLaunch.ini
gosub IniReader



;Auto Close?



If AutoClose = True
    {
    AutoClose = True
    ACloseChecked := "Checked"
} else {
    AutoClose = False
    ACloseChecked =
    }


;Borderless Mode enabled?


If BorderlessEnabled = True
    {
    BorderlessEnabled = True
    BCloseChecked := "Checked"
} else {
    BorderlessEnabled = False
    BCloseChecked =
    }

;Check for updates?

If CheckForUpdates = True
    {
    CheckForUpdates = True
    UpdateChecker := "Checked"
} else {
    CheckForUpdates = False
    UpdateChecker =
    }

;FOC and WFC need differing delays before engaging borderless due to load times.


If FOCDelay = nil
    {
    FOCDelay = 10
    }


If WFCDelay = nil
    {
    WFCDelay = 15
    }
    
    
;Check WFC and FOC paths in ini

CfgPath := "TransGame\Config\PC\Cooked"
WFCCfgPath = %WFCPath%%CfgPath%
FOCCfgPath = %FOCPath%%CfgPath%

if (WFCPath = 0 or WFCPath = nil) {
    WFCList := "Launch WFC once first"
    WFCCFGSel := 1
    WFCFirst := True
    } else {
    Tag := "WFC"
    WFCFirst := False
    gosub ConfigRead
    }




if (FOCPath = 0 or FOCPath = nil) {
    FOCList := "Launch FOC once first"
    FOCCFGSel := 1
    FOCFirst := True
    } else {
    Tag := "FOC"
    FOCFirst := False
    gosub ConfigRead
    }
    
    

;MsgBox %FOCConfig% %WFCConfig%
    

;Launch Parameters
    
if (Launch == "FOC" or Launch == "foc") {
    gosub FOC
    gosub FIN
    return
    }

if (Launch == "WFC" or Launch == "wfc") {
    gosub WFC
    gosub FIN
    return
    }
    
    
First := FileExist("TFLaunch.ini")
MainImg := FileExist("imgs/TFLaunchGUI.png")
DimImg := FileExist("imgs/matrixdim.png")
IcoImg := FileExist("imgs/matrix.ico")

IfNotExist, ./imgs
    {
    FileCreateDir, ./imgs
    }

If (MainImg != "A")
    {
    gosub DownMain
    }
If (DimImg != "A")
    {
    gosub DownDim
    }
If (IcoImg != "A")
    {
    gosub DownIco
    }

If (IcoImg == "A")
    {
    menu, tray, icon, imgs/matrix.ico
    }
    
    
FileCreateShortcut, %A_ScriptFullPath%, LaunchFOC.lnk,, FOC
FileCreateShortcut, %A_ScriptFullPath%, LaunchWFC.lnk,, WFC


;Check for updates function

FormatTime, time, A_now, yyyyMMdd

if (LastCheck < time)
    {
    If CheckForUpdates = True
        {
        UrlDownloadToFile, https://raw.githubusercontent.com/SoraHjort/AHK_TF_ReEnergized_Launcher/main/version, ./updateCheck
        FileReadLine, updateCheck, ./updateCheck, 1
        FileDelete, ./updateCheck
        If (version <= updateCheck)
            {
            UpdateMsg =
(
There is an update available! 
Current:   v%version%  
Updated: v%updateCheck%
Check the github for the update!
)
            MsgBox %UpdateMsg%
            }
        }
    }


;First Launch text box

FirstBlock =
(
This appears to be the first time you've ran this! Or the ini got deleted.

This tool helps you launch the Steam versions of War For Cybertron and Fall Of Cybertron, for playing on the ReEnergized server! This is because the Steam version likes to overwrite the CD Key whenever you launch it. This launcher helps solve this issue by launching the game and then running the registry file automatically!

Click the Help button on the main window for more info! But the quick rundown is:

1. Make sure the .reg files are in the same location as the launcher. Original names given to you by the bot.
2. Borderless mode requires the games to be in windowed mode, not fullscreen mode
3. WFC and FOC have different load times, adjust the delay for borderless accordingly
4. Shortcuts have been created next to the launcher for quickly launching into the games. This'll also use the borderless options configured in the launcher!

~Sora Hjort
)


;Help button text

HelpBlock =
(
This launcher still needs you to grab the Coalesced.ini from the Discord Server.

The reg files "tfcwfc_pc.reg" and "tfcfoc_pc.reg" must be in the same folder as the launcher. The launcher will yell at you if you did not do this.

The Borderless mode does require you to run the game in windowed mode.

WFC and FOC have differing load times, adjust the delay (in seconds) to fine tune when the borderless event triggers. When in doubt, increase the delay up to 20 or even 30 seconds to make sure it triggers.

You can also trigger the borderless while the game is running by attempting to run the shortcuts or pressing one of the launch buttons. It will not launch a second instance of the game.

If you wish to launch the games through this launcher through Steam, you will have to add the launcher as a non-steam game. And if you wish for it to launch straight into a specific game, add "WFC" or "FOC" without quotes as the launch option to have it launch directly into that specific game.

When in doubt, look at the properties of the shortcuts.

Note: If you're running the AHK script version of the launcher instead of the EXE, you will have steam add any other program. Then you'll have to edit the properties of the entry to direct to the script.
)


;Launcher main text

TxtBlock =
(
Welcome to the ReEnergized Launcher Helper for Steam!

Make sure you have the .reg files inthe same folder as this program. They need to be the same name as they were given to you by the bot!

If you have not, then please go follow the instructions in the install guide. It's over on the discord server!

P.S. This launcher and the registry files can be stored anywhere, as long as they're in the same folder!

Signed Sora Hjort



Select the game you wish to launch!
)



;Create the Gui!

WFCBlock = 
(
&War For
Cybertron
)

FOCBlock = 
(
&Fall Of
Cybertron
)

Gui, Main:New, ,ReEnergized Steam Launcher
Gui, Margin ,0,0
Gui, add, picture, xm0 ym0 w960 h540 BackgroundTrans, imgs/TFLaunchGUI.png

gui, color, 0x000000
Gui, Font, s16 c39ff14, Arial

Gui, Add, Button, xm+10 ym+500 w140 h30 gHelp , &Help

Gui, Add, Text, xm345 ym470 , Delay:
Gui, Add, Text, xm345 ym500 , (In Seconds)


Gui, Add, Button, xm+170 ym+460 w150 h70 gWFC , %WFCBlock%

Gui, Add, Edit,  w70 xm410 ym470 h30 +Center
Gui, Add, UpDown, vWFCDelay range0-100 wrap, %WFCDelay%


Gui, Add, Text, xm665 ym470 , Delay:
Gui, Add, Text, xm665 ym500 , (In Seconds)

Gui, Add, Button, xm+490 ym+460 w150 h70 gFOC , %FOCBlock%

Gui, Add, Edit,  w70 xm730 ym470 h30 +Center
Gui, Add, UpDown, vFOCDelay range0-100 wrap, %FOCDelay%

Gui, Add, Button, xm+810 ym+460 w140 h70 gCancel , &Close


gui, Add, CheckBox, vBEnable %BCloseChecked% xm0 ym400 , Enable Borderless Fullscreen? (Experimental)

gui, Add, CheckBox, xm0 ym430 vAutoCloseTester %ACloseChecked% , Automatically Close Launcher?

GuiControl, Focus, Help


If (First != "A")
    {
    gosub FirstRun
    gosub FinishGui
    Gui, First:new,,First ReEnergized
    gui, color, 0x000000
    Gui, Font, s16 c39ff14, Arial
    Gui, Add, Text,w960 wrap BackgroundTrans, %FirstBlock%
    Gui, First:Show, xcenter ycenter 
    } else {
    gosub FinishGui
    }
Return


FinishGui:
    Gui, Main:Font, s12
    gui, Main:Add, CheckBox, xm750 ym90 vUpdateEnable %UpdateChecker%, Check updates daily?
    gui, Main:add, DropDownList, vWFCConfig xm750 ym10 w200 Choose%WFCCFGSel%, %WFCList%
    gui, Main:add, DropDownList, vFOCConfig xm750 ym50 w200 Choose%FOCCFGSel%, %FOCList%
    Gui, Main:Show, xcenter ycenter h130 AutoSize, ReEnergized Steam Launcher
return



Help:
Gui, Help:New,,Launcher Help
Gui, Margin ,20,20
Gui, add, picture, +Center xm64 ym64 w512 BackgroundTrans,  imgs/matrixdim.png
gui, color, 0x000000
Gui, Font, s16 c39ff14, Arial
Gui, Add, Text, W640 xm0 ym0 wrap BackgroundTrans, %HelpBlock%
Gui, Add, Button, gHelpGuiClose, &Close
Gui, Help:Show
return

;WFC's block

WFC:
gosub Read
SecMult := WFCDelay * 1000
game := "ahk_exe TWFC.exe"
Stub := "WFC"
StubLong := "War For Cybertron"
If (WFCFirst = True)
    {
    gosub FirstLaunch
    }
WFCSub:
WFCCfgPath = %WFCPath%%CfgPath%
if FileExist("tfcwfc_pc.reg") {
    FileCopy, %A_ScriptDir%\configs\%WFCConfig%, %WFCCfgPath%\Coalesced.ini, 1
    run steam://run/42650
    WinWait %game%
    RunWait reg import tfcwfc_pc.reg
    sleep, %SecMult%
    WinActivate %game%
    #If WinActive(%game%)
        {
        if (BorderlessEnabled = "True")
            {
            gosub Borderless
            }
        }
    gosub Save
    return
    }
else
    {
    MsgBox WFC CDKey Registry not found in launcher's directory, be sure to follow the instructions! You didn't rename it, did you?
    return
    }
return
gosub EOF


;FOC's Block

FOC:
gosub Read
SecMult := FOCDelay * 1000
game := "ahk_exe TFOC.exe"
Stub := "FOC"
StubLong := "Fall Of Cybertron"
If (FOCFirst = True)
    {
    gosub FirstLaunch
    }
FOCSub:
FOCCfgPath = %FOCPath%%CfgPath%
if !FileExist("tfcfoc_pc.reg") {
    MsgBox FOC CDKey Registry not found in launcher's directory, be sure to follow the instructions! You didn't rename it, did you?
    return
    } 
else
    {
    FileCopy, %A_ScriptDir%\configs\%FOCConfig%, %FOCCfgPath%\Coalesced.ini, 1
    run steam://run/213120
    WinWait %game%
    Run reg import tfcfoc_pc.reg
    sleep, %SecMult%
    WinActivate %game%
    #If WinActive(%game%)
        {
        if (BorderlessEnabled = "True")
            {
            gosub Borderless
            }
        }
    gosub Save
    }
return
gosub EOF

Borderless:

    WinActivate %game%
    WinMove, %game%, , 0, 0, A_ScreenWidth, A_ScreenHeight
    WinSet, Style, 0x140A0000, %game%
    WinSet, Style, -0xC00000, %game%
    WinSet, Style, -0x800000, %game%
    WinSet, Style, -0x40000, %game%
    WinSet, Style, -0x400000, %game%
    WinSet, Style, -0x0, %game%
    WinSet, Style, -0x80880000, %game%
    ;WinSet, Redraw, , %game%
    ;WinHide, %game%
    ;WinShow, %game%
    ;WinMove, %game%, , 0, 0, A_ScreenWidth, A_ScreenHeight
    WinSet, Redraw,, %game%
    ;DllCall("SetMenu", "Ptr", WinExist(), "Ptr", 0)


    ;WinActivate %game%
    ;WinMove, %game%, , 10, 10, (A_ScreenWidth - 10), (A_ScreenHeight - 10)
    ;WinSet, Style, +0xC00000, %game%
    ;WinSet, Style, +0xC40000, %game%
    ;WinSet, Style, +0x40000, %game%
    ;WinSet, Style, +0x800000, %game%
    
    ;WinSet, ExStyle, -0x00000200, %game%
    ;WinSet, Style, -0xC00000, %game%
    ;msgbox c0
    ;WinSet, Style, -0xC40000, %game%
    ;WinSet, ExStyle, -0x00000200, %game%
    ;WinSet, Style, -0x840000, %game%
    ;msgbox c4
    ;WinSet, Style, -0x40000, %game%
    ;msgbox 04
    ;WinSet, Style, -0x800000, %game%
    ;msgbox 80
    ;WinSet, Style, -0xC00000, %game%
    ;WinMaximize, %game%
    ;DllCall("SetMenu", "Ptr", WinExist(), "Ptr", 0)
    ;WinMove, %game%, , 0, 0, A_ScreenWidth, A_ScreenHeight
return


;Closing out

Cancel:
gosub Read
gosub Save
gosub FIN
return


;Read the Ini Files

IniReader:
IniRead, FOCPath, %ini%, Launch, FOCPath, 0
IniRead, WFCConfig, %ini%, launch, WFCConfig, "WFC.ReEnergized.ini"
IniRead, FOCConfig, %ini%, launch, FOCConfig, "FOC.ReEnergized.ini"
IniRead, LastCheck, %ini%, Update, LastCheck, 0
IniRead, CheckForUpdates, %ini%, Update, CheckForUpdates, 0
IniRead, AutoClose, %ini%, Launch, AutoClose, True
IniRead, BorderlessEnabled, %ini%, Launch, BorderlessEnabled, 0
IniRead, FOCDelay, %ini%, Launch, FOCDelay, 10
IniRead, WFCDelay, %ini%, Launch, WFCDelay, 15
IniRead, WFCPath, %ini%, Launch, WFCPath, 0
return


;Read controls

Read:

Gui, Main:Submit, NoHide

;MsgBox %FOCConfig% %FOCDelay% %WFCDelay%
    If (AutoCloseTester = 0)
        {
        AutoClose = False
        } else {
        AutoClose = True
        }

;GuiControlGet, BEnableTester,, BEnable
    If (BEnable = 0)
        {
        BorderlessEnabled = False
        } else {
        BorderlessEnabled = True
        }

    If (UpdateEnable = 0)
        {
        CheckForUpdates = False
        } else {
        CheckForUpdates = True
        }

return


;Save to ini

Save:

Gui, Main:Submit, NoHide

if (WFCConfig = "Launch WFC once first")
    {
    WFCConfig := "WFC.ReEnergized.ini"
    }
if (FOCConfig = "Launch FOC once first")
    {
    FOCConfig := "FOC.ReEnergized.ini"
    }

if (Stub = "FOC" or Stub = "WFC")
    {
    WinGet, GamePath, ProcessPath, %game%

    GamePath := StrReplace(GamePath, "Binaries\TFOC.exe")
    GamePath := StrReplace(GamePath, "Binaries\TWFC.exe")

    IniWrite, %GamePath%, %ini%, Launch, %Stub%Path
    }

IniWrite, %BorderlessEnabled%, %ini%, Launch, BorderlessEnabled
IniWrite, %WFCDelay%, %ini%, Launch, WFCDelay
IniWrite, %FOCDelay%, %ini%, Launch, FOCDelay
IniWrite, %AutoClose%, %ini%, Launch, AutoClose
IniWrite, %WFCConfig%, %ini%, Launch, WFCConfig
IniWrite, %FOCConfig%, %ini%, Launch, FOCConfig
IniWrite, %time%, %ini%, Update, LastCheck
IniWrite, %CheckForUpdates%, %ini%, Update, CheckForUpdates

if (Stub = "FOC")
    {
    if (FOCFirst = True)
        {
        Tag := "FOC"
        WinGet, PID, PID, %game%
        Process, Close, %PID%
        gosub ConfigRead
        gosub IniReader
        FOCFirst := False
        FOCConfig := FOCCfgDef
        FOCCFGNum := 2
        RestartQ := True
        goto FOCSub
        return
        }
    }
    
if (Stub = "WFC")
    {
    if (WFCFirst = True)
        {
        Tag := "WFC"
        WinGet, PID, PID, %game%
        Process, Close, %PID%
        gosub ConfigRead
        gosub IniReader
        WFCFirst := False
        WFCConfig := WFCCfgDef
        WFCCFGNum := 2
        RestartQ := True
        goto WFCSub
        return
        }
    }
    WinActivate, %game%
    Gui, Launch:Destroy
if (AutoCloseTester = 1)
        {
        gui, Main:Hide
        sleep, 1000
        gosub FIN
        }
if (AutoCloseTester = 0 and RestartQ = True)
    {
    goto FirstRestart
    }
return

FirstGuiClose:
FirstGuiEscape:
gui, First:hide
return

HelpGuiClose:
HelpGuiEscape:
gui, Help:hide
return

FirstLaunch:

FirstBlock =
(
Please hold why we launch %StubLong%,
kill the game, then relaunch it for you.

This should only occur during the first launch of
%StubLong%.

Don't worry, your old Coalesced.ini files for
%StubLong% are being backed up. They'll
show up in the Config Selection dropdown boxes
labeled as "%Stub%.Backup.ini".

If you did any custom changes to the config file
prior, you may want to go into the configs folder
and rename it. Remember to keep the %Stub% prefix
and the .ini extension.
)

Gui, Launch:new
Gui, +AlwaysOnTop -caption
gui, font,s16
Gui, add, text,, %FirstBlock%
gui, Launch:show
return

;Download sub sections

DownMain:
UrlDownloadToFile, https://github.com/SoraHjort/AHK_TF_ReEnergized_Launcher/raw/main/imgs/TFLaunchGUI.png, ./imgs/TFLaunchGui.png
return

DownDim:
UrlDownloadToFile, https://raw.githubusercontent.com/SoraHjort/AHK_TF_ReEnergized_Launcher/main/imgs/matrixdim.png, ./imgs/matrixdim.png
return

DownIco:
UrlDownloadToFile, https://raw.githubusercontent.com/SoraHjort/AHK_TF_ReEnergized_Launcher/main/imgs/matrix.ico, ./imgs/matrix.ico
return

;download the ReEnergized basic configs 

DownConfigs:
DownBlock =
(
Now downloading config files. Please hold.

This message will disappear when the
downloads are completed.
)
Gui, Down:New
Gui, Font, s16
Gui, add, text,, %DownBlock%
Gui, show
UrlDownloadToFile, https://wiki.aiwarehouse.xyz/guides/tfcwfc_pc_guide/coalesced.ini, ./configs/WFC.ReEnergized.ini
UrlDownloadToFile, https://wiki.aiwarehouse.xyz/guides/tfcfoc_guide/coalesced.ini, ./configs/FOC.ReEnergized.ini
Gui, Down:Destroy
return

;Make a backup of the configs incase of overwriting concerns

BackupConfigs:
gosub IniReader
WFCCfgPath = %WFCPath%%CfgPath%
FOCCfgPath = %FOCPath%%CfgPath%
sleep 50
FileCopy, %FOCCfgPath%\Coalesced.ini, %A_ScriptDir%\configs\FOC.Backup.ini
sleep 50
FileCopy, %WFCCfgPath%\Coalesced.ini, %A_ScriptDir%\configs\WFC.Backup.ini
sleep 50
FileCopy, %FOCCfgPath%\Coalesced.ini, %A_ScriptDir%\configs\FOC.Backup.ini
sleep 50
FileCopy, %WFCCfgPath%\Coalesced.ini, %A_ScriptDir%\configs\WFC.Backup.ini

BackupBlock =
(
The old Coalesced.ini files for WFC and FOC
have been backed up. They'll show up in the
dropdown boxes labeled as "backup".

Sorry if you see this message multiple times.
The backup process can be a little finicky a
few times.
)
;MsgBox %BackupBlock%
return


;List the configs in the configs folder

ConfigRead:

FOCArray := []
WFCArray := []

WFCCfgDef := "WFC.ReEnergized.ini"
FOCCfgDef := "FOC.ReEnergized.ini"

IfNotExist, ./configs
        {
        FileCreateDir, ./configs
        }

CountWithMe := 0


Loop, ./configs/%Tag%*.ini
{
    If (Tag = "FOC") {
        If (CountWithMe > 0) {
            FOCList = %FOCList%|%A_LoopFileName%
            AddCfg = %A_LoopFileName%
            FOCArray.push(AddCfg)
            ;msgbox 1 %AddCfg%
            ;msgbox % FOCArray[A_Index]
            } else {
            FOCList = %FOCList%%A_LoopFileName%
            AddCfg = %A_LoopFileName%
            FOCArray.push(AddCfg)
            ;msgbox 2 %AddCfg%
            }
    } else if (Tag = "WFC") {
        If (CountWithMe > 0) {
            WFCList = %WFCList%|%A_LoopFileName%
            AddCfg = %A_LoopFileName%
            WFCArray.push(AddCfg)
            ;msgbox 3 %AddCfg%
            } else {
            WFCList = %WFCList%%A_LoopFileName%
            AddCfg = %A_LoopFileName%
            WFCArray.push(AddCfg)
            ;msgbox 4 %AddCfg%
            }
        }
    
    CountWithMe++
}

;MsgBox %CountWithMe%

If CountWithMe <= 0
    {
    FileCreateDir, ./configs
    gosub DownConfigs
    goto ConfigRead
    return
    }

If CountWithMe <= 1
    {
    FileCreateDir, ./configs
    gosub BackupConfigs
    goto ConfigRead
    return
    }

If (Tag = "WFC") {
    loop % WFCArray.length()
        {
        WFCTest = % WFCArray[A_Index]
        WFCCFGNum++
        if (WFCTest = WFCConfig) {
            WFCCFGSel := WFCCFGNum
            }
        if (WFCTest = WFCCfgDef) {
            WFCCFGDefSel := WFCCFGNum
            }
        }
}

If (Tag = "FOC") {
    loop % FOCArray.length()
        {
        ;msgbox 1
        FOCTest = % FOCArray[A_Index]
        FOCCFGNum++
        if (FOCTest = FOCConfig) {
            ;msgbox 2
            FOCCFGSel := FOCCFGNum
            }
        if (FOCTest = FOCCfgDef) {
            FOCCFGDefSel := FOCCFGNum
            }
        }
}
;msgbox test %FOCCFGSel%
If (FOCCFGSel = "")
    {
    FOCCFGSel := FOCCFGDefSel
    ;MsgBox FOCTest %FOCCFGSel%
    }
    
If (WFCCFGSel = "")
    {
    WFCCFGSel := WFCCFGDefSel
    ;MsgBox WFCTest %WFCCFGSel%
    }
return


;First Run Section
FirstRun:
FileCreateDir, ./configs
;gosub BackupConfigs
gosub DownConfigs
return



;Exit
MainGuiClose:
MainGuiEscape:
FIN:
ExitApp
return

FirstRestart:
RestartBlock =
(
Due to you turning off the auto close launcher before
the first time setup of launching %StubLong%,
the launcher will now restart. This does mean it will
bring itself infront of the game. 

This should only occur this one time from launching
%StubLong%. 
)
    MsgBox, %RestartBlock%
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" %1% /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %1%
    }
    ExitApp


;Should never reach here
EOF:
return