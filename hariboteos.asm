; hello-os
; TAB=4

  ORG   0x7c00			; where to load this program
  CYLS  EQU 10      ; cylinder number (max)

; FAT12 Floppy

  JMP   entry
  DB    0x90
  DB    "HELLOIPL"  ; boot sector name
  DW    512         ; 1 sector size
  DB    1           ; claster size
  DW    1           ; where FAT starts (by sector number)
  DB    2           ; number of FAT
  DW    224         ; size of root directory zone (by entry number)
  DW    2880        ; size of this drive (by sector size)
  DB    0xF0        ; type of the media
  DW    9           ; length of FAT zone (by sector size)
  DW    18          ; what number of sector exists in 1 track
  DW    2           ; number of the head
  DD    0           ; partition
  DD    2880        ; size of this drive (one more)
  DB    0,0,0x29    ; ?
  DD    0xFFFFFFFF  ; volume serial number?
  DB    "HELLO-OS   "  ; number of the disk (11 bytes) 
  DB    "FAT12   "  ; type of format (8 bytes)
  TIMES 18 DB 0

; Main

entry:
  MOV   AX, 0       ; initialize Registers
  MOV   SS, AX
  MOV   SP, 0x7c00
  MOV   DS, AX
  MOV   ES, AX

; Read Disk
  MOV   AX, 0x0820
  MOV   ES, AX
  MOV   CH, 0     ; Cylinder 0
  MOV   DH, 0     ; Head 0
  MOV   CL, 2     ; Sector 2 (2nd: not 3rd)
readloop:
  MOV   SI, 0     ; register for counting errors
retry:
  MOV   AH, 0x02  ; read disk
  MOV   AL, 1     ; 1 sector
  MOV   BX, 0
  MOV   DL, 0x00  ; A drive
  INT   0x13      ; call disk bios
  JNC   next
  ADD   SI, 1
  CMP   SI, 5
  JAE   error     ; Jump if Above or Equel
  MOV   AH, 0x00
  MOV   DL, 0x00
  INT   0x13      ; reset drive
  JMP   retry
next:
  MOV   AX, ES    ; advance ES adrress 0x20
  ADD   AX, 0x0020
  MOV   ES, AX
  ADD   CL, 1
  CMP   CL, 18
  JBE   readloop  ; Jump if Below or Equal
  MOV   CL, 1
  ADD   DH, 1
  CMP   DH, 2
  JB    readloop
  MOV   DH, 0
  ADD   CH, 1
  CMP   CH, CYLS
  JB    readloop

fin:
  HLT
  JMP   fin

error:
  MOV   SI, msg

putloop:
  MOV   AL, [SI]
  ADD   SI, 1
  CMP   AL, 0
  JE    fin
  MOV   AH, 0x0e
  MOV   BX, 15
  INT   0x10
  JMP   putloop

msg:
  DB    0x0a, 0x0a
  DB    "hello, world"
  DB    0x0a
  DB    0

  TIMES 0x7dfe-($-$$) DB 0

  DB    0x55, 0xaa

; After Boot-Sector
  DB    0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
  TIMES 4600 DB 0
  DB    0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
  TIMES 1469432 DB 0
