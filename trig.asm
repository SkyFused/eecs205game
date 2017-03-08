; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 5
;   mrr958 - Mateusz Ryczek
;
; #########################################################################

.586
.MODEL FLAT,STDCALL
.STACK 4096
option casemap :none

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	              ;;  PI
TWO_PI	= 411774            ;;  2 * PI
PI_INC_RECIP =  5340353     ;;  Use reciprocal to find the table entry for a given angle

.CODE

FixedSinCalc PROC USES ebx edx angle:FXPT
  mov eax, angle                    ; copy angle to eax
  mov ebx, PI_INC_RECIP             ; ebx <- 256 / pi
  imul ebx                          ; edx:eax <-- r * (256 / pi). the int part we need is in edx entirely
  shl edx, 16                       ; truncate 16 MSB's of int in edx
  shr edx, 16                       ; truncate 16 MSB's of int in edx
  xor eax, eax                      ; clear trash in upper part of eax
  mov ax, [SINTAB + 2*edx]          ; lookup the value in table

  ret
FixedSinCalc ENDP

FixedSin PROC USES ebx ecx angle:FXPT
    mov ebx, angle                    ; make a copy of the angle for testing

  check_less_zero:
    cmp ebx, 0                        ; test supplied angle against 0
    jge check_greater_2pi             ; angle ≥ 0, check if angle < 2pi
    add ebx, TWO_PI                   ; if fell thru so angle < 0. add 2pi
    jmp check_less_zero               ; check again in case we need to add more

  check_greater_2pi:
    cmp ebx, TWO_PI                   ; check if angle > 2pi. sub 2pi until it's not
    jl  trig_quad_1                   ; 0 ≤ angle < 2pi so do some trig
    sub ebx, TWO_PI                   ; fell thru so angle ≥ 2pi. subtract 2pi
    jmp check_greater_2pi             ; try again after adding in case we need to sub more

  trig_quad_1:
    ; ebx is known to contain a radian r ∋ 0 ≤ r < τ
    cmp ebx, PI_HALF                  ; first quadrant check. if a ≤ pi / 2 look it up
    jg trig_quad_2                    ; angle > pi / 2, deal with it elsewhere

    invoke FixedSinCalc, ebx          ; calculate the angle
    jmp end_fixed_sin                 ; jump to ret

  trig_quad_2:
    ; ebx is known to contain a radian r ∋ (pi / 2) < r < τ
    cmp ebx, PI                       ; second quadrant check. if pi / 2 < a ≤ pi look it up
    jg trig_quad_3                    ; angle > pi, deal with it elsewhere

    ; do sin(x) = sin(pi - x)
    mov ecx, PI                       ; ecx <- PI
    sub ecx, ebx                      ; ecx <- PI - x

    invoke FixedSinCalc, ecx          ; calc angle
    jmp end_fixed_sin                 ; jump to ret

  trig_quad_3:
    ; ebx is known to contain a radian r ∋ pi < r < τ
    cmp ebx, PI + PI_HALF             ; third quadrant check. if pi < a ≤ 3pi / 4 look it up
    jg trig_quad_4                    ; angle > 3pi / 4, deal with it elsewhere

    ; sin(x + pi) = -sin(x)  so sub ebx, PI then invoke calc and neg result
    sub ebx, PI
    invoke FixedSinCalc, ebx
    neg eax
    jmp end_fixed_sin

  trig_quad_4:
    ; ebx is known to contain a radian r ∋ 3pi / 4 < r < τ
    mov ecx, TWO_PI                    ; ecx <- 2pi
    sub ecx, ebx                       ; ecx = 2pi - angle

    invoke FixedSinCalc, ecx           ; we've shifted to quadrant 1, calc angle
    neg eax                            ; adjust for 4th quadrant presence

  end_fixed_sin:
  	ret
FixedSin ENDP

FixedCos PROC USES ebx angle:FXPT
  mov ebx, angle                    ; clone angle into new reg
  add ebx, PI_HALF                  ; cos (x) = sin (x + Pi/2)
  invoke FixedSin, ebx              ; calculate "sin" and ret

	ret
FixedCos ENDP

END
