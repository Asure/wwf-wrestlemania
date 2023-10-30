@echo off
rem uncomment and add orig roms to build flat merged bin.
c:\bin\far\srec_cat -o ROM_ORIG.bin -binary wwf.54 -binary -unsplit 2 0 wwf.63 -binary -unsplit 2 1
rem copy /b mk321f8.0 + mk321fc.0  mk321u54.bin
rem copy /b mk321f8.1 + mk321fc.1  mk321u63.bin
rem del *.0 *.1

