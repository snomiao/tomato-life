/* 
LICENCE: GPL v3
author: snomiao@gmail.com
*/
SwitchToDesktop(idx){
    if (!SwitchToDesktopByInternalAPI(idx)){
        TrayTip , WARN, SwitchToDesktopByHotkey
        SwitchToDesktopByHotkey(idx)
    }
}
SwitchToDesktopByHotkey(idx){
    SendInput ^#{Left 10}
    idx -= 1
    Loop %idx% {
        SendInput ^#{Right}
    }
}
SwitchToDesktopByInternalAPI(idx)
{
    succ := 0
    IServiceProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{6D5140C1-7436-11CE-8034-00AA006009FA}")
    IVirtualDesktopManagerInternal_Win11 := ComObjQuery(IServiceProvider, "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}", "{B2F925B9-5A0F-4D2E-9F4D-2B1507593C10}")
    IVirtualDesktopManagerInternal_Win10 := ComObjQuery(IServiceProvider, "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}", "{F31574D6-B682-4CDC-BD56-1827860ABEC6}")
    win11 := !!IVirtualDesktopManagerInternal_Win11
    win10 := !!IVirtualDesktopManagerInternal_Win10
    IVirtualDesktopManagerInternal := !!IVirtualDesktopManagerInternal_Win11 ? IVirtualDesktopManagerInternal_Win11 : IVirtualDesktopManagerInternal_Win10
    ; tooltip win %win11% %win10%
    ObjRelease(IServiceProvider)
    if (IVirtualDesktopManagerInternal) {
        ; tooltip %idx%
        GetCount := vtable(IVirtualDesktopManagerInternal, 3)
        GetDesktops := vtable(IVirtualDesktopManagerInternal, 7)
        SwitchDesktop := vtable(IVirtualDesktopManagerInternal, 9)
        ; TrayTip, , % IVirtualDesktopManagerInternal
        pDesktopIObjectArray := 0
        _ := win10 && DllCall(GetDesktops, "Ptr", IVirtualDesktopManagerInternal, "Ptr*", pDesktopIObjectArray)
        _ := win11 && DllCall(GetDesktops, "Ptr", IVirtualDesktopManagerInternal, "Ptr", 0, "Ptr*", pDesktopIObjectArray)
        ; Tooltip %pDesktopIObjectArray%
        if (pDesktopIObjectArray) {
            GetDesktopCount := vtable(pDesktopIObjectArray, 3)
            GetDesktopAt := vtable(pDesktopIObjectArray, 4)
            _ := win10 && DllCall(GetDesktopCount, "Ptr", IVirtualDesktopManagerInternal, "UInt*", DesktopCount)
            _ := win11 && DllCall(GetDesktopCount, "Ptr", IVirtualDesktopManagerInternal, "Ptr", 0, "UInt*", DesktopCount)  
            ; tooltip 切换到桌面 %idx% / %DesktopCount% 
            ; if idx-th desktop doesn't exists then create a new desktop
            if (idx > DesktopCount) {
                diff := idx - DesktopCount
                loop %diff% {
                    SendEvent ^#d
                }
            }
            ; if desktop count is more than 10 then delete them
            if (DesktopCount > 10){
                delCount := DesktopCount - 10 + 1
                SendEvent ^#d
                loop %delCount% {
                    SendEvent ^#{F4}
                }
            }
            _ := win10 && GetGUIDFromString(IID_IVirtualDesktop, "{FF72FFDD-BE7E-43FC-9C03-AD81681E88E4}")
            _ := win11 && GetGUIDFromString(IID_IVirtualDesktop, "{536D3495-B208-4CC9-AE26-DE8111275BF8}")
            DllCall(GetDesktopAt, "Ptr", pDesktopIObjectArray, "UInt", idx - 1, "Ptr", &IID_IVirtualDesktop, "Ptr*", VirtualDesktop)
            ObjRelease(pDesktopIObjectArray)
            if (VirtualDesktop) {
                _ := win10 && DllCall(SwitchDesktop, "Ptr", IVirtualDesktopManagerInternal, "Ptr", VirtualDesktop)
                _ := win11 && DllCall(SwitchDesktop, "Ptr", IVirtualDesktopManagerInternal, "Ptr", 0, "Ptr", VirtualDesktop)
                ObjRelease(VirtualDesktop)
                succ := idx
            }
        }
        ObjRelease(IVirtualDesktopManagerInternal)
    }
    Return succ
}

GetGUIDFromString(ByRef GUID, sGUID) ; Converts a string to a binary GUID
{
    VarSetCapacity(GUID, 16, 0)
    DllCall("ole32\CLSIDFromString", "Str", sGUID, "Ptr", &GUID)
}

vtable(ptr, n){
    ; NumGet(ptr+0) Returns the address of the object's virtual function
    ; table (vtable for short). The remainder of the expression retrieves
    ; the address of the nth function's address from the vtable.
    Return NumGet(NumGet(ptr+0), n*A_PtrSize)
}
