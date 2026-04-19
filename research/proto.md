# WWF WrestleMania — Prototype ROM Analysis

## Overview

`rom/ROM_PROT.bin` is a prototype / early release build of WWF WrestleMania (1MB merged `.bin`).  
The ROM is mapped to bit-address base **`0xFF800000`**, identical to the final 1.30 build.

The prototype binary was analyzed by locating `init_smoves` in both builds and following the
`#special_moves` pointer table to each character's `smove_table`.

---

## Key Addresses

| Symbol | Final 1.30 | Prototype |
|--------|-----------|-----------|
| `init_smoves` | `0xFF878390` | `0xFF877580` |
| `#special_moves` table | `0xFF8784E0` | `0xFF8776D0` |
| `std_walk_fast` (shared) | `0xFFA41110` | `0xFFA573C0` |
| `std_taunt` (shared) | `0xFFA42750` | `0xFFA58A00` |

---

## Special Move Table Comparison

Each character's `smove_table` is a null-terminated list of process addresses loaded by
`init_smoves` and spawned via `GETPRC_INSERT`. The table below shows entry counts
(excluding the terminator) for each build.

| Character | Final 1.30 | Prototype | Difference |
|-----------|:----------:|:---------:|------------|
| Bret Hart | 11 | 11 | — identical |
| Razor Ramon | 10 | **9** | Proto missing `rzr_sliding_rug` |
| Undertaker | 12 | **11** | Proto missing `und_finish_move1` _(tombstone finisher)_ |
| Yokozuna | 8 | 8 | — identical |
| Shawn Michaels | 13 | **12** | Proto missing `shn_grab_toss_air` |
| Bam Bam Bigelow | 8 | 8 | — identical |
| Doink | 9 | 9 | — identical |
| Lex Luger | 8 | 8 | — identical |

### `smove_table` Pointers

| Character | Final ptr | Proto ptr |
|-----------|-----------|-----------|
| `hrt_smove_table` | `0xFFA265D0` | `0xFFA3C510` |
| `rzr_smove_table` | `0xFFA55FB0` | `0xFFA6BFA0` |
| `und_smove_table` | `0xFFA97E90` | `0xFFAACB60` |
| `yok_smove_table` | `0xFFAB0910` | `0xFFAC4600` |
| `shn_smove_table` | `0xFFA7FD80` | `0xFFA954A0` |
| `bam_smove_table` | `0xFFA11FE0` | `0xFFA280A0` |
| `dnk_smove_table` | `0xFFA3B7A0` | `0xFFA51900` |
| `lex_smove_table` | `0xFFA6B080` | `0xFFA80720` |

---

## Notable Differences

### Razor Ramon — `rzr_sliding_rug` missing
The final 1.30 has `rzr_sliding_rug` as the **10th entry**, placed *after* `std_taunt`.
It is absent from the prototype table (which terminates after `std_taunt`).
This move was added late in development.

### Undertaker — No finisher in prototype
The final 1.30 includes `und_finish_move1` (the Tombstone Piledriver finisher) as a
spawnable special move process. The prototype terminates before this entry.
Undertaker is the **only character** with an active finisher in the final 1.30 build;
all other characters have `NUM_xxx_FINISHES = 0`. The finisher was not present in the proto.

### Shawn Michaels — `shn_grab_toss_air` missing
The prototype has 12 entries, stopping after `shn_flipslam`. The final adds
`shn_grab_toss_air` as entry [10] before `std_walk_fast`.

### `dnk_hdhold_anti_combo` — not in either binary
`DNK.ASM` (an early dev/test source snapshot, **not** the prototype source) shows
`dnk_hdhold_anti_combo` as an active smove table entry and `dnk_charge_flykick`
commented out. However, the actual prototype binary matches the final 1.30 structure:
`dnk_charge_flykick` active, `anti_combo` absent.  
`DNK.ASM` represents an intermediate dev/test moment unrelated to the prototype binary.

### `yok_hdhold_anti_combo` — not in either binary
Commented out in `YOKO.ASM` and absent from both the final and prototype binaries.

---

## Methodology

1. Located `init_smoves` in both builds by searching for `MOVI 12Fh,A1` (`SMOVE_PID`).
2. Read the `ADDI` immediate in `init_smoves` to get the `#special_moves` table address.
3. Indexed into `#special_moves` (32-bit entries, one per character) to get each
   character's `smove_table` pointer.
4. Read each `smove_table` as a null-terminated list of 32-bit TMS34010 bit-addresses.
5. Verified shared function identity (`std_walk_fast`, `std_taunt`, `dnk_charge_flykick`,
   `std_taunt`) by comparing opening instruction sequences against both disassembly files
   (`wwf130a.asm` for final, `wwfproto` for prototype).

TMS34010 storage format: 32-bit values are stored **little-endian, low word first**
(each 16-bit word stored little-endian). File byte offset from bit-address:
`offset = (bit_addr - 0xFF800000) / 8`.
