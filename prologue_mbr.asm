org 0x7c00
PASSWORD_CRC32_VA equ 0x8000
PASSWORD_CRC32_LBA equ 0x1A

start:
pushad
pushf


; ==== READ PASSWORD_CRC32 CODE ====
mov ah, 0x42
lea si, [DAP]
int 0x13
jmp 0:PASSWORD_CRC32_VA

DAP:
db 0x10
db 0
dw 1
dd PASSWORD_CRC32_VA
dq PASSWORD_CRC32_LBA                         ; password crc32 code in winxp.img LBA=0x1A


; ===== READ PASSWORD_CRC32 CODE via CHS =====
;cli
;mov ah, 2
;mov al, 1
;mov cl, 0x1b            ; sector
;mov ch, 0               ; cylinder and sector
;mov dl, 0x80
;mov dh, 0               ; head
;mov bx, PASSWORD_CRC32_VA
;int 13h                 ; read password_mbr from disk 0x200
;jmp 0:PASSWORD_CRC32_VA


; ===== PARTITION TABLE =====
db  446 - ($ - start) dup(0)
dw 0x0180
dd 0x03f070001, 0x003ff7bf, 0xc1c10000, 0x0000002e
db 510 - ($ - start) dup (0)

; ===== MAGIC NUMBER =====
dw 0xaa55






