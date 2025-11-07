#!/bin/sh

mkdir -p isodir/boot/grub
cp Image isodir/boot
cp conf/grub.cfg isodir/boot/grub
grub-mkrescue -o Image.iso isodir
