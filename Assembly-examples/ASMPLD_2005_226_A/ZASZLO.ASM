code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h


start:
        cld                             ; String m�veletek el�refele menjenek
;
; K�perny� �zemm�d be�ll�t�s
;
        mov     ax,13h                  ; MCGA �zemm�d k�dja
        int     10h                     ; Az �tkapcsol�s megt�tele
;
; A h�rom sz�n kialak�t�sa
;
        mov     al,1                    ; Sz�nsz�m (1 = piros)
        mov     bl,63                   ; Maxim�lis piros
        mov     bh,0                    ; Nincs z�ld 
        mov     cl,0                    ; Nincs k�k
        call    szinde                  ; Sz�nbe�ll�t�s (piros)
        mov     al,3                    ; Sz�nsz�m (3 = z�ld)
        xchg    bl,bh                   ; Piros-z�ld csere
        call    szinde                  ; Sz�nbe�ll�t�s (z�ld)
        mov     al,2                    ; Sz�nsz�m (2 = feh�r)
        mov     bl,bh                   ; BL-be  (piros) 63 (ami a z�ld volt)
        mov     cl,bh                   ; CL-be  (k�k) 63 (ami a z�ld volt)
        call    szinde                  ; Sz�nbe�ll�t�s (feh�r)
;
; A k�perny�mem�ria felt�lt�se
;
        mov     ax,0a000h               ; A grafikus ter�let szegmense
        mov     es,ax                   ; ES <- MCGA ter�let szegmensc�me
;
; Pontok felt�lt�se
;
        mov     di,(40 * 320) + 70      ; Itt az els� pont helye
        mov     si,180                  ; Ennyi hossz� egy sz�ncs�k
        mov     bp,320 - 180            ; Ennyi a marad�k a k�vetkez�ig
        mov     cx,40                   ; Ennyi egy sz�n hossza
        mov     al,1                    ; Sz�nsz�m = 1, azaz piros
        call    szinki                  ; Megrajzolom a tetej�t
        mov     al,2                    ; Sz�nsz�m = 2, azaz feh�r
        call    szinki                  ; Megrajzolom a tetej�t
        mov     al,3                    ; Sz�nsz�m = 3, azaz z�ld
        call    szinki                  ; Megrajzolom a tetej�t
;
; Kiv�rok egy le�t�st
;
        mov     ah,8                    ; N�ma bek�r�s k�dja
        int     21h                     ; DOS h�v�s le�t�sv�r�sra
;
; �tdefini�lom az 1-es �s 3-as sz�nt
;
        mov     al,3                    ; Sz�nsz�m (3 = z�ld)
        mov     bl,63                   ; Maxim�lis piros
        mov     bh,0                    ; Nincs z�ld 
        mov     cl,0                    ; Nincs k�k
        call    szinde                  ; Sz�nbe�ll�t�s (piros) (most a 3-as)
        mov     al,1                    ; Sz�nsz�m (1 = piros)
        xchg    bl,bh                   ; Piros-z�ld csere
        call    szinde                  ; Sz�nbe�ll�t�s (z�ld) (most az 1-es)
;
; Kil�p�s el�tti le�t�sv�r�s
;
        mov     ah,8                    ; N�ma bek�r�s k�dja
        int     21h                     ; DOS h�v�s le�t�sv�r�sra
        mov     ax,3                    ; 80x25-�s sz�nes �zemm�d k�dja
        int     10h                     ; Az �tkapcsol�s megt�tele
	mov	ah,4ch
	int	21h
;
; Sz�ncsik kipakol�
;
; Input:  DI <- kezd� poz�ci�
;         SI <- a kit�tel hossza (pontban)
;         BP <- A k�vetkez� sor t�vols�ga (pontban)
;         CX <- Cs�ksz�less�g
;
szinki:
        push    cx                      ; Ennyi egy sz�n hossza, de kell m�g
szinst:
        push    cx                      ; Elrontom
        mov     cx,si                   ; Egy cs�k hossza
        rep     stosb                   ; Kitettem egy sort
        add     di,bp                   ; R�t�rek a k�vetkez�re
        pop     cx                      ; Vissza a sz�nsz�less�g sz�ml�l�
        loop    szinst                  ; Ciklusban a sz�n
        pop     cx                      ; Vissza az eredeti sor darabsz�m
        ret                             ; Kivitel k�sz
;
; Sz�ndefini�l�
;
; Input:  AL <- sz�nsz�m
;         BL <- R �sszetev� (piros)
;         BH <- G �sszetev� (z�ld)
;         CL <- B �sszetev� (k�k)
;
szinde:
        mov     dx,3c8h                 ; Palettasz�n t�rol� c�me
        out     dx,al                   ; Sz�nsz�m elk�ld�s
        inc     dx                      ; L�pek a sz�nt�rol�kra
        mov     al,bl                   ; R sz�n�sszetev� AL-be
        out     dx,al                   ; �sszetev� elk�ld�s
        mov     al,bh                   ; G sz�n�sszetev� AL-be
        out     dx,al                   ; �sszetev� elk�ld�s
        mov     al,cl                   ; B sz�n�sszetev� AL-be
        out     dx,al                   ; �sszetev� elk�ld�s
        ret                             ; K�sz

code	ends
	end	start








