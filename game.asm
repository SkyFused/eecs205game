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
paused_state   DWORD 0
tabloop_active DWORD 0
tabinit_active DWORD 0

;; Sprite struct declarations
Player1 OBJECT< >
Player2  OBJECT< >

;; Collision vars
xCollide DWORD 0
yCollide DWORD 0

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

CheckIntersect PROC USES ebx oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP,
twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
  ;; More comparisons than a 5th grader telling yo momma jokes
  ;;
  ;; return (((x.width / 2) + (y.width / 2)) < (abs (x1 - x2)) &&
  ;;        ((x.height / 2) + (y.height / 2)) < (abs (y1 -y2)))
  ;;
  ;; Calculate half-width and half-height for faster computes
  LOCAL oneHalfHeight:DWORD, oneHalfWidth:DWORD, twoHalfHeight:DWORD, twoHalfWidth:DWORD

  ;; Clear out collision vars from before
  mov xCollide, 0
  mov yCollide, 0

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Chop some widths and heights
  mov ebx, oneBitmap

  mov eax, (EECS205BITMAP PTR [ebx]).dwWidth
  sar eax, 1
  mov oneHalfWidth, eax

  mov eax,(EECS205BITMAP PTR [ebx]).dwHeight
  sar eax, 1
  mov oneHalfHeight, eax

  ;; Next bitmap
  mov ebx, twoBitmap

  mov eax, (EECS205BITMAP PTR [ebx]).dwWidth
  sar eax, 1
  mov twoHalfWidth, eax

  mov eax,(EECS205BITMAP PTR [ebx]).dwHeight
  sar eax, 1
  mov twoHalfHeight, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Compute x-axis intersection
  mov eax, oneHalfWidth
  add eax, twoHalfWidth

  mov ebx, twoX
  sub ebx, oneX
  cmp ebx, 0
  jg eval_x_axis

  ;; fell through; compute abs(ebx)
  neg ebx

eval_x_axis:
  cmp eax, ebx
  jl compute_y_axis

  ;; Fell through so there's potentially a collision on the x-axis.
  ;; Set the flag and check y-axis
  mov xCollide, 1

compute_y_axis:
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Compute y-axis intersection
  mov eax, oneHalfHeight
  add eax, twoHalfHeight

  mov ebx, twoY
  sub ebx, oneY
  cmp ebx, 0
  jg eval_y_axis

  ;; fell through; compute abs(ebx)
  neg ebx

eval_y_axis:
  cmp eax, ebx
  jl compute_intersect

  ;; Fell through so there's potentially a collision on the y-axis.
  ;; Set the flag and cross check with x-axis
  mov yCollide, 1

compute_intersect:
  mov eax, xCollide
  mov ebx, yCollide
  and eax, ebx

  ;; From the AND, eax will have either a 1 if collision or 0 if none.
  ;; In either case, return it.
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

  ;; Make sure game is not paused on startup
  mov paused_state, 0
  mov KeyPress, 0

	ret
GameInit ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GamePlay PROC
  ;; Game not paused, waiting for TAB to be released to pause
  cmp tabinit_active, 1
  je TABINIT

  ;; Game paused, waiting for TAB to be released to unpause
  cmp tabloop_active, 1
  je TABLOOP

  ;; Clear the screen on each runthrough to prevent artifacts
  INVOKE ClearScreen

  ;; Check right away if game is paused. Only render pause screen if yes
  cmp paused_state, 1
  jne draw_game

  ;; The game is paused. Draw it and check TAB keypress
draw_paused:
  INVOKE DrawPauseField
  INVOKE DrawStr, OFFSET paused_msg, 280, 220, 0ffh
  INVOKE DrawStr, OFFSET unpause_msg, 240, 240, 0ffh

  ;; Now check if TAB is currently being pressed
  mov eax, KeyPress
  cmp eax, VK_TAB
  jne GamePlayDone

  mov tabinit_active, 1
  ;; TAB is being pressed, wait for it to be released
TABINIT:
  cmp KeyPress, 0
  jne GamePlayDone

  ;; Fallthrough: TAB was released, reset pause state and ret
  mov tabinit_active, 0
  mov paused_state, 0
  jmp GamePlayDone

draw_game:
  ;; Draw the background
  INVOKE DrawStarField
  INVOKE DrawRect, 0, 400, 639, 479, 0ffh

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Do a physics on Player1 and then draw it
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

  ;; Draw Player1
  INVOKE BasicBlit, Player1.bitmap, ebx, ecx

  ;; Draw Player2
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
  INVOKE DrawStr, OFFSET collision_str, 300, 300, 0ffh
  jmp away

print_no_collision:
  INVOKE DrawStr, OFFSET no_collision_str, 300, 300, 0ffh

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
  jne MouseNotPressed

  ;; Move Player2
  mov eax, -5
  shl eax, 16
  add Player2.posY,eax
  INVOKE DrawStr, OFFSET mouse_str, 200, 400, 0ffh

MouseNotPressed:
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if TAB was pressed. If yes , wait for it to be released, then
  ;; set the paused_state bool.
  mov eax, KeyPress
  cmp eax, VK_TAB
  jne GamePlayDone

  mov tabloop_active, 1

  ;; TAB is currently down, wait until it is released.
TABLOOP:
  cmp KeyPress, 0
  jne GamePlayDone

  ;; TAB was released, set state and RET
  mov tabloop_active, 0
  mov paused_state, 1

;; We've finished doing something somewhere else, ret
GamePlayDone:
  ret

GamePlay ENDP

END
