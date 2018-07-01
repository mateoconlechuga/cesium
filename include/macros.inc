; included general files

include 'fasmg-ez80/ez80.inc'
include 'fasmg-ez80/tiformat.inc'
format ti executable 'CESIUM'
include 'app.inc'
include 'ti84pceg.inc'

; useful macros

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
	macro end?.relocate?
		name.length? := $ - name.destination?
		org name.source? + name.length?
		purge end?.relocate?
	end macro
end macro

macro set_cursor? x, y
	ld	bc,x
	ld	a,y
	call	util_set_cursor
end macro

macro save_cursor?
	call	util_save_cursor
end macro

macro restore_cursor?
	call	util_restore_cursor
end macro

macro set_text_fg_color? index
	ld	a,index
	ld	(lcd_text_fg),a
end macro

macro set_text_bg_color? index
	ld	a,index
	ld	(lcd_text_bg),a
end macro

macro set_inverted_text?
	call	util_set_inverted_text_color
end macro

macro set_normal_text?
	call	util_set_normal_text_color
end macro

macro print? string, x, y
	ld	hl,string
	ld	bc,x
	ld	a,y
	call	util_string_xy
end macro

macro draw_rectangle Lx, Ty, Rx, By
	ld	bc,Rx - Lx
	ld	de,(lcdWidth * Ty) + Lx
	ld	a,By - Ty
	call	lcd_rectangle.computed
end macro

macro draw_rectangle_outline? Lx, Ty, Rx, By
	ld	bc,Rx - Lx + 1
	ld	d,By - Ty + 1
	ld	e,Ty
	ld	hl,Lx
	call	lcd_rectangle_outline.computed
end macro

macro draw_rectangle_outline_double? Lx, Ty, Rx, By
	draw_rectangle_outline Lx, Ty, Rx, By
	draw_rectangle_outline Lx+1, Ty+1, Rx-1, By-1
end macro

macro draw_horiz? x, y, length
	ld	hl,(lcdWidth * y) + vRamBuffer + x
	ld	bc,length
	call	lcd_horizontal.computed
end macro

macro draw_vert? x, y, length
	ld	hl,(lcdWidth * y) + vRamBuffer + x
	ld	b,length
	call	lcd_vertical.computed
end macro

macro draw_sprite? sprite, x, y
	ld	hl,sprite
	ld	bc,(256 * x) + y
	call	lcd_sprite
end macro

macro draw_sprite_2x? x, y
	ld	bc,(256 * x) + y
	call	lcd_sprite_2x
end macro

macro compare_hl_zero?
	add	hl,de
	or	a,a
	sbc	hl,de
end macro

macro compare_hl_de?
	or	a,a
	sbc	hl,de
	add	hl,de
end macro

macro draw_option? Lx, Ty, Rx, By
	ld	bc,Rx - Lx + 1
	ld	de,((By - Ty + 1) * 256) + Ty
	ld	hl,Lx
	call	gui_draw_option
end macro

macro draw_highlightable_option? Lx, Ty, Rx, By, num
	ld	bc,Rx - Lx + 1
	ld	de,((By - Ty + 1) * 256) + Ty
	ld	hl,Lx
	ld	a,num
	call	gui_draw_highlightable_option
end macro

macro flash_unlock_m
	di
	ld.sis	sp,$ea1f
	call.is	flash_unlock and $ffff
end macro

macro flash_lock_m
	call.is	flash_lock and $ffff
end macro

; general

cesium_version := '3.0'
cesium_name := 'Cesium'
cesium_copyright := '(C) 2018 MateoConLechuga'
cesium_execution_base := $d09466

config_english := 1

; file management

file_asm := 0
file_c := 1
file_basic := 2
file_ice := 3
file_ice_source := 4
file_dir := 5

byte_cesium := $01
byte_jp := $c3
byte_ice_source := $2c
byte_ice := $7f
byte_c := $00
byte_dir := file_dir

item_location_base := pixelShadow

; lcd

vRamBuffer := vRam + ((vRamEnd - vRam) / 2)

; colors

color_primary_default := 107
color_secondary_default := 107
color_white := 255
color_highlight := 230
color_hidden := 181

; password

password_max_length := 10

; settings flags

settings_flag := $22
setting_basic_indicator := 0
setting_list_count := 1
setting_clock := 2
setting_ram_backup := 3
setting_special_directories := 4
setting_enable_shortcuts := 5

settings_appvar_size := 30
setting_config_default := (1 shl setting_special_directories) or (1 shl setting_enable_shortcuts)

; sorting flags

sort_flag := $21
sort_first_item_found := 0
sort_first_hidden := 1
sort_second_hidden := 2

; cesium flags

cesium_flag := $21
cesium_is_disabled := 3
cesium_is_nl_disabled := 4
cesium_execute_alt := 5

; program flags

item_flag := $2f
drawing_selected := 0
scroll_down_available := 1
scroll_up_available := 2
item_renaming := 3

prgm_flag := $30
prgm_archived := 0
prgm_locked := 1
prgm_hidden := 2

temp_prgm_flag := $31
temp_prgm_archived := 0
temp_prgm_locked := 1
temp_prgm_hidden := 2

; location of items

clock_x := 255
clock_y := 7

; location of variables

edit_status := appdata
edit_mode := edit_status + 1

settings_data := edit_mode + 1
setting_color_primary := settings_data
setting_color_secondary := setting_color_primary + 1
setting_config := setting_color_secondary + 1
setting_password := setting_config + 1
current_option_selection := setting_password + password_max_length + 1
current_selection_absolute := current_option_selection + 1
current_selection := current_selection_absolute + 3
scroll_amount := current_selection + 3
current_screen := scroll_amount + 3
prgm_ptr := current_screen + 1
prgm_data_ptr := prgm_ptr + 3
prgm_size := prgm_data_ptr + 3
prgm_real_size := prgm_size + 3
prgm_type := prgm_real_size + 3
item_ptr := prgm_type + 1;

sprite_temp := mpLcdCrsrImage
string_temp := mpLcdCrsrImage

settings_size := setting_password + password_max_length + 1 - settings_data

; colors

color_primary := setting_color_primary
color_secondary := setting_color_secondary

; constants

screen_programs := 0
screen_apps := 1
screen_usb := 2
screen_settings := 3
screen_password := 4
