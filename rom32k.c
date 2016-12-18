//__sfr __at (0xA8) g_slotPort;
//	int __at 0x32 a;

#include "msx.h"

void bios_chput(char a);
void puts(char *s);
char chkprislot(void);
void pageaddr(int addr, char num);

void main(void)
{
	unsigned int i;
	unsigned int j;
	__asm
		.DW	#0x4241,test,0,0,0,0,0,0
	test:
	  call BEEP
	  call INITXT
	__endasm;
	puts ( "ROM header ok");
	puts ( "16k ROM boot ok");
		
	init_32krom ();

	puts ( "32k ROM init ok");
	puts ( "start main ::");

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
	bios_chput (0xd); // CR
	bios_chput (0xa); // LF	
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
