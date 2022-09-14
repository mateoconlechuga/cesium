define @ez80 @ez80
macro @ez80.suffix @l, @il*
	rawmatch @@l @@il, @l @il
		namespace @ez80
			l = @@l
			il = @@il
			lil = l or il shl 1
			pre = lil or lil shl 3 or 100o
		end namespace
	end rawmatch
end macro
macro @ez80.opc @values*&
	db @values
end macro
macro @ez80.byte @value
	local value
	value := @value
	if elementsof value
		err 'invalid immediate'
	end if
	db +value
end macro
macro @ez80.offset @value*
	local value
	value := @value
	if elementsof value
		err 'invalid offset'
	else if value < -200o | 200o <= value
		err 'offset is out of range'
	end if
	db +value
end macro
macro @ez80.word @value*
	local value
	value := @value
	if elementsof value
		err 'invalid immediate'
	end if
	emit word + @ez80.il: +value
end macro
macro @ez80.idxpre @regs*&
	local pre
	iterate @reg, @regs
		pre = @reg metadata 1 scale 1
		if pre > 300o
			@ez80.byte pre
			break
		end if
	end iterate
end macro
macro @ez80.idxoff @reg*
	local reg
	reg := @reg
	if reg metadata 1 scale 1 > 300o
		@ez80.offset @reg scale 0
	else if reg scale 0
		err 'invalid arguments'
	end if
end macro
macro @ez80.emit @values*&
	if defined @ez80.pre
		db @ez80.pre
	end if
	iterate @value, @values
		@ez80.@value
	end iterate
end macro
macro @ez80.nest @inst*&
	if defined @ez80.pre
		@ez80.pre =: @ez80.pre
	end if
	@ez80.@inst
end macro
macro @ez80.check: @res*, @expr&
	match @left ) @right, <@expr>
		match @ ( @mid, <@left>
			@ez80.check @res, @mid @right
		else
			@res.ind =: 0
		end match
	else
		@res.ind =: 1
	end match
end macro
macro @ez80.classify @res, @arg&
	match, @arg
		@res.ind =: 0
	else
		@res =: @arg
		match ( @ ), @arg
			@ez80.check @res, @
		else
			@res.ind =: 0
		end match
	end match
end macro

long? = 3
; FIXME: dup relocations
macro dw? @values*&
	if @ez80.adl
		emit word?: @values
	else
		match left =dup? right, @values
			emit word?: @values
		else
			iterate @value, @values
				@ez80.word @value
			end iterate
		end match
	end if
end macro
macro dl? @values*&
	if @ez80.adl
		match left =dup? right, @values
			emit long?: @values
		else
			iterate @value, @values
				@ez80.word @value
			end iterate
		end match
	else
		emit long?: @values
	end if
end macro
iterate @name, dw, rw, dl, rl
	struc (name) @name? @values*&
		label name: long?
		@name? @values
	end struc
end iterate
macro assume? @expr*
	match =adl? == @adl, @expr
		local adl
		adl := @adl
		if adl = adl and 1
			@ez80.l = adl
			@ez80.il = adl
			@ez80.adl = adl
		else
			err 'adl assume should be 0 or 1'
		end if
	else
		err 'invalid assume statement'
	end match
end macro
assume? adl = 1

element @ez80.breg
element   b?: @ez80.breg * 003o + 030o
element  nz?: @ez80.breg * 010o + 001o
element   z?: @ez80.breg * 010o + 011o
element  nc?: @ez80.breg * 010o + 021o
element   c?: @ez80.breg * 003o + 031o
element  po?: @ez80.breg * 010o + 041o
element  pe?: @ez80.breg * 010o + 051o
nv? = po?
v? = pe?
element   p?: @ez80.breg * 010o + 061o
element   m?: @ez80.breg * 010o + 071o
element   d?: @ez80.breg * 003o + 032o
element   e?: @ez80.breg * 003o + 033o
element   h?: @ez80.breg * 003o + 034o
element ixh?: @ez80.breg * 335o + 034o
element iyh?: @ez80.breg * 375o + 034o
element   l?: @ez80.breg * 003o + 035o
element ixl?: @ez80.breg * 335o + 035o
element iyl?: @ez80.breg * 375o + 035o
element   f?: @ez80.breg * 002o + 036o
element   a?: @ez80.breg * 003o + 037o

element @ez80.irmb
element   i?: @ez80.irmb * 107o + 127o
element   r?: @ez80.irmb * 117o + 137o
element  mb?: @ez80.irmb * 155o + 156o

element @ez80.wreg
element bc?: @ez80.wreg * 007o + 000o
element de?: @ez80.wreg * 007o + 020o
element hl?: @ez80.wreg * 007o + 040o
element ix?: @ez80.wreg * 335o + 040o
element iy?: @ez80.wreg * 375o + 040o
element sp?: @ez80.wreg * 006o + 060o
element af?: @ez80.wreg * 001o + 060o
element af'? ; '

@ez80.is_reg equ metadata 1 element 1 eq

macro @ez80.inst! @name*, @params&
	restore @name?
	define @name? @name?
	@ez80.oplist equ @name?
	macro @name? @args&
		@ez80.@name @args
	end macro
	iterate <@suffix*,@l,@il>, s,0,il, l,1,il, is,l,0, il,l,1, sis,0,0, lis,1,0, sil,0,1, lil,1,1
		macro @name?.@suffix? @args&
			@ez80.suffix @l, @il
			@name? @args
		end macro
	end iterate
	local @temp
	virtual
		iterate @param, @params
			match @arg @, @param*
				@temp = string `@arg shr 8
				db 'local ', @temp, 10
				match @arg &, @param
					db 'iterate @, ', `@arg, 10, 9, 'indx %%-%+1', 10, 9
				end match
				db '@ez80.classify ', @temp, ', '
				match @@ &, @param
					db '@', 10, 'end iterate', 10
				else
					db `@arg, 10
				end match
			end match
		end iterate
		load @temp: $ - $$ from $$
	end virtual
	esc macro @ez80.@name: @params
		local before, after, noerr
		before := $
		eval @temp
end macro
macro end?.@ez80.inst!
		after := $
		if ~defined noerr & before = after
			err 'invalid arguments'
		end if
		restore @ez80.pre
		assume? adl = @ez80.adl
	esc end macro
end macro

iterate <@name, @opc*>,       \
         nop,   000o,         \
         rlca,  007o,         \
         rrca,  017o,         \
         rla,   027o,         \
         rra,   037o,         \
         daa,   047o,         \
         cpl,   057o,         \
         scf,   067o,         \
         ccf,   077o,         \
         halt,  166o,         \
         exx,   331o,         \
         di,    363o,         \
         ei,    373o,         \
         neg,   <355o, 104o>, \
         retn,  <355o, 105o>, \
         reti,  <355o, 115o>, \
         rrd,   <355o, 147o>, \
         rld,   <355o, 157o>, \
         slp,   <355o, 166o>, \
         stmix, <355o, 175o>, \
         rsmix, <355o, 176o>, \
         inim,  <355o, 202o>, \
         otim,  <355o, 203o>, \
         ini2,  <355o, 204o>, \
         indm,  <355o, 212o>, \
         otdm,  <355o, 213o>, \
         ind2,  <355o, 214o>, \
         inimr, <355o, 222o>, \
         otimr, <355o, 223o>, \
         ini2r, <355o, 224o>, \
         indmr, <355o, 232o>, \
         otdmr, <355o, 233o>, \
         ind2r, <355o, 234o>, \
         ldi,   <355o, 240o>, \
         cpi,   <355o, 241o>, \
         ini,   <355o, 242o>, \
         outi,  <355o, 243o>, \
         outi2, <355o, 244o>, \
         ldd,   <355o, 250o>, \
         cpd,   <355o, 251o>, \
         ind,   <355o, 252o>, \
         outd,  <355o, 253o>, \
         outd2, <355o, 254o>, \
         ldir,  <355o, 260o>, \
         cpir,  <355o, 261o>, \
         inir,  <355o, 262o>, \
         otir,  <355o, 263o>, \
         oti2r, <355o, 264o>, \
         lddr,  <355o, 270o>, \
         cpdr,  <355o, 271o>, \
         indr,  <355o, 272o>, \
         otdr,  <355o, 273o>, \
         otd2r, <355o, 274o>, \
         inirx, <355o, 302o>, \
         otirx, <355o, 303o>, \
         indrx, <355o, 312o>, \
         otdrx, <355o, 313o>
	@ez80.inst @name
		@ez80.emit <opc @opc>
	end @ez80.inst
end iterate

iterate @name, inc, dec
	@ez80.inst @name, @reg*
		if reg.ind
			if reg relativeto reg element 1 & reg @ez80.is_reg @ez80.wreg \
			 & reg metadata 1 scale 0 = 040o
				@ez80.emit idxpre reg, opc 063o + %, idxoff reg
			end if
		else if reg eq reg element 1
			if reg @ez80.is_reg @ez80.wreg & reg metadata 1 scale 1 and 004o
				@ez80.emit idxpre reg, opc reg metadata 1 scale 0 - 005o \
				                         + % shl 3
			else if reg @ez80.is_reg @ez80.breg \
			      & reg metadata 1 scale 1 and 001o
				@ez80.emit idxpre reg, opc reg metadata 1 scale 0 shl 3 \
				                         and 070o or % + 3
			end if
		end if
	end @ez80.inst
end iterate

@ez80.inst ex, @arg1, @arg2*
	if arg1.ind
		if arg2.ind
			err 'invalid indirection'
		else if arg1 eq sp? & arg2 eq arg2 element 1                          \
		      & arg2 @ez80.is_reg @ez80.wreg & arg2 metadata 1 scale 0 = 040o
			@ez80.emit idxpre arg2, opc 343o
		end if
	else if arg2.ind
		@ez80.nest ex @arg2, @arg1
	else if (arg1 eq af? & arg2 eq af'?) | (arg1 eq af'? & arg2 eq af?)
		@ez80.emit opc 010o
	else if (arg1 eq de? & arg2 eq hl?) | (arg1 eq hl? & arg2 eq de?)
		@ez80.emit opc 353o
	end if
end @ez80.inst

@ez80.inst djnz, @addr*
	if addr.ind
		err 'invalid indirection'
	else
		@ez80.emit opc 020o, offset addr - after
	end if
end @ez80.inst
@ez80.inst jr, @arg1*, @arg2
	if arg1.ind | arg2.ind
		err 'invalid indirection'
	else if ~defined arg2
		@ez80.emit opc 030o, offset arg1 - after
	else
		if arg1 eq arg1 element 1 & arg1 @ez80.is_reg @ez80.breg \
		 & arg1 metadata 1 scale 0 and 047o = 001o
			@ez80.emit opc arg1 metadata 1 scale 0 and 030o or 040o, \
			           offset arg2 - after
		end if
	end if
end @ez80.inst
@ez80.inst jq, @arg1*, @arg2
	local off, forward
	if arg1.ind | arg2.ind
		err 'invalid indirection'
	else if ~defined arg2
		off = arg1 - before - 2
		if defined @ez80.pre
			off = off - 1
		end if
		if ~definite @arg1
			define forward
		end if
		if defined forward + after & arg1 eq after
			define noerr
		else if ~elementsof off & -200o <= off & off < 200o
			@ez80.emit opc 030o, offset off
		else
			@ez80.emit opc 303o, word arg1
		end if
	else if arg1 eq arg1 element 1 & arg1 @ez80.is_reg @ez80.breg \
		  & arg1 metadata 1 scale 0 and 007o = 001o
		off = arg2 - before - 2
		if defined @ez80.pre
			off = off - 1
		end if
		if ~definite @arg2
			define forward
		end if
		if defined forward + after & arg2 eq after
			define noerr
		else if arg1 metadata 1 scale 0 < 040o & ~elementsof off \
		      & -200o <= off & off < 200o
			@ez80.emit opc arg1 metadata 1 scale 0 and 030o or 040o, \
			           offset off
		else
			@ez80.emit opc arg1 metadata 1 scale 0 and 070o or 302o, \
			           word arg2
		end if
	end if
end @ez80.inst

@ez80.inst ld, @dst, @src*
	local opc
	if dst.ind & src.ind
		err 'invalid indirection'
	else if dst.ind
		if dst relativeto dst element 1 & dst @ez80.is_reg @ez80.wreg
			if dst metadata 1 scale 0 = 040o
				if src eq src element 1 & src @ez80.is_reg @ez80.breg \
				 & src metadata 1 scale 1 = 003o
					@ez80.emit idxpre dst, opc src metadata 1 scale 0     \
					                         and 007o or 160o, idxoff dst
				else if src eq src element 1 & src @ez80.is_reg @ez80.wreg \
				      & src metadata 1 scale 1 and 005o = 005o
					opc = src metadata 1 scale 0 or 017o
					if src metadata 1 scale 1 > 300o
						if dst metadata 1 scale 1 xor src metadata 1 scale 1 \
						   and 040o
							opc = opc + 017o
						else
							opc = opc + 020o
						end if
					end if
					if dst metadata 1 scale 1 > 300o
						@ez80.emit idxpre dst, opc opc, idxoff dst
					else if ~dst scale 0
						@ez80.emit <opc 355o, opc>
					end if
				else
					@ez80.emit idxpre dst, opc 066o, idxoff dst, byte src
				end if
			else if src eq a? & dst metadata 1 scale 0 < 040o
				@ez80.emit opc dst metadata 1 scale 0 or 002o
			end if
		else if src eq a?
			@ez80.emit opc 062o, word dst
		else if src eq src element 1 & src @ez80.is_reg @ez80.wreg \
		      & src metadata 1 scale 1 and 004o
			if src metadata 1 scale 0 = 040o
				@ez80.emit idxpre src, opc 042o, word dst
			else
				@ez80.emit <opc 355o, src metadata 1 scale 0 or 103o>, word dst
			end if
		end if
	else if src.ind
		if ~dst eq dst element 1
		else if src relativeto src element 1 & src @ez80.is_reg @ez80.wreg
			if src metadata 1 scale 0 = 040o
				if dst @ez80.is_reg @ez80.breg & dst metadata 1 scale 1 = 003o
					@ez80.emit idxpre src, opc dst metadata 1 scale 0 shl 3 \
					                         and 070o or 106o, idxoff src
				else if dst @ez80.is_reg @ez80.wreg            \
				      & dst metadata 1 scale 1 and 005o = 005o
					opc = dst metadata 1 scale 0 or 007o
					if dst metadata 1 scale 1 > 300o
						if dst metadata 1 scale 1 xor src metadata 1 scale 1 \
						   and 040o
							opc = opc + 012o
						else
							opc = opc + 020o
						end if
					end if
					if src metadata 1 scale 1 > 300o
						@ez80.emit idxpre src, opc opc, idxoff src
					else if ~src scale 0
						@ez80.emit <opc 355o, opc>
					end if
				end if
			else if dst eq a? & src metadata 1 scale 0 < 040o
				@ez80.emit opc src metadata 1 scale 0 or 012o
			end if
		else if dst eq a?
			@ez80.emit opc 072o, word src
		else if dst @ez80.is_reg @ez80.wreg & dst metadata 1 scale 1 and 004o
			if dst metadata 1 scale 0 = 040o
				@ez80.emit idxpre dst, opc 052o, word src
			else
				@ez80.emit <opc 355o, dst metadata 1 scale 0 or 113o>, word src
			end if
		end if
	else if dst eq dst element 1
		if dst @ez80.is_reg @ez80.breg
			if src eq src element 1 & src @ez80.is_reg @ez80.breg          \
			 & dst metadata 1 scale 1 and src metadata 1 scale 1 and 001o  \
			 & (dst metadata 1 scale 0 xor src metadata 1 scale 0 and 006o \
			  | dst metadata 1 scale 1 = src metadata 1 scale 1)           \
			 & (~dst eq src | dst metadata 1 scale 0 > 033o)
				@ez80.emit <idxpre dst, src>,                          \
				           opc dst metadata 1 scale 0 shl 3 and 070o   \
				             + src metadata 1 scale 0 and 007o or 100o
			else if src eq src element 1 & src @ez80.is_reg @ez80.irmb \
			      & dst eq a?
				@ez80.emit <opc 355o, src metadata 1 scale 0>
			else if dst metadata 1 scale 1 and 001o
				@ez80.emit idxpre dst,                                         \
				           opc dst metadata 1 scale 0 shl 3 and 070o or 006o, \
				           byte src
			end if
		else if dst @ez80.is_reg @ez80.wreg & dst metadata 1 scale 1 and 004o
			if dst eq sp? & src eq src element 1 & src @ez80.is_reg @ez80.wreg \
			 & src metadata 1 scale 0 = 040o
				@ez80.emit idxpre src, opc 371o
			else if dst eq hl? & src eq i?
				@ez80.emit <opc 355o, 327o>
			else
				@ez80.emit idxpre dst, opc dst metadata 1 scale 0 or 001o, \
				           word src
			end if
		else if dst @ez80.is_reg @ez80.irmb & src eq a?
			@ez80.emit <opc 355o, dst metadata 1 scale 1>
		else if dst eq i? & src eq hl?
			@ez80.emit <opc 355o, 307o>
		end if
	end if
end @ez80.inst

@ez80.inst add, @arg1*, @arg2
	if ~defined arg2
		@ez80.nest add a?, @arg1
	else if arg1.ind
		err 'invalid indirection'
	else if arg1 eq a?
		if arg2.ind
			if arg2 relativeto arg2 element 1 & arg2 @ez80.is_reg @ez80.wreg \
			 & arg2 metadata 1 scale 0 = 040o
				@ez80.emit idxpre arg2, opc 206o, idxoff arg2
			end if
		else if arg2 eq arg2 element 1 & arg2 @ez80.is_reg @ez80.breg \
		      & arg2 metadata 1 scale 1 and 001o
			@ez80.emit idxpre arg2, opc arg2 metadata 1 scale 0 and 007o \
			                          or 200o
		else
			@ez80.emit opc 306o, byte arg2
		end if
	else if arg2.ind
		err 'invalid indirection'
	else if arg1 eq arg1 element 1 & arg1 @ez80.is_reg @ez80.wreg             \
	      & arg2 eq arg2 element 1 & arg1 @ez80.is_reg @ez80.wreg             \
	      & arg1 metadata 1 scale 0 = 040o & arg2 metadata 1 scale 1 and 004o \
	      & (arg1 metadata 1 scale 0 <> arg2 metadata 1 scale 0               \
	       | arg1 metadata 1 scale 1 =  arg2 metadata 1 scale 1)
		@ez80.emit idxpre arg1, opc arg2 metadata 1 scale 0 or 011o
	end if
end @ez80.inst
iterate @name, adc, sbc
	@ez80.inst @name, @arg1*, @arg2
		if ~defined arg2
			if arg1 @ez80.is_reg @ez80.wreg
				@ez80.nest @name hl?, @arg1
			else
				@ez80.nest @name a?, @arg1
			end if
		else if arg1.ind
			err 'invalid indirection'
		else if arg1 eq a?
			if arg2.ind
				if arg2 relativeto arg2 element 1 \
				 & arg2 @ez80.is_reg @ez80.wreg   \
				 & arg2 metadata 1 scale 0 = 040o
					@ez80.emit idxpre arg2, opc 176o + % shl 4, idxoff arg2
				end if
			else if arg2 eq arg2 element 1 & arg2 @ez80.is_reg @ez80.breg \
			      & arg2 metadata 1 scale 1 and 001o
				@ez80.emit idxpre arg2, opc arg2 metadata 1 scale 0 and 007o \
				                          or 170o + % shl 4
			else
				@ez80.emit opc 276o + % shl 4, byte arg2
			end if
		else if arg2.ind
			err 'invalid indirection'
		else if arg1 eq hl? & arg2 eq arg2 element 1 \
		      & arg2 @ez80.is_reg @ez80.wreg         \
		      & arg2 metadata 1 scale 1 and 002o
			@ez80.emit <opc 355o, arg2 metadata 1 scale 0 + 122o - % shl 3>
		end if
	end @ez80.inst
end iterate
iterate <@name, @opc*>, \
         sub,   220o,   \
         and,   240o,   \
         xor,   250o,   \
         or,    260o,   \
         cp,    270o
	@ez80.inst @name, @arg1*, @arg2
		if ~defined arg2
			if arg1.ind
				if arg1 relativeto arg1 element 1 \
				 & arg1 @ez80.is_reg @ez80.wreg   \
				 & arg1 metadata 1 scale 0 = 040o
					@ez80.emit idxpre arg1, opc @opc or 006o, idxoff arg1
				end if
			else if arg1 relativeto arg1 element 1   \
			      & arg1 @ez80.is_reg @ez80.breg     \
			      & arg1 metadata 1 scale 1 and 001o
				@ez80.emit idxpre arg1, opc arg1 metadata 1 scale 0 and 007o \
				                          or @opc
			else
				@ez80.emit opc @opc or 106o, byte arg1
			end if
		else if arg1.ind
			err 'invalid indirection'
		else if arg1 eq a?
			@ez80.nest @name @arg2
		end if
	end @ez80.inst
end iterate
@ez80.inst tst, @arg1*, @arg2
	if ~defined arg2
		if arg1.ind
			if arg1 eq hl?
				@ez80.emit <opc 355o, 064o>
			end if
		else if arg1 eq arg1 element 1 & arg1 @ez80.is_reg @ez80.breg \
		      & arg1 metadata 1 scale 1 = 003o
			@ez80.emit <opc 355o,                                           \
			                arg1 metadata 1 scale 0 shl 3 and 070o or 004o>
		else
			@ez80.emit <opc 355o, 144o>, byte arg1
		end if
	else if arg1.ind
		err 'invalid indirection'
	else if arg1 eq a?
		@ez80.nest tst @arg2
	end if
end @ez80.inst

@ez80.inst ret, @cond
	if ~defined cond
		@ez80.emit opc 311o
	else if cond.ind
		err 'invalid indirection'
	else if cond eq cond element 1 & cond @ez80.is_reg @ez80.breg \
	      & cond metadata 1 scale 0 and 007o = 001o
		@ez80.emit opc cond metadata 1 scale 0 and 070o or 300o
	end if
end @ez80.inst
iterate @name, pop, push
	@ez80.inst @name, @reg*&
		while defined reg + reg.ind
			if reg.ind
				err 'invalid indirection'
			else if reg eq reg element 1 & reg @ez80.is_reg @ez80.wreg \
			      & reg metadata 1 scale 1 and 001o
				@ez80.emit idxpre reg,                                 \
				           opc reg metadata 1 scale 0 + 275o + % shl 2
			else if `@name = 'push'
				@ez80.nest pea reg
			else
				err 'invalid argument'
			end if
			restore reg, reg.ind
		end while
	end @ez80.inst
end iterate

@ez80.inst jp, @arg1*, @arg2
	if ~defined arg2
		if ~arg1.ind
			@ez80.emit opc 303o, word arg1
		else if arg1 eq arg1 element 1 & arg1 @ez80.is_reg @ez80.wreg \
		      & arg1 metadata 1 scale 0 = 040o
			@ez80.emit idxpre arg1, opc 351o
		end if
	else if arg1.ind | arg2.ind
		err 'invalid indirection'
	else if arg1 eq arg1 element 1 & arg1 @ez80.is_reg @ez80.breg \
	      & arg1 metadata 1 scale 0 and 007o = 001o
		@ez80.emit opc arg1 metadata 1 scale 0 and 070o or 302o, word arg2
	end if
end @ez80.inst
@ez80.inst call, @arg1*, @arg2
	if arg1.ind | arg2.ind
		err 'invalid indirection'
	else if ~defined arg2
		@ez80.emit opc 315o, word arg1
	else if arg1 eq arg1 element 1 & arg1 @ez80.is_reg @ez80.breg \
	      & arg1 metadata 1 scale 0 and 007o = 001o
		@ez80.emit opc arg1 metadata 1 scale 0 and 070o or 304o, word arg2
	end if
end @ez80.inst
@ez80.inst rst, @addr*
	if addr.ind
		err 'invalid indirection'
	else if addr = addr and 070o
		@ez80.emit opc addr or 307o
	else
		err 'invalid rst target'
	end if
end @ez80.inst

iterate <@name, @opc*>, \
         rlc,   000o,   \
         rrc,   010o,   \
         rl,    020o,   \
         rr,    030o,   \
         sla,   040o,   \
         sra,   050o,   \
         srl,   070o
	@ez80.inst @name, @reg*
		if `@name = 'rl' & ~defined @ez80.pre & ~elementsof reg
			rb long? * reg
			define noerr
		else if reg.ind
			if reg relativeto reg element 1 & reg @ez80.is_reg @ez80.wreg \
			 & reg metadata 1 scale 0 = 040o
				@ez80.emit idxpre reg, opc 313o, idxoff reg, opc @opc or 006o
			end if
		else if reg eq reg element 1 & reg @ez80.is_reg @ez80.breg \
		      & reg metadata 1 scale 1 = 003o
			@ez80.emit <opc 313o, reg metadata 1 scale 0 and 007o or @opc>
		end if
	end @ez80.inst
end iterate
iterate @name, bit, res, set
	@ez80.inst @name, @bit, @reg*
		if bit.ind
			err 'invalid indirection'
		else if reg.ind
			if reg relativeto reg element 1 & reg @ez80.is_reg @ez80.wreg \
			 & reg metadata 1 scale 0 = 040o
				@ez80.emit idxpre reg, opc 313o, idxoff bit shr 3 + reg, \
				           opc bit shl 3 and 070o or % shl 6 or 006o
			end if
		else if reg eq reg element 1
			if reg @ez80.is_reg @ez80.breg & reg metadata 1 scale 1 = 003o \
			 & bit = bit and 007o
				@ez80.emit <opc 313o, reg metadata 1 scale 0 and 007o \
				                    or % shl 6 or bit shl 3>
			else if reg @ez80.is_reg @ez80.wreg                        \
			      & reg metadata 1 scale 1 = 007o & bit = bit and 017o
				@ez80.emit <opc 313o, bit shl 3 and 070o or % shl 6 \
				                    or reg metadata 1 scale 0 shr 3 \
				                    or 001o and not bit shr 3>
			end if
		end if
	end @ez80.inst
end iterate

@ez80.inst out, @port, @reg*
	if ~port.ind
		err 'missing indirection'
	else if reg.ind
		err 'invalid indirection'
	else if port eq bc? | port eq c?
		if reg eq reg element 1 & reg @ez80.is_reg @ez80.breg \
		 & reg metadata 1 scale 1 = 003o
			@ez80.emit <opc 355o, reg metadata 1 scale 0 shl 3 and 070o \
			                        or 101o>
		else if ~reg
			@ez80.emit <opc 355o, 161o>
		end if
	else if reg eq a?
		@ez80.emit opc 323o, byte port
	end if
end @ez80.inst
@ez80.inst in, @reg*, @port
	if ~defined port
		@ez80.nest in f?, @reg
	else if reg.ind
		err 'invalid indirection'
	else if ~port.ind
		err 'missing indirection'
	else if port eq bc? | port eq c? & reg eq reg element 1               \
	      & reg @ez80.is_reg @ez80.breg & reg metadata 1 scale 1 and 002o
		@ez80.emit <opc 355o, reg metadata 1 scale 0 shl 3 and 070o or 100o>
	else if reg eq a?
		@ez80.emit opc 333o, byte port
	end if
end @ez80.inst
@ez80.inst in0, @reg*, @port
	if ~defined port
		@ez80.nest in0 f?, @reg
	else if reg.ind
		err 'invalid indirection'
	else if ~port.ind
		err 'missing indirection'
	else if reg eq reg element 1 & reg @ez80.is_reg @ez80.breg \
	      & reg metadata 1 scale 1 and 002o
		@ez80.emit <opc 355o, reg metadata 1 scale 0 shl 3 and 070o \
		                        or 000o>, byte port
	end if
end @ez80.inst
@ez80.inst out0, @port, @reg*
	if ~port.ind
		err 'missing indirection'
	else if reg.ind
		err 'invalid indirection'
	else if reg eq reg element 1 & reg @ez80.is_reg @ez80.breg \
	      & reg metadata 1 scale 1 = 003o
		@ez80.emit <opc 355o, reg metadata 1 scale 0 shl 3 and 070o \
		                        or 001o>, byte port
	end if
end @ez80.inst
@ez80.inst tstio, @src*
	if src.ind
		err 'invalid indirection'
	else
		@ez80.emit <opc 355o, 164o>, byte src
	end if
end @ez80.inst

@ez80.inst lea, @dst, @src*
	if dst.ind | src.ind
		err 'invalid indirection'
	else if dst eq dst element 1 & src relativeto src element 1            \
	      & dst @ez80.is_reg @ez80.wreg & src @ez80.is_reg @ez80.wreg      \
	      & dst metadata 1 scale 0 <> 060o & src metadata 1 scale 1 > 300o
		local opc
		if dst metadata 1 scale 1 and 002o
			opc = src metadata 1 scale 1 shr 5 and 001o \
			   or dst metadata 1 scale 0 or 002o
		else if dst relativeto src
			opc = dst metadata 1 scale 1 shr 5 and 001o or 062o
		else
			opc = dst metadata 1 scale 1 shr 5 and 001o or 124o
		end if
		@ez80.emit <opc 355o, opc>, offset src scale 0
	end if
end @ez80.inst
@ez80.inst pea, @src*
	if src.ind
		err 'invalid indirection'
	else if src relativeto src element 1 & src @ez80.is_reg @ez80.wreg \
	 & src metadata 1 scale 1 > 300o
		@ez80.emit <opc 355o, src metadata 1 scale 1 shr 5 and 001o + 145o>, \
		           offset src scale 0
	end if
end @ez80.inst

@ez80.inst im, @mode*
	if mode.ind
		err 'invalid indirection'
	else if mode = 0
		@ez80.emit <opc 355o, 106o>
	else if mode = 1
		@ez80.emit <opc 355o, 126o>
	else if mode = 2
		@ez80.emit <opc 355o, 136o>
	else
		err 'invalid mode'
	end if
end @ez80.inst

@ez80.inst mlt, @reg*
	if reg.ind
		err 'invalid indirection'
	else if reg eq reg element 1 & reg @ez80.is_reg @ez80.wreg \
	      & reg metadata 1 scale 1 and 002o
		@ez80.emit <opc 355o, reg metadata 1 scale 0 or 114o>
	end if
end @ez80.inst

purge inst
purge end?.inst
