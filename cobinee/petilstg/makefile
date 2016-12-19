#! make -f
#
# makefile - start
#


# directory
#

# source file directory
SRCDIR			=	sources

# include file directory
INCDIR			=	sources

# object file directory
OBJDIR			=	objects

# binary file directory
BINDIR			=	bin

# output file directory
OUTDIR			=	disk

# vpath search directories
VPATH			=	$(SRCDIR):$(INCDIR):$(OBJDIR):$(BINDIR)

# assembler
#

# assembler command
AS				=	sdasz80

# assembler flags
ASFLAGS			=	-ls -I$(INCDIR) -I.

# c compiler
#

# c compiler command
CC				=	sdcc

# c compiler flags
CFLAGS			=	-mz80 --opt-code-speed -I$(INCDIR) -I.

# linker
#

# linker command
LD				=	sdcc

# linker flags
LDFLAGS			=	-mz80 --no-std-crt0 --nostdinc --nostdlib --code-loc 0x8420 --data-loc 0xd400
LDFLAGS1		=	-mz80 --no-std-crt0 --nostdinc --nostdlib --code-loc 0x4200 --data-loc 0xd400

# suffix rules
#
.SUFFIXES:			.s .c .rel

# assembler source suffix
.s.rel:
	$(AS) $(ASFLAGS) -o $(OBJDIR)/$@ $<

# c source suffix
.c.rel:
	$(CC) $(CFLAGS) -o $(OBJDIR)/$@ -c $<

# project files
#

# target name
TARGET			=	PETILSTG

# assembler source files
ASSRCS			=	crt0.s \
				main.s System.s \
				App.s \
				Game.s Unit.s Enemy.s Player.s Eshot.s Pshot.s Cockpit.s Star.s Text.s Demo.s \
				sprite.s pattern.s
				
ASSRCS1			=	crt1.s \
				main.s System.s \
				App.s \
				Game.s Unit.s Enemy.s Player.s Eshot.s Pshot.s Cockpit.s Star.s Text.s Demo.s \
				sprite.s pattern.s				

# c source files
CSRCS			=	

# object files
OBJS			=	$(ASSRCS:.s=.rel) $(CSRCS:.c=.rel)
OBJS1			=	$(ASSRCS1:.s=.rel) $(CSRCS1:.c=.rel)


# build project target
#
$(TARGET).rom:		$(OBJS1)
	$(LD) $(LDFLAGS1) -o $(BINDIR)/$(TARGET).ihx $(foreach file,$(OBJS1),$(OBJDIR)/$(file))
	hex2bin -e rom -l 0x8000 $(BINDIR)/$(TARGET).ihx 
	mv $(BINDIR)/$(TARGET).rom .

$(TARGET).com:		$(OBJS)
	$(LD) $(LDFLAGS) -o $(BINDIR)/$(TARGET).ihx $(foreach file,$(OBJS),$(OBJDIR)/$(file))
	hex2bin -m $(BINDIR)/$(TARGET).ihx $(OUTDIR)/$(TARGET).BIN

	
	
# clean project
#
clean:
	rm -f $(OBJDIR)/*
	rm -f $(BINDIR)/*
	rm -f *.rom
#	@del /F /Q $(OBJDIR)\*.*
#	@del /F /Q $(BINDIR)\*.*
##	@del /F /Q makefile.depend

# build depend file
#
depend:
##	ifneq ($(strip $(CSRCS)),)
##		$(CC) $(CFLAGS) -MM $(foreach file,$(CSRCS),$(SRCDIR)/$(file)) > makefile.depend
##	endif

# build resource file
#
resource:
	@bin2s -n spriteGeneratorTable -o sources\sprite.s resources\sprite\sprite.chr
	@bin2s -n patternGeneratorTable -o sources\pattern.s resources\pattern\pattern.chr

# phony targets
#
.PHONY:				clean depend

# include depend file
#
-include makefile.depend


# makefile - end
