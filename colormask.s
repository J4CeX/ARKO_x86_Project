section .text
global colormask

colormask:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    ; [ebp + 8] = img (void *)
    ; [ebp + 12] = width (uint32_t)
    ; [ebp + 16] = height (uint32_t)
    ; [ebp + 20] = mask_img (void *)
    ; [ebp + 24] = mask_width (uint32_t)
    ; [ebp + 28] = mask_height (uint32_t)
    ; [ebp + 32] = x (uint32_t)
    ; [ebp + 36] = y (uint32_t)
    ; [ebp + 40] = color1 (uint32_t)
    ; [ebp + 44] = color2 (uint32_t)
    ; [ebp + 48] = color3 (uint32_t)

    mov ecx, [ebp + 8]      ; ecx = img
    mov edx, [ebp + 20]     ; edx = mask_img
    mov esi, [ebp + 32]     ; esi = x
    mov edi, 0              ; edi = x_mask

mask:
    mov eax, [ebp + 24]     ; eax = mask_width
    cmp [esp + 0], eax            ; if x_mask = mask_width then next_row
    jge next_row

    mov eax, [ebp + 12]     ; eax = width
    cmp esi, eax            ; if x = width then next_row
    jge next_row

    mov edi, [ebp + 36]     ; edi = current y

    mov eax, [ebp + 36]
    mov ebx, [ebp + 16]     ; ebx = height
    dec ebx                 ; ebx -= 1
    sub ebx, eax            ; mask_y = height - 1 - y

    mov eax, [ebp + 12]     ; width
    imul ebx, eax           ; mask_y * width
    add ebx, esi            ; + x
    imul ebx, 3             ; offset w bajtach

    mov edi, [esp + 4]

    mov eax, [ebp + 28]     ; eax = mask_height
    dec eax                 ; eax -= 1
    sub eax, edi            ; y_mask = mask_height - 1 - y
    imul eax, [ebp + 24]    ; y_mask * mask_width
    add eax, [esp + 0]      ; + x_mask
    imul eax, 3             ; offset w bajtach

    mov edi, eax


    mov eax,


    ; kopiowanie koloru z maski do obrazu
    mov ecx, [ebp + 8]      ; ecx = img
    mov edx, [ebp + 20]     ; edx = mask_img
    mov al, [edx + edi]     ; save B of pixel in mask_img to al
    mov [ecx + ebx], al     ; save B of pixel in mask as al
    mov al, [edx + edi + 1] ; save G of pixel in mask_img to al
    mov [ecx + ebx + 1], al ; save G of pixel in mask as al
    mov al, [edx + edi + 2] ; save R of pixel in mask_img to al
    mov [ecx + ebx + 2], al ; save R of pixel in mask as al

    inc esi     ; increment x
    mov eax, [esp + 0]
    inc eax             ; increment x_mask
    mov [esp + 0], eax
    jmp mask

next_row:
    mov esi, [ebp + 32]     ; set current x as given x
    mov eax, [ebp + 36]
    inc eax                 ; inc y
    mov [ebp + 36], eax

    mov ebx, [ebp + 16]     ; height
    cmp eax, ebx            ; if y = height then mask else exit
    jl mask
    jge exit

    mov ebx, [ebp + 28]     ; mask_height
    cmp eax, ebx            ; if y = mask_height then mask else exit
    jl mask
    jge exit

    jmp mask

exit:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
