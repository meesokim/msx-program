__sfr __at (0xA8) g_slotPort;
//	int __at 0x32 a;

void main(void)
{
	__asm
		.DW	#0x4241,0,test,0,0,0,0,0
	test:
		di
		ld sp, (#0xFC4A)
		ei
	__endasm;
	g_slotPort = (g_slotPort & 0xCF) | ((g_slotPort & 0x0c) << 2);
	while(1);
}

