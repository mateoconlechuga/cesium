; unrelocated data

data_cesium_appvar:
	db	appVarObj
data_string_cesium_name:
	db	cesium_name,0

data_string_password:
if config_english
	db	'Password:',0
else
	db	'Mot de passe:'',0
end if

; data in this location is allowed to be modified at runtime
	app_data
