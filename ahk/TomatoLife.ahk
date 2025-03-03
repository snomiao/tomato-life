#Persistent
#SingleInstance, force

#Include, %A_ScriptDir%/IsFullScreen.ahk
#Include, %A_ScriptDir%/VirtualDesktop.ahk

EnvGet ENVIROMENT, ENVIROMENT
if ("TEST" == ENVIROMENT || !!RegExMatch(DllCall("GetCommandLine", "str"), "/TEST")) {
    tooltip % "[INFO] MODULE LOAD OK, SKIP CORE"
    ExitApp
}

run cmd /c mkdir %appdata%/tomato-life
; run cmd /c notepad %appdata%/tomato-life/run-at-work.cmd
; run cmd /c notepad %appdata%/tomato-life/run-at-rest.cmd

Menu, tray, icon, %A_ScriptDir%/Tomato.ico

高精度时间配置()
; Menu, Tray, Click
TomatoLifeLaunch()
MakeSureStartup()

Return


高精度时间配置(){
    ToolTip, Tomato-Life 正在为您配置系统高精度时间
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "FrequencyCorrectRate" /t REG_DWORD /d 2 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "UpdateInterval" /t REG_DWORD /d 100 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MaxPollInterval" /t REG_DWORD /d 6 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MinPollInterval" /t REG_DWORD /d 6 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MaxAllowedPhaseOffset" /t REG_DWORD /d 0 /f, , Hide
    RunWait reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d 64 /f, , Hide
    RunWait net stop w32time , , Hide
    RunWait net start w32time, , Hide
    ToolTip
}

; ; dev
; #if ENVIROMENT=="DEV"
; ^!i:: TomatoTicker(1)
; ~^s:: reload

#if
MakeSureStartup(){
    content = start "" %A_AhkPath%
    startCMDPath = %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\tomato-life.cmd
    FileDelete, %startCMDPath%
    FileAppend, %content%, %startCMDPath%
}

TomatoLifeLaunch() {
    HighPerformanceTimeConfig()
    SetTimer TomatoLife, -1
}

HighPerformanceTimeConfig()
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

StatusCalc()
{
    Return ((Mod((UnixTimeGet() / 60000), 30) < 25) ? "工作时间" : "休息时间")
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
    
    static 上次番茄状态 := ""
    ; static 上次番茄状态 := StatusCalc()
    
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
    run cmd /c %appdata%/tomato-life/run-at-work.cmd
    倒计时(番茄状态 "桌面切换")
    Func("SwitchToDesktop").Call(2) ; 切到工作桌面（桌面2）
}
番茄休息(){
    SoundPlay % A_ScriptDir "/NoteG_C.mp3" ; 降调
    run cmd /c %appdata%/tomato-life/run-at-rest.cmd
    倒计时(番茄状态 "桌面切换")
    Func("SwitchToDesktop").Call(1) ; 切到休息桌面（桌面1）k
}
倒计时(名义, 秒 := 10){
    while (秒 > 0){
        ToolTip % 名义 "倒计时" 秒 "秒"
        Sleep 1000
        秒 -= 1
    }
    ToolTip
}
UnixTimeGet()
{
    ; ref: https://www.autohotkey.com/boards/viewtopic.php?t=17333
    t := A_NowUTC
    EnvSub, t, 19700101000000, Seconds
    Return t * 1000 + A_MSec
}

TomatoLife:
    间隔 := 60000 ; 间隔为1分钟，精度到毫秒级
    延时 := (间隔 - Mod(UnixTimeGet(), 间隔))
    TomatoTicker()
    SetTimer TomatoLife, %延时%
Return
