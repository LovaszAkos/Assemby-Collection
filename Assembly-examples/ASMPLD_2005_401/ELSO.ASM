code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h


start:
        mov     ah,9                    ; Ki�rat�sk�r�s k�dja
        mov     dx,offset szoveg        ; A sz�veg c�me
        int     21h                     ; A DOS megh�v�sa ki�r�sk�r�ssel
	mov	ah,4ch
	int	21h

szoveg  db      'Szervusz Jancsi b�csi!', 10,13
        db      'J�l vagy?',10,13,'�n j�l vagyok!',10,13,'$'

code	ends
	end	start

