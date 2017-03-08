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
  ;; star header
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

  ;; star footer
  invoke DrawStar, 100, 360
  invoke DrawStar, 247, 365
  invoke DrawStar, 20,  370
  invoke DrawStar, 600, 375
  invoke DrawStar, 174, 380
  invoke DrawStar, 420, 385
  invoke DrawStar, 576, 390
  invoke DrawStar, 99,  395
  invoke DrawStar, 50,  400
  invoke DrawStar, 512, 405
  invoke DrawStar, 450, 410
  invoke DrawStar, 30,  415
  invoke DrawStar, 102, 420
  invoke DrawStar, 247, 425
  invoke DrawStar, 302, 405
  invoke DrawStar, 350, 375
  invoke DrawStar, 390, 420

  ;; star left side
  invoke DrawStar, 10,  120
  invoke DrawStar, 15,  420
  invoke DrawStar, 21,  367
  invoke DrawStar, 28,  334
  invoke DrawStar, 30,  213
  invoke DrawStar, 15,  405
  invoke DrawStar, 59,  403
  invoke DrawStar, 65,  100
  invoke DrawStar, 70,  125
  invoke DrawStar, 77,  344
  invoke DrawStar, 83,  169
  invoke DrawStar, 87,  225
  invoke DrawStar, 95,  315
  invoke DrawStar, 100, 375
  invoke DrawStar, 115, 402
  invoke DrawStar, 120, 275
  invoke DrawStar, 135, 250
  invoke DrawStar, 140, 219
  invoke DrawStar, 146, 284
  invoke DrawStar, 153, 117
  invoke DrawStar, 161, 400
  invoke DrawStar, 167, 225
  invoke DrawStar, 170, 114
  invoke DrawStar, 177, 198
  invoke DrawStar, 183, 174
  invoke DrawStar, 187, 313
  invoke DrawStar, 195, 305

  ;; star right side
  invoke DrawStar, 630,  120
  invoke DrawStar, 625,  420
  invoke DrawStar, 619,  367
  invoke DrawStar, 612,  334
  invoke DrawStar, 610,  213
  invoke DrawStar, 625,  405
  invoke DrawStar, 589,  403
  invoke DrawStar, 575,  100
  invoke DrawStar, 570,  125
  invoke DrawStar, 563,  344
  invoke DrawStar, 557,  169
  invoke DrawStar, 553,  225
  invoke DrawStar, 545,  315
  invoke DrawStar, 540, 375
  invoke DrawStar, 525, 402
  invoke DrawStar, 520, 275
  invoke DrawStar, 505, 250
  invoke DrawStar, 500, 219
  invoke DrawStar, 494, 284
  invoke DrawStar, 487, 117
  invoke DrawStar, 479, 400
  invoke DrawStar, 473, 225
  invoke DrawStar, 470, 114
  invoke DrawStar, 463, 198
  invoke DrawStar, 457, 174
  invoke DrawStar, 453, 313
  invoke DrawStar, 445, 305

	ret
DrawPauseField ENDP


END
