void kernel_main(void)
{
    volatile unsigned short *vga = (unsigned short *)0xB8000;

    const char *msg = "KERNEL MAIN() OK!";

    for (int i = 0; msg[i] != '\0'; i++)
    {
        vga[i] = ((unsigned short)0x0F << 8) | msg[i];
    }

    while (1)
    {
        __asm__ volatile ("cli; hlt");
    }
}