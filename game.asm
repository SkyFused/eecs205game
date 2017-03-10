; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 5
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

;; Keycodes
include keys.inc

;; Library Includes
include\masm32\include\windows.inc
include\masm32\include\winmm.inc
includelib\masm32\lib\winmm.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib


.DATA
  ;; Debugging strings
  collision_str    BYTE "Collision Detected", 0
  no_collision_str BYTE "No Collision Detected", 0
  mouse_str        BYTE "Mouse Pressed", 0
  p1_fire_str      BYTE "P1 fired!", 0
  p2_fire_str      BYTE "P2 fired!", 0
  tank_pos_str     BYTE "x: %d", 0
  tank_pos_out     BYTE 16 DUP (0)

  ;; Sounds
  fire_snd         BYTE "fire_01.wav", 0

  ;; Game info strings
  paused_msg       BYTE "Game Paused", 0
  unpause_msg      BYTE "Press tab to resume!", 0

  p1_win_str       BYTE "Game Over: P1 Won!!", 0
  p2_win_str       BYTE "Game Over: P2 Won!!", 0
  restart_str      BYTE "Press esc to restart.", 0

  score_str        BYTE "$%d", 0
  score_out        BYTE 32 DUP (0)

  health_str       BYTE "HP: %d", 0
  health_out       BYTE 16 DUP (0)

  salvo_str        BYTE "Salvos: %d", 0
  salvo_out        BYTE 8 DUP (0)

  ;; Game state vars
  paused_state   DWORD 0
  tabloop_active DWORD 0
  tabinit_active DWORD 0
  MaxVelo        DWORD 5
  MaxVeloNeg     DWORD -5
  P1Wrench_active DWORD 0
  P2Wrench_active DWORD 0

  ;; Sprite struct declarations
  Player1 PLAYER< >
  Player2 PLAYER< >

  P1Shot BULLET< >
  P2Shot BULLET< >

  WALL1 OBJECT< >
  WALL2 OBJECT< >
  WALL3 OBJECT< >

  HEALTHBOX BULLET< >

  P1AIM ROTSPRT< >
  P2AIM ROTSPRT< >

  P1SALVO BULLET 5 DUP (< >)
  P2SALVO BULLET 5 DUP (< >)

  ;; Collision helper vars
  xCollide DWORD 0
  yCollide DWORD 0

.CODE

;; Clear the screen (fill entire thing with dark blue)
ClearScreen PROC USES eax ebx

  ;; Find end of screen
  LOCAL ScreenBitsEnd:DWORD

  ;; Set up loop for clearing
  mov eax, ScreenBitsPtr
  mov ebx, ScreenBitsPtr
  add ebx, 307199
  mov ScreenBitsEnd, ebx

  clearLoop:
  ;; Write the color byte to the whole screen
  mov (BYTE PTR [eax]), 001h
  inc eax

  ;; 640 * 480 = 307,200 - 1 for zero index
  ;; Loop through entire screen array
  cmp eax, ScreenBitsEnd
  jl clearLoop

  ret
