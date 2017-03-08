; #########################################################################
;
;   sprites.asm - Assembly file for EECS205 Assignment 5
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


P2TANK EECS205BITMAP <50, 38, 0ffh,, offset P2TANK + sizeof P2TANK>
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,08dh,08dh,0b6h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0b6h,0b6h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,06dh,08dh,0dbh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0dbh,0ffh,0dbh,020h
	BYTE 000h,000h,092h,0d6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,049h,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,044h,069h,0b6h
	BYTE 049h,020h,08dh,08dh,000h,000h,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,08dh,020h,0b6h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,000h
	BYTE 020h,000h,020h,08ch,0b6h,0b6h,069h,020h,044h,049h,0b6h,092h,06dh,0ffh,0b6h,000h
	BYTE 06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h
	BYTE 049h,06dh,048h,044h,044h,044h,06dh,091h,08dh,068h,000h,000h,000h,044h,08ch,06dh
	BYTE 024h,044h,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0b6h,0b6h,092h,092h,0dbh,0b6h
	BYTE 069h,0b6h,0dah,0b6h,08dh,08dh,068h,000h,044h,08ch,069h,044h,08dh,08dh,068h,020h
	BYTE 069h,000h,000h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0b6h,08dh,020h,08dh,069h,000h
	BYTE 06dh,000h,040h,0d6h,0d6h,08dh,069h,068h,044h,024h,068h,06dh,048h,044h,08dh,0b1h
	BYTE 08dh,08dh,08dh,069h,000h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0dbh,0b6h,0b6h,0b6h,0b6h,0b6h,0b6h,0b6h,0b6h,0b6h,091h,091h,0b2h,068h,08dh
	BYTE 044h,000h,000h,000h,069h,08dh,068h,044h,044h,020h,044h,020h,000h,024h,068h,044h
	BYTE 044h,044h,06dh,0b1h,0b1h,08dh,068h,091h,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,06dh,0dbh,0b2h,000h,08dh,069h,000h,000h,000h,020h,020h,0b1h,0d6h,0b2h
	BYTE 044h,044h,020h,020h,024h,020h,044h,068h,044h,044h,020h,044h,08dh,068h,000h,000h
	BYTE 020h,024h,000h,000h,000h,044h,044h,068h,08dh,08dh,08ch,091h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,000h,0b2h,092h,020h,08dh,069h,024h,044h,044h,044h,048h,08dh
	BYTE 08dh,068h,044h,024h,024h,024h,000h,044h,048h,044h,024h,020h,020h,024h,068h,068h
	BYTE 044h,044h,024h,000h,080h,0a8h,088h,000h,000h,020h,020h,044h,068h,06dh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,040h,068h,044h,024h,020h,020h,020h,044h,068h,024h,020h,020h,020h,020h
	BYTE 000h,020h,044h,044h,024h,000h,0a0h,0c8h,088h,044h,024h,020h,020h,044h,020h,06dh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,0b6h,0b6h,0b6h,0b6h,0b6h,0b6h
	BYTE 0b6h,0b6h,0b6h,092h,069h,044h,000h,000h,000h,000h,000h,044h,044h,024h,024h,044h
	BYTE 044h,020h,020h,000h,000h,020h,020h,020h,060h,060h,020h,044h,044h,020h,024h,000h
	BYTE 000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,000h,044h,044h,044h,044h,024h,000h,020h,000h
	BYTE 000h,024h,044h,020h,020h,024h,020h,020h,020h,024h,020h,020h,020h,000h,020h,020h
	BYTE 000h,024h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b2h,049h,06dh,0b6h,0b1h,0b1h,0b1h,068h,000h
	BYTE 020h,044h,048h,024h,000h,000h,000h,020h,020h,020h,020h,020h,024h,020h,024h,06dh
	BYTE 048h,000h,020h,0b6h,0ffh,0ffh,0ffh,0ffh,092h,092h,092h,0b6h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,092h,092h,092h,069h,08ch,0b1h,0b1h,0b2h,08dh,08dh,08dh
	BYTE 068h,044h,068h,08dh,08dh,08dh,08dh,068h,08dh,069h,044h,024h,000h,000h,000h,000h
	BYTE 024h,06eh,025h,000h,068h,08dh,092h,0dbh,0ffh,0dbh,040h,092h,0b1h,08dh,0b6h,0b6h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,020h,08dh,0d6h,0d6h,0b1h,08dh,068h,044h
	BYTE 044h,044h,020h,044h,044h,068h,040h,068h,08dh,068h,068h,068h,044h,069h,068h,0b1h
	BYTE 0b5h,091h,048h,0b5h,0b5h,048h,020h,020h,000h,06dh,0dbh,0b2h,08dh,0adh,089h,08dh
	BYTE 088h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,068h,0dah,0dbh,0b1h,068h,044h
	BYTE 040h,044h,044h,044h,024h,044h,044h,044h,049h,049h,000h,024h,069h,049h,020h,068h
	BYTE 068h,0d5h,0f9h,0b1h,068h,0d5h,0f5h,08ch,000h,048h,069h,069h,06dh,068h,0b1h,08dh
	BYTE 064h,044h,049h,069h,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,06dh,044h,069h,06dh,068h,044h
	BYTE 024h,044h,024h,020h,024h,024h,020h,044h,068h,068h,0b6h,092h,000h,049h,0d6h,08eh
	BYTE 000h,000h,044h,0ach,0d0h,0ach,044h,0ach,0d0h,0ach,024h,044h,069h,068h,044h,08dh
	BYTE 0b1h,0b1h,069h,020h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,069h,068h,0b1h,08dh,020h
	BYTE 044h,044h,048h,048h,044h,044h,024h,024h,020h,000h,024h,044h,091h,08dh,064h,068h
	BYTE 0b1h,08dh,048h,048h,044h,0ach,0d0h,0ach,044h,0ach,0cch,088h,020h,020h,044h,044h
	BYTE 044h,068h,08dh,091h,044h,000h,069h,0ffh,0ffh,0b6h,06dh,08dh,048h,044h,069h,048h
	BYTE 044h,024h,024h,000h,020h,024h,020h,020h,044h,044h,044h,044h,020h,020h,040h,020h
	BYTE 044h,044h,020h,044h,06dh,068h,044h,0a8h,0ach,088h,044h,088h,0a8h,064h,020h,020h
	BYTE 000h,000h,000h,020h,068h,044h,020h,000h,092h,0ffh,092h,000h,000h,020h,044h,069h
	BYTE 068h,000h,000h,000h,068h,08dh,068h,000h,068h,08dh,024h,000h,044h,044h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,020h,040h,084h,064h,020h,044h,064h,040h
	BYTE 000h,000h,020h,020h,044h,044h,044h,000h,000h,000h,0b6h,0ffh,0b2h,069h,06dh,049h
	BYTE 000h,044h,08dh,069h,000h,000h,044h,08dh,069h,000h,069h,08dh,024h,000h,000h,000h
	BYTE 048h,048h,044h,044h,024h,024h,024h,024h,020h,020h,020h,068h,068h,064h,000h,000h
	BYTE 000h,000h,000h,000h,000h,020h,044h,044h,044h,06dh,044h,000h,0b6h,0ffh,0ffh,0dbh
	BYTE 06dh,069h,044h,000h,024h,044h,064h,048h,048h,040h,040h,020h,000h,000h,044h,044h
	BYTE 040h,068h,0b1h,0b1h,068h,020h,024h,044h,044h,068h,044h,044h,024h,068h,048h,048h
	BYTE 044h,044h,044h,024h,000h,000h,020h,020h,000h,000h,024h,024h,044h,000h,06dh,0dbh
	BYTE 0ffh,06dh,068h,0b1h,08dh,000h,000h,044h,08dh,0b1h,0adh,068h,064h,044h,004h,049h
	BYTE 08dh,0b1h,0b1h,08dh,068h,044h,020h,000h,045h,06dh,069h,020h,044h,069h,020h,000h
	BYTE 020h,000h,068h,0b1h,0b1h,06dh,000h,020h,044h,020h,000h,000h,000h,04dh,092h,024h
	BYTE 000h,06dh,0ffh,0b6h,024h,044h,044h,044h,089h,068h,068h,048h,048h,024h,024h,000h
	BYTE 06dh,0b6h,06dh,048h,08dh,048h,020h,092h,06dh,044h,08dh,092h,068h,08dh,0b6h,092h
	BYTE 088h,020h,08eh,092h,044h,08dh,06dh,068h,024h,020h,020h,000h,044h,040h,049h,0bbh
	BYTE 0dbh,0ffh,0dbh,0dbh,0ffh,0b6h,069h,040h,000h,044h,068h,020h,000h,000h,000h,000h
	BYTE 000h,000h,068h,0b1h,044h,000h,044h,020h,020h,092h,06dh,06dh,0b2h,08dh,000h,091h
	BYTE 0b2h,049h,0b6h,06dh,06dh,092h,024h,044h,044h,020h,020h,020h,068h,064h,044h,020h
	BYTE 049h,092h,08dh,0dbh,0ffh,0ffh,06dh,08ch,08dh,068h,044h,044h,020h,000h,020h,020h
	BYTE 020h,000h,024h,000h,068h,08dh,044h,020h,044h,044h,020h,044h,024h,044h,08dh,0d6h
	BYTE 08dh,040h,064h,044h,0b1h,06dh,020h,044h,044h,044h,044h,020h,020h,000h,048h,0adh
	BYTE 08dh,000h,020h,020h,020h,0b6h,0ffh,0ffh,0dbh,06dh,020h,020h,020h,044h,020h,020h
	BYTE 024h,020h,024h,020h,020h,020h,044h,068h,044h,020h,044h,020h,020h,068h,068h,000h
	BYTE 020h,06dh,0b1h,0b1h,091h,048h,068h,044h,068h,08dh,024h,020h,024h,020h,020h,000h
	BYTE 000h,044h,08dh,08dh,020h,040h,092h,0dbh,0ffh,0ffh,0ffh,0ffh,049h,000h,020h,044h
	BYTE 020h,020h,020h,020h,044h,020h,020h,020h,024h,044h,024h,020h,020h,020h,020h,044h
	BYTE 044h,024h,000h,000h,0b1h,0d6h,0b1h,044h,068h,048h,024h,044h,024h,020h,020h,020h
	BYTE 020h,000h,000h,000h,068h,08dh,024h,000h,049h,08dh,0b6h,0ffh,0ffh,0b6h,024h,020h
	BYTE 024h,044h,020h,000h,020h,000h,020h,000h,020h,020h,020h,044h,024h,020h,020h,020h
	BYTE 024h,044h,024h,020h,068h,08dh,08dh,068h,08dh,08dh,068h,020h,020h,044h,020h,020h
	BYTE 020h,020h,020h,000h,000h,020h,000h,068h,044h,000h,040h,040h,092h,0ffh,0ffh,044h
	BYTE 040h,044h,000h,020h,020h,020h,020h,020h,024h,020h,020h,000h,000h,000h,020h,020h
	BYTE 000h,020h,020h,044h,024h,020h,068h,08dh,068h,000h,044h,08dh,044h,000h,024h,044h
	BYTE 020h,020h,020h,020h,000h,020h,000h,020h,020h,044h,020h,020h,049h,092h,0dbh,0ffh
	BYTE 0ffh,06dh,064h,020h,000h,000h,020h,000h,020h,020h,000h,000h,044h,044h,020h,020h
	BYTE 020h,000h,000h,000h,000h,000h,000h,020h,020h,000h,000h,020h,000h,000h,000h,020h
	BYTE 000h,000h,000h,000h,000h,000h,020h,044h,020h,000h,044h,044h,000h,000h,092h,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,049h,000h,024h,000h,020h,020h,020h,020h,020h,048h,08dh,08dh
	BYTE 064h,064h,044h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,000h,000h
	BYTE 000h,000h,000h,000h,000h,020h,000h,000h,000h,020h,020h,000h,044h,044h,000h,000h
	BYTE 024h,0b6h,0ffh,0ffh,0ffh,0ffh,0dbh,06dh,020h,024h,000h,020h,020h,040h,044h,06dh
	BYTE 069h,044h,044h,020h,024h,020h,000h,000h,000h,044h,044h,000h,000h,000h,020h,020h
	BYTE 000h,020h,024h,000h,000h,000h,000h,044h,068h,069h,044h,044h,020h,020h,024h,020h
	BYTE 020h,024h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,000h,064h,024h,000h,000h,020h
	BYTE 000h,000h,000h,000h,040h,000h,000h,020h,040h,000h,000h,020h,000h,044h,0b6h,0b6h
	BYTE 044h,000h,000h,000h,000h,020h,000h,000h,000h,000h,044h,069h,044h,044h,020h,000h
	BYTE 000h,000h,000h,000h,06dh,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,092h,040h,020h,092h
	BYTE 0b2h,044h,020h,049h,092h,092h,069h,044h,049h,06dh,049h,000h,06dh,0b6h,0b6h,0dbh
	BYTE 0ffh,0ffh,0dbh,0b6h,0d6h,092h,069h,06dh,069h,000h,000h,020h,044h,000h,000h,000h
	BYTE 020h,040h,044h,092h,0b6h,0b6h,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,024h
	BYTE 000h,0b6h,0ffh,069h,000h,0b6h,0ffh,0ffh,0dbh,049h,0d7h,0ffh,092h,049h,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,020h,000h,024h,020h,020h
	BYTE 000h,024h,020h,000h,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh

