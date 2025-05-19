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
    mov dword [esp + 8], 0  ; img_offset
    mov dword [esp + 12], 0 ; mask_offset

mask:
    mov eax, [ebp + 24]     ; eax = mask_width
    cmp [esp + 0], eax      ; if x_mask = mask_width then next_row
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


    ; --- RED ---
    mov ebx, [ebp + 20]     ; ebx = mask_img
    mov edi, [esp + 12]     ; edi = mask_offset
    movzx eax, byte [ebx + edi + 2] ; save mask RR to eax
    movzx edx, byte [ebx + edi + 1] ; save mask GG to edx
    movzx ecx, byte [ebx + edi]     ; save mask BB to ecx

    mov ebx, [ebp + 40] ; ebx = color1
    shr ebx, 16         ; select RR
    and ebx, 0xFF
    imul eax, ebx       ; eax = red(color1) * red(mask_img)

    mov ebx, [ebp + 44] ; ebx = color2
    shr ebx, 16         ; select RR
    and ebx, 0xFF
    imul edx, ebx       ; edx = red(color2) * green(mask_img)

    mov ebx, [ebp + 48] ; ebx = color3
    shr ebx, 16         ; select RR
    and ebx, 0xFF
    imul ecx, ebx       ; ecx = red(color3) * blue(mask_img)

    add eax, edx        ; eax = eax + edx = red(color1) * red(mask_img) + red(color2) * green(mask_img)
    add eax, ecx        ; eax = eax + ecx = red(color1) * red(mask_img) + red(color2) * green(mask_img) + ecx = red(color3) * blue(mask_img)
    and eax, 0xFF       ; cut result to last 8bit
    mov ebx, [esp + 8]  ; ebx = img_offset
    mov ecx, [ebp + 8]  ; ecx = img
    mov [ecx + ebx + 2], al ; red(img) = ...

    ; --- GREEN ---
    mov ebx, [ebp + 20]     ; ebx = mask_img
    mov edi, [esp + 12]     ; edi = mask_offset
    movzx eax, byte [ebx + edi + 2] ; save mask RR to eax
    movzx edx, byte [ebx + edi + 1] ; save mask GG to edx
    movzx ecx, byte [ebx + edi]     ; save mask BB to ecx

    mov ebx, [ebp + 40] ; ebx = color1
    shr ebx, 8          ; select GG
    and ebx, 0xFF
    imul eax, ebx       ; eax = green(color1) * red(mask_img)

    mov ebx, [ebp + 44] ; ebx = color2
    shr ebx, 8          ; select GG
    and ebx, 0xFF
    imul edx, ebx       ; edx = green(color2) * green(mask_img)

    mov ebx, [ebp + 48] ; ebx = color3
    shr ebx, 8          ; select GG
    and ebx, 0xFF
    imul ecx, ebx       ; ecx = green(color3) * blue(mask_img)

    add eax, edx        ; eax = eax + edx = green(color1) * red(mask_img) + green(color2) * green(mask_img)
    add eax, ecx        ; eax = eax + ecx = green(color1) * red(mask_img) + green(color2) * green(mask_img) + ecx = green(color3) * blue(mask_img)
    and eax, 0xFF       ; cut result to last 8bit
    mov ebx, [esp + 8]  ; ebx = img_offset
    mov ecx, [ebp + 8]  ; ecx = img
    mov [ecx + ebx + 1], al ; green(img) = ...

    ; --- BLUE ---
    mov ebx, [ebp + 20]     ; ebx = mask_img
    mov edi, [esp + 12]     ; edi = mask_offset
    movzx eax, byte [ebx + edi + 2] ; save mask RR to eax
    movzx edx, byte [ebx + edi + 1] ; save mask GG to edx
    movzx ecx, byte [ebx + edi]     ; save mask BB to ecx

    mov ebx, [ebp + 40] ; ebx = color1
    and ebx, 0xFF       ; select BB
    imul eax, ebx       ; edx = blue(color1) * red(mask_img)

    mov ebx, [ebp + 44] ; ebx = color2
    and ebx, 0xFF       ; select BB
    imul edx, ebx       ; eax = blue(color2) * green(mask_img)

    mov ebx, [ebp + 48] ; ebx = color3
    and ebx, 0xFF       ; select BB
    imul ecx, ebx       ; edx = blue(color3) * blue(mask_img)

    add eax, edx        ; eax = eax + edx = green(color1) * red(mask_img) + green(color2) * green(mask_img)
    add eax, ecx        ; eax = eax + ecx = green(color1) * red(mask_img) + green(color2) * green(mask_img) + ecx = green(color3) * blue(mask_img)
    and eax, 0xFF       ; cut result to last 8bit
    mov ebx, [esp + 8]  ; ebx = img_offset
    mov ecx, [ebp + 8]  ; ecx = img
    mov [ecx + ebx], al ; blue(img) = ...

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
    cmp [ebp + 36], ebx     ; if y = height then mask else exit
    jge exit

    mov ebx, [ebp + 28]     ; mask_height
    cmp [esp + 4], ebx      ; if y_mask = mask_height then mask else exit
    jge exit

    jmp mask

exit:
    ; epilogue
    add esp, 16
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
