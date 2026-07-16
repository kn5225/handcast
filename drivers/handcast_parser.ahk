#Requires AutoHotkey v2.0
#SingleInstance Force
Esc:: ExitApp
ComPort := "COM5" 
BaudRate := 115200
try {
    serialPort := FileOpen(ComPort, "r", "UTF-8")
} catch {
    ExitApp
    MsgBox("Script failed to run.")
}
Loop {
    if (serialPort) {
        line := serialPort.ReadLine()
        if InStr(line, "DIST:") {
            rawVal := StrReplace(line, "DIST:")
            distance := Float(StrReplace(rawVal, "`n", ""))
            if (distance > 5 && distance <= 15) {
                Send "{Space}" 
                Sleep 200
            }
            else if (distance > 15 && distance <= 30) {
                Send "{Right}"
                Sleep 200
            }
        }
    }
    Sleep 10
} 