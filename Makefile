CC=sdcc
AS=sdasz80

OBJ1 = $(SRC1:.s=.rel)
OBJ2 = $(SRC2:.c=.rel)

OBJ = $(OBJ1) $(OBJ2)

CFLAGS = -mz80
LDFLAGS = -mz80 --code-loc $(CODELOC) --data-loc 0xe000 --no-std-crt0

%.rel: %.c
	$(CC) -c $< $(CFLAGS)
%.rel: %.s
	$(AS) -l -o $<	

rom32k:
SRC1=msxdef.s
SRC2=rom32k.c
TARGET1=rom32k
CODELOC=0x4000
SIZE1=0x8000

$(TARGET1): $(OBJ)
	$(CC) $^ $(LDFLAGS) -o $@.ihx
	hex2bin -e rom -l $(SIZE1) $(TARGET1).ihx

prueba:
SRC1=
SRC2=prueba.c
TARGET2=prueba
CODELOC=0x4000
SIZE2=0x4000

$(TARGET2): $(OBJ)
	$(CC) $^ $(LDFLAGS) -o $@.ihx
	hex2bin -e rom -l $(SIZE2) $(TARGET2).ihx
	
msxmem:
SRC1=
SRC2=msxmem.c
TARGET3=msxmem
CODELOC=0x4000
SIZE3=0x4000

$(TARGET3): $(OBJ)
	$(CC) $^ $(LDFLAGS) -o $@.ihx
	hex2bin -e rom -l $(SIZE3) $(TARGET3).ihx	
	
callex:
SRC1=psg.s basic.s
SRC2=
TARGET4=callex
CODELOC=0x4010
SIZE4=0x4000

$(TARGET4): $(OBJ)
	$(CC) $^ $(LDFLAGS) -o $@.ihx
	hex2bin -e rom -l $(SIZE4) $(TARGET4).ihx	


all: 
	make rom32k
	make prueba
	make callex

clean:
	rm -f *.rel *.lst *.rom *. *.map *.lk *.noi *.ihx *.sym *.asm *~
