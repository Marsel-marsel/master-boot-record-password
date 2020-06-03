org 0x8000  ; RAW = 0x3400


PASSWD_SIZE equ 20
ORIG_MBR_LBA equ 0x1b
MBR_VA equ 0x7c00

main:
; ZERO PASSWORD MEMORY
mov cx, PASSWD_SIZE/2
xor ax, ax
lea di, [passwd_input]
rep stosw

; PRINT "Enter password: "
lea si, [welcome]
print_next:
lodsb
test al, al
jz read_password
mov ah, 0xE
int 0x10
jmp print_next

; READ USER INPUT
read_password:
lea edi, [passwd_input]
mov cx, PASSWD_SIZE
read_next: mov ah, 0
int 0x16
cmp al, 0xD
jz new_line
stosb
mov al, '*'
mov ah, 0xE
int 0x10
loop read_next

; PRINT "\n\r"
new_line:
mov al, 0xA
mov ah, 0xE
int 0x10
mov al, 0xD
mov ah, 0xE
int 0x10

; CALCULATE CRC-32 OF USER INPUT (GENERATOR POLYNOMIAL = 0xdeadbeef)
lea esi, [passwd_input]
xor ebx, ebx                    ; store crc-32 result in ebx

next_byte: mov al, [si]         ; read symbol
inc si
test al, al
jz crc_end                      ; exit if all symbols have been  proceed
shl eax, 56                     ; shift symbol to the most left of eax  (0x00000031 becomes 0x31000000)
xor ebx, eax                    ; xor with previously calculated crc-32
xor cx, cx                      ; bits counter in cx

next_bit: cmp cx, 8
je next_byte
shl ebx, 1                      ; shift crc-32 to the left
inc cx
jb xor_gen32                    ; if MSB is set xor with genarator polynomial
jmp next_bit
xor_gen32: xor ebx, [gen32]
jmp next_bit
crc_end: nop

; COMPARE USER'S CRC-32 WITH PREDEFINED CRC-32 OF "123"
cmp ebx, [passwd_crc32]
jnz main        ; WRONG PASSWORD, GO AGAIN

; PASSWORD OK
; WRITE ORIGINAL MBR TO 7C00
mov ah, 0x42
lea si, [ORIG_MBR_DAP]
int 0x13

popf
popad

; JUMP TO ORIGINAL MBR. CONTINUE WINDOWS LOADING
jmp 0:MBR_VA

; .DATA
ORIG_MBR_DAP:
db 0x10
db 0
dw 1
dd MBR_VA
dq ORIG_MBR_LBA     ; password crc32 code in winxp.img LBA=0x1A

welcome db "Enter password: ", 0
passwd_input db PASSWD_SIZE  dup(0), 0
gen32 dd 0xDEADBEEF
passwd_crc32 dd 0xac9bb5fb           ; "123" CRC-32'ed

