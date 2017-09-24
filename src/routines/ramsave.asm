
	.assume	adl = 0
	
unlock:	ld	a, $8c
	out0	($24), a
	ld	c, 4
	in0	a, (6)
	or	c
	out0	(6), a
	out0	($28), c
	ret.l
lock:	xor	a, a
	out0	($28), a
	in0	a, (6)
	res	2, a
	out0	(6), a
	ld	a, $88
	out0	($24), a
	ret.l
	
	.assume adl = 1
