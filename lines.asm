; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;   Mateusz Ryczek
;
;
; #########################################################################

      .686
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD

   	LOCAL delta_x:DWORD, delta_y:DWORD,
          inc_x:DWORD, inc_y:DWORD,
          curr_x:DWORD, curry:DWORD,
          error:DWORD, prev_error:DWORD

  ;; delta_x = abs(x1-x0)
  mov eax,x1    ;; eax <- x1
  sub eax,x0    ;; compute x1-x0 (delta_x)
  mov ebx, eax  ;; ebx <- eax
  neg eax       ;; eax <- -eax
  cmovns eax,ebx ;;if neg of eax (delta_x) was -, initially it was +, so restore. otherwise eax now +.
  mov delta_x, eax

  ;; delta_y = abs(y1-y0)
  mov eax,y1    ;; eax <- x1
  sub eax,y0    ;; compute y1-y0 (delta_y)
  mov ebx, eax  ;; ebx <- eax
  neg eax       ;; eax <- -eax
  cmovns eax,ebx ;; same logic as above
  mov delta_y, eax

  mov eax, x0
  cmp x1, eax   ;; (x1 > x0)?
  jle set_x
  mov inc_x, 1
  jmp done_x
set_x:
  mov inc_x, -1
done_x:

  mov eax, y0
  cmp y1, eax  ;; (y1 > y0)?
  jle set_y
  mov inc_y, 1
  jmp done_y
set_y:
  mov inc_y, -1
done_y:

  ;; if (delta_x > delta_y)
  mov eax,delta_x
  cmp eax,delta_y
  jle else_
  shr eax,1         ;; quick divide
  mov error,eax
  jmp break
else_:
  mov eax,delta_y
  shr eax,1         ;; quick divide
  neg eax
  mov error,eax
break:

  ;; Make some curry for dinner
  mov eax,x0
  mov ebx,y0
  mov curr_x,eax
  mov curry,ebx

  ;; Draw first pixel
  invoke DrawPixel, curr_x, curry, color

  ;; Start while loopin
  jmp eval

body:
  invoke DrawPixel, curr_x, curry, color

  mov eax,error
  mov prev_error,eax ;; prev_error = error

  mov ebx,delta_x
  neg ebx
  cmp prev_error,ebx  ;; if (prev_error > - delta_x) ? error = error - delta_y : curr_x = curr_x + inc_x
  jle next_if         ;; if condition not met jump to next if
  mov eax,delta_y
  sub error,eax       ;; error = error - delta_y
  mov eax,curr_x
  add eax,inc_x       ;; curr_x = curr_x + inc_x
  mov curr_x,eax

next_if:
  mov eax,delta_y
  cmp prev_error,eax  ;; if (prev_error < delta_y) ? error = error + delta_x : curr_y = curr_y + inc_y
  jge eval            ;; if condition not met just to while evaluation
  mov eax,delta_x
  add error,eax       ;; error = error + delta_x
  mov eax,curry
  add eax,inc_y       ;; curry = curry + inc_y
  mov curry, eax

eval:
  mov eax,curr_x
  cmp eax,x1  ;;eax has curr_x from line 78
  jne body    ;; OR satisfied, execute body

  mov eax,curry
  cmp eax,y1  ;; first condition not satisfied, trying 2nd
  jne body    ;; OR satisfied, execute body

  ret        	;; Lord OR is not pleased, end subroutine

DrawLine ENDP

END
