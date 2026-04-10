loadw main /t=c:\tmp\wwf /FI /E
loadw bam /A /t=c:\tmp\wwf /FI /E
loadw bret /A /t=c:\tmp\wwf /FI /E
loadw doink /A /t=c:\tmp\wwf /FI /E
loadw lex /A /t=c:\tmp\wwf /FI /E
loadw razor /A /t=c:\tmp\wwf /FI /E
loadw shawn /A /t=c:\tmp\wwf /FI /E
loadw taker /A /t=c:\tmp\wwf /FI /E
loadw yoko /A /t=c:\tmp\wwf /FI /E
loadw misc /A /t=c:\tmp\wwf /FI /E
loadw adam /A /t=c:\tmp\wwf /FI /E
cd c:\tmp\wwf
copy bgndglo.txt + bgndtbl.asm temp.xyz
copy temp.xyz bgndtbl.asm
copy bgndglo.txt + bgndpal.asm temp.xyz
copy temp.xyz bgndpal.asm
del temp.xyz
del junkxxxx
del *.~sm
del *.~bl
del l2temp
echo.
echo.
echo.
echo	done...
echo.

