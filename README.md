# WWF Wrestlemania

##Status:
- Current build per 3-11-2023 works and boots. We can get to attract mode. It can show fights.
- We can't get out of the select screen for some reason.
- The build breaks if i add the leading .long 0 into each seq. You can see experiments in .seq folder.. t2..
- This likely points to something wrong in anim.axx or the *seq.asm files which i'm not sure of.
- The .AXX preasm tool is sloppy and needs exceptions. It breaks some axx files when auto generating.
- The broken .axx files are fixed manually atm, don't delete the .axx if you want to build!
- At this point in time you can run gmake -m in DOSBOX if your TI tools are set up, and it will build and link. (see dosbox.conf for a sample that auto builds.)
- Then in the ROM folder run FF8.BAT to build roms for FF800000 start.
- Outside dosbox, run the MERGE.CMD to join the split rom parts and you're ready to go.

##Fixed
- Can't generate .axx files. (see fixes/preasm.ps1 powershell)
- Runs out of memory compiling wrestle.axx (magically fixed sort of. gmake eats ram.)
- Seems some SEQ files missing, not sure what/why and what they should be. (seq generator written.)
- Wrestle2.axx has some issues (sloppy axx generator.)
- Add rom build tools.




