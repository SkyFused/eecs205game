; #########################################################################
;
;   blit.inc - Includes for EECS205 Assignment 3
;
; #########################################################################


_EECS205BITMAP STRUCT
 dwWidth      DWORD  ?
 dwHeight     DWORD  ?
 bTransparent BYTE   ?
              BYTE   3 DUP(?)
 lpBytes      DWORD  ?
_EECS205BITMAP ENDS

EECS205BITMAP TYPEDEF _EECS205BITMAP

EXTERNDEF ScreenBitsPtr:DWORD

BasicBlit PROTO STDCALL ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD

RotateBlit PROTO STDCALL ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT

DrawRect PROTO STDCALL x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD, color:DWORD

VarToStr PROTO STDCALL Arg:DWORD, FormatStr:DWORD, OutStr:DWORD, x:DWORD, y:DWORD
