code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h


start:
        mov     ax,3                    ; K�perny�t�rl�shez m�dv�lt�s k�dja
        int     10h                     ; Video BIOS h�v�sa a t�rl�shez
        mov     dx,offset szoveg        ; Sz�vegc�m
        mov     ah,9                    ; String ki�r�s k�dja
        int     21h                     ; DOS h�v�sa ki�r�sra
        mov     dl,'a'                  ; Kezd� karakter
ciklus:
        mov     ah,8                    ; N�ma le�t�sv�r�s k�dja
        int     21h                     ; DOS h�v�sa le�t�sv�r�sra
        cmp     al,27                   ; �ppen az ESC?
        jz      abbaha                  ; Igen, akkor abba is hagyom
        mov     ah,2                    ; Karakter ki�rat�s k�dja
        int     21h                     ; DOS h�v�sa ki�r�sra
        inc     dl                      ; A k�vetkez�re
        cmp     dl,'z' + 1              ; �ppen a 'z'-t �rta ki?
        jnz     ciklus                  ; Nem, akkor a le�t�sv�r�si ciklusba
abbaha:
	mov	ah,4ch
	int	21h

szoveg  db      'ESC-v�ge!',13,10,'$'

code	ends
	end	start

