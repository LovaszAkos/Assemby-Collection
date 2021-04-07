code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h


start:
        mov     ax,3                    ; K�perny�t�rl�shez m�dv�lt�s
        int     10h                     ; M�dv�lt�s a VIDEO BIOS seg�ts�g�vel
        mov     dx,offset mitcsi        ; Sz�vegc�m
        mov     ah,9                    ; String ki�rat�s k�dja
        int     21h                     ; A DOS h�v�sa ki�rat�sra
        mov     cx,10                   ; Ennyi a ciklussz�m
ciklus:
        mov     ah,8                    ; N�ma le�t�svr�s k�dja
        int     21h                     ; DOS-sal beolvas�s
        cmp     al,27                   ; Az ESC az?
        jz      kilep                   ; Igen, akkor abba-fejezem
        cmp     al,'Q'                  ; A 'Q' az?
        jz      kilep                   ; Igen, akkor abba-fejezem
        cmp     al,'q'                  ; A 'q' az?
        jz      kilep                   ; Igen, akkor abba-fejezem
        mov     ah,9                    ; String ki�rat�s k�dja
        mov     dx,offset egyszo        ; Sz�vegc�m
        cmp     al,'1'                  ; Az '1' az?
        jz      simkir                  ; Igen, akkor valamit tennem kell
        mov     dx,offset ketszo        ; Sz�vegc�m
        cmp     al,'2'                  ; A '2' az?
        jz      simkir                  ; Igen, akkor valamit tennem kell
        mov     dx,offset harszo        ; Sz�vegc�m
        cmp     al,'3'                  ; A '3' az?
        jz      simkir                  ; Igen, akkor valamit tennem kell
        mov     dl,al                   ; Karakter a ki�rat�s hely�re
        mov     ah,2                    ; Karakter ki�rat�s k�dja
simkir:
        int     21h                     ; Ki�rat�s a DOS-al
        loop    ciklus                  ; Vissza ciklusban
kilep:
	mov	ah,4ch
	int	21h

mitcsi  db      '�ss billenty�ket. ESC, Q vagy q eset�n kil�p.', 13, 10, '$'
egyszo  db      'egy$'
ketszo  db      'kett�$'
harszo  db      'h�rom$'

code	ends
	end	start

