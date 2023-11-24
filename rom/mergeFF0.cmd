@echo off
del *.u54
del *.u63
rem mk321u54 63
rem uncomment and add orig roms to build flat merged bin.
copy /b wwf2Mf0.0 + wwf2Mf2.0 + wwf2Mf4.0 + wwf2Mf6.0 + wwf2Mf8.0 + wwf2Mf8.0 + wwf2Mf8.0 + wwf2Mf8.0 wwf_game_rom_l1.30.u54
copy /b wwf2Mf0.1 + wwf2Mf2.1 + wwf2Mf4.1 + wwf2Mf6.1 + wwf2Mf8.1 + wwf2Mf8.1 + wwf2Mf8.1 + wwf2Mf8.1 wwf_game_rom_l1.30.u63
rem creates comparable bin for dev:
c:\bin\far\srec_cat -o .\2m\rom_mine.bin -binary wwf_game_rom_l1.30.u54 -binary -unsplit 2 0 wwf_game_rom_l1.30.u63 -binary -unsplit 2 1
rem fix vector table gets nuked by srec tool
@echo off
rem 1FFF70 = 2097008
dd if=..\wwf2m.out bs=8 skip=51 of=.\vectable.bin count=16
dd conv=notrunc bs=1 seek=2097024 if=vectable.bin of=./2m/rom_mine.bin
rem split odd/even
c:\bin\far\srec_cat .\2m\rom_mine.bin -binary -split 2 0 -o .\2m\wwf_game_rom_l1.30.u54 -binary
c:\bin\far\srec_cat .\2m\rom_mine.bin -binary -split 2 1 -o .\2m\wwf_game_rom_l1.30.u63 -binary
rem zip 2m
zip d:\mame\roms\wwfmania.zip .\2m\wwf_*
rem delete the copy w/o vectable:
del wwf_game_rom_l1.30.u54
del wwf_game_rom_l1.30.u63
del *.0 *.1
rem 2M version now in .\2m

