; #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

FXPT TYPEDEF SDWORD

ProjStruct STRUCT
  ;; bitmap to use for this object
  bitmap DWORD ?

  ;; boolean to track if active (render and do physX)
  is_active DWORD ?

  ;; Position of obj on screen
  posX   FXPT 0
  posY   FXPT 0

  ;; Velocity of obj
  velX   FXPT 0
  velY   FXPT 0

  ;; Acceleration of obj
  accX   FXPT 0
  accY   FXPT 10000h

  ;; Damage this projectile deals
  dmg DWORD ?
ProjStruct ENDS

PlayerStruct STRUCT
  ;; Bitmap to use for this player
  bitmap DWORD ?

  ;; Score of this player. Starting score 0
  score DWORD 0

  ;; Health of this player. Starting health 100
  health DWORD 100

  ;; boolean stored as DWORD, determines if it's this player's
  ;; turn to move, shoot, etc. By default is 0.
  is_turn DWORD 0

  ;; Number of salvos player can fire
  salvo_count DWORD 2

  ;; Position of player on screen
  posX   FXPT 0
  posY   FXPT 0

  ;; Velocity of player
  velX   FXPT 0
  velY   FXPT 0

  ;; Acceleration of player
  accX   FXPT 0
  accY   FXPT 0
PlayerStruct ENDS

ObjStruct STRUCT
  ;; bitmap to use for this object
  bitmap DWORD ?

  ;; boolean to track if active (render and do physX)
  is_active DWORD ?

  ;; Position of obj on screen
  posX   FXPT 0
  posY   FXPT 0

  ;; Velocity of obj
  velX   FXPT 0
  velY   FXPT 0

  ;; Acceleration of obj
  accX   FXPT 0
  accY   FXPT 0
ObjStruct ENDS

RotStruct STRUCT
  ;; bitmap to use for this object
  bitmap DWORD ?

  ;; boolean to track if active (render and do physX)
  is_active DWORD ?

  ;; Position of obj on screen
  posX   FXPT 0
  posY   FXPT 0

  ;; Velocity of obj
  velX   FXPT 0
  velY   FXPT 0

  ;; Acceleration of obj
  accX   FXPT 0
  accY   FXPT 0

  ;; Rotation of obj
  angle  FXPT 0
RotStruct ENDS

ROTSPRT TYPEDEF RotStruct
BULLET  TYPEDEF ProjStruct
PLAYER  TYPEDEF PlayerStruct
OBJECT  TYPEDEF ObjStruct

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD

;; sprites
EXTERNDEF P1TANK:EECS205BITMAP
EXTERNDEF P2TANK:EECS205BITMAP
EXTERNDEF SHOT_01:EECS205BITMAP
EXTERNDEF SHOT_02:EECS205BITMAP
EXTERNDEF SHOT_03:EECS205BITMAP
EXTERNDEF SHOT_04:EECS205BITMAP
EXTERNDEF WALL:EECS205BITMAP
EXTERNDEF ARROW:EECS205BITMAP
EXTERNDEF StarBitmap:EECS205BITMAP

;; User Defined Functions
GameInit PROTO
GamePlay PROTO
P1ShotPhysX PROTO
P2ShotPhysX PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
