; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;   Mateusz Ryczek - mrr958
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc

;; Has keycodes
include keys.inc

;; Screen Printing Includes
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

.DATA

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

  ;; Draw our backdrop
  INVOKE DrawStarField

  ;; Draw a test star or 2
  INVOKE BasicBlit, OFFSET StarBitmap, 100, 100
  INVOKE BasicBlit, OFFSET StarBitmap, 200, 200

	ret
GamePlay ENDP

CheckIntersect PROC USES ebx ecx edx oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
  ;; More comparisons than a 5th grader telling yo momma jokes
  ;;
  ;; Upper Left: (one.x - bitmap.width / 2, one.y - bitmap.height / 2)
  ;; Upper Right: (one.x + bitmap.width / 2, one.y - bitmap.height / 2)
  ;; Bottom Left: (one.x - bitmap.width / 2, one.y + bitmap.height / 2)
  ;; Bottom Right: (one.x + bitmap.width / 2, one.y + bitmap.height / 2)

  ;; Allocate some storage to keep track of box bounds
  LOCAL oneLeftEdge:DWORD, oneRightEdge:DWORD, oneTopEdge:DWORD, oneBottomEdge:DWORD
  LOCAL twoLeftEdge:DWORD, twoRightEdge:DWORD, twoTopEdge:DWORD, twoBottomEdge:DWORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create bounding box for first sprite

  mov edx, oneBitmap

  ;; oneLeftEdge = oneX - oneBitmap.dwWidth / 2
  mov ebx, (EECS205BITMAP PTR [edx]).dwWidth
  sar ebx, 1
  mov ecx, oneX
  sub ecx, ebx
  mov oneLeftEdge, ecx

  ;; oneRightEdge = oneLeftEdge + oneBitmap.dwWidth
  ;; simpler than dividing by 2 again and adding
  shl ebx, 1
  add ecx, ebx
  mov oneRightEdge, ecx

  ;; oneTopEdge = oneY - oneBitmap.dwHeight / 2
  mov ebx, (EECS205BITMAP PTR [edx]).dwHeight
  sar ebx, 1
  mov ecx, oneY
  sub ecx, ebx
  mov oneTopEdge, ecx

  ;; oneBottomEdge = oneTopEdge + oneBitmap.dwHeight
  ;; simpler than dividing by 2 again and adding
  sal ebx, 1
  add ecx, ebx
  mov oneBottomEdge, ecx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create bounding box for second sprite

  mov edx, twoBitmap

  ;; twoLeftEdge = twoX - twoBitmap.dwWidth / 2
  mov ebx, (EECS205BITMAP PTR [edx]).dwWidth
  sar ebx, 1
  mov ecx, twoX
  sub ecx, ebx
  mov twoLeftEdge, ecx

  ;; twoRightEdge = twoLeftEdge + twoBitmap.dwWidth
  ;; simpler than dividing by 2 again and adding
  sal ebx, 1
  add ecx, ebx
  mov twoRightEdge, ecx

  ;; twoTopEdge = twoY - twoBitmap.dwHeight / 2
  mov ebx, (EECS205BITMAP PTR [edx]).dwHeight
  sar ebx, 1
  mov ecx, twoY
  sub ecx, ebx
  mov twoTopEdge, ecx

  ;; twoBottomEdge = twoTopEdge + twoBitmap.dwHeight
  ;; simpler than dividing by 2 again and adding
  sal ebx, 1
  add ecx, ebx
  mov twoBottomEdge, ecx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check for intersections between boxes

  ;; If there's no intersection this will be set to 0
  mov eax, 1

  ;; If (oneRightEdge ≤ twoLeftEdge) we're clear
  mov ebx, oneRightEdge
  cmp ebx, twoLeftEdge
  jle no_collision

  ;; If (oneLeftEdge ≥ twoRightEdge) we're clear
  mov ebx, oneLeftEdge
  cmp ebx, twoRightEdge
  jge no_collision

  ;; If (oneBottomEdge ≤ twoTopEdge) we're clear
  mov ebx, oneBottomEdge
  cmp ebx, twoTopEdge
  jle no_collision

  ;; If (oneTopEdge ≥ twoBottomEdge) we're clear
  mov ebx, oneTopEdge
  cmp ebx, twoBottomEdge
  jge no_collision

  ;; We fell through so there's been an intersection, return eax (1)
  ret

;; A gap between sprites was detected so no intersection
no_collision:
  sub eax, 1
  ret
CheckIntersect ENDP

END
