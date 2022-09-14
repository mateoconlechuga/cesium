macro format?.ti? clause&
	local all, checkloc, checksum, cplx, data, exec, flag, head, name, process, prot, temp, type, ext, var
	macro process: setting
		match first rest, setting
			process first
			process rest
		else match =ARCHIVED?, setting
			flag = flag or 1 shl 7
		else match =EXECUTABLE?, setting
			define exec
		else match =PROTECTED?, setting
			type = 6
			define prot
		else match =REAL?, setting
			type = 0
			ext = '8xn'
		else match =LIST?, setting
			if defined cplx
				type = 13
			else
				type = 2
			end if
			ext = '8xl'
		else match =MATRIX?, setting
			type = 2
			ext = '8xm'
		else match =EQUATION?, setting
			type = 3
			ext = '8xy'
		else match =STRING?, setting
			type = 4
			ext = '8xs'
		else match =PROGRAM?, setting
			if defined prot
				type = 6
			else
				type = 5
			end if
			ext = '8xp'
		else match =PICTURE?, setting
			type = 7
			ext = '8ci'
		else match =GDB?, setting
			type = 1
			ext = '8xd'
		else match =COMPLEX?, setting
			type = 12
			define cplx
			ext = '8xc'
		else match =APPVAR?, setting
			type = 21
			ext = '8xv'
		else match =GROUP?, setting
			type = 23
			ext = '8xg'
		else match =IMAGE?, setting
			type = 26
			ext = '8ca'
		else if setting eqtype 'name'
			name = setting
		else if setting eqtype 0
			type = setting
			ext = '8x'
		end if
	end macro
	name = 'A'
	type = 6
	ext = '8xp'
	flag = 0
	process clause
	format binary as ext
	assert ~$% & 'Unexpected data before format directive'
	dq '**TI83F*'
	db 26, 10, 0
	rb 42
	dw sizeof all
	label all: checkloc - $%
	dw sizeof head, sizeof data
	label head: data - $
	db type
	dq name
	db 0, flag
	dw sizeof data
	label data: checkloc - $%
	dw sizeof var
	label var: checkloc - $%
	if defined exec
		dw 07BEFh
		org 0D1A881h
	else
		org 0
	end if
	postpone
		label checkloc at $%
	end postpone
	postpone ?
		assert checkloc = $% & 'Unexpected postpone before format directive'
		checksum = 0
		repeat sizeof all
			load temp: byte from: all + %-1
			checksum = (checksum + temp) and 0FFFFh
		end repeat
		dw checksum
	end postpone
end macro
