; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;   Mateusz Ryczek - mrr958
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc

;; Has keycodes
include keys.inc

.DATA

;; If you need to, you can place global variables here


.CODE

;; Note: You will need to implement CheckIntersect!!!

GameInit PROC

	ret
GameInit ENDP


GamePlay PROC
  ;; Clear the screen on each runthrough to prevent artifacts
  INVOKE ClearScreen

	ret
GamePlay ENDP

CheckIntersect PROTO STDCALL oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP

  ret
CheckIntersect ENDP

;; Clear the screen
ClearScreen PROC USES eax

  ;; Set up loop for clearing
  mov eax, ScreenBitsPtr
  xor ebx, ebx

clearLoop:
  ;; Write the black color byte to the whole screen
  mov (BYTE PTR [eax]), bl
  inc eax

  ;; 640 * 480 = 307,200 - 1 for zero index
  ;; Loop through entire screen array
  cmp eax, 307199
  jle clearLoop

  ret
ClearScreen ENDP

END
