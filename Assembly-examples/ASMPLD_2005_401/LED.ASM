code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h


start:
        mov     dx,offset szoveg        ; Sz�vegc�m, amit ki kell �rni
        mov     ah,9                    ; Ki�rat�s k�dja
        int     21h                     ; DOS h�v�s ki�rat�sra
ciklus:
        mov     bl,010b                 ; Ezt teszem ki
        call    ledkit                  ; A LED-ek kit�tele
        call    idohuz                  ; Id�h�z�s
        mov     bl,000b                 ; Ezt teszem ki
        call    ledkit                  ; A LED-ek kit�tele
        call    idohuz                  ; Id�h�z�s
        mov     ah,1                    ; Csak k�rdez�s k�dja
        int     16h                     ; Klavi BIOS megsz�l�t�s
        jz      ciklus                  ; Nincs le�tve
        mov     ah,0                    ; Beolvas�s k�dja
        int     16h                     ; Klavi BIOS megsz�l�t�s
        cmp     al,27                   ; ESC van lenyomva?
        jnz     ciklus                  ; Nem, nem az volt le�tve
	mov	ah,4ch
	int	21h

ledkit:
        mov     al,0edh                 ; LED megsz�l�t� �rt�k
        out     60h,al                  ; 8042-nek elk�ld�s
        xor     cx,cx                   ; Null�zom CX-et
ledcik:
        nop                             ; Csak id�h�z�s
        nop                             ; Csak id�h�z�s
        loop    ledcik                  ; Kiv�rok
        mov     al,bl                   ; LED helyzet
        out     60h,al                  ; 8042-nek elk�ld�s
        ret                             ; K�sz a LED kipakol�s

idohuz:
        mov     cx,400                  ; Ennyiszer 65536 ciklus
kulcik:
        push    cx                      ; Elmentem, mert mingy�' romlik
        xor     cx,cx                   ; CX <- 0
belido:
        nop                             ; Csak id�h�z�s
        nop                             ; Csak id�h�z�s
        loop    belido                  ; Kiv�rok
        pop     cx                      ; Sz�ml�l� vissza
        loop    kulcik
        ret                             ; Id�h�z�s k�sz


szoveg  db      'Kil�p�s ESC-re.', 10, 13, '$'

code	ends
	end	start

