 define .icon,space=ram
 segment .icon
 xdef __icon_begin
 xdef __icon_end
 xdef __program_description
 xdef __program_description_end

 db 1
 db 16,16
__icon_begin:
 db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0DEh,0D6h,0D6h,0DEh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
 db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0D6h,0DEh,0DEh,0B5h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
 db 0FFh,0FFh,0DEh,0D6h,0D6h,0FFh,0D6h,0DEh,0DEh,0B5h,0FFh,0B5h,0B5h,0B6h,0FFh,0FFh
 db 0FFh,0DEh,0DEh,0FEh,0DEh,0B6h,0B5h,0D6h,0D6h,0B5h,0B5h,0D6h,0DEh,0B5h,0B6h,0FFh
 db 0FFh,0DEh,0B6h,0DEh,0D6h,0DEh,0DEh,0D6h,0D6h,0DEh,0D6h,0D6h,0D6h,06Ch,0B5h,0FFh
 db 0FFh,0FFh,0DEh,0D6h,0D6h,0D6h,0B5h,094h,094h,0B5h,0B6h,0B5h,0B5h,0B5h,0FFh,0FFh
 db 0D6h,0D6h,0B6h,0DEh,0D6h,0B5h,094h,0DEh,0DEh,0B5h,0B6h,0B5h,0D6h,094h,094h,094h
 db 0B6h,0DEh,0D6h,0D6h,0D6h,0B4h,0DEh,0FFh,0FFh,0DEh,0B5h,0B6h,0B5h,0B6h,0DEh,06Bh
 db 0B5h,0DEh,0D6h,0B6h,0D6h,0B5h,0DEh,0FFh,0FFh,0DEh,0B5h,0B5h,0B5h,0B5h,0D6h,06Bh
 db 0B5h,094h,0B4h,0D6h,0B6h,0D6h,0B5h,0DEh,0DEh,0B5h,0B5h,0B5h,0B5h,06Bh,06Bh,06Bh
 db 0FFh,0FFh,0D6h,0B6h,0B5h,0B6h,0B6h,0B5h,0B5h,0B5h,0B5h,0B5h,0B5h,0B5h,0FFh,0FFh
 db 0FFh,0D6h,0B4h,0D6h,0B6h,0D6h,0D6h,0D6h,0B6h,0D6h,0B6h,0B5h,0D6h,06Bh,0B5h,0FFh
 db 0FFh,0D6h,0B5h,0DEh,0B4h,093h,093h,0B6h,0B5h,06Bh,06Bh,0B4h,0D6h,08Ch,0B5h,0FFh
 db 0FFh,0FFh,0B5h,06Bh,06Bh,0FFh,094h,0D6h,0B6h,06Bh,0FEh,06Bh,04Ah,094h,0FFh,0FFh
 db 0FFh,0FFh,0FFh,0DEh,0FFh,0FFh,094h,0B5h,0B5h,06Bh,0FFh,0FFh,0DEh,0FFh,0FFh,0FFh
 db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0B6h,08Ch,06Ch,0B5h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
__icon_end:
__program_description:
 db "iconc.png",0
__program_description_end:
