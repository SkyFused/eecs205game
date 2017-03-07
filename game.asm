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
paused_msg       BYTE "Game Paused", 0
unpause_msg      BYTE "Press tab to resume!", 0

;; Game state vars
paused_state DWORD 0

;; Sprite struct declarations
Player1 OBJECT< >
Player2  OBJECT< >

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
  ;; Initialize P1 at (100,380)
  mov Player1.bitmap, OFFSET P1TANK
  mov eax, 100
  shl eax, 16
  mov Player1.posX, eax

  mov eax, 380
  shl eax, 16
  mov Player1.posY, eax

  ;; Set vel and acc'l to 0
  xor eax, eax

  mov Player1.velX, eax
  mov Player1.velY, eax
  mov Player1.accX, eax
  mov Player1.accY, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Initialize P2 at (500, 380)
  mov Player2.bitmap, OFFSET P2TANK

  mov eax, 500
  shl eax, 16
  mov Player2.posX, eax

  mov eax, 380
  shl eax, 16
  mov Player2.posY, eax

  ;; Set vel and acc'l to 0
  xor eax, eax

  mov Player2.velX, eax
  mov Player2.velY, eax
  mov Player2.accX, eax
  mov Player2.accY, eax

	ret
GameInit ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GamePlay PROC
  ;; Clear the screen on each runthrough to prevent artifacts
  INVOKE ClearScreen

  ;; Check right away if tab was pressed. Only render pause screen if yes
  mov eax, KeyPress
  cmp eax, VK_TAB
  jne tab_not_pressed

  ;; the tab key was pressed, check if game already paused
  cmp paused_state, 0
  jne draw_game
  mov paused_state, 1

draw_paused:
  INVOKE DrawPauseField
  INVOKE DrawStr, OFFSET paused_msg, 280, 220, 0ffh
  INVOKE DrawStr, OFFSET unpause_msg, 240, 240, 0ffh
  jmp GamePlayDone

tab_not_pressed:
  ;; tab was not pressed, check if we're paused tho
  mov eax, paused_state
  cmp eax, 1
  je draw_paused

draw_game:
  ;; Clear the pause state
  mov paused_state, 0
  
  ;; Draw the background
  INVOKE DrawStarField
  INVOKE DrawRect, 0, 400, 639, 479, 0ffh

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Do a physics on the Player1 and then draw it
  mov eax, Player1.accX
  add Player1.velX, eax

  mov eax, Player1.accY
  add Player1.velY, eax

  ;; Move the sprite
  mov eax, Player1.velX
  add Player1.posX, eax

  mov eax, Player1.velY
  add Player1.posY, eax

  ;; Shift positions from FXPT so that we can draw them
  mov ebx, Player1.posX
  sar ebx, 16

  mov ecx, Player1.posY
  sar ecx, 16

  ;; Draw our Player1
  INVOKE BasicBlit, Player1.bitmap, ebx, ecx

  ;; Draw the Player2
  mov ebx, Player2.posX
  sar ebx, 16

  mov ecx, Player2.posY
  sar ecx, 16
  INVOKE BasicBlit, Player2.bitmap, ebx, ecx

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if the 2 sprites intersect
  mov eax, Player1.posX
  mov ebx, Player1.posY

  mov ecx, Player2.posX
  mov edx, Player2.posY
  INVOKE CheckIntersect, eax, ebx, Player1.bitmap, ecx, edx, Player2.bitmap

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
  mov Player1.velX, eax
  jmp GamePlayDone

  ;; Stop moving if the key was not pressed
DNotPressed:
  mov eax, 0
  sal eax, 16
  mov Player1.velX, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if A key was pressed. If yes move left, else fall through
  mov eax, KeyPress
  cmp eax, VK_A
  jne ANotPressed

  ;; Set velocity
  mov eax, -10
  shl eax, 16
  mov Player1.velX, eax
  jmp GamePlayDone

  ;; Stop moving if the key was not pressed
ANotPressed:
  mov eax, 0
  sal eax, 16
  mov Player1.velX, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if LMB was pressed. If yes move Player2 up, else ret
  mov eax, MouseStatus.buttons
  cmp eax, MK_LBUTTON
  jne GamePlayDone

  ;; Move Player2
  mov eax, -5
  shl eax, 16
  add Player2.posY,eax
  INVOKE DrawStr, OFFSET mouse_str, 200, 400, 0ffh

;; We've finished doing something somewhere else, ret
GamePlayDone:
  ret

GamePlay ENDP

END
