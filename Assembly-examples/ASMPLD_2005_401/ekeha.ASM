code    segment para    public  'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h


start:
        mov     ax,3                    ; T�pus k�dja
        int     10h                     ; M�d be�ll�t�ssal k�perny� t�rl�s
        mov     ah,9                    ; Sz�vegki�rat�s k�dja
        mov     dx,offset szoveg        ; Sz�vegc�m DX-be
        int     21h                     ; DOS h�v�sa ki�rat�sra
        mov     cx,10                   ; Maximum ennyit
ciklus:
        mov     ah,8                    ; N�ma bek�r�s k�dja
        int     21h                     ; DOS h�v�s beolvas�sra
        cmp     al,27                   ; ESC volt?
        jz      kilepes                 ; Igen, befejezem
        cmp     al,'q'                  ; A le�t�s 'q' volt?
        jz      kilepes                 ; Igen, befejezem
        cmp     al,'Q'                  ; A le�t�s 'Q' volt?
        jz      kilepes                 ; Igen, befejezem
        mov     ah,9                    ; Sz�vegki�rat�s k�dja
        mov     dx,offset egyszo        ; Sz�vegc�m
        cmp     al,'1'                  ; �ppen az 1-es?
        jz      ponteg                  ; Most �ppen az
        mov     dx,offset ketszo        ; Sz�vegc�m
        cmp     al,'2'                  ; �ppen a 2-es?
        jz      ponteg                  ; Most �ppen az
        mov     dx,offset harszo        ; Sz�vegc�m
        cmp     al,'3'                  ; �ppen a 3-as?
        jz      ponteg                  ; Most �ppen az
        mov     dl,al                   ; Most csak a m�solatot �rom ki
        mov     ah,2                    ; Egy karakter kit�tele
ponteg:
        int     21h                     ; DOS m�velet k�r�s
        loop    ciklus                  ; Ha maradt m�g, visszal�pek
kilepes:
	mov	ah,4ch
	int	21h


szoveg  db      '�ss�n le billenty�ket!',10,13,'$'
egyszo  db      'EGY$'
ketszo  db      'KETT�$'
harszo  db      'H�ROM$'

code	ends
	end	start

