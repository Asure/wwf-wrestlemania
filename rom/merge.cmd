@echo off
del *.u54
del *.u63
copy /b wwf321f8.0 + wwf321fc.0  wwf_game_rom_l1.30.u54
copy /b wwf321f8.1 + wwf321fc.1  wwf_game_rom_l1.30.u63
del *.0 *.1
zip d:\mame\roms\wwfmania.zip .\wwf_*.u*


