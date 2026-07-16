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

ToolTip("COM5 Connected! Processing latest stream...")
Sleep 1500

lastSend := 0

Loop {
    if (serialPort) {
        rawStream := serialPort.Read(4096)
        
        if (rawStream != "") {
            lastIndex := InStr(rawStream, "DIST:", , -1)
            
            if (lastIndex) {
                targetData := SubStr(rawStream, lastIndex)
                
                if RegExMatch(targetData, "DIST:([\d\.]+)", &match) {
                    try {
                        distance := Float(match[1])
                        ToolTip("Real-time Distance: " distance " cm")
                        
                        if (A_TickCount - lastSend > 200) {
                            if (distance > 5 && distance <= 15) {
                                Send "{Space}" 
                                lastSend := A_TickCount
                            }
                            else if (distance > 15 && distance <= 30) {
                                Send "{Right}"
                                lastSend := A_TickCount
                            }
                        }
                    }
                }
            }
        }
    }
    Sleep 10
}