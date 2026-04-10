# wwf-wrestlemania

## What is this?
- A clean branch, that in the end, would build a 1:1 clean copy of production.
- No changes, hacks whatever.

## Prereqs

- Dosbox 0.74.3 (so you can compile and link the code.)
https://sourceforge.net/projects/dosbox/files/dosbox/0.74-3/DOSBox0.74-3-win32-installer.exe/download

- Python 3 (so you can run build.py.)
https://www.python.org/ftp/python/3.14.4/python-3.14.4-amd64.exe

- Srecord (Optional. Allows rom file manipulation.)
https://sourceforge.net/projects/srecord/files/srecord-win32/1.65/srecord-1.65.0-win64.exe/download

- DD for Windows (Optional. Allows file manipulations. Rename to dd.exe)
http://www.chrysocome.net/downloads/ddrelease64.exe

- Zip for Windows (Optional)
http://downloads.sourceforge.net/gnuwin32/zip-3.0-bin.zip

## How-to
- Install Dosbox and Python 3
- Now you can double-click on build.py. Game roms will end up in rom\ folder.
- Windows: Run rom\merge.cmd to create game roms. ( Optional: Edit the CMD file to allow auto-zipping into mame rom folder.)
- Optional tools: Extract them as needed, and put them in your PATH on Windows. (I like to put tools like these in c:\bin folder.)

Build.py will do all the work and create the game rom files.

## Other artifacts
Do not run these, they will start with old base files and delete any modifications done in advance!

File fix_wwf.py was used to convert old style hex notations into modern GSPA v6 notations.
File preasm.ps1 was used to fix the duplicate label style that Midway liked to use. 

## Todo
- Compare production roms vs. 1.30 code leak and make it 1:1
- Compare release 1.20/1.1 and see what was changed.
 
 

