#Requires AutoHotkey v2.0
#SingleInstance Force
Esc:: ExitApp

PortNum := "COM5"
BaudRate := 115200

hPort := DllCall("CreateFile", "Str", "\\.\" PortNum, "UInt", 0xC0000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
if (hPort = -1) {
    MsgBox("Failed to open " PortNum)
    ExitApp
}

DCB := Buffer(28, 0)
NumPut("UInt", 28, DCB, 0)
DllCall("GetCommState", "Ptr", hPort, "Ptr", DCB)
NumPut("UInt", BaudRate, DCB, 4)
NumPut("UInt", 1, DCB, 8)
NumPut("UChar", 8, DCB, 18)
NumPut("UChar", 0, DCB, 19)
NumPut("UChar", 0, DCB, 20)
DllCall("SetCommState", "Ptr", hPort, "Ptr", DCB)

COMMTIMEOUTS := Buffer(20, 0)
NumPut("UInt", 0xFFFFFFFF, COMMTIMEOUTS, 0)
NumPut("UInt", 0, COMMTIMEOUTS, 4)
NumPut("UInt", 0, COMMTIMEOUTS, 8)
NumPut("UInt", 0, COMMTIMEOUTS, 12)
NumPut("UInt", 0, COMMTIMEOUTS, 16)
DllCall("SetCommTimeouts", "Ptr", hPort, "Ptr", COMMTIMEOUTS)

ToolTip("COM5 direct connection active...")
Sleep 1500

serialBuffer := ""
ReadBuf := Buffer(1024, 0)
BytesRead := Buffer(4, 0)

Loop {
    if DllCall("ReadFile", "Ptr", hPort, "Ptr", ReadBuf, "UInt", 1024, "Ptr", BytesRead, "Ptr", 0) {
        readCount := NumGet(BytesRead, 0, "UInt")
        if (readCount > 0) {
            newData := StrGet(ReadBuf, readCount, "UTF-8")
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
