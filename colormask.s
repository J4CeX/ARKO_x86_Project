section .text
global colormask

colormask:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    sub esp, 4              ; miejsce na lokalne y

    mov ecx, [ebp + 8]      ; ecx = img
    mov edx, [ebp + 20]     ; edx = mask_img
    mov esi, [ebp + 32]     ; esi = x
    mov eax, [ebp + 36]     ; eax = y
    mov [esp], eax          ; zapisujemy y na stosie

mask:
    mov ebx, [ebp + 12]     ; width
    cmp esi, ebx
    je next_row

    mov eax, [esp]          ; y
    mov ebx, [ebp + 28]     ; mask_height
    dec ebx
    sub ebx, eax            ; mask_y = mask_height - 1 - y

    mov eax, [ebp + 24]     ; mask_width
    imul ebx, eax           ; mask_y * mask_width
    add ebx, esi            ; + x
    imul ebx, 3             ; offset w bajtach

    ; kopiuj kolor z maski do obrazu
    mov al, [edx + ebx]
    mov [ecx + ebx], al
    mov al, [edx + ebx + 1]
    mov [ecx + ebx + 1], al
    mov al, [edx + ebx + 2]
    mov [ecx + ebx + 2], al

    inc esi
    jmp mask

next_row:
    mov esi, 0
    mov eax, [esp]
    inc eax
    mov [esp], eax

    mov ebx, [ebp + 16]     ; height
    cmp eax, ebx
    jl mask

exit:
    add esp, 4
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
