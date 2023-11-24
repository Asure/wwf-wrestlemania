@echo off
rem 1FFF70 = 2097008
dd conv=notrunc bs=1 seek=2097024 if=vectable.bin of=rom_mine.bin
rem split odd/even
c:\bin\far\srec_cat rom_mine.bin -binary -split 2 0 -o .\2m\wwf_game_rom_l1.30.u54 -binary
c:\bin\far\srec_cat rom_mine.bin -binary -split 2 1 -o .\2m\wwf_game_rom_l1.30.u63 -binary
