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
TARGET			=	TEKKOTSU

# assembler source files
ASSRCS			=	crt0.s \
				main.s System.s \
				App.s \
				Title.s \
				Game.s Pilot.s Steel.s \
				sprite.s \
				LogoPatternName.s LogoPatternGenerator.s LogoColor.s \
				BackPatternName.s BackPatternGenerator.s BackColor.s \
				FontPatternGenerator.s FontColor.s

# c source files
CSRCS			=	

# object files
OBJS			=	$(ASSRCS:.s=.rel) $(CSRCS:.c=.rel)


# build project target
#
$(TARGET).com:		$(OBJS)
	$(LD) $(LDFLAGS) -o $(BINDIR)/$(TARGET).ihx $(foreach file,$(OBJS),$(OBJDIR)/$(file))
	hex2bin -s 0x8400 $(BINDIR)/$(TARGET).ihx 
	mv $(BINDIR)/$(TARGET).bin $(OUTDIR)/$(TARGET).BIN

# clean project
#
clean:
	rm -f $(OBJDIR)/*
	rm -f $(BINDIR)/*
	rm -f $(OUTDIR)/$(TARGET).BIN
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
	@bmp2sc2 resources\pattern\logo.bmp
	@bin2s -n logoPatternNameTable -o sources\LogoPatternName.s resources\pattern\logo.name.sc2
	@bin2s -n logoPatternGeneratorTable -o sources\LogoPatternGenerator.s resources\pattern\logo.generator.sc2
	@bin2s -n logoColorTable -o sources\LogoColor.s resources\pattern\logo.color.sc2
	@bmp2sc2 resources\pattern\back.bmp
	@bin2s -n backPatternNameTable -o sources\BackPatternName.s resources\pattern\back.name.sc2
	@bin2s -n backPatternGeneratorTable -o sources\BackPatternGenerator.s resources\pattern\back.generator.sc2
	@bin2s -n backColorTable -o sources\BackColor.s resources\pattern\back.color.sc2
	@bmp2sc2 resources\pattern\font.bmp
	@bin2s -n fontPatternGeneratorTable -o sources\FontPatternGenerator.s resources\pattern\font.generator.sc2
	@bin2s -n fontColorTable -o sources\FontColor.s resources\pattern\font.color.sc2

# phony targets
#
.PHONY:				clean depend

# include depend file
#
-include makefile.depend


# makefile - end
