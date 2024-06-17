.intel_syntax noprefix
.data
.global _start

.balign 4096
memory:
    .fill 1000000

.equiv SECRET, 0

.text
_start:
    mov rax, [memory]
    mov rax, [memory+(1<<16)]
    mov rax, [memory+(2<<16)]
    mov rax, [memory+(3<<16)]
    mov rax, [memory+(4<<16)]
    mov rax, [memory+(5<<16)]
    mov rax, [memory+(6<<16)]
    mov rax, [memory+(7<<16)]
    // ensure [memory+((8<<16)+SECRET*64)] gets a TLB hit
    mov rax, [memory+((8<<16)+128)]
    mfence
    
    // delay availability of source for conditional jump test
    xor rbx, rbx 
    lea rbx, [rbx + rax + 2]
    lea rbx, [rbx + rax + 2]
    lea rbx, [rbx + rax + 2]
    lea rbx, [rbx + rax + 2]
    lea rbx, [rbx + rax + 2]
    lea rbx, [rbx + rax + 2]
    lea rbx, [rbx + rax + 2]

    test rbx, 1
    // Misprediction!
    jz branch
    // This address maps to the same cache set as [memory+((0,1,...,7 << 16) + SECRET*64)]
    mov rax, [memory+((8<<16)+SECRET*64)]

branch:
    // exit
    mov rax, 0x3c
    syscall
