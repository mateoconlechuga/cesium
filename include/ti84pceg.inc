macro private
	; assign needs to be local so that it is only
	; defined once (no purge!) so that it can be
	; forward referenced so that it can recurse
	local assign
	macro assign name*, expr&
		match left =% right, expr
			assign name, left mod right
		else match left =| right, expr
			assign name, left or right
		else match left =& right, expr
			assign name, left and right
		else match left =^ right, expr
			assign name, left xor right
		else match left =<=< right, expr
			assign name, left shl right
		else match left =>=> right, expr
			assign name, left shr right
		else match left =~ right, expr
			assign name, left not right
		else match =~ right, expr
			assign name, not right
		else
			name? = expr
		end match
	end macro
	struc (name) equ? expr&
		assign name, expr
	end struc
	macro Ld args&
		match =equ? expr, args
			assign name, expr
		end match
	end macro
end macro
private
purge private

macro .list?
end macro
macro .nolist?
end macro
macro #define? name
end macro
macro #ifdef? name
end macro
macro #ifndef? name
end macro
macro #endif?
end macro

element anovaf_vars?
include 'ti84pce.inc'

restruc equ?
purge Ld
purge .list?
purge .nolist?
purge #define?
purge #ifdef?
purge #ifndef?
purge #endif?
