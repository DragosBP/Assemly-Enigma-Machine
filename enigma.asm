%include "../include/io.mac"

;; defining constants, you can use these as immediate values in your code
LETTERS_COUNT EQU 26

section .data
    extern len_plain
    start DD 0
    enigma_call DB 0


section .text
    global rotate_x_positions
    global enigma

; void rotate_x_positions(int x, int rotor, char config[10][26], int forward);
rotate_x_positions:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; x
    mov ebx, [ebp + 12] ; rotor
    mov ecx, [ebp + 16] ; config (address of first element in matrix)
    mov edx, [ebp + 20] ; forward
    ;; DO NOT MODIFY
    ;; TODO: Implement rotate_x_positions
    ;; FREESTYLE STARTS HERE

    ; Calcularea pozitia liniei de start a rotorului EBX
    push edx
    push eax
    mov al, bl
    mov bl, 52
    mul bl
    xor edx, edx
    mov dx, ax
    pop eax
    add ecx, edx ; Punerea in ECX pozitia de start a liniei corecte
    mov dword [start], ecx ; Salvarea in START a pozitiei de start a liniei corecte


    ; Verificarea daca trebuie rotit in stanga sau in dreapta
    pop edx
    cmp edx, 0
    je left
    mov eax, 26
    sub eax, [ebp + 8] ; Rotirea in dreapta X ori e rotirea in stanga de 26-X ori
    mov [ebp + 8], eax

    left:
    cmp eax, 0
    je done
    ; Retinerea pe stiva a literele care trebuie mutate la finalul liniei
    copy_left:
        xor ebx, ebx
        mov bl, byte [ecx]
        push ebx
        add ecx, 26
        mov bl, byte [ecx]
        push ebx
        sub ecx, 25
        sub eax, 1
        cmp eax, 0
    jg copy_left

    ; Calcularea adreselor pentru tragere
    mov edx, [ebp + 8]
    mov ebx, edx
    mov eax, 26
    sub eax, edx
    mov ecx, dword [start] ; ECX - adresa unde trebuie sa fie trase
    mov edx, ecx
    add edx, ebx ; EDX - adresa unde este ce trebuie sa fie ttras

    ; Mutarea literelor
    drag_left:
        xor ebx, ebx
        mov bl, byte [edx]
        mov byte [ecx], bl
        add ecx, 26
        add edx, 26
        mov bl, byte [edx]
        mov byte [ecx], bl
        sub ecx, 25
        sub edx, 25
        sub eax, 1
        cmp eax, 0
    jg drag_left
    
    ; Calcularea adresei unde trebuie scrise literele salvate in stiva
    mov ecx, [start]
    add ecx, 26
    mov eax, [ebp + 8]

    ; Scrierea literelor din stiva la finalul liniei
    write_left:
        xor ebx, ebx
        add ecx, 25
        pop ebx
        mov byte [ecx], bl
        sub ecx, 26
        pop ebx
        mov byte [ecx], bl
        sub eax, 1
        cmp eax, 0
    jg write_left

    done:

    really_done:
    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY

