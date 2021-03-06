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
	mov dx,offset hibast			; Sz�vegc�m (a hib�t felt�telezem)
	mov ah,9				; String ki�r�s k�dja
	mov si,80h				; A sz�ml�l� c�me
	lodsb					; AL <- [80h], majd INC SI is
	mov cl,al				; �tm�solom (CX lesz a sz�ml�l�)
	mov ch,0				; CX <- darabsz�m
	jcxz ninika				; Nincs parancssor, hibaki�rat�sra ugrok
	inc si					; SI <- 82h azaz a parancssor c�me
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
; Bek�rem a vizsg�land� karaktert.		;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	mov dx,offset bekerk			; Sz�vegc�m
	mov ah,9				; String ki�r�s k�dja
	int 21h					; DOS h�v�sa ki�rat�sra
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
; Itt most lehet a visszhangos beolvas�st 	;
; h�vni.					;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	mov ah,1				; Visszahangos beolvas�s k�dja
	int 21h					; DOS h�v�sa beolvas�sra
	mov ah,al				; �tm�solom, mert a LODSB AL-be olvas majd be
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
; A sz�ml�l�ba egyb�l karakter ker�l.	 	;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	mov bl,'0'				; Kezd� sz�ml�l�
vizsac:
	lodsb					; Beolvasom a kitett karaktert
	cmp al,0dh				; Az 'Enter' volt?
	jz ittave				; Igen, befejeztem
	cmp al,ah				; Azonosak?
	jnz vizsac				; Nem, akkor nem sz�molom
	inc bl					; N�velem a sz�ml�l�t
	jmp vizsac				; Vissza a n�vel�s ut�n (nem LOOP !!!!!!)
ittave:
	mov dx,offset nemfor			; Sz�vegc�m (ezt felt�telezem)
	mov ah,9				; String ki�r�s k�dja
	cmp bl,'0'				; Maradt a CL 0-ban?
	jz ninika				; Igen, azaz nem fordult el�
	mov dx,offset elofor			; Sz�vegc�m (Most m�r ez lesz)
	int 21h					; DOS h�v�sa ki�rat�sra
	mov ah,2				; Karakter ki�r�s k�dja
	mov dl,bl				; Az el�fordul�sok sz�ma (karakterben!)
ninika:
	int 21h					; DOS h�v�sa ki�rat�sra
	mov ah,4ch				; A kil�p�s k�dja
	int 21h					; A DOS h�v�sa kil�p�sre

bekerk	db	'Melyik karaktert vizsg�ljam? $'
elofor	db	13, 10, 'Az el�fordul�sok sz�ma: $'
nemfor	db	13, 10, 'Nem fordult el�!$'
hibast	db	'Nincs elemezend� parancsor! Kil�pek!$'

code	ends
	end	start