ClearScreen ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Imaginary Motor 4® (Collision Detection)
CheckIntersect PROC USES ebx oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
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
;; Like Unity Start() func, runs once at startup
GameInit PROC

  ;; Initialize P1 at (50,380)
  mov Player1.bitmap, OFFSET P1TANK
  mov eax, 100
  shl eax, 16
  mov Player1.posX, eax

  mov eax, 380
  shl eax, 16
  mov Player1.posY, eax

  ;; P1 goes first
  mov Player1.is_turn, 1

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Initialize P2 at (550, 380)
  mov Player2.bitmap, OFFSET P2TANK

  mov eax, 550
  shl eax, 16
  mov Player2.posX, eax

  mov eax, 380
  shl eax, 16
  mov Player2.posY, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Initialize P1 projectile at P1 start pos
  mov P1Shot.bitmap, OFFSET SHOT_01

  mov eax, 50
  shl eax, 16
  mov P1Shot.posX, eax

  mov eax, 380
  shl eax, 16
  mov P1Shot.posY, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Initialize P2 projectile at P2 start pos
  mov P2Shot.bitmap, OFFSET SHOT_01

  mov eax, 550
  shl eax, 16
  mov P2Shot.posX, eax

  mov eax, 380
  shl eax, 16
  mov P2Shot.posY, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Initialize 3 wall objects on top of each other, in the middle
  mov WALL1.bitmap, OFFSET WALL
  mov WALL2.bitmap, OFFSET WALL
  mov WALL3.bitmap, OFFSET WALL

  mov WALL1.is_active, 1
  mov WALL2.is_active, 1
  mov WALL3.is_active, 1

  mov eax, 320
  shl eax, 16

  mov WALL1.posX, eax
  mov WALL2.posX, eax
  mov WALL3.posX, eax

  mov eax, 384
  shl eax, 16
  mov WALL1.posY, eax

  mov eax, 352
  shl eax, 16
  mov WALL2.posY, eax

  mov eax, 320
  shl eax, 16
  mov WALL3.posY, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Initialize aim arrows
  mov P1AIM.bitmap, OFFSET ARROW

  mov eax, 50
  shl eax, 16
  mov P1AIM.posX, eax

  mov eax, 100
  shl eax, 16
  mov P1AIM.posY, eax

  mov eax, 0
  shl eax, 16
  mov P1AIM.angle, eax

  mov P1AIM.is_active, 1

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Initialize Health Powerup

  mov HEALTHBOX.bitmap, OFFSET WRENCH

  mov HEALTHBOX.dmg, -20

  mov eax, 320
  shl eax, 16
  mov HEALTHBOX.posX, eax

  mov eax, 100
  shl eax, 16
  mov HEALTHBOX.posY, eax

  mov HEALTHBOX.is_active, 0

	ret
GameInit ENDP

P1ShotPhysX PROC USES eax ebx ecx edx
  mov eax, P1Shot.accY
  sub P1Shot.velY, eax

  ;; Move the bullet
  mov eax, P1Shot.velX
  add P1Shot.posX, eax

  mov eax, P1Shot.velY
  sub P1Shot.posY, eax

  ;; Shift position and render bullet
  mov ebx, P1Shot.posX
  sar ebx, 16

  mov ecx, P1Shot.posY
  sar ecx, 16

  cmp ebx, 0
  jle p1_shot_dead

  cmp ebx, 640
  jge p1_shot_dead

  cmp ecx, 400
  jge p1_shot_dead


  push ebx
  push ecx

  INVOKE BasicBlit, P1Shot.bitmap, ebx, ecx

  pop ecx
  pop ebx

  ;; Collision Detection
  mov eax, Player2.posX
  sar eax, 16

  mov edx, Player2.posY
  sar edx, 16

  INVOKE CheckIntersect, ebx, ecx, P1Shot.bitmap, eax, edx, Player2.bitmap
  cmp eax, 1
  jne end_proj_1

  add Player1.score, 100
  sub Player2.health, 10

  ;; Shot dead
  p1_shot_dead:
  mov P1Shot.is_active, 0
  mov Player1.reloaded, 1

  end_proj_1:
  ret
P1ShotPhysX ENDP

P2ShotPhysX PROC USES eax ebx ecx edx
  mov eax, P2Shot.accY
  sub P2Shot.velY, eax

  ;; Move the bullet
  mov eax, P2Shot.velX
  add P2Shot.posX, eax

  mov eax, P2Shot.velY
  sub P2Shot.posY, eax

  ;; Shift position and render bullet
  mov ebx, P2Shot.posX
  sar ebx, 16

  mov ecx, P2Shot.posY
  sar ecx, 16

  cmp ebx, 0
  jle p2_shot_dead

  cmp ebx, 640
  jge p2_shot_dead

  cmp ecx, 400
  jge p2_shot_dead

  push ebx
  push ecx

  INVOKE BasicBlit, P2Shot.bitmap, ebx, ecx

  pop ecx
  pop ebx

  ;; Collision Detection
  mov eax, Player1.posX
  sar eax, 16

  mov edx, Player1.posY
  sar edx, 16

  INVOKE CheckIntersect, ebx, ecx, P2Shot.bitmap, eax, edx, Player1.bitmap
  cmp eax, 1
  jne end_proj_2

  add Player2.score, 100
  sub Player1.health, 10

  ;; Shot dead
  p2_shot_dead:
  mov Player2.reloaded, 1
  mov P2Shot.is_active, 0

  end_proj_2:
  ret
P2ShotPhysX ENDP