; void enigma(char *plain, char key[3], char notches[3], char config[10][26], char *enc);
enigma:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; plain (address of first element in string)
    mov ebx, [ebp + 12] ; key
    mov ecx, [ebp + 16] ; notches
    mov edx, [ebp + 20] ; config (address of first element in matrix)
    mov edi, [ebp + 24] ; enc
    ;; DO NOT MODIFY
    ;; TODO: Implement enigma
    ;; FREESTYLE STARTS HERE

    codify:
        push eax
        xor eax, eax
        ; Verifficare cate rotoare trebuie rotite cu cheile lor dupa notch-uri
        mov byte [enigma_call], 2 ; ENIGMA_CALL - tine minte pentru care rotor a fost chemata rotirea sa
        ; stie dupa unde sa se intoarca (putea fi facut cu call & ret in loc dar am realizat prea tarziu)
        
        ; Daca primul rotor trebuie rotit
        mov al, byte [ebx + 1]
        cmp al, byte [ecx + 1]
        jne go_second ; Daca notch[1] != key[1], sari peste rotatia primului rotor
        mov byte [enigma_call], 0 ; Zi unde sa se intoarca dupa rotatia primului rotor
        ; Pregateste EDX - adresa la inceputul liniei si ECX - folosit ca auxiliar in interschimbarea literelor
        push ecx
        push edx
        jmp rotate_once
        after_first: ; Dupa rotirea primului rotor
        ; Incrementeaza prima litera la key
        xor ecx, ecx
        add byte [ebx], 1
        mov cl, byte [ebx]
        cmp ecx, 91
        jne first_not_big ; Verifica daca a devenit caracterul din cheie peste 'Z'
        mov byte [ebx], 65 ; Si daca da, scrie 'A'
        first_not_big:
        pop edx
        pop ecx
        ; Roteste si al doilea rotor ca sa nu roteasca la infinit primul rotor dupa
        jmp rotate_second

        go_second:
        ; Daca al doilea rotor trebuie rotit
        mov al, byte [ebx + 2]
        cmp al, byte [ecx + 2]
        jne go_third ; Daca notch[2] != key[2], sari peste rotatia primului rotor
        rotate_second:
        mov byte [enigma_call], 1 ; Zi unde sa se intoarca dupa rotatia al doileaului rotor
        push ecx
        push edx
        add edx, 52 ; Pune adresa in EDX sa pointeze catre al doilea rotor
        jmp rotate_once
        after_second:
        ; Incrementeaza a doua litera la key
        xor ecx, ecx
        add byte [ebx + 1], 1
        mov cl, byte [ebx + 1]
        cmp ecx, 91
        jne second_not_big ; Verifica daca a devenit caracterul din cheie peste 'Z'
        mov byte [ebx + 1], 65 ; Si daca da, scrie 'A'
        second_not_big:
        pop edx
        pop ecx

        go_third:
        ; Rotatia a treileaului rotor este mereu facuta
        mov byte [enigma_call], 2 ; Zi unde sa se intoarca dupa rotatia al treileaului rotor
        push ecx
        push edx
        add edx, 104 ; Pune adresa in EDX sa pointeze catre al treilea rotor
        jmp rotate_once
        after_third:
        ; Incrementeaza a treia litera la key
        xor ecx, ecx
        add byte [ebx + 2], 1
        mov cl, byte [ebx + 2]
        cmp ecx, 91
        jne third_not_big ; Verifica daca a devenit caracterul din cheie peste 'Z'
        mov byte [ebx + 2], 65 ; Si daca da, scrie 'A'
        third_not_big:
        pop edx
        pop ecx
        pop eax
        
        ; Doar aici se incepe implementarea encriptiei
        ; Stiu ca pot sa iau cheia si sa o adun cu litera mea ca sa obtin noua coloana
        ; dar cand scriu mesajul asta, deja e tarziu si codul merge

        push ecx ; ECX - folosit sa retin litera la care am ajuns intr-un moment 
        xor ecx, ecx
        ; Prima partea a encriptiei, pana la reflector
        mov cl, byte [eax] ; CL - litera curenta
        ; 1) Gaseste CL pe linia 9 (PlugBoard)
        mov esi, edx ; ESI - folosit sa retin linia cu care lucrez
        add esi, 234
        sub esi, 1
        el9: ; el9 = encrypt line 9
            add esi, 1
            cmp byte [esi], cl
        jne el9
        ; 2) Schimba pe ESI ca sa pointeze catre linia 5 (Al treilea Rotor) si extrage litera de acolo, dupa coloana
        sub esi, 104
        mov cl, byte [esi]
        ; 3) Gaseste CL pe linia 4
        mov esi, edx
        add esi, 104
        sub esi, 1
        el4: ; el4 = encrypt line 4
            add esi, 1
            cmp byte [esi], cl
        jne el4
        ; 4) Schimba pe ESI ca sa pointeze catre linia 3 (Al doilea Rotor) si extrage litera de acolo
        sub esi, 26
        mov cl, byte [esi]
        ; 5) Gaseste CL pe linia 2
        mov esi, edx
        add esi, 52
        sub esi, 1
        el2: ; el2 = encrypt line 2
            add esi, 1
            cmp byte [esi], cl
        jne el2
        ; 6) Schimba pe ESI ca sa pointeze catre linia 1 (Primul Rotor) si extrage litera de acolo
        sub esi, 26
        mov cl, byte [esi]
        ; 7) Gaseste CL pe linia 0
        mov esi, edx
        sub esi, 1
        el0: ; el0 = encrypt line 0
            add esi, 1
            cmp byte [esi], cl
        jne el0
        ; 8) Schimba pe ESI ca sa pointeze catre linia 6 (Reflector) si extrage litera de acolo
        add esi, 156
        mov cl, byte [esi]
        ; 9) Gaseste CL pe linia 7
        mov esi, edx
        add esi, 182
        sub esi, 1
        el7: ; el7 = encrypt line 7
            add esi, 1
            cmp byte [esi], cl
        jne el7

        ; Parrtea a doua a encriptarii, dupa ce am ajuns la reflector
        ; 10) Schimba pe ESI ca sa pointeze catre linia 0 (Primul Rotor) si extrage litera de acolo
        sub esi, 182
        mov cl, byte [esi]
        ; 11) Gaseste CL pe linia 1
        mov esi, edx
        add esi, 26
        sub esi, 1
        el1: ; el1 = encrypt line 1
            add esi, 1
            cmp byte [esi], cl
        jne el1
        ; 12) Schimba pe ESI ca sa pointeze catre linia 2 (Al doilea Rotor) si extrage litera de acolo
        add esi, 26
        mov cl, byte [esi]
        ; 13) Gaseste CL pe linia 3
        mov esi, edx
        add esi, 78
        sub esi, 1
        el3: ; el3 = encrypt line 3
            add esi, 1
            cmp byte [esi], cl
        jne el3
        ; 14) Schimba pe ESI ca sa pointeze catre linia 4 (Al treilea Rotor) si extrage litera de acolo
        add esi, 26
        mov cl, byte [esi]
        ; 15) Gaseste CL pe linia 5
        mov esi, edx
        add esi, 130
        sub esi, 1
        el5: ; el5 = encrypt line 5
            add esi, 1
            cmp byte [esi], cl
        jne el5
        ; 16) Schimba pe ESI ca sa pointeze catre linia 9 (PlugBoard) si extrage litera de acolo
        add esi, 104
        mov cl, byte [esi]
        ; In CL se afla litera encriptata
        mov byte [edi], cl ; Pune litera encriptata in sirul final
        pop ecx ; Ia inapoi notches in ECX pentru urmatoarea rotatie
        add edi, 1
        add eax, 1
        sub dword [len_plain], 1
    cmp dword [len_plain], 0
    jne codify
    jmp done_enigma

    ; Roteste o data la stanga
    rotate_once:
        xor ecx, ecx
        mov cl, byte [edx]
        push ecx ; Adauga prima litera de pe prima linie in stiva
        add edx, 26 ; Se muta pe a doua linie
        mov cl, byte [edx];
        push ecx ; Adauga prima litera de pe a doua linie in stiva
        sub edx, 26 ; Se muta inapoi pe prima linie
        mov esi, 24
        rr_once:
            ; Muta a doua litera din prima linie pe prima pozitie
            mov cl, byte [edx + 1]
            mov byte [edx], cl
            ; Muta a doua litera din a doua linie pe prima pozitie
            add edx, 26
            mov cl, byte [edx + 1]
            mov byte [edx], cl
            sub edx, 25 ; Inapoi pe prima linie, dar urmatoarea litera
            sub esi, 1
            cmp esi, 0
        jge rr_once
        xor ecx, ecx
        ; Extrage ultima litera de pe a doua linie
        pop ecx
        add edx, 26
        mov byte [edx], cl
        ; Extrage ultima litera de pe prima linie
        pop ecx
        sub edx, 26
        mov byte [edx], cl
    cmp byte [enigma_call], 0
    je after_first
    cmp byte [enigma_call], 1
    je after_second
    jmp after_third

    done_enigma:
    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY