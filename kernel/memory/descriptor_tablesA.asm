[bits 32]

; void __attribute__((cdecl)) GDT_Load(GDTDescriptor* descriptor, uint16_t codeSegment, uint16_t dataSegment);
global GDT_Load
GDT_Load:

    ; make new call frame
    push ebp
    mov ebp, esp

    ; load gdt
    mov eax, [ebp + 8]
    lgdt [eax]

    ; reload code segment
    mov eax, [ebp + 12]
    push eax
    push .reload_cs
    retf

    .reload_cs:
        ; reload data segments
        mov ax, [ebp + 16]
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax

        ; restore old call frame
        mov esp, ebp
        pop ebp
        ret

%macro ISR_NOERRCODE 1
  global isr%1
  isr%1:
    cli                         ; Disable interrupts firstly.
    push byte 0                 ; Push dummy error code.
    push byte %1                ; Push the interrupt number.
    jmp isr_common_stub         ; Go to our common handler code.
%endmacro

%macro ISR_ERRCODE 1
  global isr%1
  isr%1:
    cli                         ; Disable interrupts.
    push byte %1                ; Push the interrupt number
    jmp isr_common_stub
%endmacro

ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE   8
ISR_NOERRCODE 9
ISR_ERRCODE   10
ISR_ERRCODE   11
ISR_ERRCODE   12
ISR_ERRCODE   13
ISR_ERRCODE   14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31

extern isr_handler

isr_common_stub:
    pusha

    mov ax, ds
    push eax

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call isr_handler

    pop ebx
    mov ds, bx
    mov es, bx
    mov fs, bx
    mov gs, bx

    popa
    add esp, 8
    sti
    iret

; void __attribute__((cdecl)) IDT_Load(IDTDescriptor* descriptor);
global IDT_Load
IDT_Load:
    mov eax, [esp+4]
    lidt [eax]
    ret