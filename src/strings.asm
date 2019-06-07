; commonly used strings

string_cesium:
	db	cesium_name,0
string_cesium_version:
	db	cesium_name,' Version ',cesium_version,0
string_asm:
	db	'eZ80',0
string_c:
	db	'C',0
string_ice:
	db	'ICE',0
string_ice_source:
	db	'ICE S',0
string_directory:
	db	'Folder',0
string_usb:
	db	'USB',0
string_basic:
	db	'Basic',0
string_application:
	db	'App',0
string_ti:
	db	'TI-OS',0
string_unknown:
	db	'Unknown',0
string_appvar:
	db	'Data',0
string_mode_select:
	db	'   < ',$7e,'MODE] >',0
string_min_os_version:
	db	'5.0.0.0.0',0
.length := $-.

; english configuration

if config_english

string_primary_color:
	db	'Primary Color',0
string_secondary_color:
	db	'Secondary Color',0
string_tertiary_color:
	db	'Highlight Color',0
string_quaternary_color:
	db	'Inversion Color',0
string_quinary_color:
	db	'Hidden Program Color',0
string_senary_color:
	db	'Background Color',0
string_language:
	db	'Type: ',0
string_archived:
	db	'Archived',0
string_read_only:
	db	'Read-Only',0
string_hidden:
	db	'Hidden',0
string_system:
	db	'System',0
string_locked:
	db	'Locked',0
string_size:
	db	'Size: ',0
string_min_version:
	db	'Min Version:',0
string_ram_free:
	db	'RAM Free: ',0
string_rom_free:
	db	'ROM Free: ',0
string_file_information:
	db	'File Information',0
string_settings:
	db	'Settings',0
	db	$7e,'MODE]',0
string_delete:
	db	'Delete',0
	db	$7e,'DEL]',0
string_attributes:
	db	'Attrib',0
	db	$7e,'ALPHA]',0
string_rename:
	db	'Rename',0
	db	$7e,'GRAPH]',0
string_transfer:
	db	'Transfer',0
	db	$7e,'PRGM]',0
string_edit_prgm:
	db	'Edit Prgm',0
	db	$7e,'ZOOM]'
string_new_prgm:
	db	'New Prgm',0
	db	$7e,'Y=]'
string_editor_name:
	db	'Prgm Editor',0
string_delete_confirmation:
	db	'Delete?: ',$7e,'ZOOM]-Yes  ',$7e,'GRAPH]-No',0
string_general_settings:
	db	'General Settings',0
string_setting_color:
	db	'Cesium Color',0
string_setting_indicator:
	db	'Disable busy indicator in programs',0
string_setting_list_count:
	db	'Show directory item count',0
string_setting_clock:
	db	'Display clock',0
string_setting_ram_backup:
	db	'Backup RAM before executing programs',0
string_setting_special_directories:
	db	'Show special directories',0
string_setting_enable_shortcuts:
	db	'Enable keypad shortcuts',0
string_settings_usb_edit:
	db	'Enable USB flash drive access',0
string_settings_delete_confirm:
	db	'Show item deletion confirmation prompt',0
string_new_password:
	db	'Input new password: ',0
string_usb_info_0:
	db	'Use any FAT32 USB flash drive',0
string_usb_info_1:
	db	'for external storage and transfer.',0
string_usb_info_2:
	db	'You will need to install LibLoad',0
string_usb_info_3:
	db	'and the FATDRVCE library from here:',0
string_usb_info_4:
	db	'http://tiny.cc/clibs',0
string_usb_info_5:
	db	'Press enter to retry.',0
string_usb_not_detected:
	db	'No USB Connection Detected.',0
string_usb_no_partitions:
	db	'No FAT32 partitions found.',0
string_insert_fat32:
	db	'Please insert a FAT32 formatted drive.',0
string_partition:
	db	'Partition ',0
string_select_partition_0:
	db	'This drive contains multiple partitions.',0
string_select_partition_1:
	db	'Choose one from the list above.',0
string_fat_init_error_0:
	db	'Error initializing FAT partition.',0
string_fat_init_error_1:
	db	'Error code: ',0
