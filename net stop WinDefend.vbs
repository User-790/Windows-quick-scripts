Set objShell = CreateObject("WScript.Shell")
Return = objShell.Run("cmd /c sc config WinDefend start= disabled", 0, True)

Return = objShell.Run("cmd /c net stop WinDefend", 0, True)
WScript.Echo "Windows Defender service disabled."