P1TANK EECS205BITMAP <50, 38, 06dh,, offset P1TANK + sizeof P1TANK>
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,049h,092h,091h,048h,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,08dh,08dh,048h,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,049h,049h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,048h,06ch,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,049h,048h,024h,024h,024h,049h,06dh,049h,049h,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,048h,048h
	BYTE 048h,06dh,06dh,06dh,06dh,06dh,06dh,048h,000h,048h,091h,091h,048h,048h,048h,048h
	BYTE 048h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,024h,024h,048h,06dh,048h,048h,048h,024h,028h,028h,06dh,0b6h,0d6h,091h,048h
	BYTE 000h,024h,000h,000h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,069h,028h,000h,048h,091h,06ch,000h,000h,028h,06dh,091h,091h,06dh
	BYTE 048h,048h,048h,048h,06dh,06dh,048h,069h,06dh,06dh,06dh,069h,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,048h,000h,024h,06ch,028h,06ch,091h,091h,06ch,06dh
	BYTE 091h,04ch,024h,06dh,091h,091h,0d6h,0fah,0b6h,04ch,048h,06dh,048h,091h,06dh,048h
	BYTE 069h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,024h,000h,06dh,091h,091h,0b5h,0b5h,095h
	BYTE 048h,06ch,091h,06dh,028h,048h,071h,091h,095h,0dah,0dah,06dh,000h,024h,000h,091h
	BYTE 091h,048h,06ch,048h,049h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,091h,091h,091h,0b5h,0b5h,091h
	BYTE 06ch,06ch,04ch,06ch,048h,000h,024h,048h,048h,04ch,04ch,091h,095h,06ch,004h,024h
	BYTE 000h,024h,091h,06ch,0b6h,0b6h,08dh,048h,049h,048h,048h,048h,06dh,06dh,048h,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,048h,095h,0b5h,091h,06ch,048h
	BYTE 048h,028h,004h,004h,028h,024h,000h,000h,08dh,091h,048h,028h,048h,04ch,06ch,06ch
	BYTE 028h,024h,028h,024h,048h,04ch,0b6h,0dah,0b5h,048h,04ch,048h,048h,04ch,06dh,0b6h
	BYTE 028h,0b6h,0dbh,049h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,048h,091h,06ch,024h
	BYTE 048h,004h,000h,08ch,0b0h,084h,000h,028h,048h,04ch,091h,06dh,048h,028h,048h,048h
	BYTE 048h,06ch,048h,024h,048h,048h,028h,06ch,091h,091h,091h,048h,048h,028h,028h,048h
	BYTE 06dh,091h,024h,091h,0b6h,024h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,024h,048h
	BYTE 048h,024h,024h,048h,048h,08ch,0cch,0a8h,004h,028h,06ch,048h,024h,000h,024h,024h
	BYTE 028h,048h,048h,06ch,04ch,024h,024h,024h,048h,04ch,06dh,068h,024h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,004h,028h,048h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 024h,024h,028h,048h,028h,048h,04ch,048h,084h,068h,028h,028h,024h,004h,000h,024h
	BYTE 024h,048h,04ch,048h,048h,04ch,048h,004h,000h,000h,000h,004h,048h,048h,048h,048h
	BYTE 048h,048h,048h,048h,048h,049h,048h,049h,049h,06dh,06dh,06dh,06dh,069h,048h,06dh
	BYTE 06dh,06dh,06dh,024h,000h,000h,024h,024h,024h,028h,028h,028h,048h,028h,028h,028h
	BYTE 048h,028h,028h,048h,048h,000h,024h,024h,000h,024h,048h,048h,048h,048h,004h,024h
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,048h,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,049h,048h,024h,024h,024h,024h,024h,024h,024h,024h
	BYTE 028h,028h,024h,004h,000h,000h,048h,048h,048h,024h,000h,06dh,0b5h,0b5h,0b5h,0b6h
	BYTE 071h,048h,048h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,069h,091h
	BYTE 091h,0b6h,0b6h,06dh,048h,06dh,049h,048h,06dh,06dh,028h,000h,000h,000h,000h,000h
	BYTE 000h,000h,048h,04ch,071h,091h,06dh,091h,091h,091h,091h,06dh,04ch,06ch,095h,0b5h
	BYTE 091h,0b6h,0b5h,0b5h,095h,048h,048h,06ch,04ch,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 024h,091h,091h,08dh,0b1h,0b1h,06dh,049h,024h,000h,048h,004h,048h,0b5h,0b5h,06ch
	BYTE 091h,0b6h,091h,06dh,071h,06ch,06ch,06ch,071h,091h,06ch,04ch,06ch,06ch,048h,048h
	BYTE 06ch,06ch,04ch,06dh,091h,0b5h,0dah,0dah,0b5h,04ch,048h,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,024h,048h,068h,06ch,091h,0b5h,091h,024h,048h,06dh,04ch,024h,091h,0fah
	BYTE 0d9h,06ch,0b5h,0feh,0d5h,091h,06dh,048h,049h,06dh,048h,024h,049h,049h,048h,04ch
	BYTE 048h,048h,04ch,06ch,048h,048h,04ch,070h,0b5h,0dbh,0dah,06dh,024h,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,024h,048h,06dh,0b5h,0b5h,091h,06ch,06ch,071h,04ch,048h
	BYTE 0b0h,0f5h,0b0h,048h,0b0h,0d5h,0b0h,048h,024h,000h,092h,0b6h,06dh,000h,0b6h,0b6h
	BYTE 06dh,06ch,048h,024h,048h,048h,028h,048h,048h,048h,048h,06dh,06dh,06dh,06ch,048h
	BYTE 049h,06dh,06dh,06dh,06dh,06dh,06dh,024h,024h,048h,0b5h,091h,06ch,048h,048h,048h
	BYTE 028h,028h,090h,0d4h,0b0h,048h,0b0h,0d5h,0b0h,048h,04ch,04ch,091h,0b5h,06dh,048h
	BYTE 091h,0b1h,048h,028h,024h,024h,048h,048h,048h,06ch,06ch,06ch,06ch,04ch,048h,091h
	BYTE 0b5h,091h,048h,049h,06dh,06dh,06dh,06dh,06dh,048h,024h,024h,048h,06ch,028h,000h
	BYTE 004h,000h,024h,024h,08ch,0b0h,08ch,048h,08ch,0d0h,0b0h,048h,06dh,091h,048h,048h
	BYTE 048h,048h,048h,048h,024h,024h,04ch,04ch,048h,048h,028h,024h,028h,024h,004h,028h
	BYTE 048h,048h,048h,06ch,06ch,04ch,06ch,048h,049h,06dh,06dh,049h,020h,024h,000h,048h
	BYTE 06ch,04ch,028h,024h,000h,000h,048h,068h,068h,024h,08ch,0ach,068h,024h,004h,024h
	BYTE 000h,000h,024h,024h,004h,000h,000h,000h,048h,048h,000h,024h,091h,06dh,000h,06dh
	BYTE 091h,06ch,000h,000h,000h,06ch,06dh,048h,04ch,028h,024h,048h,06dh,048h,024h,048h
	BYTE 06dh,04ch,048h,04ch,028h,024h,000h,000h,000h,000h,000h,024h,068h,08ch,06dh,024h
	BYTE 024h,028h,028h,048h,024h,048h,048h,048h,048h,048h,024h,000h,000h,024h,091h,06dh
	BYTE 000h,06dh,091h,048h,000h,024h,06dh,091h,048h,000h,000h,024h,024h,048h,06dh,024h
	BYTE 048h,048h,048h,028h,000h,000h,024h,024h,000h,000h,024h,048h,044h,06ch,06ch,06ch
	BYTE 06ch,048h,04ch,06ch,06ch,06ch,048h,048h,028h,06dh,0b5h,0b5h,06ch,044h,048h,048h
	BYTE 000h,000h,024h,048h,048h,048h,06ch,06ch,068h,024h,000h,048h,06ch,048h,049h,06dh
	BYTE 028h,024h,024h,048h,024h,024h,024h,000h,024h,068h,024h,004h,091h,0b5h,0b5h,091h
	BYTE 004h,028h,024h,028h,06dh,04ch,028h,06dh,091h,049h,004h,024h,06ch,06dh,0b1h,0b5h
	BYTE 0b5h,091h,049h,004h,048h,06ch,06dh,0b5h,0b5h,091h,048h,020h,024h,091h,0b5h,08dh
	BYTE 024h,06dh,06dh,069h,06dh,049h,049h,024h,06ch,048h,000h,024h,024h,048h,06ch,091h
	BYTE 091h,04ch,092h,092h,024h,091h,092h,0b6h,091h,06dh,092h,0b5h,048h,091h,092h,028h
	BYTE 06ch,091h,06ch,071h,0b6h,06dh,000h,024h,048h,048h,068h,06ch,08dh,08dh,068h,048h
	BYTE 068h,024h,024h,06dh,06dh,06dh,06dh,068h,048h,024h,048h,048h,068h,06ch,024h,024h
	BYTE 048h,048h,04ch,048h,0b6h,06dh,091h,0b6h,06dh,0b6h,092h,024h,08dh,0d6h,06dh,071h
	BYTE 092h,048h,024h,04ch,004h,048h,0b5h,06dh,000h,000h,000h,000h,000h,000h,024h,06ch
	BYTE 048h,000h,048h,06ch,06dh,06dh,06dh,06dh,049h,048h,048h,024h,004h,091h,0b5h,068h
	BYTE 000h,024h,028h,048h,06ch,048h,048h,004h,06dh,0b5h,048h,06ch,068h,092h,0dah,091h
	BYTE 048h,048h,048h,028h,048h,04ch,048h,048h,0b1h,048h,000h,024h,024h,024h,024h,024h
	BYTE 000h,024h,06ch,068h,06dh,0b1h,0b1h,044h,06dh,06dh,049h,048h,048h,024h,091h,0b1h
	BYTE 048h,000h,000h,028h,048h,048h,028h,048h,091h,06ch,048h,06ch,06ch,091h,0b5h,0b5h
	BYTE 091h,024h,004h,06dh,091h,048h,028h,048h,028h,048h,06dh,048h,024h,024h,024h,048h
	BYTE 024h,028h,028h,024h,06ch,024h,024h,048h,048h,06dh,06dh,06dh,091h,048h,000h,048h
	BYTE 091h,06dh,000h,000h,004h,028h,048h,024h,028h,048h,048h,024h,06ch,06ch,048h,0b6h
	BYTE 0dah,0b5h,024h,000h,048h,048h,048h,048h,028h,028h,028h,048h,06ch,028h,024h,024h
	BYTE 024h,048h,028h,024h,024h,024h,048h,024h,000h,000h,049h,06dh,06dh,06dh,08dh,048h
	BYTE 000h,048h,06dh,000h,024h,004h,000h,024h,024h,024h,028h,048h,048h,048h,024h,06dh
	BYTE 091h,091h,06dh,091h,091h,06ch,028h,048h,048h,048h,048h,024h,028h,028h,048h,024h
	BYTE 024h,024h,024h,024h,004h,024h,024h,024h,048h,024h,024h,024h,048h,06dh,06dh,069h
	BYTE 024h,048h,024h,024h,048h,024h,024h,024h,024h,024h,024h,024h,024h,024h,048h,048h
	BYTE 000h,048h,091h,048h,000h,06ch,091h,06ch,028h,048h,048h,028h,024h,024h,024h,024h
	BYTE 000h,000h,004h,024h,024h,028h,024h,024h,024h,024h,024h,004h,048h,048h,024h,06dh
	BYTE 06dh,06dh,06dh,024h,024h,000h,048h,068h,000h,028h,048h,024h,024h,000h,000h,004h
	BYTE 024h,004h,024h,024h,000h,004h,024h,000h,000h,004h,024h,004h,000h,024h,000h,000h
	BYTE 000h,024h,024h,024h,048h,048h,000h,024h,024h,024h,024h,024h,004h,000h,024h,06ch
	BYTE 048h,06dh,06dh,06dh,048h,024h,000h,000h,048h,06ch,004h,024h,028h,024h,000h,000h
	BYTE 024h,004h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,048h,06dh,06ch,091h,091h,048h,024h,024h,024h,024h,024h,000h,024h
	BYTE 000h,024h,06dh,06dh,06dh,06dh,048h,048h,044h,024h,024h,024h,024h,024h,048h,06ch
	BYTE 06dh,06dh,048h,024h,000h,000h,000h,024h,024h,000h,024h,024h,004h,000h,000h,048h
	BYTE 048h,004h,000h,000h,024h,024h,024h,044h,048h,06dh,091h,048h,048h,024h,024h,000h
	BYTE 024h,048h,024h,049h,06dh,06dh,06dh,06dh,06dh,048h,024h,000h,000h,000h,000h,024h
	BYTE 048h,06ch,06dh,06ch,000h,000h,000h,024h,048h,024h,000h,000h,000h,024h,048h,048h
	BYTE 024h,044h,048h,000h,000h,048h,048h,000h,024h,048h,000h,000h,000h,000h,024h,048h
	BYTE 000h,024h,06ch,048h,048h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,048h,049h,048h,024h
	BYTE 048h,024h,000h,000h,024h,048h,024h,000h,000h,048h,068h,024h,048h,049h,048h,049h
	BYTE 06dh,06dh,049h,048h,048h,024h,000h,048h,048h,024h,048h,06ch,048h,044h,024h,048h
	BYTE 068h,069h,024h,048h,048h,048h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,049h,024h,024h,024h,024h,024h,024h,024h,024h,024h,049h,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,024h,048h,06dh,049h,048h,06dh,06dh,06dh
	BYTE 049h,024h,048h,06dh,049h,024h,024h,06dh,06dh,06dh,06dh,06dh

