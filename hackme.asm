.286
.model tiny
.code

locals @@

org 80h
ArgLen:
org 81h
ArgStr:

org 100h

Start:
		cli

		push		0B800h
		pop		es

		xor		cx,		cx
		mov		cl, byte ptr	[ArgLen]
		sub		cl,		01h
		jl		@@Failed
		lea		si,		ArgStr + 1

		call		GetHash
		xor		cx,		cx
		xor		ax,		783Bh
		jz		@@Correct

@@Failed:	lea		si,		FailedMessage
		mov		di,		25d*80d - (FAILEDMSGLEN and not 1)
		mov		cx,		FAILEDMSGLEN
		mov		ah,		0FCh
		call		PrintStr

		jmp		@@ProgEnd

@@Correct:	lea		si,		SuccessMessage
		mov		di,		25d*80d - (SUCCESSMSGLEN and not 1)
		mov		cx,		SUCCESSMSGLEN
		mov		ah,		72h
		call		PrintStr

@@ProgEnd:	sti

		mov		ax,		4C00h
		int		21h			; exit

;----------------------------------------------------------------------------------------------------
; Outputs string to video memory
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- video buffer destination address
;		DS:SI	- string address
;		CX	- string length
;		AH	- screen attrubute
; Exit:		ES:DI	- address of word after last output word
;		DS:SI	- address of byte after last output byte of string
; Destroys:	AL, CX
;----------------------------------------------------------------------------------------------------
PrintStr	proc

@@PrintLoop:	lodsb
		stosw
		loop	@@PrintLoop

		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Calculates the hash of given string
;----------------------------------------------------------------------------------------------------
; Entry:	DS:SI	- string address
;		CX	- string length
; Exit:		AX	- string hash
; Destroys:	BX, CX, SI
;----------------------------------------------------------------------------------------------------
GetHash		proc

		xor		bx,		bx
		xor		ax,		ax

@@HashLoop:	lodsb
		shl		bx,		01h
		xor		bx,		ax
		loop		@@HashLoop

		mov		ax,		bx

		ret
		endp
;----------------------------------------------------------------------------------------------------


.data
FailedMessage	db	"Stop right there, you criminal scum!"
FAILEDMSGLEN	equ	$ - offset FailedMessage

SuccessMessage	db	"ACCESS GRANTED"
SUCCESSMSGLEN	equ	$ - offset SuccessMessage
end Start
