del std*.*
rem del *.obj
del finis*.obj
del yoko*.obj
del *.out
del *.lst
"C:\Program Files (x86)\DOSBox-0.74\DOSBox.exe" -noconsole -conf D:\dosbox\tools\c\mywwf\dosbox.conf
del std*.txt
cd rom
call merge.cmd
call joinnew.cmd
rem update the zip for debugging
zip d:\mame\roms\wwfmania.zip wwf_g*

