code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h

maxstr	EQU	20				; Ennyi lehet a leghosszabb string


start:
	mov ax,3				; K�perny�t�rl�shez m�dbe�ll�t�s k�dja
	int 10h					; Video BIOS h�v�s a t�rl�shez
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
; El�sz�r bek�rem a stringet.			;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	mov dx,offset bekero			; Sz�vegc�m
	mov ah,9				; String ki�r�s k�dja
	int 21h					; DOS h�v�sa ki�rat�sra
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
; Itt most lehet a n�ma beolvas�st h�vom	;
; �s ki�rom a le�t�ttet.		 	;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	mov cx,maxstr				; Legfeljebb ennyi hossz� lehet
	mov di,offset bekstr			; Ide pakolom le a beolvasottakat
bekcik:
	mov ah,8				; Visszahangos beolvas�s k�dja
	int 21h					; DOS h�v�sa beolvas�sra
	stosb					; Ki is teszem a t�rol�ba
	cmp al,0dh				; 'Enter' volt?
	jz enyvol				; Igen, v�ge a beolvas�snak
	mov ah,2				; Karakter ki�r�s k�dja
	mov dl,al				; Ez volt a karakter
	int 21h					; DOS h�v�sa ki�rat�sra
	loop bekcik				; Legfeljebb ennyiszer
	mov al,0dh				; Az 'Enter' k�dja
	stosb					; Kimegy egy befejez� Enter
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
; Bek�rem a vizsg�land� karaktert.		;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enyvol:
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
	mov cl,'0'				; Kezd� sz�ml�l�
	mov si,offset bekstr			; Itt vizsg�lok
vizsac:
	lodsb					; Beolvasom a kitett karaktert
	cmp al,0dh				; Az 'Enter' volt?
	jz ittave				; Igen, befejeztem
	cmp al,ah				; Azonosak?
	jnz vizsac				; Nem, akkor nem sz�molom
	inc cl					; N�velem a sz�ml�l�t
	jmp vizsac				; Vissza a n�vel�s ut�n (nem LOOP !!!!!!)
ittave:
	mov dx,offset nemfor			; Sz�vegc�m (ezt felt�telezem)
	mov ah,9				; String ki�r�s k�dja
	cmp cl,'0'				; Maradt a CL 0-ban?
	jz ninika				; Igen, azaz nem fordult el�
	mov dx,offset elofor			; Sz�vegc�m (Most m�r ez lesz)
	int 21h					; DOS h�v�sa ki�rat�sra
	mov ah,2				; Karakter ki�r�s k�dja
	mov dl,cl				; Az el�fordul�sok sz�ma (karakterben!)
ninika:
	int 21h					; DOS h�v�sa ki�rat�sra
	mov ah,4ch				; A kil�p�s k�dja
	int 21h					; A DOS h�v�sa kil�p�sre

bekero	db	'Add meg a vizsg�land� stringet! (Befejez�s ''Enter'')$'
bekerk	db	13, 10, 'Melyik karaktert vizsg�ljam? $'
elofor	db	13, 10, 'Az el�fordul�sok sz�ma: $'
nemfor	db	13, 10, 'Nem fordult el�!$'
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
; Egyel t�bbet foglalok a befejez� ENTER-hez.	;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
bekstr	db	maxstr + 1 dup (?)		; Kit�ltetlen mem�riahely k�sz�t�s

code	ends
	end	start

