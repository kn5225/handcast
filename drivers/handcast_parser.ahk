#Requires AutoHotkey v2.0
#SingleInstance Force
Esc:: ExitApp

PortNum := "COM5"
BaudRate := 115200

hPort := DllCall("CreateFile", "Str", "\\.\" PortNum, "UInt", 0xC0000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
if (hPort = -1 || hPort = 0) {
    MsgBox("Failed to open " PortNum "`nMake sure your Arduino Serial Monitor is closed.")
    ExitApp
}

DCB := Buffer(100, 0)
NumPut("UInt", 100, DCB, 0)

if !DllCall("BuildCommDCB", "Str", PortNum ":baud=" BaudRate " parity=N data=8 stop=1", "Ptr", DCB) {
    MsgBox("Failed to build COM settings.")
    DllCall("CloseHandle", "Ptr", hPort)
    ExitApp
}

if !DllCall("SetCommState", "Ptr", hPort, "Ptr", DCB) {
    MsgBox("Failed to apply baud rate to " PortNum)
    DllCall("CloseHandle", "Ptr", hPort)
    ExitApp
}

COMMTIMEOUTS := Buffer(20, 0)
NumPut("UInt", 0xFFFFFFFF, COMMTIMEOUTS, 0)
NumPut("UInt", 0, COMMTIMEOUTS, 4)
NumPut("UInt", 0, COMMTIMEOUTS, 8)
NumPut("UInt", 0, COMMTIMEOUTS, 12)
NumPut("UInt", 0, COMMTIMEOUTS, 16)

if !DllCall("SetCommTimeouts", "Ptr", hPort, "Ptr", COMMTIMEOUTS) {
    MsgBox("Failed to apply serial timeouts.")
    DllCall("CloseHandle", "Ptr", hPort)
    ExitApp
}

ToolTip("Listening on " PortNum "...")

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
