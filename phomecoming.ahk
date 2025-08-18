#Requires AutoHotkey v2.0
#SingleInstance Force

; ======================================================================
; INITIALIZATION
; ======================================================================

; Use Maps to store counters and timers for each key
; This allows us to track state independently for each hotkey
global counters := Map()  ; Tracks number of consecutive presses
global timers   := Map()  ; Stores timer references for reset

; List of keys we want to monitor for triple-press
global keys := ["f", "m", "y", "n", "g"]

; Initialize counters and timers for each key
for key in keys {
    counters[key] := 0  ; Start with 0 presses
    timers[key]   := 0  ; No active timers initially
}

; ======================================================================
; HOTKEY DEFINITIONS
; ======================================================================

; Define what happens when each key is pressed
; Format: $Key:: HandleKey("Key", ["Sequence", "Of", "Keys"], Timeout_ms)
$f:: HandleKey("f", ["F7", "Enter"],     1000)
$m:: HandleKey("m", ["t", "m", "Enter"], 1000)
$y:: HandleKey("y", ["t", "y", "Enter"], 1000)
$n:: HandleKey("n", ["t", "n", "Enter"], 1000)
$g:: HandleKey("g", ["t", "g", "Enter"], 1000)

; ======================================================================
; KEY HANDLER FUNCTION
; ======================================================================

; This function handles all key press logic
HandleKey(key, sequence, timeout) {
    global counters, timers
    
    ; Cancel any existing reset timer for this key
    if (timers[key]) {
        SetTimer(timers[key], 0)  ; Turn off the timer
        timers[key] := 0           ; Clear timer reference
    }
    
    ; Increase press counter for this key
    counters[key]++
    
    ; Check if we've reached 3 presses
    if (counters[key] >= 3) {
        ; Reset counters and timers
        counters[key] := 0
        timers[key]   := 0
        
        ; Send the predefined key sequence
        Loop sequence.Length {
            ; Send current key in sequence
            SendKey(sequence[A_Index])
            
            ; Add delay between keys (but not after last key)
            if (A_Index < sequence.Length)
                Sleep 150  ; 150ms delay between keys
        }
    } else {
        ; If not triple press yet, send normal key
        ; {Blind} preserves modifier keys (Shift, Ctrl, Alt)
        SendInput "{Blind}{" key "}"
        
        ; Set timer to reset counter after timeout period
        ; This creates the "triple-press window"
        timers[key] := SetTimer(ResetCount.Bind(key), -timeout)
    }
}

; ======================================================================
; HELPER FUNCTIONS
; ======================================================================

; Sends a key with proper down/up events
SendKey(key) {
    ; Send key down event
    SendInput "{" key " down}"
    ; Hold key for 10ms to ensure registration
    Sleep 10  
    ; Send key up event
    SendInput "{" key " up}"
}

; Resets the counter for a specific key
ResetCount(key) {
    global counters, timers
    counters[key] := 0  ; Reset press counter
    timers[key]   := 0  ; Clear timer reference
}

; ======================================================================
; END OF SCRIPT
; ======================================================================
