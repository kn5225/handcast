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

Loop {
    if (serialPort) {
        rawStream := serialPort.Read(2048)
        
        if (rawStream != "") {
            lastIndex := InStr(rawStream, "DIST:", , -1)
            
            if (lastIndex) {
                targetData := SubStr(rawStream, lastIndex)
                
                if RegExMatch(targetData, "DIST:([\d\.]+)", &match) {
                    try {
                        distance := Float(match[1])
                        ToolTip("Real-time Distance: " distance " cm")
                        
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
    }
    Sleep 30
}