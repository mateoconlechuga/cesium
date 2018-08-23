; unrelocated data

data_cesium_appvar:
	db	appVarObj
data_string_cesium_name:
	db	cesium_name,0

data_string_password:
if config_english
	db	'Password:',0
else
	db	'Mot de passe:',0
end if

data_string_quit1:
	db	'1:',0,'Quit',0
data_string_quit2:
	db	'2:',0,'Goto',0

; data in this location is allowed to be modified at runtime
	app_data

