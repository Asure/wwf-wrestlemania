@echo off
del *.u54
del *.u63
rem mk321u54 63
rem uncomment and add orig roms to build flat merged bin.
rem c:\bin\far\srec_cat -o ROM_ORIG.bin -binary mk321u54.bin -binary -unsplit 2 0 mk321u63.bin -binary -unsplit 2 1
copy /b wwf321f8.0 + wwf321fc.0  wwf_game_rom_l1.30.u54
copy /b wwf321f8.1 + wwf321fc.1  wwf_game_rom_l1.30.u63
del *.0 *.1

