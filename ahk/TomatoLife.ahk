#Persistent
#SingleInstance, force

#Include, %A_ScriptDir%/IsFullScreen.ahk
#Include, %A_ScriptDir%/VirtualDesktop.ahk

; setup tray
Menu, tray, icon, %A_ScriptDir%/Tomato.ico

Menu, Tray, Add, Trigger Tomato Ticker, TomatoTicker
Menu, Tray, Default, Trigger Tomato Ticker
Menu, Tray, Click, 1

Menu, Tray, Add, Goto Website, GotoWebsite

; bind twinkle
; global TwinkleTrayPath := "%LocalAppData%\Programs\twinkle-tray\Twinkle Tray.exe"

; Detect Environment
EnvGet ENVIRONMENT, ENVIRONMENT
global isDevMode := !!FileExist(A_ScriptDir . "/../.git")
global isTestMode := "TEST" == ENVIRONMENT || !!RegExMatch(DllCall("GetCommandLine", "str"), "--test")
; MsgBox, isDevMode %isDevMode%
if (isTestMode) {
    tooltip % "[INFO] MODULE LOAD OK, SKIP CORE"
    ExitApp
}

initHelperScripts()
HighPerformanceTimerConfig()
TomatoLifeLaunch()
AddUserStartup()

Return

; dev hotkey for reloading on saving
#if isDevMode
    ~^s:: Reload

#if

