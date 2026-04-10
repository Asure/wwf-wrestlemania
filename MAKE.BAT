echo off
attrib -r
del *.obj 
del *.lst
del mc*.* 
del make0*.bat 
del make0*.lck
del wrestle.out
del rom\wwf*.*
\tools\vidram on
rem \opus\make %1 %2 %3 %4 %5
\tools\gmake -m
cd rom
echo "Beginning Program File Build Process..."
del *.u*
c:\tools\vidram off
c:\tools\bigsrec <ff8.lrn
exit




