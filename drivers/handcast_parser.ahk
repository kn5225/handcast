#Requires AutoHotkey v2.0
#SingleInstance Force
Esc:: ExitApp

ComPort := "COM5" 
BaudRate := 115200

RunWait(A_ComSpec ' /c mode ' ComPort ': baud=' BaudRate ' parity=n data=8 stop=1 dtr=off', , "Hide")

try {
    serialPort := FileOpen("\\.\" ComPort, "r-d", "UTF-8")
} catch OSError as err {
    MsgBox("Script failed to run.`nError: " err.Message)
    ExitApp
}

Loop {
    if (serialPort) {
        line := serialPort.ReadLine()
        if InStr(line, "DIST:") {
            rawVal := StrReplace(line, "DIST:")
            
            cleanVal := StrReplace(StrReplace(rawVal, "`r", ""), "`n", "")
            
            try {
                distance := Float(cleanVal)
                
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
    }
    Sleep 10
}