GotoWebsite(){
    ; - [snomiao/tomato-life]( https://github.com/snomiao/tomato-life )
    Run https://github.com/snomiao/tomato-life
}

StatusCalc()
{
    Return ((Mod((UnixTimeGet() / 60000), 30) < 25) ? "工作时间" : "休息时间")
}

TomatoLifeLaunch() {
    SetTimer TomatoLifeTimer, -1
}
TomatoLifeTimer(){
    间隔 := 60000 ; 间隔为1分钟，精度到毫秒级
    延时 := (间隔 - Mod(UnixTimeGet(), 间隔))
    TomatoTicker()
    SetTimer TomatoLifeTimer, %延时%
}
TomatoTicker(force:=0)
{
    ; ToolTip, ticker
    ; 检测睡眠标记文件以跳过报时
    static SLEEPING_FLAG_CLEAN := 0
    if(!SLEEPING_FLAG_CLEAN) {
        ; 启动时重置标记文件
        FileDelete %TEMP%/SLEEPING_FLAG
        SLEEPING_FLAG_CLEAN := 1
    } else {
        FileRead SLEEPING_FLAG, %TEMP%/SLEEPING_FLAG
        if (SLEEPING_FLAG) {
            Return
        }
    }
    番茄状态 := StatusCalc()
    ; 边沿触发过滤器

    ; static 上次番茄状态 := ""
    static 上次番茄状态 := StatusCalc()

    ; msgbox %上次番茄状态% %番茄状态%
    ; 番茄未变化
    if (上次番茄状态 == 番茄状态 && !force) {
        Return
    }
    ; 忽略全屏
    if (IsFullScreen()){
        Return
    }
    ; ignore afk
    if ( A_TimeIdlePhysical > 30 * 60 * 1000 ){
        Return
    }
    ; 切换番茄状态
    ; MsgBox, 番茄：%番茄状态%
    ; TrayTip, 番茄：%番茄状态%, ： %番茄状态%
    ; 状态动作
    if ("工作时间" == 番茄状态) {
        番茄工作()
    }
    if ("休息时间" == 番茄状态) {
        番茄休息()
    }
    上次番茄状态 := 番茄状态
}

番茄工作(){
    SoundPlay % A_ScriptDir "/NoteC_G.mp3" ; 升调
    Run cmd /c %A_AppData%/tomato-life/run-at-work.cmd
    ; SendInput {Media_Play_Pause}
    shiftBright(10)
    CountDownTooltip(番茄状态 "桌面切换")
    Func("SwitchToDesktop").Call(1) ; 切到工作桌面（桌面1）
}
番茄休息(){
    SoundPlay % A_ScriptDir "/NoteG_C.mp3" ; 降调
    Run cmd /c %A_AppData%/tomato-life/run-at-rest.cmd
    ; SendInput {Media_Play_Pause}
    shiftBright(-10)
    CountDownTooltip(番茄状态 "桌面切换")
    Func("SwitchToDesktop").Call(10) ; 切到休息桌面（桌面10）
}
CountDownTooltip(名义, 秒 := 10){
    global CountDownTooltipName, CountDownTooltipRemain
    CountDownTooltipName := 名义
    CountDownTooltipRemain := 秒
    SetTimer, CountDownTooltipTimer, 1000
}
CountDownTooltipTimer(){
    global CountDownTooltipName, CountDownTooltipRemain
    if(CountDownTooltipRemain){
        ToolTip % CountDownTooltipName "" CountDownTooltipRemain "秒"
        CountDownTooltipRemain -= 1
        return
    }
    ToolTip
    SetTimer, CountDownTooltipTimer, Off
}

shiftBright(offset, 秒 := 10){
    global shiftBrightTimerRemain, shiftBrightTimerOffset
    shiftBrightTimerRemain := 秒
    shiftBrightTimerOffset := offset
    SetTimer, shiftBrightTimer, 1000
}
shiftBrightTimer(){
    global shiftBrightTimerRemain, shiftBrightTimerOffset
    if (!shiftBrightTimerRemain){
        SetTimer, shiftBrightTimer, Off
        return
    }
    addMonitorsBright(shiftBrightTimerOffset)
    shiftBrightTimerRemain -= 1
}

UnixTimeGet()
{
    ; ref: https://www.autohotkey.com/boards/viewtopic.php?t=17333
    t := A_NowUTC
    EnvSub, t, 19700101000000, Seconds
    Return t * 1000 + A_MSec
}

; 高精度时间配置(){
;     ToolTip, Tomato-Life 正在为您配置系统高精度时间
;     RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "FrequencyCorrectRate" /t REG_DWORD /d 2 /f, , Hide
;     RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "UpdateInterval" /t REG_DWORD /d 100 /f, , Hide
;     RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MaxPollInterval" /t REG_DWORD /d 6 /f, , Hide
;     RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MinPollInterval" /t REG_DWORD /d 6 /f, , Hide
;     RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MaxAllowedPhaseOffset" /t REG_DWORD /d 0 /f, , Hide
;     RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d 64 /f, , Hide
;     RunWait net stop w32time , , Hide
;     RunWait net start w32time, , Hide
;     ToolTip
; }

HighPerformanceTimerConfig()
{
    ; RegWrite, REG_SZ|REG_EXPAND_SZ|REG_MULTI_SZ|REG_DWORD|REG_BINARY, HKLM|HKU|HKCU|HKCR|HKCC, SubKey [, ValueName, Value]
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "FrequencyCorrectRate" /t REG_DWORD /d 2 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "UpdateInterval" /t REG_DWORD /d 100 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MaxPollInterval" /t REG_DWORD /d 6 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MinPollInterval" /t REG_DWORD /d 6 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MaxAllowedPhaseOffset" /t REG_DWORD /d 0 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d 64 /f, , Hide
    RunWait net stop w32time, , Hide
    RunWait net start w32time, , Hide
}

setMonitorsBright(bright:=100){
    If (FileExist(LocalAppData . "\Programs\twinkle-tray\Twinkle Tray.exe")){
        Run, "%LocalAppData%\Programs\twinkle-tray\Twinkle Tray.exe" --All --Set=%bright%
    }
}
addMonitorsBright(offset:=100){
    If (FileExist(LocalAppData . "\Programs\twinkle-tray\Twinkle Tray.exe")){
        Run, "%LocalAppData%\Programs\twinkle-tray\Twinkle Tray.exe" --All --Offset=%offset%
    }
}

AddUserStartup(){
    content = start "" %A_AhkPath%
    startCMDPath := A_AppData . "\Microsoft\Windows\Start Menu\Programs\Startup\tomato-life-startup.cmd"
    FileDelete, %startCMDPath%
    FileAppend, %content%, %startCMDPath%
}

initHelperScripts(){

    FileCreateDir, A_AppData . "/tomato-life"
    if (!FileExist(A_AppData . "/tomato-life/run-at-work.cmd")) {
        FileAppend, % "", % A_AppData . "/tomato-life/run-at-work.cmd"
    }
    if (!FileExist(A_AppData . "/tomato-life/run-at-rest.cmd")) {
        FileAppend, % "", % A_AppData . "/tomato-life/run-at-rest.cmd"
    }
}