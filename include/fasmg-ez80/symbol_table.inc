macro ?!
	local output, context, latest
	virtual as 'lab'
		output::
	end virtual
	context equ
	latest equ
	macro namespace? name*
		namespace? name
			match expand, context
				context equ expand.name
			else
				context equ name
			end match
			latest equ
	end macro
	macro end?.namespace?
			restore context, latest
		end?.namespace?
	end macro
	struc (name) ? line&
		name line
		match :: @, line*
		else match : @, line*
			if defined name
				local value
				value = name
				if value eqtype 0 & value relativeto 0
					virtual output
						match expand, context
							db `expand, '.'
						end match
						if `name and $FF = '.'
							match expand, latest
								db `expand
							end match
						else match :== @@, line*
						else
							latest reequ name
						end match
						db `name, ' = '
						if value < 0
							db '-'
							value = -value
						end if
						repeat 1, bind: value
							db `bind, 10
						end repeat
					end virtual
				end if
			end if
		end match
	end struc
	purge ?
end macro
