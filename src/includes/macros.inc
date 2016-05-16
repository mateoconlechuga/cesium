#define popCall() pop hl

#macro drawSpr255(sprite, posX, posY)
	ld	hl,sprite
	ld	bc,(posY)+(256*(posX))
	call	_Sprite8bpp
#endmacro

#macro drawRectOutlineDouble(LposX, TposY, RposX, BposY)
	drawRectOutline(LposX, TposY, RposX, BposY)
	drawRectOutline(LposX+1, TposY+1, RposX-1, BposY-1)
#endmacro

#macro drawRectFilled(LposX, TposY, RposX, BposY)
	ld	bc,RposX-LposX
	ld	de,(lcdWidth*TposY)+LposX
	ld	a,BposY-TposY
	call	FillRectangle_Computed
#endmacro

#macro drawRectFilledColor(LposX, TposY, RposX, BposY, color)
	ld	bc,RposX-LposX
	ld	de,(lcdWidth*TposY)+LposX
	ld	a,BposY-TposY
	call	FillRectangle_Computed
#endmacro

#macro drawRectOutline(LposX, TposY, RposX, BposY)
	ld	bc,RposX-LposX+1
	ld	d,BposY-TposY+1
	ld	e,TposY
	ld	hl,LposX
	call	RectangleOutline
#endmacro

#macro drawHLine(posX, posY, length)
	ld	hl,320*posY+vBuf2+posX
	ld	bc,length
	ld	a,(cIndex)
	call	_MemSet
#endmacro

#macro drawVLine(posX, posY, length)
	ld	hl,320*posY+vBuf2+posX
	ld	b,length
	call	drawVLine8
#endmacro

#macro print(string, pos1, pos2)
	ld hl,string
	ld bc,pos1
	ld (posX),bc
	ld a,pos2
	ld (posY),a
	call DrawString
#endmacro

#macro changeFGColor(index)
#if index=0
	xor a
#else
	ld a,index
#endif
	ld (ForeColor),a
#endmacro

#macro SetDefaultTextColor()
	changeFGColor(BG_COlOR_INDEX)
	changeBGColor(255)
#endmacro

#macro SetInvertedTextColor()
	changeFGColor(255)
	ld a,(skinColor)
	ld (BackColor),a
#endmacro

#macro changeBGColor(index)
#if index=0
	xor a
#else
	ld a,index
#endif
	ld (BackColor),a
#endmacro

#macro relocate(new_location)
 #ifdef old_location
 .echo "Mateo: ",__file,":",__line,": Error: You cannot nest relocated blocks."
 #else
 #define old_location eval($)
 .org new_location
 #define g_location eval(new_location)
 #endif
#endmacro

#macro endrelocate()
 #ifdef g_location
 .org $-g_location + old_location
 #undefine g_location
 #undefine old_location
 #else
 .echo "Error line ",__line,": No relocate statements corresponds to this endrelocate."
 #endif
#endmacro
