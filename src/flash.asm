; the os can't do 16 bit relocations... which means we need to copy flash code to ram before running :/
; call this before calling any flash_* functions as necessary

flash_code_copy:
	flash_code.copy
	ret

relocate flash_code, ti.mpLcdCrsrImage

write_port:
	ld	de,$C979ED
	ld	hl,ti.heapBot - 3
	ld	(hl),de
	jp	(hl)

read_port:
	ld	de,$C978ED
	ld	hl,ti.heapBot - 3
	ld	(hl),de
	jp	(hl)

flash_unlock:
	ld	bc,$24
	ld	a,$8c
	call	write_port
	ld	bc,$06
	call	read_port
	or	a,4
	call	write_port
	ld	bc,$28
	ld	a,$4
	jp	write_port

flash_lock:
	ld	bc,$28
	xor	a,a
	call	write_port
	ld	bc,$06
	call	read_port
	res	2,a
	call	write_port
	ld	bc,$24
	ld	a,$88
	jp	write_port

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
	call	ti.WriteFlash

	flash_lock_m
	ret

flash_erase_sector:
	ld	bc,$f8				; lol, what a flaw
	push	bc
	jp	ti.EraseFlashSector

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
	call	ti.WriteFlashByte		; clear old backup
	flash_lock_m
	ret

string_ram_backup:
if config_english
	db	'Backing up...',0
else
	db	'Sauvegarde en cours...',0
end if

end relocate
