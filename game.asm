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
;; Collision detection printing strings
str_collision    BYTE "Collision Detected",0
str_no_collision BYTE "No Collision Detected",0

;; Sprite struct declarations
deathStar SPRITE< >

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
  ;; Initialize the deathStar object at (100,320)
  mov eax, 100
  shl eax, 16

  mov deathStar.posX, eax

  mov eax, 320
  shl eax, 16
  mov deathStar.posY, eax

  ;; Set vel and acc'l to 0
  xor eax, eax

  mov deathStar.velX, eax
  mov deathStar.velY, eax
  mov deathStar.accX, eax
  mov deathStar.accY, eax

	ret
GameInit ENDP


GamePlay PROC
  ;; Clear the screen on each runthrough to prevent artifacts
  INVOKE ClearScreen

  ;; Draw our backdrop
  INVOKE DrawStarField

  ;; Draw a test star that we will crash into
  INVOKE BasicBlit, OFFSET StarBitmap, 420, 320

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Do a Newton on the DeathStar and then draw it
  mov eax, deathStar.accX
  add deathStar.velX, eax

  mov eax, deathStar.accY
  add deathStar.velY, eax

  ;; Move the sprite
  mov eax, deathStar.velX
  add deathStar.posX, eax

  mov eax, deathStar.velY
  add deathStar.posY, eax

  ;; Shift positions from FXPT so that we can draw them
  mov eax, deathStar.posX
  sar eax, 16

  mov ebx, deathStar.posY
  sar ebx, 16

  ;; Draw our moved (or not) star
  INVOKE BasicBlit, OFFSET StarBitmap, eax, ebx

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if the 2 sprites intersection
  INVOKE CheckIntersect, eax, ebx, OFFSET StarBitmap, 420, 320, OFFSET StarBitmap

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if D key was pressed. If yes move right, else JMP done.
  mov eax, KeyPress
  cmp eax, VK_D
  jne GamePlayDone

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Set velocity
  mov eax, 10
  sal eax, 16
  mov deathStar.velX, eax

GamePlayDone:
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

  ;; We fell through so there's been an intersection, return eax (1) & notify
  INVOKE DrawStr, OFFSET str_collision, 0, 460, 0ffh
  ret

;; A gap between sprites was detected = no intersection, return eax (0) & notify
no_collision:
  INVOKE DrawStr, OFFSET str_no_collision, 0, 460, 0ffh
  sub eax, 1
  ret
CheckIntersect ENDP

END
