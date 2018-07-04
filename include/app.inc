; ----------------------

macro app_private
	local app
	element app.base

	min_version := '5.0.0.0.0'

	postpone
		virtual
			irpv relocation, app.relocations
				dl relocation
			end irpv
			load app.relocation_table: $-$$ from $$
		end virtual
	end postpone

 	postpone
		app.data_end = $% - app.header_start
		app.signature = $%
		db $02,$3e,$01,$00
		db 256 dup $ff
		app.size = $% - app.start_offset
		app.end = app.size + app.start
		dl app.size
	end postpone

 	macro app_start? name,copyright
		local value
		local freespace
		app.start = $
		app.start_offset = $%
		app.string = copyright
		value = app.signature - $%
		db $81,$0f,$00
		dl (value - 6) bswap 3
		db $81,$12,$13,$0f
		db $81,$2d,lengthof min_version + 1,min_version,$00
		db $81,$32,$59,$00
		db $81,lengthof name,name
		db $81,$a1,$07
		db $03,$26,$09,$00
		db $21,$bb,$6e,$dc
		freespace = 247-$+app.start
		db $00,$0d,freespace
		db freespace dup $ff
		value = app.signature - $%
		db $81,$7f,$00
		dl (value - 6) bswap 3
		app.header_start = $%
		db 'eZ8'
		app.exe = $
		dq name
		db 0,3				; 00Bh,00Ch
		db 0,0				; 00Dh,00Eh
		dl 0				; 00Fh
		dl app.code			; 012h
		dl app.data			; 015h
		dl app.data_end-app.data	; 018h
		dl app.code			; 01Bh
		dl 0				; 01Eh
		if defined app.library_table
			dl app.library_table	; 021h
		else
			dl 0			; 021h
		end if
		dl app.information_string	; 024h
		dl 0				; 027h
 		; start of application relocation table
		app.table_offset = $% - app.start_offset
		dl app.relocation_table

		app.code_offset = $% - app.start_offset
		app.code = $% - app.header_start
		org app.base
	end macro

	macro app_data?
		irpv export, app.exports
			if % = 1
				dl 'LIB',%%
				app.library_table = $% - app.header_start
			end if
			@ez80.word export
		end irpv
		app.information_string = $% - app.header_start
		db app.string,$00
		app.data = $% - app.header_start
		org $D1787C
	end macro

	macro export? function
		app.exports equ function
	end macro

	macro app_create?
		di
		call	.create_code
		jp	.continue
.create_code:
		ld	hl,app.exe
		push	hl
		call	$21100
		pop	bc
		ret	nz
		ld	hl,$3b0000		; applications start here
.find:
		push	hl
		call	$22044			; locates start of next application header
		pop	de
		jr	nz,.find
.found:
		ex	de,hl
		dec	hl
		dec	hl
		dec	hl
		push	hl
		ld	a,$d1
		ld	mb,a
		ld.sis	sp,$987e
		call.is	.unlock and $ffff
		pop	hl
		ld	de,(app.end)
		or	a,a
		sbc	hl,de
		ex	de,hl
		push	de
		ld	hl,app.start
		ld	bc,app.size+3
		call	$02e0			; write app to flash memory
		pop	hl
		push	hl
		ld	de,app.code_offset
		add	hl,de
		ex	de,hl
		pop	hl
		ld	bc,app.table_offset
		add	hl,bc
.relocate:
		or	a,a
		sbc	hl,de
		add	hl,de
		jr	z,.endrelocate
		ld	ix,(hl)
		add	ix,de			; location to overwrite
		inc	hl
		inc	hl
		inc	hl
		push	hl
		push	de
		ld	hl,(hl)
		add	hl,de
		lea	de,ix
		ld	($d0062f),hl
		ld	hl,$d0062f
		ld	bc,3
		call	$02e0
		pop	de
		pop	hl
		inc	hl
		inc	hl
		inc	hl
		jr	.relocate
.endrelocate:
		call.is	.lock and $ffff
		ld	a,$d0
		ld	mb,a
		xor	a,a
		ret

		assume	adl = 0

.unlock:
		ld	a,$8c
		out0	($24),a
		ld	c,4
		in0	a,(6)
		or	c
		out0	(6),a
		out0	($28),c
		ret.l
.lock:
		xor	a
		out0	($28),a
		in0	a,(6)
		res	2,a
		out0	(6),a
		ld	a,$88
		out0	($24),a
		ret.l

		assume adl = 1
.continue:
	end macro

	macro relocate? name, address*
		name.source? := $
		name.destination? := address
		org name.destination?
		macro name.copy?
			ld	hl, name.source?
			ld	de, name.destination?
			ld	bc, name.length?
			ldir
		end macro
		macro name.run
			name.copy
			jp	name.destination?
		end macro
		macro name.call
			name.copy
			call	name.destination?
		end macro
		app.relocation equ name
		macro end?.relocate?
			name.length? := $ - name.destination?
			org name.source? + name.length?
			restore app.relocation
			purge end?.relocate?
		end macro
	end macro

	macro @ez80.word @value*
		local value, address
		value = @value
		if value relativeto app.base
			address = $
			match relocation, app.relocation
				if defined address - relocation.destination? + relocation.source?
					address = address - relocation.destination? + relocation.source?
				end if
			end match
			app.relocations equ address-app.base, value-app.base
			@ez80.word $ffffff
		else
			@ez80.word value
		end if
	end macro

end macro

; ----------------------

app_private
purge app_private
