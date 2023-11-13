@echo off
rem quick and dirty..
rem cut off the header that comes from the load2.exe tool used to build these IRW files
rem actual load2.exe tool should be run from dosbox.
dd if=../lrk2.irw of=0.bin bs=0x44 skip=1
dd if=../lrk3.irw of=1.bin bs=0x44 skip=1
dd if=../lrk4.irw of=2.bin bs=0x44 skip=1
dd if=../lrk5.irw of=3.bin bs=0x44 skip=1
rem MAME debug commands to load these from the mame folder:
rem loadr 0.bin,0,0,:gfxrom
rem loadr 1.bin,200000,0,:gfxrom
rem loadr 2.bin,400000,0,:gfxrom
rem loadr 3.bin,600000,0,:gfxrom
rem 
rem extend the files to 2MByte size:
rem on unix use trunc command..  (truncate -s 5MB 0.bin and so on.)
rem
fsutil file seteof 0.bin 2097152
fsutil file seteof 1.bin 2097152
fsutil file seteof 2.bin 2097152
fsutil file seteof 3.bin 2097152
rem 
rem Create roms to use in NBA Jam driver for now
rem
rem 0-200000
c:\bin\far\srec_cat 0.bin -binary -split 4 0 -o l1_nba_jam_game_rom_ug14.ug14 -binary
c:\bin\far\srec_cat 0.bin -binary -split 4 1 -o l1_nba_jam_game_rom_uj14.uj14 -binary
c:\bin\far\srec_cat 0.bin -binary -split 4 2 -o l1_nba_jam_game_rom_ug19.ug19 -binary
c:\bin\far\srec_cat 0.bin -binary -split 4 3 -o l1_nba_jam_game_rom_uj19.uj19 -binary
rem 200000-400000
c:\bin\far\srec_cat 1.bin -binary -split 4 0 -o l1_nba_jam_game_rom_ug16.ug16 -binary
c:\bin\far\srec_cat 1.bin -binary -split 4 1 -o l1_nba_jam_game_rom_uj16.uj16 -binary
c:\bin\far\srec_cat 1.bin -binary -split 4 2 -o l1_nba_jam_game_rom_ug20.ug20 -binary
c:\bin\far\srec_cat 1.bin -binary -split 4 3 -o l1_nba_jam_game_rom_uj20.uj20 -binary
rem 400000-600000
c:\bin\far\srec_cat 2.bin -binary -split 4 0 -o l1_nba_jam_game_rom_ug17.ug17 -binary
c:\bin\far\srec_cat 2.bin -binary -split 4 1 -o l1_nba_jam_game_rom_uj17.uj17 -binary
c:\bin\far\srec_cat 2.bin -binary -split 4 2 -o l1_nba_jam_game_rom_ug22.ug22 -binary
c:\bin\far\srec_cat 2.bin -binary -split 4 3 -o l1_nba_jam_game_rom_uj22.uj22 -binary
rem 600000-800000
c:\bin\far\srec_cat 3.bin -binary -split 4 0 -o l1_nba_jam_game_rom_ug18.ug18 -binary
c:\bin\far\srec_cat 3.bin -binary -split 4 1 -o l1_nba_jam_game_rom_uj18.uj18 -binary
c:\bin\far\srec_cat 3.bin -binary -split 4 2 -o l1_nba_jam_game_rom_ug23.ug23 -binary
c:\bin\far\srec_cat 3.bin -binary -split 4 3 -o l1_nba_jam_game_rom_uj23.uj23 -binary

