code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h

                      
start:
        mov     ax,3                    ; K�perny�t�rl�shez m�dv�lt�s k�dja
        int     10h                     ; VIDEO BIOS-al k�perny�t�rl�s
        mov     dx,offset hogyhi        ; Sz�vegc�m
        mov     ah,9                    ; Stringki�rat�s k�dja
        int     21h                     ; DOS h�v�sa ki�rat�shoz
        mov     cx,5                    ; Pontosan ennyi karakterb�l �ll
        mov     bx,offset nevhel        ; A t�rol� els� c�me
karbeo:
        mov     ah,1                    ; Lehet visszhangos beolvas�s
        int     21h                     ; A DOS seg�ts�g�vel beolvasok
        mov     [bx],al                 ; Kiteszem a t�rol�ba
        inc     bx                      ; A k�vetkez� t�rol�c�mre l�pek
        loop    karbeo                  ; Ciklusban beolvasok
        mov     dx,offset sziasz        ; Sz�vegc�m
        mov     ah,9                    ; Stringki�rat�s k�dja
        int     21h                     ; DOS h�v�sa ki�rat�shoz
        mov     cx,5                    ; Pontosan ennyi karakterb�l �ll
        mov     bx,offset nevhel        ; A t�rol� els� c�me
        mov     ah,2                    ; Karakter ki�rat�s k�dja
karkii:
        mov     dl,[bx]                 ; Karakter ki�rat�sra
        inc     bx                      ; K�vetkez�re
        int     21h                     ; DOS ki�rat�sra
        loop    karkii                  ; Ciklusban ki�ratom
        mov     dx,offset sziave        ; Sz�vegc�m
        mov     ah,9                    ; Stringki�rat�s k�dja
        int     21h                     ; DOS h�v�sa ki�rat�shoz


	mov	ah,4ch
        int     21h
sziave  db      '!', 13,10,'$'
sziasz  db      13,10,'Szia $'

hogyhi  db      'Hogy h�vnak? $'

nevhel  db      5 dup(?)

code	ends
	end	start

