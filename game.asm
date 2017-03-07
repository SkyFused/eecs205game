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
collision_str    BYTE "Collision Detected", 0
no_collision_str BYTE "No Collision Detected", 0
mouse_str        BYTE "Mouse Pressed", 0

;; Sprite struct declarations
movableStar SPRITE< >
testStar  SPRITE< >

.CODE

;; Clear the screen
ClearScreen PROC USES eax ebx

  ;; Find end of screen
  LOCAL ScreenBitsEnd:DWORD

  ;; Set up loop for clearing
  mov eax, ScreenBitsPtr
  mov ebx, ScreenBitsPtr
  add ebx, 307199
  mov ScreenBitsEnd, ebx
  xor ebx, ebx

clearLoop:
  ;; Write the black color byte to the whole screen
  mov (BYTE PTR [eax]), bl
  inc eax

  ;; 640 * 480 = 307,200 - 1 for zero index
  ;; Loop through entire screen array
  cmp eax, ScreenBitsEnd
  jl clearLoop

  ret
ClearScreen ENDP

CheckIntersect PROC USES ebx ecx edx oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP,
twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
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
  shl ebx, 1
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
  shl ebx, 1
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
  shl ebx, 1
  add ecx, ebx
  mov twoBottomEdge, ecx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check for intersections between boxes

  ;; If there's no collision this will be set to 0
  mov eax, 1

  ;; If (oneRightEdge < twoLeftEdge) we're clear
  mov ebx, oneRightEdge
  cmp ebx, twoLeftEdge
  jl no_collision

  ;; If (oneBottomEdge < twoTopEdge) we're clear
  mov ebx, oneBottomEdge
  cmp ebx, twoTopEdge
  jl no_collision

  ;; If (oneLeftEdge > twoRightEdge) we're clear
  mov ebx, oneLeftEdge
  cmp ebx, twoRightEdge
  jg no_collision

  ;; If (oneTopEdge > twoBottomEdge) we're clear
  mov ebx, oneTopEdge
  cmp ebx, twoBottomEdge
  jg no_collision

  ;; Fell through so return eax (1)
  jmp Intersect_Done

;; A gap between sprites was detected = no intersection, return eax (0)
no_collision:
  mov eax, 0

Intersect_Done:
  ret
CheckIntersect ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameInit PROC
  ;; Initialize the movableStar object at (100,320)
  mov movableStar.bitmap, OFFSET StarBitmap
  mov eax, 100
  shl eax, 16
  mov movableStar.posX, eax

  mov eax, 320
  shl eax, 16
  mov movableStar.posY, eax

  ;; Set vel and acc'l to 0
  xor eax, eax

  mov movableStar.velX, eax
  mov movableStar.velY, eax
  mov movableStar.accX, eax
  mov movableStar.accY, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Initialize static star
  mov testStar.bitmap, OFFSET StarBitmap

  mov eax, 420
  shl eax, 16
  mov testStar.posX, eax

  mov eax, 320
  shl eax, 16
  mov testStar.posY, eax

  ;; Set vel and acc'l to 0
  xor eax, eax

  mov testStar.velX, eax
  mov testStar.velY, eax
  mov testStar.accX, eax
  mov testStar.accY, eax

	ret
GameInit ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GamePlay PROC
  ;; Clear the screen on each runthrough to prevent artifacts
  INVOKE ClearScreen

  ;; Draw the background
  INVOKE DrawStarField

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Do a physics on the movableStar and then draw it
  mov eax, movableStar.accX
  add movableStar.velX, eax

  mov eax, movableStar.accY
  add movableStar.velY, eax

  ;; Move the sprite
  mov eax, movableStar.velX
  add movableStar.posX, eax

  mov eax, movableStar.velY
  add movableStar.posY, eax

  ;; Shift positions from FXPT so that we can draw them
  mov ebx, movableStar.posX
  sar ebx, 16

  mov ecx, movableStar.posY
  sar ecx, 16

  ;; Draw our movableStar
  INVOKE BasicBlit, movableStar.bitmap, ebx, ecx

  ;; Draw the testStar
  mov ebx, testStar.posX
  sar ebx, 16

  mov ecx, testStar.posY
  sar ecx, 16
  INVOKE BasicBlit, testStar.bitmap, ebx, ecx

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if the 2 sprites intersect
  mov eax, movableStar.posX
  mov ebx, movableStar.posY

  mov ecx, testStar.posX
  mov edx, testStar.posY
  INVOKE CheckIntersect, eax, ebx, movableStar.bitmap, ecx, edx, testStar.bitmap

  ;; See what CheckIntersect returned, and notify on-screen accordingly
  ;; 0 means no collision
  ;; 1 means collision
  cmp eax, 0
  je print_no_collision

  ;; fell through so there was a collision, print that
  INVOKE DrawStr, OFFSET collision_str, 400, 400, 0ffh
  jmp away

print_no_collision:
  INVOKE DrawStr, OFFSET no_collision_str, 400, 400, 0ffh

away:
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if D key was pressed. If yes move right, else fall through
  mov eax, KeyPress
  cmp eax, VK_D
  jne DNotPressed

  ;; Set velocity
  mov eax, 10
  sal eax, 16
  mov movableStar.velX, eax
  jmp GamePlayDone

  ;; Stop moving if the key was not pressed
DNotPressed:
  mov eax, 0
  sal eax, 16
  mov movableStar.velX, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if A key was pressed. If yes move left, else fall through
  mov eax, KeyPress
  cmp eax, VK_A
  jne ANotPressed

  ;; Set velocity
  mov eax, -10
  shl eax, 16
  mov movableStar.velX, eax
  jmp GamePlayDone

  ;; Stop moving if the key was not pressed
ANotPressed:
  mov eax, 0
  sal eax, 16
  mov movableStar.velX, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if LMB was pressed. If yes move testStar up, else ret
  mov eax, MouseStatus.buttons
  cmp eax, MK_LBUTTON
  jne GamePlayDone

  ;; Move testStar
  mov eax, -5
  shl eax, 16
  add testStar.posY,eax
  INVOKE DrawStr, OFFSET mouse_str, 200, 400, 0ffh

;; We've finished doing something somewhere else, ret
GamePlayDone:
  ret

GamePlay ENDP

END
