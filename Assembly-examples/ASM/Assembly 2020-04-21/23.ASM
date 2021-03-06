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
	mov cl,al				; �tm�solom (CX lesz a sz�ml�l�)
	mov ch,0				; CX <- darabsz�m
	jcxz ninika				; Nincsincs parancssor, hibaki�rat�sra ugrok
	mov ah,2				; Egyenk�nt �rom ki
	mov bx,2				; Ennyivel "beljebb" kezdek
	inc si					; �tl�pek a parancssor els� karakter�re
kaciki:
	push cx					; Ne ronmoljon, ez�' mentem
	mov cx,bx				; Ennyivel menjen beljebb
	mov dl,' '				; Ezt teszem ki ciklusban
kezcik:
	int 21h					; DOS h�v�sa ki�rat�sra
	loop kezcik				; Mehet beljebb
	inc bx					; A k�vetkez� sorban egyel t�bbet teszek (majd) ki
	mov dl,[si]				; A parancssor karaktere
	int 21h					; DOS h�v�sa ki�rat�sra
	inc si					; L�pek a k�vetkez�re
	mov dl,13				; CR karakter
	int 21h					; DOS h�v�sa ki�rat�sra
	mov dl,10				; LF karakter
	int 21h					; DOS h�v�sa ki�rat�sra
	pop cx					; Vissza a sz�ml�l�
	loop kaciki				; Mehet m�g vissza a ciklusba
kilep:
	mov ah,4ch				; A kil�p�s k�dja
	int 21h					; A DOS h�v�sa kil�p�sre
ninika:
	mov dx,offset hibast			; Sz�vegc�m
	mov ah,9				; String ki�r�s k�dja
	int 21h					; DOS h�v�sa ki�rat�sra
	jmp kilep				; Ut�na ki is l�pek

hibast	db	'Nincs ki�rand� parancsor! Kil�pek!$'

code	ends
	end	start

