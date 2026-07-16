#Requires AutoHotkey v2.0
#SingleInstance Force
Esc:: ExitApp

PortNum := "COM5"
BaudRate := 115200


RunWait(A_ComSpec ' /c mode ' PortNum ': baud=' BaudRate ' parity=n data=8 stop=1 dtr=off', , "Hide")


ComPort := "\\.\" PortNum

try {
    serialPort := FileOpen(ComPort, "r-d", "UTF-8")
} catch OSError as err {
    MsgBox("Failed to open " PortNum "`nError: " err.Message)
    ExitApp
}


Sleep 2000

Loop {
    if (serialPort) {
        line := serialPort.ReadLine()
        if (line != "") {
            if InStr(line, "DIST:") {
                rawVal := StrReplace(line, "DIST:")
                cleanVal := RegExReplace(rawVal, "[\r\n]") 
                
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
    }
    Sleep 10
}
