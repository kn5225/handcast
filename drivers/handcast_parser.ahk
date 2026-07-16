#Requires AutoHotkey v2.0
#SingleInstance Force
Esc:: ExitApp

closeKey := "{Space}"
midKey   := "{Right}"
farKey   := "{Down}"

ib1 := InputBox("Enter key for Close Zone (5-20 cm):", "Macro Config", "w300 h130", closeKey)
if (ib1.Result = "OK" && ib1.Value != "")
    closeKey := ib1.Value

ib2 := InputBox("Enter key for Mid Zone (25-40 cm):", "Macro Config", "w300 h130", midKey)
if (ib2.Result = "OK" && ib2.Value != "")
    midKey := ib2.Value

ib3 := InputBox("Enter key for Far Zone (45-60 cm):", "Macro Config", "w300 h130", farKey)
if (ib3.Result = "OK" && ib3.Value != "")
    farKey := ib3.Value

RunWait(A_ComSpec ' /c mode COM5: baud=115200 parity=n data=8 stop=1 dtr=off', , "Hide")

try {
    serialPort := FileOpen("\\.\COM5", "r-d", "UTF-8")
} catch OSError {
    MsgBox("Failed to connect to COM5. Make sure your serial monitor is closed!")
    ExitApp
}

closeStart := midStart := farStart := 0
closeLatched := midLatched := farLatched := false
settleTime := 150

Loop {
    rawStream := ""
    while (serialPort.Length > 0) {
        rawStream := serialPort.Read(4096)
    }
    
    if (rawStream != "") {
        lastIndex := InStr(rawStream, "DIST:", , -1)
        
        if (lastIndex && RegExMatch(SubStr(rawStream, lastIndex), "DIST:([\d\.]+)", &match)) {
            try {
                distance := Float(match[1])
                now := A_TickCount

                if (distance > 5 && distance <= 20) {
                    midStart := farStart := 0
                    
                    if (closeStart = 0) {
                        closeStart := now
                    } else if (now - closeStart > settleTime) {
                        midLatched := farLatched := false
                        if (!closeLatched) {
                            Send closeKey
                            closeLatched := true
                        }
                    }
                }
                else if (distance > 25 && distance <= 40) {
                    closeStart := farStart := 0

                    if (midStart = 0) {
                        midStart := now
                    } else if (now - midStart > settleTime) {
                        closeLatched := farLatched := false
                        if (!midLatched) {
                            Send midKey
                            midLatched := true
                        }
                    }
                }
                else if (distance > 45 && distance <= 60) {
                    closeStart := midStart := 0

                    if (farStart = 0) {
                        farStart := now
                    } else if (now - farStart > settleTime) {
                        closeLatched := midLatched := false
                        if (!farLatched) {
                            Send farKey
                            farLatched := true
                        }
                    }
                }
                else {
                    closeStart := midStart := farStart := 0
                    closeLatched := midLatched := farLatched := false
                }
            }
        }
    }
    Sleep 10
}