P1WrenchPhysX PROC USES eax ebx ecx edx

  mov HEALTHBOX.is_active, 1

  mov eax, HEALTHBOX.accY
  sub HEALTHBOX.velY, eax

  ;; Move the box
  mov eax, HEALTHBOX.velX
  add HEALTHBOX.posX, eax

  mov eax, HEALTHBOX.velY
  sub HEALTHBOX.posY, eax

  ;; Shift position and render box
  mov ebx, HEALTHBOX.posX
  sar ebx, 16

  mov ecx, HEALTHBOX.posY
  sar ecx, 16

  push ebx
  push ecx

  INVOKE BasicBlit, HEALTHBOX.bitmap, ebx, ecx

  pop ecx
  pop ebx

  ;; Collision Detection
  mov eax, Player1.posX
  sar eax, 16

  mov edx, Player1.posY
  sar edx, 16

  INVOKE CheckIntersect, ebx, ecx, HEALTHBOX.bitmap, eax, edx, Player1.bitmap
  cmp eax, 1
  jne end_box_1

  mov eax, HEALTHBOX.dmg
  sub Player1.health, eax
  mov HEALTHBOX.is_active, 0
  mov P1Wrench_active, 0
  mov HEALTHBOX.velY, 0

  end_box_1:
  ret
P1WrenchPhysX ENDP

P2WrenchPhysX PROC USES eax ebx ecx edx

  mov HEALTHBOX.is_active, 1

  mov eax, HEALTHBOX.accY
  sub HEALTHBOX.velY, eax

  ;; Move the box
  mov eax, HEALTHBOX.velX
  add HEALTHBOX.posX, eax

  mov eax, HEALTHBOX.velY
  sub HEALTHBOX.posY, eax

  ;; Shift position and render box
  mov ebx, HEALTHBOX.posX
  sar ebx, 16

  mov ecx, HEALTHBOX.posY
  sar ecx, 16

  push ebx
  push ecx

  INVOKE BasicBlit, HEALTHBOX.bitmap, ebx, ecx

  pop ecx
  pop ebx

  ;; Collision Detection
  mov eax, Player2.posX
  sar eax, 16

  mov edx, Player2.posY
  sar edx, 16

  INVOKE CheckIntersect, ebx, ecx, HEALTHBOX.bitmap, eax, edx, Player2.bitmap
  cmp eax, 1
  jne end_box_2

  mov eax, HEALTHBOX.dmg
  sub Player2.health, eax
  mov HEALTHBOX.is_active, 0
  mov P2Wrench_active, 0
  mov HEALTHBOX.velY, 0

  end_box_2:
  ret
P2WrenchPhysX ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The Game Loop
GamePlay PROC

  ;; Check player healths to see if anyone died
  mov eax, Player1.health
  cmp eax, 0
  jg p2_check

  INVOKE ClearScreen
  INVOKE DrawPauseField
  INVOKE DrawStr, OFFSET p2_win_str, 245, 220, 0ffh
  INVOKE DrawStr, OFFSET restart_str, 240, 240, 0ffh
  jmp FrameComplete

  p2_check:
  mov eax, Player2.health
  cmp eax, 0
  jg tab_checks

  INVOKE ClearScreen
  INVOKE DrawPauseField
  INVOKE DrawStr, OFFSET p1_win_str, 245, 220, 0ffh
  INVOKE DrawStr, OFFSET restart_str, 240, 240, 0ffh
  jmp FrameComplete

  tab_checks:
  ;; Game not paused, waiting for TAB to be released to pause
  cmp tabinit_active, 1
  je TABINIT

  ;; Game paused, waiting for TAB to be released to unpause
  cmp tabloop_active, 1
  je TABLOOP

  ;; Clear the screen on each runthrough to prevent artifacts
  INVOKE ClearScreen

  ;; Check right away if game is paused. Only render pause screen if it is
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
  jne FrameComplete

  mov tabinit_active, 1

  ;; TAB is being pressed, wait for it to be released
  TABINIT:
  cmp KeyPress, 0
  jne FrameComplete

  ;; Fallthrough: TAB was released, reset pause state and ret
  mov tabinit_active, 0
  mov paused_state, 0
  jmp FrameComplete

  draw_game:
  ;; Draw the background
  INVOKE DrawStarField
  INVOKE DrawRect, 0, 400, 639, 479, 0ffh

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Draw walls if active
  ;; cmp WALL1.is_active, 1
  ;; jne wall2_render
