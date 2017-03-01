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

GameInit PROC

	ret
GameInit ENDP


GamePlay PROC
  ;; Clear the screen on each runthrough to prevent artifacts
  INVOKE ClearScreen

  ;; Draw a test star or 2
  INVOKE BasicBlit, OFFSET StarBitmap, 100, 100
  INVOKE BasicBlit, OFFSET StarBitmap, 200, 200

	ret
GamePlay ENDP

CheckIntersect PROC STDCALL oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
;; More comparisons than a 5th grader telling yo momma jokes
;; Upper Left: (one.x - bitmap.width / 2, one.y - bitmap.height / 2)
;; Upper Right: (one.x + bitmap.width / 2, one.y - bitmap.height / 2)
;; Bottom Left: (one.x - bitmap.width / 2, one.y + bitmap.height / 2)
;; Bottom Right: (one.x + bitmap.width / 2, one.y + bitmap.height / 2)


  ret
CheckIntersect ENDP

END
