; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;   mrr958 - Mateusz Ryczek
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here

.CODE

DrawPixel PROC USES ebx x:DWORD, y:DWORD, color:DWORD
  ; screen width = x = 640px, height = y = 480px
  ; if given value outside of [0,639] for width or
  ; [0,479] for height, don't draw anthing.

  cmp x, 0
  jl clip_map

  cmp y, 0
  jl clip_map

  cmp x, 639
  jg clip_map

  cmp y, 479
  jg clip_map

  ; need to convert from [x,y] coords to an array index
  ; do ((y * 640) + x) to get index

  mov eax, 640
  mov ebx, y
  mul ebx
  add eax, x

  ; turn above index (stored in eax) into an address
  add eax, ScreenBitsPtr

  ; time to color!
  ; since color is a byte, we can just mov bl into address calculated above.
  mov ebx, color
  mov [eax], bl

clip_map:
	ret
DrawPixel ENDP

BasicBlit PROC USES ebx ecx edx edi esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
; Draw a bitmap of dwWidth and dwHeight centered at [xcenter, ycenter]
; We will draw pixel by pixel until entire array is drawn. Best way to do
; is a nested for loop with y on the outside and x inside (same reason as above).
; Also, start drawing from [0,0] of bitmap, so need to find that from center.
;
; Do:
; x_start = xcenter - (dwWidth / 2)
; y_startstartstart = ycenter - (dwHeight / 2)
;
; for(y = 0, y < dwHeight, y++){
;   for(x = 0, x < dwWidth, x++){
;     if(x !< 0 && x !> 639 && y !< 0 && y !> 479){
;       DrawPixel(x + x_start, y + y_startstartstart, color);
; }}}
;
; Store bitmap origin pointer in esi

LOCAL x_start:DWORD, y_start:DWORD

  mov esi, ptrBitmap

; find x_start
  mov eax, (EECS205BITMAP PTR [esi]).dwWidth
  mov ebx, xcenter
  sar eax, 1
  sub ebx, eax
  mov x_start, ebx

; find y_start
  mov eax, (EECS205BITMAP PTR [esi]).dwHeight
  mov ebx, ycenter
  sar eax, 1
  sub ebx, eax
  mov y_start, ebx

  ; clear y for loop counters. from this point on:
  ; x is in ecx
  ; y is in edi
  mov edi, 0

  ; Enter the Drag... err loop
  jmp outer_eval

outer_loop:
  ; just reset x each iteration of outer loop
  mov ecx, 0
  jmp inner_eval

inner_loop:
  mov eax, (EECS205BITMAP PTR [esi]).dwWidth     ; eax <- frame width (640)
  mul edi                                        ; edx:eax <- y * 640
  add eax, ecx                                   ; eax <- (y * 640) + x = current pixel index

  ; get color of current pixel
  mov ebx, (EECS205BITMAP PTR [esi]).lpBytes     ; edx <- color byte array start
  xor edx, edx
  mov dl, BYTE PTR [ebx + eax]

  ; calculate current drawing offsets (in array notation [x,y])
  add ecx, x_start                            ; current position = x + x_start
  add edi, y_start                            ; current position = y + y_start

  ; check array bounds and clipping, don't draw if out of bounds.
  cmp ecx, 0
  jl do_not_draw

  cmp ecx, 639
  jg do_not_draw

  cmp edi, 0
  jl do_not_draw

  cmp edi, 479
  jg do_not_draw

  ; check if we need to bTransparent
  xor eax, eax                                   ; pixel index no longer needed, clear it
  mov al, (EECS205BITMAP PTR [esi]).bTransparent ; mov special transparent byte into al
  cmp al, dl                                     ; if these are equal dont draw this pixel
  je do_not_draw

  ; we passed all the checks so we can actually draw
  invoke DrawPixel, ecx, edi, dl

do_not_draw:
  ; when a pixel just doesn't make the cut
  ; subtract out x_start and y_start from ebx and ecx
  ; also do x++

  sub ecx, x_start
  sub edi, y_start

  inc ecx

inner_eval:
  ; check inner loop
  cmp ecx, (EECS205BITMAP PTR [esi]).dwWidth
  jl inner_loop

  ; fall through condition so do y++
  inc edi

outer_eval:
  ; fall through to outer loop eval
  cmp edi, (EECS205BITMAP PTR [esi]).dwHeight
  jl outer_loop

	ret
BasicBlit ENDP

MulFixIntHelp PROC USES edx x:DWORD, y:FXPT
; Computers are gr8 @ doing menial tasks for us
; Here we exploit the poor thing to multiply a DWORD and FXPT
; converts the DWORD TO FXPT and multiplies, then returns int part

mov edx, x         ; migrate vars
mov eax, y         ; migrate vars
shl edx, 16        ; make x into an FXPT of the form ????.0000
imul edx           ; imul into a 32/32 FXPT where int part in edx and frac in eax
mov eax, edx       ; nobody cares about fractions, return the int : ^ )

ret
MulFixIntHelp ENDP

RotateBlit PROC USES ebx ecx edx esi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT

