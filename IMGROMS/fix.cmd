@echo off
rem quick and dirty..
rem cut off the header that comes from the load2.exe tool used to build these IRW files
rem actual load2.exe tool should be run from dosbox.
dd if=misc2.irw of=misc.bin bs=0x44 skip=1
