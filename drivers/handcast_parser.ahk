#Requires AutoHotkey v2.0
#SingleInstance Force
Esc:: ExitApp

PortNum := "COM5"
BaudRate := 115200

RunWait(A_ComSpec ' /c mode ' PortNum ': baud=' BaudRate ' parity=n data=8 stop=1 dtr=off', , "Hide")

try {
    serialPort := FileOpen("\\.\" PortNum, "r-d", "UTF-8")
} catch OSError as err {
    MsgBox("Failed to open " PortNum "`nError: " err.Message)
    ExitApp
}

ToolTip("COM5 Active! Move your hand to test...")
Sleep 1500

serialBuffer := ""

Loop {
    if (serialPort) {
        if (newData := serialPort.Read(100)) {
            serialBuffer .= newData
            
            if RegExMatch(serialBuffer, "DIST:([\d\.]+)\r?\n", &match) {
                try {
                    distance := Float(match[1])
                    ToolTip("Distance: " distance " cm")
                    
                    if (distance > 5 && distance <= 15) {
                        Send "{Space}" 
                        Sleep 200
                    }
                    else if (distance > 15 && distance <= 30) {
                        Send "{Right}"
                        Sleep 200
                    }
                }
                
                serialBuffer := "" 
            }
            
            if (StrLen(serialBuffer) > 500) {
                serialBuffer := ""
            }
        }
    }
    Sleep 50
}
