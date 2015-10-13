StopToken equ $D9-$CE	; "Stop" token

ParserHook:
 .db 83h		; Required for all hooks
 or a			; Which condition?
 ret z
 ld a,b
 sub a,StopToken	; Did we hit a stop token?
 jr nz,ReturnZ		; No error condition, just quit -- The parser will handle it.
 xor a,a
 jp _JError		; This should do what I want just fine
ReturnZ:
 cp a
 ret