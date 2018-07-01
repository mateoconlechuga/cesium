assume	adl = 0

; modifies - a,c

flash_unlock:
	ld	a,$8c
	out0	($24),a
	ld	c,4
	in0	a,(6)
	or	c
	out0	(6),a
	out0	($28),c
	ret.l

flash_lock:
	xor	a
	out0	($28),a
	in0	a,(6)
	res	2,a
	out0	(6),a
	ld	a,$88
	out0	($24),a
	ret.l

assume	adl = 1

flash_backup_ram:
	flash_unlock_m

	ld	a,$3f
	call	flash_erase_sector		; clean out the flash sectors
	ld	a,$3e
	call	flash_erase_sector
	ld	a,$3d
	call	flash_erase_sector
	ld	a,$3c
	call	flash_erase_sector

	ld	hl,$d00001
	ld	(hl),$a5
	dec	hl
	ld	(hl),$5a			; write some magical bytes
	ld	de,$3c0000			; write all of ram
	ld	bc,$40000
	call	_WriteFlash

	flash_lock_m
	ret

flash_erase_sector:
	ld	bc,$f8				; lol, what a security flaw
	push	bc
	jp	_EraseFlashSector

flash_clear_backup:
	ld	de,$3c0000			; backup address
	ld	hl,$d00001
	xor	a,a
	ld	b,a				; write 0
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ld	a,(de)
	or	a,a
	ret	z				; dont clear if done already
	flash_unlock_m
	call	_WriteFlashByte			; clear old backup
	flash_lock_m
	ret

string_ram_backup:
if config_english
	db	'Backing up...',0
else
	db	'Sauvegarde en cours...',0
end if
