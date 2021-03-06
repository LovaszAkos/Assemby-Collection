code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h

start:
	mov ax,3				; K�perny�t�rl�shez m�dbe�ll�t�s k�dja
	int 10h					; Video BIOS h�v�s a t�rl�shez
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
; Megn�zem, hogy "�res"-a a parancssor.		;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	mov si,80h				; A sz�ml�l� c�me
	lodsb					; AL <- [80h], majd INC SI is
	mov bl,al				; �tm�solom (CX lesz a sz�ml�l�)
	mov bh,0				; BX <- darabsz�m
	or bx,bx				; BX nulla lett?
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
; Lehetne �gy is gondolkozni, hogy:		;
;	mov dx,offset hibast	; Sz�vegc�m	;
;	mov ah,9		; String ki�r�s	;
; �s a "ninika" c�mk�t az INT 21H el�ttre	;
; tessz�k ki, mert a DEC BX "egyb�l" negat�v	;
; BX-et eredm�nyez, �s kil�p. :-)		;
; Persze akkor az itt "ninika" cimke alatti	;
; �t sorra nincs sz�ks�g!			;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	jz ninika				; Igen, azaz nincsincs parancssor, hibaki�rat�sra ugrok
	mov ah,2				; Egyenk�nt �rom ki
kaciki:
	mov dl,[82h + bx]			; Indexelt beolvas�s a parancssorb�l (82H a karakterek c�me)
	int 21h					; DOS h�v�sa ki�rat�sra
	dec bx					; Visszafele l�pegetek
	jns kaciki				; Mehet m�g vissza a ciklusba (nem negat�v)
kilep:
	mov ah,4ch				; A kil�p�s k�dja
	int 21h					; A DOS h�v�sa kil�p�sre
ninika:
	mov dx,offset hibast			; Sz�vegc�m
	mov ah,9				; String ki�r�s k�dja
	int 21h					; DOS h�v�sa ki�rat�sra
	jmp kilep				; Ut�na ki is l�pek

hibast	db	'Nincs ford�tva ki�rand� parancsor! Kil�pek!$'

code	ends
	end	start

