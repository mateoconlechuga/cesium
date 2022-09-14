macro ?!
	local maxfilewidth, maxnumwidth, filewidth, numwidth, output, hex, before, after
	maxfilewidth = 0
	maxnumwidth = 0
	postpone
		filewidth = maxfilewidth
		numwidth = maxnumwidth
	end postpone
	virtual as 'lst'
		output::
	end virtual
	macro hex value, digits*, leading: '0'
		local val, zero, digit, char
		val = value
		zero = leading
		repeat digits
			digit = (val shr ((%% - %) shl 2)) and 0Fh
			if digit < 10
				char = '0' + digit
			else
				char = 'A' + digit - 10
			end if
			if digit
				zero = '0'
			else if % <> %%
				char = zero
			end if
			emit 1: char
		end repeat
	end macro
	before = $
	macro after
		local outer, base, uninit, target, offset, a
		outer::
		base := $$
		uninit := $@
		target := $
		offset := $%
		virtual output
			while before <> target
				hex before - target + offset, 6
				db ':'
				if elementsof before
					db '+'
				else
					db ' '
				end if
				hex before scale 0, 6
				db ':'
				repeat 16
					db ' '
					if before < uninit
						load a: byte from outer: before
						hex a, 2
					else
						db '??'
					end if
					before = before + 1
					if before = target
						break
					end if
				end repeat
				db 10
			end while
		end virtual
	end macro
	iterate <name>, org, section
		macro name? address*
			after
			name? address
			before = $$
		end macro
	end iterate
	macro ? line&
		virtual output
			repeat 1, num: __LINE__
				if maxfilewidth < lengthof __FILE__
					maxfilewidth = lengthof __FILE__
				end if
				if maxnumwidth < lengthof `num
					maxnumwidth = lengthof `num
				end if
				db filewidth - lengthof __FILE__ dup ' ', __FILE__, ':', `num, numwidth - lengthof `num + 8 dup ' ', `line, 10
			end repeat
		end virtual
		outscope line
		after
	end macro
	retaincomments
	purge ?
end macro