SHOT_01 EECS205BITMAP <8, 8, 0ffh,, offset SHOT_01 + sizeof SHOT_01>
	BYTE 0ffh,0b6h,084h,0c8h,0a8h,040h,0b2h,0ffh,0b6h,0cdh,0e8h,0ech,0ech,0c8h,0adh,0b6h
	BYTE 084h,0e8h,0f1h,0fah,0f4h,0f0h,0c8h,064h,0c8h,0ech,0fah,0ffh,0f8h,0f4h,0cch,0adh
	BYTE 0a8h,0ech,0f4h,0f8h,0f8h,0f4h,0cch,0adh,040h,0c8h,0f0h,0f4h,0f4h,0f0h,0c8h,064h
	BYTE 0b6h,0adh,0c8h,0cch,0cch,0c8h,0adh,0b6h,0ffh,0b6h,064h,0adh,0adh,064h,0b6h,0ffh

SHOT_02 EECS205BITMAP <8, 8, 255,, offset SHOT_02 + sizeof SHOT_02>
	BYTE 0ffh,0b6h,080h,0c9h,0a9h,060h,0b2h,0ffh,0b6h,0cdh,0e1h,0e5h,0e9h,0c5h,0adh,0b6h
	BYTE 080h,0e1h,0eeh,0f6h,0f2h,0eah,0c5h,064h,0c9h,0e5h,0f6h,0ffh,0f7h,0eeh,0e9h,0a9h
	BYTE 0a9h,0e9h,0f2h,0f7h,0f7h,0eeh,0e9h,0a9h,060h,0c5h,0eah,0eeh,0eeh,0eah,0c5h,064h
	BYTE 0b2h,0adh,0c5h,0e9h,0e9h,0c5h,0a9h,0b6h,0ffh,0b6h,060h,0a9h,0a9h,064h,0b6h,0ffh

SHOT_03 EECS205BITMAP <8, 8, 255,, offset SHOT_03 + sizeof SHOT_03>
	BYTE 0ffh,0d6h,0a8h,0d1h,0cdh,064h,0b6h,0ffh,0d6h,0d1h,0f1h,0f5h,0f5h,0d1h,0cdh,0b6h
	BYTE 0a8h,0f1h,0fah,0feh,0feh,0fah,0d1h,088h,0d1h,0f5h,0feh,0ffh,0ffh,0feh,0f5h,0adh
	BYTE 0cdh,0f5h,0feh,0ffh,0ffh,0feh,0f5h,0adh,064h,0d1h,0fah,0feh,0feh,0fah,0d1h,068h
	BYTE 0b6h,0cdh,0d1h,0f5h,0f5h,0d1h,0cdh,0b6h,0ffh,0b6h,088h,0adh,0adh,068h,0b6h,0ffh

.CODE

END
