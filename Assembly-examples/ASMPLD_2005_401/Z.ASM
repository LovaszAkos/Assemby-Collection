code    segment para    public  'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h

szeles  equ     180                     ; Ennyi a z�szl� sz�less�ge (pont)
vastag  equ     40                      ; Ennyi egy sz�n vastags�ga (sor)

kezdos  equ     (200 - (3 * vastag)) / 2; Ebben a sorban kezd
kezosz  equ     (320 - szeles) / 2      ; Ebben az oszlopban kezd

start:
;
; K�perny� �zemm�d be�ll�t�s
;
        mov     ax,13h                  ; MCGA �zemm�d k�dja
        int     10h                     ; Az �tkapcsol�s megt�tele
;
; String m�veletek ir�nya
;
        cld                             ; String m�veletek el�refele menjenek
;
; A k�perny�mem�ria felt�lt�se a z�szl�val
;
        mov     ax,0a000h               ; A grafikus ter�let szegmense
        mov     es,ax                   ; ES <- MCGA ter�let szegmensc�me
        mov     di,(kezdos * 320) + kezosz; Itt az els� pont helye
;
; AL-ben nulla van �ppen!!!, kihaszn�lom sz�nsz�mnak
;
megszt:
        mov     cl,vastag               ; Ennyi egy sz�n hossza
        inc     ax                      ; A k�vetkez� sz�n
szinst:
        push    cx                      ; Elrontom
        mov     cl,szeles               ; Egy cs�k hossza
        rep     stosb                   ; Kitettem egy sor
        add     di,320 - szeles         ; R�t�rek a k�vetkez�re
        pop     cx                      ; Vissza a sz�nsz�less�g sz�ml�l�
        loop    szinst                  ; Ciklusban a sz�n
        cmp     al,3                    ; M�r a h�rmassal rajzoltam?
        jnz     megszt                  ; M�g nem, kiteszem tov�bb
;
; A h�rom sz�n kialak�t�sa �s v�rakoz�s
;
        mov     bx, 0101111001001110b   ; A t�m�r�tett paletta �rt�kek

szinbe:
        mov     cl,3                    ; 3 palettasz�n be�ll�t�s lesz
        push    cx                      ; Egyben 80x25-�s �zemm�d k�d
szinde:
        mov     dx,3c8h                 ; Palettasz�n t�rol� c�me
        mov     al,cl                   ; CL mint a sz�nsz�m
        out     dx,al                   ; Sz�nsz�m elk�ld�s
        inc     dx                      ; L�pek a sz�nt�rol�kra
        push    cx                      ; Az �sszetev�sz�m rontja
        mov     cl,3                    ; RGB az 3 darab
        stc                             ; �gy lesz a kil�p�skor z�ld
rgbval:
        mov     al,0                    ; A sz�nsz�m 0
        rcl     bx,1                    ; Csupacseles RGB sz�mol�s
        jnc     numehe                  ; Ha CY = 0, akkor marad AL 0
        mov     al,63                   ; Egy�bk�nt 63
numehe:
        out     dx,al                   ; Sz�n�rt�k elk�ld�s
        loop    rgbval                  ; RGB, azaz mindh�rom sz�n
        pop     cx                      ; Vissza a sz�nsz�m�l�
        loop    szinde                  ; Tov�bbi sz�n be�ll�t�s
        mov     ah,8                    ; N�ma bek�r�s k�dja
        int     21h                     ; DOS h�v�s le�t�sv�r�sra
        pop     ax                      ; Egyben 80x25-�s �zemm�d k�d
        cmp     bh,0fdh                 ; M�r a m�sodszori �llapot?
        jne     szinbe                  ; Ha nem az, akkor m�g megy
        int     10h                     ; Az �tkapcsol�s megt�tele
        int     20h                     ; Kil�p�s

code	ends
	end	start
