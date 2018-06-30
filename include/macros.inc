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

; settings

settings_flag := $22
settings_basic_indicator := 0
settings_list_count := 1
settings_clock := 2
settings_ram_backup := 3
settings_extra_folders := 2
settings_enable_shortcuts := 5
settings_appvar_size := 30

; colors

color_bg_default := 107

; password

password_max_length := 10

; sorting

sort_flag := $21
sort_first_item_found := 0
sort_first_hidden := 1
sort_second_hidden := 2


; location of variables
settings_color := appdata
settings_password := settings_color + 1
current_selection_absolute := settings_password + password_max_length + 1
current_selection := current_selection_absolute + 3
scroll_amount := current_selection + 3
