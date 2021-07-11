; "Route 66", Atari XL/XE Intro 256B
; art direction by Piesiu / Agenda
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2021-07-10

rtclok	equ $0012
rowcrs	equ $0054
colcrs	equ $0055
oldrow	equ $005a
oldcol	equ $005b
sdmctl	equ $022f
gprior	equ $026f
pcolr0	equ $02c0
color0	equ $02c4
atachr	equ $02fb
hposp0	equ $d000
hposp1	equ $d001
sizep2	equ $d00a
colbk	equ $d01a
gractl	equ $d01d
random	equ $d20a
wsync	equ $d40a
vcount	equ $d40b
osgraph	equ $ef9c
osprint	equ $f1a4
ospoint	equ $f1d8
osdraw	equ $f9c2


	org $0080

	bvc start

	; half of the car drawing procedure
draw	ldx #carlne-carln-1
	lda #135
	sta row
loopx1	lda carln,x
	asl
	pha
	and #%00001110
	bcs skipx1
opcodx3	ldy #77
	sty oldcol
	sty colcrs
	;clc				; not necessary
	adc row
	sta oldrow
	sta row
	bvc skipx2
skipx1	;clc				; not necessary
	adc rowcrs
skipx2	sta rowcrs
	pla
	lsr
	lsr
	lsr
opcodx1	eor #$00
opcodx2	clc
	adc colcrs
	sta colcrs
	txa
	pha
	jsr osdraw
	pla
	tax
	dex
	bpl loopx1
	rts

colors	.byte $a2, $02, $78

	; lines of the car
carln	; tires
	.byte 1 << 7 | 0 << 0 | 4 << 3
	.byte 1 << 7 | 0 << 0 | 1 << 3
	.byte 1 << 7 | 3 << 0 | 0 << 3
	.byte 0 << 7 | 0 << 0 | 9 << 3
	.byte 1 << 7 | 3 << 0 | 0 << 3
	.byte 0 << 7 | 0 << 0 | 12 << 3

	; under bumper
	.byte 0 << 7 | 1 << 0 | 13 << 3
	.byte 1 << 7 | 0 << 0 | 0 << 3
	.byte 0 << 7 | 1 << 0 | 13 << 3

	; bumper
	.byte 0 << 7 | 3 << 0 | 14 << 3
	.byte 1 << 7 | 2 << 0 | 0 << 3
	.byte 0 << 7 | 1 << 0 | 14 << 3

	; lights
	.byte 0 << 7 | 2 << 0 | 12 << 3
	.byte 0 << 7 | 2 << 0 | 2 << 3
	.byte 1 << 7 | 3 << 0 | 0 << 3
	.byte 0 << 7 | 0 << 0 | 12 << 3
	.byte 1 << 7 | 3 << 0 | 0 << 3
	.byte 0 << 7 | 1 << 0 | 8 << 3

	.byte 1 << 7 | 5 << 0 | 0 << 3
	.byte 0 << 7 | 1 << 0 | 13 << 3

	; trunk lid
	.byte 0 << 7 | 4 << 0 | 10 << 3
	.byte 1 << 7 | 3 << 0 | 2 << 3
	.byte 0 << 7 | 1 << 0 | 9 << 3

	; trunk
	.byte 1 << 7 | 5 << 0 | 2 << 3
	.byte 0 << 7 | 1 << 0 | 10 << 3

	; glass
	.byte 0 << 7 | 5 << 0 | 7 << 3
	.byte 1 << 7 | 4 << 0 | 2 << 3
	.byte 0 << 7 | 1 << 0 | 5 << 3

	; roof
	.byte 1 << 7 | 7 << 0 | 4 << 3
	.byte 0 << 7 | 0 << 0 | 6 << 3
carlne	


row	equ *
start	lda #$0f
	jsr osgraph

	lda #208
	sta hposp1+1
	lda #$7a
	sta gractl
	sta sdmctl
	inc sizep2

	; set up gradient colors
cntr	*
	ldx #$02
	stx atachr
loopa1	txa
	lsr
	lsr
	lsr
opcoda1	ora #$30
	cpx random
	bcc skipa2
	adc #$01
skipa2	sta $5000-18,x	
	txa
	asl
	bcc skipa1
	sty opcoda1+1
skipa1	dec $0500,x
	dec $0600,x
	inx
	bne loopa1

	; draw the road
loopb1	lda #75
	sta oldrow
	sta oldcol
	inc colcrs
	lda #191
	sta rowcrs
	jsr osdraw
	sta oldcol			; A=$01 after "jsr osdraw"
	dec cntr
	bne loopb1

	; draw mountains
	lda #42
	sta gprior
	sta hposp1
loopc1	sta rowcrs
loopc2	bit random			;lda $80, inc loopc2+1
	dec rowcrs
	bvc skipc1
	inc rowcrs
	inc rowcrs
skipc1	lda #80
	sta oldrow
	jsr osdraw
	inc colcrs
	inc oldcol
	bne loopc2
	lda #64
	dec atachr
	bne loopc1

	; draw the car
	dec atachr
	jsr draw
	dec opcodx1+1
	lda #$38			; it is opcode of "sec"
	sta opcodx2
	inc opcodx3+1
	jsr draw

	; show gradient
loopd1	ldx vcount
	bne loopd1
loopd2	lda $5000,x
	sta wsync
	sta colbk
	lda colors-1,x			; set colors		;f3e3-1  fa3d-1
	sta color0-1,x	
	inx 
	bne loopd2
	bvc loopd1			; infinite loop