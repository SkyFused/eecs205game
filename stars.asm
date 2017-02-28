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

DrawStarField proc

        invoke DrawStar,  100,10
        invoke DrawStar,  247,15
        invoke DrawStar,  20,20
        invoke DrawStar,  600,25
        invoke DrawStar,  174,30
        invoke DrawStar,  420,35
        invoke DrawStar,  576,40
        invoke DrawStar,  99,45
        invoke DrawStar,  50,50
        invoke DrawStar,  512,55
        invoke DrawStar,  450,60
        invoke DrawStar,  30,65
        invoke DrawStar,  102,70
        invoke DrawStar,  247,75
        invoke DrawStar,  302, 55
        invoke DrawStar,  350, 25
        invoke DrawStar,  390, 70

	ret  			; Careful! Don't remove this line
DrawStarField endp



END
