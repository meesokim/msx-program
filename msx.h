#ifdef __MSX
#define __MSX

#define CHKRAM 0x0000
#define SYNCHR 0x0004
#define RDSLT  0x000c
#define CHRGTR 0x0010
#define WRSLT  0x0014
#define OUTDO  0x0018
#define CALSLT 0x001c
#define DCOMPR 0x0020
#define ENASLT 0x0024
#define GETYPR 0x0028
#define ROMID  0x002d
#define CALLF  0x0030
#define KEYINT 0x0038
#define INITIO 0x003b
#define INTFNK 0x003e
#define DISSCR 0x0041
#define ENASCR 0x0044
#define WRTVDP 0x0047
#define RDVRM  0x004A
#define WRTVRM 0x004D
#define SETRD  0x0050
#define SETWRT 0x0053
#define FILVRM 0x0056
#define LDIRVM 0x0059
#define CHGMOD 0x005F
#define CHGCLR 0x0062
#define NMI    0x0066
#define CLRSPR 0x0069
#define INITXT 0x006c
#define INIT32 0x006f
#define INIGRP 0x0072
#define INIMLT 0x0075
#define SETTXT 0x0078
#define SET32  0x007b
#define SETGRP 0x007e
#define CALPAT 0x0084
#define CALATR 0x0087
#define GSPSIZ 0x008a
#define GRPPRT 0x008d
#define GICINI 0x0090
#define WRTPSG 0x0093
#define RDPSG  0x0096
#define STRTMS 0x0099
#define CHSNS  0x009c
#define CHGET  0x009f
#define CHPUT  0x00a2
#define LPTOUT 0x00a5
#define LPTSTT 0x00a8
#define CNVCHR 0x00ab
#define PINLIN 0x00ae
#define INLIN  0x00b1
#define QINLIN 0x00b4
#define BREAKX 0x00b7
#define ISCNTC 0x00ba
#define CKCNTC 0x00bd
#define BEEP   0x00c0
#define CLS    0x00c3
#define POSIT  0x00c6
#define FNKSB  0x00c9
#define ERAFNK 0x00cc
#define DSPFNK 0x00cf
#define TOTEXT 0x00d2
#define GTSTCK 0x00d5
#define GTTRIG 0x00d8
#define GTPAD  0x00db
#define GTPDL  0x00de
#define TAPION 0x00e1
#define TAPIN  0x00e4
#define TAPIOF 0x00e7
#define TAPOON 0x00ea
#define TAPOUT 0x00ed
#define TAPOOF 0x00f0
#define STMOTR 0x00f3
#define LFTQ   0x00f6
#define PUTQ   0x00f9
#define RIGHTC 0x00fc
#define LEFTC  0x00ff
#define UPC    0x0102
#define TUPC   0x0105
#define DOWNC  0x0108
#define TDOWNC 0x010b
#define SCALXY 0x010e
#define MAPXY  0x0111
#define FETCHC 0x0114
#define STOREC 0x0117
#define SETATR 0x011a
#define READC  0x011d
#define SETC   0x0120
#define NSETCX 0x0123
#define GTASPC 0x0126
#define PNTINI 0x0129
#define SCANR  0x012c
#define SCANL  0x012f
#define CHGCAP 0x0132
#define CHGSND 0x0135
#define RSLREG 0x0138
#define WSLREG 0x013b
#define RDVDP  0x013e
#define SNSMAT 0x0141
#define PHYDIO 0x0144
#define FORMAT 0x0147
#define ISFLIO 0x014a
#define OUTDLP 0x014d
#define GETVDP 0x0150
#define GETVC2 0x0153
#define KILBUF 0x0156
#define CALBAS 0x0159

// MSX2
#define SUBROM 0x015c
#define EXTROM 0x015f
#define CHKSLZ 0x0162
#define CHKNEW 0x0165
#define EOL    0x0168
#define BIGFIL 0x016b
#define NSETRD 0x016e
#define NSTWRT 0x0171
#define NRDVRM 0x0174
#define NWRVRM 0x0177
// MSX2+
#define RDBTST 0x017a
#define WRBTST 0x017d
// MSX TURBO-R
#define CHGCPU 0x0180
#define GETCPU 0x0183
#define PCMPLY 0x0186
#define PCMREC 0x0189

#endif // __MSX

volatile unsigned char  __at (0xFCC1) EXPTBL;
volatile unsigned char  __at 0xFCC1 EXPTBL0;
volatile unsigned char  __at 0xFCC2 EXPTBL1;
volatile unsigned char  __at 0xFCC3 EXPTBL2;
volatile unsigned char  __at 0xFCC4 EXPTBL3;
volatile unsigned char  __at 0xFCC5 SLTTBL;
volatile unsigned char  __at 0xFCC5 SLTTBL0;
volatile unsigned char  __at 0xFCC6 SLTTBL1;
volatile unsigned char  __at 0xFCC7 SLTTBL2;
volatile unsigned char  __at 0xFCC8 SLTTBL3;
volatile unsigned char  __at 0xFCC9 SLTATR;
volatile unsigned char  __at 0x002d MSXVER;
volatile unsigned char  __at 0xffff SUBSTSEL;
volatile unsigned char  __at 0xfaf8 EXBRSA;