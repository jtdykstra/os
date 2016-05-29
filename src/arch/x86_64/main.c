int strlength(char *string)
{
    int len = 0;

    while(*string++)
        ++len;

    return len;
}

void printToScreen(char *toPrint, int color)
{
    int i = 0;
    char *vgaBuffer = (char *)0xb8000;
    for (i = 0; i < strlength(toPrint); ++i)
    {
        *vgaBuffer++ = toPrint[i];
        *vgaBuffer++ = color;
    }
}


extern int main()
{
    char color = 0x1f; 
    char *dog = "Fuck yeah, booted OS in c land!";
    int i = 0;
    
    printToScreen(dog, 0x1f);
    while(1)
    {

    }
}
