#Requires AutoHotkey v2.0
#SingleInstance Force
Esc:: ExitApp

PortNum := "COM5"
BaudRate := 115200

try {
    serialPort := FileOpen("\\.\" PortNum, "r-d", "UTF-8")
} catch OSError as err {
    MsgBox("Failed to open " PortNum "`nError: " err.Message "`n`nMake sure the Arduino Serial Monitor is CLOSED.")
    ExitApp
}

hPort := serialPort.__Handle

DCB := Buffer(28, 0)
NumPut("UInt", 28, DCB, 0)
if !DllCall("GetCommState", "Ptr", hPort, "Ptr", DCB) {
    MsgBox("Failed to get serial state.")
    ExitApp
}

NumPut("UInt", BaudRate, DCB, 4) 
NumPut("UInt", 1, DCB, 8)        
NumPut("UChar", 8, DCB, 18)      
NumPut("UChar", 0, DCB, 19)      
NumPut("UChar", 0, DCB, 20)      

fState := NumGet(DCB, 8, "UInt")
fState |= 0x00000010             
NumPut("UInt", fState, DCB, 8)

if !DllCall("SetCommState", "Ptr", hPort, "Ptr", DCB) {
    MsgBox("Failed to set serial state.")
    ExitApp
}

COMMTIMEOUTS := Buffer(20, 0)
NumPut("UInt", 0xFFFFFFFF, COMMTIMEOUTS, 0) 
NumPut("UInt", 0,          COMMTIMEOUTS, 4) 
NumPut("UInt", 0,          COMMTIMEOUTS, 8) 
NumPut("UInt", 0,          COMMTIMEOUTS, 12)
NumPut("UInt", 0,          COMMTIMEOUTS, 16)

if !DllCall("SetCommTimeouts", "Ptr", hPort, "Ptr", COMMTIMEOUTS) {
    MsgBox("Failed to set serial timeouts.")
    ExitApp
}

ToolTip("Listening on COM5...")

serialBuffer := ""

Loop {
    if (serialPort) {
        if (newData := serialPort.Read(100)) {
            serialBuffer .= newData
            
            ToolTip("Raw Buffer: " serialBuffer)
            
            if RegExMatch(serialBuffer, "DIST:([\d\.]+)\r?\n", &match) {
                try {
                    distance := Float(match[1])
                    
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
            
            if (StrLen(serialBuffer) > 100) {
                serialBuffer := ""
            }
        }
    }
    Sleep 50
}
