//__sfr __at (0xA8) g_slotPort;
//	int __at 0x32 a;

#include "msx.h"

void bios_chput(char a);
void puts(char *s);
char chkprislot(void);
void pageaddr(int addr, char num);
void msxmem(void);
void init_32krom (void);
void slotput(char, char, char, char *);

void main(void)
{
	__asm
		.DW	#0x4241,test,0,0,0,0,0,0
	test:
	  call BEEP
	  call ERAFNK
	  call INITXT
	__endasm;
	msxmem();
}
void msxmem(void)
{
	unsigned int i;
	unsigned int j;
	char a, b;
	a = 3;
	b = 1;
	for(b=2;b>0;b--)
	{
		if (b==1)
			puts ( "  00  01  02  03      20  21  22  23\r\n");
		else
			puts ( "  10  11  12  13      30  31  32  33\r\n");
		puts ( " \1X\1W\1W\1Y\1X\1W\1W\1Y\1X\1W\1W\1Y\1X\1W\1W\1Y    \1X\1W\1W\1Y\1X\1W\1W\1Y\1X\1W\1W\1Y\1X\1W\1W\1Y\r\n");
		for(a=4;a>0;a--)
		{
			bios_chput('/'+a);
			puts ( "\1V  \1V\1V  \1V\1V  \1V\1V  \1V   ");
			bios_chput('/'+a);
			puts ( "\1V  \1V\1V  \1V\1V  \1V\1V  \1V\r\n");
			if (a > 1)
				puts ( " \1T\1W\1W\1S\1T\1W\1W\1S\1T\1W\1W\1S\1T\1W\1W\1S    \1T\1W\1W\1S\1T\1W\1W\1S\1T\1W\1W\1S\1T\1W\1W\1S\r\n");
		}
		puts ( " \1Z\1W\1W\1[\1Z\1W\1W\1[\1Z\1W\1W\1[\1Z\1W\1W\1[    \1Z\1W\1W\1[\1Z\1W\1W\1[\1Z\1W\1W\1[\1Z\1W\1W\1[\r\n");
	}
		
	slotput(0,0,0,"BA");

	puts ( "32k ROM init ok\r\n");
	puts ( "start main ::\r\n");

	while (1) {
		for (i = 0; i <38; i ++) {
			bios_chput ('*');
			for (j = 0; j <10000; j ++);
		}
		bios_chput (0xd);
		for (i = 0; i <38; i ++) {
			bios_chput (' ');
			for (j = 0; j <10000; j ++);
		}
		bios_chput (0xd);
	}	
}
void gotoxy(char x, char y)
{
	__asm
		push ix
		ld ix,#4
		add ix,sp
		ld l, 1(ix)
		ld h, (ix)
		call POSIT
		pop ix
	__endasm;		
}
const char posx[] = {3,  7, 11, 15,  3,  7, 11, 15, 23, 27, 31, 35, 23, 27, 31, 35};
const char posy[] = {9,  7,  5,  3, 19, 17, 15, 13,  9,  7,  5,  3, 19, 17, 15, 13};
void slotput(char a, char b, char c, char *s)
{
	char d = a * 4 + c;
	char e = b * 4 + c;
	gotoxy(posx[d], posy[e]);
	puts(s);
}

void bios_chput(char a) 
{ 
	__asm	
		ld ix,#2
		add ix,sp
		ld a,(ix)
		call 0xa2 
	__endasm; 
}
	
void puts(char *s)
{
	while(*s!=0)
		bios_chput(*s++);
}

char chkprislot(void)
{
	char slot;
	__asm
		push af
		call 0x0138
		ld l, a
		pop af
	__endasm;
	return;
}

void pageaddr(int addr, char num)
{
	__asm
		push af; backup registerfile
		push bc
		push ix
		ld ix, #8
		add ix, sp
		ld c,  (ix)
		ld b, 1(ix)
		ld a, 2(ix)
		push de
		push hl
		push iy
	;
		call 0x0024; call bios ENASLT (0x0024)
	;
		pop iy; restore registers
		pop hl
		pop de
		pop ix
		pop bc
		pop af
	;
	__endasm;
}



void init_32krom (void) {
	unsigned char rtn;
	unsigned char slotnum;

	// check slot number
	rtn = chkprislot ();
	slotnum = (rtn >> 2) & 3;

	// primary SLOT change of the PAGE address
	// (page2,0x8000-0xBFFF, PriSLOT 3 ==> PriSLOT 1 or 2 externalrom)
	pageaddr (0x8000, slotnum);
}

void asm_ext(void)
{	__asm
	#include "msxdef.s"
	__endasm;
}