; 1:3-5 God said, Let there be vars; he willed it, and at once there were vars.
LOCAL cosa:FXPT, sina:FXPT, shiftX:DWORD, shiftY:DWORD, dstWidth:DWORD,
      dstHeight:DWORD, dstX:DWORD, dstY:DWORD, srcX:DWORD, srcY:DWORD

  invoke FixedCos, angle
  mov cosa, eax

  invoke FixedSin, angle
  mov sina, eax

  ; esi holds bitmap pointer
  mov esi, lpBmp

  ; shiftX = (dwWidth * cosa / 2)   - (dwHeight * sina / 2)
  invoke MulFixIntHelp, (EECS205BITMAP PTR [esi]).dwWidth, cosa  ; mult the stuff
  sar eax, 1                                                     ; divide by 2
  mov ebx, eax                                                   ; save eax for l8r

  invoke MulFixIntHelp, (EECS205BITMAP PTR [esi]).dwHeight, sina ; same concept
  sar eax, 1                                                     ; div by 2 again
  sub ebx, eax                                                   ; do the subtraction
  mov shiftX, ebx                                                ; store in proper var

  ; shiftY = (dwHeight * cosa / 2) +  (dwWidth * sina / 2)
  ; same as above again
  invoke MulFixIntHelp, (EECS205BITMAP PTR [esi]).dwHeight, cosa ; mult the stuff
  sar eax, 1                                                     ; divide by 2
  mov ebx, eax                                                   ; save eax for l8r

  invoke MulFixIntHelp, (EECS205BITMAP PTR [esi]).dwWidth, sina  ; same concept
  sar eax, 1                                                     ; div by 2 again
  add ebx, eax                                                   ; do the add
  mov shiftY, ebx

  ; dstWidth= dwWidth +  dwHeight;
  mov eax, (EECS205BITMAP PTR [esi]).dwWidth
  add eax, (EECS205BITMAP PTR [esi]).dwHeight
  mov dstWidth, eax

  ; dstHeight= dstWidth
  mov dstHeight, eax

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; FOR LOOP APPROACHING
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; it puts the -dstWidth in dstX or else it gets the ret again
  mov dstX, eax                    ; eax is still dstWidth from previous instr...
  neg dstX                         ; ... so store it and neg!
  jmp outer_eval_rot               ; test if we're even gonna go into this loop

outer_loop_rot:
  ; dstY = - dstHeight
  mov eax, dstHeight
  mov dstY, eax
  neg dstY
  jmp inner_eval_rot

inner_loop_rot:
  ; srcX = dstX*cosa + dstY*sina
  invoke MulFixIntHelp, dstX, cosa
  mov srcX, eax

  invoke MulFixIntHelp, dstY, sina
  add srcX, eax

  ; srcY = dstY*cosa – dstX*sina
  invoke MulFixIntHelp, dstY, cosa
  mov srcY, eax

  invoke MulFixIntHelp, dstX, sina
  sub srcY, eax

  ; *** Tactical if statement inbound ***
  ; *** IFCON LEVEL 1 ***

  ; srcX ≥ 0
  cmp srcX, 0
  jl dont_draw_rot

  ; srcX < (EECS205BITMAP PTR [esi]).dwWidth
  mov eax, (EECS205BITMAP PTR [esi]).dwWidth
  cmp srcX, eax
  jge dont_draw_rot

  ; srcY ≥ 0
  cmp srcY, 0
  jl dont_draw_rot

  ; srcY < (EECS205BITMAP PTR [esi]).dwHeight
  mov eax, (EECS205BITMAP PTR [esi]).dwHeight
  cmp srcY, eax
  jge dont_draw_rot

  ; (xcenter + dstX - shiftX) ≥ 0
  mov eax, dstX
  add eax, xcenter
  sub eax, shiftX
  cmp eax, 0
  jl dont_draw_rot

  ; (xcenter + dstX - shiftX) < 639
  mov eax, dstX
  add eax, xcenter
  sub eax, shiftX
  cmp eax, 639
  jge dont_draw_rot

  ; (ycenter + dstY - shiftY) ≥ 0
  mov eax, dstY
  add eax, ycenter
  sub eax, shiftY
  cmp eax, 0
  jl dont_draw_rot

  ; (ycenter + dstY - shiftY) < 479
  mov eax, dstY
  add eax, ycenter
  sub eax, shiftY
  cmp eax, 479
  jge dont_draw_rot

  ; bitmap pixel (srcX,srcY) != transparent
  ; this one rekt me last time, let's see
  ; how it goes this time...

  ; calculate color array index
  mov eax, (EECS205BITMAP PTR [esi]).dwWidth
  imul srcY
  add eax, srcX

  ; get color of pixel [srcX, srcY]
  mov ebx, (EECS205BITMAP PTR [esi]).lpBytes
  xor ecx, ecx
  mov cl, BYTE PTR [ebx + eax]

  ; if transparent, don't draw it
  xor eax, eax
  mov al, (EECS205BITMAP PTR [esi]).bTransparent
  cmp al, cl
  je dont_draw_rot

  ; FINALLY draw the damn pixel
  ; DrawPixel(xcenter + dstX - shiftX, ycenter + dstY - shiftY, bitmap pixel)

  ; xcenter + dstX - shiftX
  mov edx, dstX
  add edx, xcenter
  sub edx, shiftX

  ; ycenter + dstY - shiftY
  mov ebx, dstY
  add ebx, ycenter
  sub ebx, shiftY

  invoke DrawPixel, edx, ebx, cl

dont_draw_rot:
  inc dstY

inner_eval_rot:
  ; check dstY < dstHeight and do dstX++
  ; if not, then fall thru to outer eval
  mov eax, dstY
  cmp eax, dstHeight
  jl inner_loop_rot

  inc dstX

outer_eval_rot:
  ; check dstX < dstWidth
  ; if no then ret
  mov eax, dstX
  cmp eax, dstWidth
  jl outer_loop_rot

  ret
RotateBlit ENDP

END
