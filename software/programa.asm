
        .ORG 0000h

        LD SP, 0FFFFh        

        LD A, 90h            
        OUT (43h), A

        XOR A                
        LD (0F828h), A       ; caracteres guardados = 0
        LD (0F829h), A       ; letras contadas = 0

        LD HL, 0F800h        ; HL apunta al inicio del buffer

        LD DE, MENSAJE1
        CALL IMPRIME

CAPTURA:
        IN A, (40h)          ; lee un caracter del teclado

        CP 0Dh               ; Enter termina la captura
        JP Z, RESULTADO

        CP 20h               ; el espacio es valido pero no es letra
        JP Z, GUARDA

        CP 41h               ; menor que 'A'
        JP C, ERROR
        CP 5Bh               ; de 'A' a 'Z'
        JP C, LETRA
        CP 61h               ; entre 'Z' y 'a' hay simbolos
        JP C, ERROR
        CP 7Bh               ; de 'a' a 'z'
        JP C, LETRA
        JP ERROR             ; cualquier otro caracter

LETRA:
        PUSH AF              ; guarda el caracter
        LD A, (0F829h)
        INC A
        LD (0F829h), A       ; una letra mas
        POP AF               ; recupera el caracter

GUARDA:
        LD (HL), A           ; guarda el caracter en el buffer
        INC HL
        OUT (41h), A         ; lo muestra en pantalla

        LD A, (0F828h)
        INC A
        LD (0F828h), A       ; un caracter mas guardado
        CP 40                ; si el buffer se lleno, termina
        JP Z, RESULTADO
        JP CAPTURA

ERROR:
        LD DE, MENSAJE2
        CALL IMPRIME
        JP CAPTURA           ; vuelve a pedir un caracter

RESULTADO:
        LD DE, MENSAJE3
        CALL IMPRIME

        LD A, (0F828h)
        LD B, A              
        LD DE, 0F800h        ; DE recorre el buffer

MUESTRA:
        LD A, B
        OR A
        JP Z, CUENTA         ; ya se imprimieron todos
        LD A, (DE)
        OUT (41h), A
        INC DE
        DEC B
        JP MUESTRA

CUENTA:
        LD DE, MENSAJE4
        CALL IMPRIME

        LD A, (0F829h)       
        LD B, 0              

DECENAS:
        CP 10
        JP C, DIGITOS        
        SUB 10
        INC B
        JP DECENAS

DIGITOS:
        LD C, A              
        LD A, B
        OR A
        JP Z, UNIDADES       
        ADD A, 30h           
        OUT (41h), A

UNIDADES:
        LD A, C
        ADD A, 30h
        OUT (41h), A

FIN:
        HALT
        JP FIN

IMPRIME:
        LD A, (DE)
        OR A
        RET Z
        OUT (41h), A
        INC DE
        JP IMPRIME


MENSAJE1:
        .TEXT "Escribe tu nombre y apellidos: "
        .DB 0

MENSAJE2:
        .DB 0Dh, 0Ah
        .TEXT "ERROR: solo se permiten letras y espacios"
        .DB 0Dh, 0Ah, 0

MENSAJE3:
        .DB 0Dh, 0Ah
        .TEXT "TEXTO CAPTURADO: "
        .DB 0

MENSAJE4:
        .DB 0Dh, 0Ah
        .TEXT "NUMERO DE LETRAS: "
        .DB 0

        .END