; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField PROC
  invoke DrawStar, 100, 10
  invoke DrawStar, 247, 15
  invoke DrawStar, 20,  20
  invoke DrawStar, 600, 25
  invoke DrawStar, 174, 30
  invoke DrawStar, 420, 35
  invoke DrawStar, 576, 40
  invoke DrawStar, 99,  45
  invoke DrawStar, 50,  50
  invoke DrawStar, 512, 55
  invoke DrawStar, 450, 60
  invoke DrawStar, 30,  65
  invoke DrawStar, 102, 70
  invoke DrawStar, 247, 75
  invoke DrawStar, 302, 55
  invoke DrawStar, 350, 25
  invoke DrawStar, 390, 70

	ret
DrawStarField ENDP

DrawPauseField PROC
  invoke DrawStar, 100, 10
  invoke DrawStar, 247, 15
  invoke DrawStar, 20,  20
  invoke DrawStar, 600, 25
  invoke DrawStar, 174, 30
  invoke DrawStar, 420, 35
  invoke DrawStar, 576, 40
  invoke DrawStar, 99,  45
  invoke DrawStar, 50,  50
  invoke DrawStar, 512, 55
  invoke DrawStar, 450, 60
  invoke DrawStar, 30,  65
  invoke DrawStar, 102, 70
  invoke DrawStar, 247, 75
  invoke DrawStar, 302, 55
  invoke DrawStar, 350, 25
  invoke DrawStar, 390, 70

  invoke DrawStar, 100, 410
  invoke DrawStar, 247, 415
  invoke DrawStar, 20,  420
  invoke DrawStar, 600, 425
  invoke DrawStar, 174, 430
  invoke DrawStar, 420, 435
  invoke DrawStar, 576, 440
  invoke DrawStar, 99,  445
  invoke DrawStar, 50,  450
  invoke DrawStar, 512, 455
  invoke DrawStar, 450, 460
  invoke DrawStar, 30,  465
  invoke DrawStar, 102, 470
  invoke DrawStar, 247, 475
  invoke DrawStar, 302, 455
  invoke DrawStar, 350, 425
  invoke DrawStar, 390, 470

	ret
DrawPauseField ENDP


END
