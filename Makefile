srcdir	:= src

ARCH	:= x86

AS		:= clang
CC		:= clang
LD		:= ld.lld

FLAGS	= -target x86_64-pc-none-elf -O2 -Wall -Wextra -ffreestanding -nostdlib -I. -Iinclude -mkernel
AFLAGS	:= $(FLAGS)
CFLAGS	:= $(FLAGS) -std=c11

SRCS_C	:= $(wildcard $(srcdir)/*.c)
SRCS_S	:= $(wildcard arch/$(ARCH)/*.S)
OBJS	:= $(SRCS_S:.S=.o) $(SRCS_C:.c=.o)

TARGET	:= Image

all: $(OBJS)
	$(LD) -T $(srcdir)/linker.lds -o $(TARGET) $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.S
	$(AS) $(AFLAGS) -c -o $@ $<

clean:
	$(RM) $(OBJS) $(TARGET)

distclean: clean
	$(RM) -drf isordir

.PHONY: all clean
