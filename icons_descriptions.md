# Program Icons / Descriptions

Program headers can be added to the start of your program to support icon and/or
description displaying from within Cesium.

## C Headers

If you use the C toolchain, you can use the makefile to control the header.
More information is available at the following URL:
https://ce-programming.github.io/toolchain/static/makefile-options.html#icon

## TI-BASIC Headers

TI-BASIC programs can have custom icons and descriptions.
Note that '0' indicates a transparent color in the following hex strings.

I recommend using TIFreak's icon creator, available at the following URL:
https://www.ticalc.org/archives/files/fileinfo/460/46035.html

    ::"Description                   (no closing quote)
    ::"256 character hex string"

Additional icons and description formats are as follows:

Description only format:

    ::"Description                   (no closing quote)

Icon only format:

    ::DCS
    :"256 character hex string"

Monochrome 8x8 icon format:

    ::DCS
    :"16 character hex string"

Monochrome 16x16 icon format:

    ::DCS6
    :"64 character hex string"

## ICE Headers

ICE programs can have specialized headers too. The format is described at:
https://github.com/PeterTillema/ICE/wiki/Icon-and-description

## Assembly Headers

Assembly programs should start with the show icon/description format shown
below. You can use convimg and the below command to create an icon.

    convimg --icon icon.png --icon-output icon.asm --icon-format asm --icon-description 'This is my icon'

The URL for convimg is:
https://github.com/mateoconlechuga/convimg

```asm
	jp	___prgm_init
	db	$01
___icon:
	db	$10, $10
	db	$FF, $FF, $FF, $FF, $FE, $B5, $B5, $D6, $D6, $B5, $B5, $FE, $FF, $FF, $FF, $FF
	db	$FF, $FF, $FF, $B5, $DE, $DF, $96, $56, $56, $96, $DF, $DE, $B5, $FF, $FF, $FF
	db	$FF, $FF, $B5, $DF, $56, $0E, $0D, $0D, $0D, $0D, $0D, $4E, $DF, $B5, $FF, $FF
	db	$FF, $B5, $DF, $2E, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $2E, $DF, $B5, $FF
	db	$FE, $DE, $56, $0D, $0D, $05, $05, $05, $05, $05, $05, $0D, $0D, $4E, $DE, $FE
	db	$B5, $DF, $0D, $05, $2D, $B7, $DF, $96, $4D, $D7, $D7, $B6, $05, $0D, $B7, $B5
	db	$B5, $96, $05, $2D, $FF, $DE, $76, $96, $4D, $FF, $96, $6E, $05, $05, $76, $B5
	db	$D6, $4E, $05, $76, $FF, $0D, $05, $05, $4D, $FF, $B6, $76, $05, $05, $4D, $D6
	db	$D6, $4E, $05, $76, $FF, $05, $05, $05, $4D, $FF, $B6, $76, $05, $05, $4D, $D6
	db	$B5, $76, $05, $2D, $FF, $B7, $6E, $96, $4D, $FF, $76, $4E, $05, $05, $6D, $B5
	db	$B5, $DE, $05, $05, $4D, $DE, $FF, $96, $4D, $DE, $DE, $B7, $05, $05, $B6, $B5
	db	$FE, $DE, $4E, $05, $05, $04, $04, $04, $04, $04, $04, $05, $05, $2D, $DE, $FE
	db	$FF, $B5, $DF, $2D, $05, $04, $04, $04, $04, $04, $05, $05, $0D, $D6, $B5, $FF
	db	$FF, $FF, $B5, $DF, $4D, $05, $04, $04, $04, $04, $05, $2D, $B6, $B5, $FF, $FF
	db	$FF, $FF, $FF, $B5, $DE, $B6, $6D, $2D, $2D, $4D, $96, $DE, $B5, $FF, $FF, $FF
	db	$FF, $FF, $FF, $FF, $FE, $B5, $B5, $D6, $D6, $B5, $B5, $DE, $FF, $FF, $FF, $FF
___description:
	db	"This is my icon", 0
___prgm_init:
```