string_fat_transferring:
	db	'Transferring...',0
string_ram_error:
	db	'Not enough free RAM',0

; french configuration

else

string_primary_color:
	db	'Couleur primaire',0
string_secondary_color:
	db	'Couleur secondaire',0
string_tertiary_color:
	db	'Couleur surligner',0
string_quaternary_color:
	db	'Couleur invers',$82,0
string_quinary_color:
	db	'Couleur programme cach',$82,0
string_senary_color:
	db	'Couleur contexte',0
string_language:
	db	'Langage : ',0
string_archived:
	db	'Archiv',$82,0
string_hidden:
	db	'Cach',$82,0
string_locked:
	db	'Verrouill',$82,0
string_size:
	db	'Taille : ',0
string_min_version:
	db	'Min Version:',0
string_ram_free:
	db	'RAM Libre : ',0
string_rom_free:
	db	'ROM Libre : ',0
string_file_information:
	db	'    Infos fichier',0
string_settings:
	db	'Options',0
	db	$7e,'MODE]',0
string_delete:
	db	'Effacer',0
	db	$7e,'SUPPR]',0
string_attributes:
	db	'Attrib',0
	db	$7e,'ALPHA]',0
string_rename:
	db	'Nom',0
	db	$7e,'GRAPH]',0
string_edit_prgm:
	db	'Modifier',0
	db	$7e,'ZOOM]'
string_new_prgm:
	db	'Nouveau',0
	db	$7e,'Y=]',0
string_editor_name:
	db	'Editeur de prgm',0
string_delete_confirmation:
	db	'Supprimer ? ',$7e,'ZOOM]-Oui ',$7e,'GRAPH]-Non',0
string_general_settings:
	db	'Options g',$82,'n',$82,'rales',0
string_setting_color:
	db	'Couleur de Cesium',0
string_setting_indicator:
	db	'Cacher l',$27,'indicateur de calcul en BASIC',0
string_setting_list_count:
	db	'Afficher le nombre de programmes',0
string_setting_clock:
	db	'Afficher l',$27,'horloge',0
string_setting_ram_backup:
	db	'Sauver la RAM avant de lancer des prgms',0
string_setting_special_directories:
	db	'Afficher les r',$82,'pertoires sp',$82,'ciaux',0
string_setting_enable_shortcuts:
	db	'Activer les raccourcis clavier',0
string_settings_usb_edit:
	db	'Activer le support de cl',$82,'s USB',0
string_settings_delete_confirm:
	db	'Afficher l',$27,'invite de suppression',0
string_new_password:
	db	'Saisir le nouveau mot de passe : ',0
string_read_only:
	db	'Lecture seule',0
string_system:
	db	'Systeme',0
string_transfer:
	db	'Transfer',0
	db	$7e,'PRGM]',0
string_usb_info_0:
	db	'Utilisez une cl',$82,' USB en FAT32',0
string_usb_info_1:
	db	'pour du stockage externe et transferts.',0
string_usb_info_2:
	db	'Vous devrez installer LibLoad',0
string_usb_info_3:
	db	'et la lib FATDRVCE depuis ici :',0
string_usb_info_4:
	db	'http://tiny.cc/clibs',0
string_usb_info_5:
	db	'Appuyez sur ',$7e,'entrer] pour retenter.',0
string_usb_not_detected:
	db	'Pas de connection USB d',$82,'tect',$82,'e.',0
string_usb_no_partitions:
	db	'Pas de partition FAT32 trouv',$82,'e.',0
string_insert_fat32:
	db	'Veuillez brancher une cl',$82,' format',$82,'e en FAT32.',0
string_partition:
	db	'Partition ',0
string_select_partition_0:
	db	'Cette cl',$82,' contient plusieurs partitions.',0
string_select_partition_1:
	db	'Choisissez-en une depuis la liste ci-dessus.',0
string_fat_init_error_0:
	db	'Erreur d',$27,'init de la partition FAT.',0
string_fat_init_error_1:
	db	'Code d\'erreur : ',0
string_fat_transferring:
	db	'Transfert en cours...',0
string_ram_error:
	db	'Pas assez de RAM libre',0

end if
