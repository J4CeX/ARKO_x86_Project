section .text
global colormask

colormask:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    sub esp, 16

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

    mov esi, [ebp + 32]     ; esi = current x

    mov dword [esp + 0], 0  ; x_mask
    mov dword [esp + 4], 0  ; y_mask
    mov dword [esp + 8], 0
    mov dword [esp + 12], 0

mask:
    mov eax, [ebp + 24]     ; eax = mask_width
    cmp [esp + 0], eax            ; if x_mask = mask_width then next_row
    jge next_row

    mov eax, [ebp + 12]     ; eax = width
    cmp esi, eax            ; if x = width then next_row
    jge next_row

    mov edi, [ebp + 36]     ; edi = current y

    mov eax, [ebp + 16]     ; eax = height
    dec eax                 ; eax -= 1
    sub eax, edi            ; y = height - 1 - y
    imul eax, [ebp + 12]    ; y * width
    add eax, esi            ; + x
    imul eax, 3             ; offset w bajtach
    mov [esp + 8], eax

    mov edi, [esp + 4]

    mov eax, [ebp + 28]     ; eax = mask_height
    dec eax                 ; eax -= 1
    sub eax, edi            ; y_mask = mask_height - 1 - y
    imul eax, [ebp + 24]    ; y_mask * mask_width
    add eax, [esp + 0]      ; + x_mask
    imul eax, 3             ; offset w bajtach
    mov [esp + 12], eax


    ; === RED ===
    mov ebx, [ebp + 20]     ; ebx = mask_img
    mov edi, [esp + 12]
    movzx eax, byte [ebx + edi + 2]
    movzx edx, byte [ebx + edi + 1]
    movzx ecx, byte [ebx + edi]

    mov ebx, [ebp + 40]
    shr ebx, 16
    and ebx, 0xFF
    imul eax, ebx

    mov ebx, [ebp + 44]
    shr ebx, 16
    and ebx, 0xFF
    imul edx, ebx

    mov ebx, [ebp + 48]
    shr ebx, 16
    and ebx, 0xFF
    imul ecx, ebx

    add eax, edx
    add eax, ecx
    cmp eax, 255
    jle skip_clamp_r
    mov eax, 255
    skip_clamp_r:
    mov ebx, [esp + 8]
    mov ecx, [ebp + 8]
    mov [ecx + ebx + 2], al


    ; === GREEN ===
    mov ebx, [ebp + 20]     ; ebx = mask_img
    mov edi, [esp + 12]
    movzx eax, byte [ebx + edi + 2]
    movzx edx, byte [ebx + edi + 1]
    movzx ecx, byte [ebx + edi]

    mov ebx, [ebp + 40]
    shr ebx, 8
    and ebx, 0xFF
    imul eax, ebx

    mov ebx, [ebp + 44]
    shr ebx, 8
    and ebx, 0xFF
    imul edx, ebx

    mov ebx, [ebp + 48]
    shr ebx, 8
    and ebx, 0xFF
    imul ecx, ebx

    add eax, edx
    add eax, ecx
    cmp eax, 255
    jle skip_clamp_g
    mov eax, 255
    skip_clamp_g:
    mov ebx, [esp + 8]
    mov ecx, [ebp + 8]
    mov [ecx + ebx + 1], al


    ; === BLUE ===
    mov ebx, [ebp + 20]     ; ebx = mask_img
    mov edi, [esp + 12]
    movzx eax, byte [ebx + edi + 2]
    movzx edx, byte [ebx + edi + 1]
    movzx ecx, byte [ebx + edi]

    mov ebx, [ebp + 40]
    and ebx, 0xFF
    imul eax, ebx

    mov ebx, [ebp + 44]
    and ebx, 0xFF
    imul edx, ebx

    mov ebx, [ebp + 48]
    and ebx, 0xFF
    imul ecx, ebx

    add eax, edx
    add eax, ecx
    cmp eax, 255
    jle skip_clamp_b
    mov eax, 255
    skip_clamp_b:
    mov ebx, [esp + 8]
    mov ecx, [ebp + 8]
    mov [ecx + ebx], al


    inc esi     ; increment x
    mov eax, [esp + 0]
    inc eax             ; increment x_mask
    mov [esp + 0], eax
    jmp mask



next_row:
    mov esi, [ebp + 32]     ; set current x as given x
    mov dword [esp + 0], 0  ; set current x_mask as given x_mask

    mov eax, [ebp + 36]
    inc eax                 ; inc y
    mov [ebp + 36], eax

    mov eax, [esp + 4]
    inc eax                 ; inc y_mask
    mov [esp + 4], eax

    mov ebx, [ebp + 16]     ; height
    cmp [ebp + 36], ebx            ; if y = height then mask else exit
    jge exit

    mov ebx, [ebp + 28]     ; mask_height
    cmp [esp + 4], ebx            ; if y_mask = mask_height then mask else exit
    jge exit

    jmp mask

exit:
    add esp, 16
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
