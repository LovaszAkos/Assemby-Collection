code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	org	100h

start:
	mov	ah,4ch			; A kil�p�s k�dja
	int	21h			; A DOS h�v�sa kil�p�sre

code	ends
	end	start

