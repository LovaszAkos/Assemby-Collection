code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h


start:
        mov     ax,3                    ; 80x25-�s m�dbe�ll�t�s-k�r�s k�dja
        int     10h                     ; Vide�-kezel� megszak�t�s h�v�s
;
; Be�ll�tom a ciklussz�mnak megfelel�en a CX regisztert
;
        mov     cx,hossz                ; Ez a ciklussz�m
        mov     bx,offset vakszo + hossz - 1; A sz�veg utols� b�jtj�nak c�me
;
; Ez a ki�rat�s ciklusa
;
vakcik:
;
;El�sz�r a SPACE ki�rat�sa j�n
;
        push    cx                      ; Elromlik a ciklussz�ml�l�
        dec     cx                      ; Egyel kevesebbet
        jcxz    nemspc                  ; Ha �gy a CX 0, nem tesz sz�k�z�ket
        mov     ah,2                    ; Karakterki�r�si k�d
        mov     dl,' '                  ; A sz�k�z, amit ki�runk
spkirc:
        int     21h                     ; DOS h�v�sa karakterki�r�sra
        loop    spkirc                  ; Sz�k�z cikluis
nemspc:
        pop     cx                      ; Eredeti sz�ml�l� vissza
        mov     ah,9                    ; A ki�rat�sk�r�s k�dja
        mov     dx,bx                   ; A k�ratand� sz�vegr�sz c�me
        int     21h                     ; A DOS megh�v�sa annyiszor
        mov     ah,8                    ; N�ma bek�r�s k�dja
        int     21h                     ; A DOS megh�v�sa v�r�sra
        dec     bx                      ; Egyel el�tte folytatom
        loop    vakcik                  ; A k�vetkez� r�sz ki�r�sa j�nne
;
; Kil�p�nk a programunkb�l
;
kilep:
        mov     ah,4ch                  ; A kil�p�sk�r�s k�dja
        int     21h                     ; A DOS h�v�sa kil�p�sre
                                        ; Innen m�r nem t�r�nk vissza!!!!

vakszo  db      'VAK�CI�!'              ; Ezt kell maj m�solgatni
hossz   equ     $ - vakszo              ; A HOSSZ sz�mb�lum �rt�kad�sa

        db      10,13,'$'               ; LF, CR, majd v�ge jel

code	ends
	end	start

