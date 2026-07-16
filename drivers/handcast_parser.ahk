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
closeZoneStart := 0
farZoneStart := 0
settleTime := 150
globalCooldown := 600

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
                        
                        currentTime := A_TickCount
                        
                        if (currentTime - lastSend > globalCooldown) {
                            if (distance > 5 && distance <= 15) {
                                farZoneStart := 0
                                
                                if (closeZoneStart = 0) {
                                    closeZoneStart := currentTime
                                } else if (currentTime - closeZoneStart > settleTime) {
                                    Send "{Space}" 
                                    lastSend := currentTime
                                    closeZoneStart := 0
                                }
                            }
                            else if (distance > 15 && distance <= 30) {
                                closeZoneStart := 0
                                
                                if (farZoneStart = 0) {
                                    farZoneStart := currentTime
                                } else if (currentTime - farZoneStart > settleTime) {
                                    Send "{Right}"
                                    lastSend := currentTime
                                    farZoneStart := 0
                                }
                            }
                            else {
                                closeZoneStart := 0
                                farZoneStart := 0
                            }
                        }
                    }
                }
            }
        }
    }
    Sleep 10
}