;;
  ;; mov eax, WALL1.posX
  ;; sar eax, 16
  ;; mov ebx, WALL1.posY
  ;; sar ebx, 16
  ;; INVOKE BasicBlit, WALL1.bitmap, eax, ebx
;;
  ;; wall2_render:
  ;; cmp WALL2.is_active, 1
  ;; jne wall3_render
;;
  ;; mov eax, WALL2.posX
  ;; sar eax, 16
  ;; mov ebx, WALL2.posY
  ;; sar ebx, 16
  ;; INVOKE BasicBlit, WALL2.bitmap, eax, ebx
;;
  ;; wall3_render:
  ;; cmp WALL3.is_active, 1
  ;; jne no_wall
;;
  ;; mov eax, WALL3.posX
  ;; sar eax, 16
  ;; mov ebx, WALL3.posY
  ;; sar ebx, 16
  ;; INVOKE BasicBlit, WALL3.bitmap, eax, ebx

  no_wall:
  ;; Draw the player health
  INVOKE VarToStr, Player1.health, OFFSET health_str, OFFSET health_out, 5, 100
  INVOKE VarToStr, Player2.health, OFFSET health_str, OFFSET health_out, 570, 100

  ;; Draw player scores
  INVOKE VarToStr, Player1.score, OFFSET score_str, OFFSET score_out, 5, 110
  INVOKE VarToStr, Player2.score, OFFSET score_str, OFFSET score_out, 570, 110

  ;; Draw player salvo counts
  ;; INVOKE VarToStr, P1Wrench_active, OFFSET salvo_str, OFFSET salvo_out, 5, 120
  ;; INVOKE VarToStr, P2Wrench_active, OFFSET salvo_str, OFFSET salvo_out, 550, 120


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Do a physics on Player1 and then draw it
  mov eax, Player1.accX
  add Player1.velX, eax

  mov eax, Player1.accY
  add Player1.velY, eax

  ;; Move the player
  mov eax, Player1.velX
  add Player1.posX, eax

  mov eax, Player1.velY
  add Player1.posY, eax

  ;; Shift positions from FXPT so that we can draw sprite
  mov ebx, Player1.posX
  sar ebx, 16

  mov ecx, Player1.posY
  sar ecx, 16

  ;; Draw Player1
  INVOKE BasicBlit, Player1.bitmap, ebx, ecx

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Do a physics on Player2 and then draw it
  mov eax, Player2.accX
  add Player2.velX, eax

  mov eax, Player2.accY
  add Player2.velY, eax

  ;; Move the player
  mov eax, Player2.velX
  add Player2.posX, eax

  mov eax, Player2.velY
  add Player2.posY, eax

  ;; Shift positions from FXPT so that we can draw them
  mov ebx, Player2.posX
  sar ebx, 16

  mov ecx, Player2.posY
  sar ecx, 16

  INVOKE BasicBlit, Player2.bitmap, ebx, ecx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Render and do physX if projectiles active
  cmp P1Shot.is_active, 1
  jne render_proj2

  INVOKE P1ShotPhysX

  render_proj2:
  cmp P2Shot.is_active, 1
  jne skip_proj

  INVOKE P2ShotPhysX

  skip_proj:
  ;; Powerup render logic
  cmp P1Wrench_active, 1
  jne wrench_checks2

  INVOKE P1WrenchPhysX
  jmp FrameComplete

  wrench_checks2:
  cmp P2Wrench_active, 1
  jne check_keys

  INVOKE P2WrenchPhysX
  jmp FrameComplete

  check_keys:
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if D key was pressed. If yes move P1 right, else brake
  mov eax, KeyPress
  cmp eax, VK_D
  jne DNotPressed

  ;; Set velocity
  mov eax, MaxVelo
  sal eax, 16
  mov Player1.velX, eax
  jmp FrameComplete

  ;; Stop moving if the key was not pressed
  DNotPressed:
  mov eax, 0
  sal eax, 16
  mov Player1.velX, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if A key was pressed. If yes move P1 left, else brake
  mov eax, KeyPress
  cmp eax, VK_A
  jne ANotPressed

  ;; Set velocity
  mov eax, MaxVeloNeg
  shl eax, 16
  mov Player1.velX, eax
  jmp FrameComplete

  ;; Stop moving if the key was not pressed
  ANotPressed:
  mov eax, 0
  sal eax, 16
  mov Player1.velX, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if left arrow was pressed. If yes move P2 left, else brake
  mov eax, KeyPress
  cmp eax, VK_LEFT
  jne LeftNotPressed

  ;; Set velocity
  mov eax, MaxVeloNeg
  shl eax, 16
  mov Player2.velX, eax
  jmp FrameComplete

  ;; Stop moving if the key was not pressed
  LeftNotPressed:
  mov eax, 0
  sal eax, 16
  mov Player2.velX, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if right arrow was pressed. If yes move P2 right, else brake
  mov eax, KeyPress
  cmp eax, VK_RIGHT
  jne RightNotPressed

  ;; Set velocity
  mov eax, MaxVelo
  shl eax, 16
  mov Player2.velX, eax
  jmp FrameComplete

  ;; Stop moving if the key was not pressed
  RightNotPressed:
  mov eax, 0
  sal eax, 16
  mov Player2.velX, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if S was pressed. If yes give P1 powerup
  mov eax, KeyPress
  cmp eax, VK_S
  jne SNotPressed

  ;; Do powerup stuff
  cmp Player1.score, 500
  jl DownNotPressed

  sub Player1.score, 500
  mov P1Wrench_active, 1

  mov eax, Player1.posX
  mov HEALTHBOX.posX, eax

  mov eax, 100
  shl eax, 16
  mov HEALTHBOX.posY, eax

  jmp FrameComplete

  SNotPressed:
  ;; Continue

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if down arrow was pressed. If yes give P2 powerup
  mov eax, KeyPress
  cmp eax, VK_DOWN
  jne DownNotPressed

  ;; Do powerup stuff
  cmp Player2.score, 500
  jl DownNotPressed

  sub Player2.score, 500
  mov P2Wrench_active, 1

  mov eax, Player2.posX
  mov HEALTHBOX.posX, eax

  mov eax, 100
  shl eax, 16
  mov HEALTHBOX.posY, eax

  jmp FrameComplete

  DownNotPressed:
  ;; Continue

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if W was pressed. If yes fire P1 projectile.
  mov eax, KeyPress
  cmp eax, VK_W
  jne next_fire

  ;; Do firing stuff
  cmp Player1.reloaded, 1
  jne next_fire

  mov P1Shot.is_active, 1
  mov Player1.reloaded, 0

  mov eax, Player1.posY
  sub eax, 0001B0000h ;; 20
  mov P1Shot.posY, eax

  mov eax, Player1.posX
  mov P1Shot.posX, eax

  mov eax, 10
  shl eax, 16
  mov P1Shot.velX, eax

  mov eax, 10
  shl eax, 16
  mov P1Shot.velY, eax

  INVOKE PlaySound, OFFSET fire_snd , 0, SND_FILENAME OR SND_ASYNC

  next_fire:
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if UP was pressed. If yes fire P2 projectile.
  mov eax, KeyPress
  cmp eax, VK_UP
  jne UpNotPressed

  cmp Player2.reloaded, 1
  jne UpNotPressed

  mov P2Shot.is_active, 1
  mov Player2.reloaded, 0

  mov eax, Player2.posY
  sub eax, 0001B0000h ;; 20
  mov P2Shot.posY, eax

  mov eax, Player2.posX
  mov P2Shot.posX, eax

  mov eax, -10
  shl eax, 16
  mov P2Shot.velX, eax

  mov eax, 10
  shl eax, 16
  mov P2Shot.velY, eax

  INVOKE PlaySound, OFFSET fire_snd , 0, SND_FILENAME OR SND_ASYNC

  UpNotPressed:
  ;; Continue

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Check if TAB was pressed. If yes , wait for it to be released, then
  ;; set the paused_state bool.
  mov eax, KeyPress
  cmp eax, VK_TAB
  jne FrameComplete

  mov tabloop_active, 1

  ;; TAB is currently down, wait until it is released.
  TABLOOP:
  cmp KeyPress, 0
  jne FrameComplete

  ;; TAB was released, set state and RET
  mov tabloop_active, 0
  mov paused_state, 1

  ;; We've finished doing something somewhere else, ret
  FrameComplete:
  ret
GamePlay ENDP

END
