.286
.model tiny
.code

locals @@

org 100h

Start:		mov		ax,		783Bh
		mov		cx,		(@@ProgEnd-@@Correct)/2
		lea		si,		@@Correct
		call		EncryptDecrypt

		push		ds
		pop		es
		lea		di,		Buffer
		call		GetS

		; cx already loaded with string length
		lea		si,		Buffer
		call		GetHash

		push		0B800h
		pop		es

		cmp		ax,		783Bh
		jnz		@@Failed

		mov		cx,		(@@ProgEnd-@@Correct)/2
		lea		si,		@@Correct
		call		EncryptDecrypt
		jmp		@@Correct

@@Failed:	lea		si,		FailedMessage
		mov		di,		25d*80d - (FAILEDMSGLEN and not 1)
		mov		cx,		FAILEDMSGLEN
		mov		ah,		0FCh	; blinking red on gray
		call		PrintStr

		mov		al,		1	; non-successful exit
		jmp		@@ProgEnd

@@Correct:	lea		si,		SuccessMessage
		mov		di,		25d*80d - (SUCCESSMSGLEN and not 1)
		mov		cx,		SUCCESSMSGLEN
		mov		ah,		7Ah	; bright green on gray
		call		PrintStr
		mov		al,		0	; successful exit
		nop					; align for even length

@@ProgEnd:	mov		ah,		4Ch
		int		21h			; exit

Buffer		db		80d dup (?)		; buffer length == screen width (VULNERABILITY)


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
; Reads string character by character into buffer (VULNERABILITY)
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- destination buffer
; Exit:		CX	- string length
; Destroysm	AX, DI
;----------------------------------------------------------------------------------------------------
GetS		proc

		xor		cx,		cx

		mov		ah,		01h
@@ReadLoop:	int		21h
		cmp		al,		0Dh	; CR
		je		@@ReadEnd

		stosb
		inc		cx
		jmp		@@ReadLoop
		
@@ReadEnd:	ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Encrypt/decrypt data with key
;----------------------------------------------------------------------------------------------------
; Entry:	DS:SI	- data address
;		AX	- encryption key
;		CX	- data length (in words)
; Exit:		None
; Destroys:	BX, CX, SI
;----------------------------------------------------------------------------------------------------
EncryptDecrypt	proc

@@NextWord:	mov		bx, word ptr	ds:[si]
		xor		bx,		ax
		mov word ptr	ds:[si],	bx

		add		si,		2
		loop		@@NextWord
		
		ret
		endp
;----------------------------------------------------------------------------------------------------


.data
FailedMessage	db	"Stop right there, you criminal scum!"
FAILEDMSGLEN	equ	$ - offset FailedMessage

SuccessMessage	db	"ACCESS GRANTED"
SUCCESSMSGLEN	equ	$ - offset SuccessMessage
end Start
