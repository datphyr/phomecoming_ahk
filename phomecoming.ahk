#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================================================================
; SECTION 1: CONFIGURATION - ADJUST THESE VALUES AS NEEDED
; =========================================================================
global INTER_KEY_DELAY      := 200   ; Delay between keys in sequences (ms)
global KEY_PRESS_DURATION   := 100   ; Duration to hold each key down (ms)
global TRIPLE_PRESS_TIMEOUT := 1000  ; Time window for triple press (ms)

; =========================================================================
; SECTION 2: INITIALIZATION
; =========================================================================

; Use Maps to store counters and timers for each key
global counters := Map()  ; Tracks number of consecutive presses
global timers   := Map()  ; Stores timer references for reset

; List of keys we want to monitor for triple-press
global keys := ["f", "m", "y", "n", "g"]

; Initialize counters and timers for each key
for key in keys {
  counters[key] := 0  ; Start with 0 presses
  timers[key]   := 0  ; No active timers initially
}

; =========================================================================
; SECTION 3: HOTKEY DEFINITIONS
; =========================================================================

; Define what happens when each key is pressed
; Format: $Key:: HandleKey("Key", ["Sequence", "Of", "Keys"])
$f:: HandleKey("f", ["F7", "Enter"])
$m:: HandleKey("m", ["t", "m", "Enter"])
$y:: HandleKey("y", ["t", "y", "Enter"])
$n:: HandleKey("n", ["t", "n", "Enter"])
$g:: HandleKey("g", ["t", "g", "Enter"])

; =========================================================================
; SECTION 4: KEY HANDLER FUNCTION
; =========================================================================

; This function handles all key press logic
HandleKey(key, sequence) {
  global counters, timers, INTER_KEY_DELAY, TRIPLE_PRESS_TIMEOUT
  
  ; Cancel any existing reset timer for this key
  if (timers[key]) {
    SetTimer(timers[key], 0)  ; Turn off the timer
    timers[key] := 0          ; Clear timer reference
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
        Sleep INTER_KEY_DELAY
    }
  } else {
    ; If not triple press yet, send normal key
    ; {Blind} preserves modifier keys (Shift, Ctrl, Alt)
    SendInput "{Blind}{" key "}"
    
    ; Set timer to reset counter after timeout period
    ; This creates the "triple-press window"
    timers[key] := SetTimer(ResetCount.Bind(key), -TRIPLE_PRESS_TIMEOUT)
  }
}

; =========================================================================
; SECTION 5: HELPER FUNCTIONS
; =========================================================================

; Sends a key with proper down/up events
SendKey(key) {
  global KEY_PRESS_DURATION
  
  ; Send key down event
  SendInput "{" key " down}"
  ; Hold key for specified duration to ensure registration
  Sleep KEY_PRESS_DURATION
  ; Send key up event
  SendInput "{" key " up}"
}

; Resets the counter for a specific key
ResetCount(key) {
  global counters, timers
  counters[key] := 0  ; Reset press counter
  timers[key]   := 0  ; Clear timer reference
}

; =========================================================================
; END OF SCRIPT
; =========================================================================
