include 'include/fasmg-ez80/ez80.inc'
include 'include/fasmg-ez80/tiformat.inc'
format ti executable 'CESIUM'
include 'include/app.inc'
include 'include/ti84pceg.inc'
include 'include/macros.inc'

include 'installer.asm'

	app_start cesium_name, cesium_copyright, cesium_version, 3

include 'main.asm'
include 'text.asm'
include 'data.asm'
