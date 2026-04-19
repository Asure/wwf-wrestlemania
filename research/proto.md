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

## Extra Prototype ROM Content

The prototype binary is ~6KB larger in live (non-padding) content than the final 1.30:
**941,124 vs 934,940 live bytes**. The bulk of the difference is in the high-ROM region
(`0xFFFC0000`–`0xFFFFFFFF`), which contains a fully-populated **operator adjustment menu
system** in the prototype that was gutted or replaced before the final release.

### Live-content delta by region (significant blocks only)

| Region | Proto extra words | Contents |
|--------|------------------:|---------|
| `0xFFFE0000` | +2892 | Coin denomination strings |
| `0xFFFF0000` | +432 | Operator menu sprite table 2 |
| `0xFFFC0000` | +335 | Operator adjustment help text |
| `0xFFFE8000` | ~+1798 | Operator menu sprite table 1 |
| Various code regions | 50–550 | Layout shift from global +0x1000 offset |

---

### `0xFFFC0000` — Operator Adjustment Menu Help Text

The prototype stores detailed description strings for every adjustable game setting,
covering:

- Sound in attract mode (`FACTORY SETTING: 3`)
- High score reset interval (`FACTORY SETTING: 5000`)
- Graphic violence level (`FACTORY SETTING: NORMAL`)
- Free play enable (`FACTORY SETTING: NO`)
- Pricing mode and coin-unit configuration
- Individual coin chute multipliers (Chutes 1–4)
- Totalizer mode (Standard / Custom)
- Bill validator
- Credits required to start / continue
- Fractional credit display
- Bookkeeping money totals
- Maximum credits limit (`FACTORY SETTING: 50`)

The final 1.30 ROM replaces this block entirely with **hardware diagnostic menu text**:
`"HARDWARE INFORMATION"`, `"REAL TIME CLOCK"`, `"DISPLAY"`, `"CALIBRATE"`,
and RTC (real-time clock) setup strings. The operator pricing help strings were removed.

---

### `0xFFFE0000` — Coin Denomination Strings

The prototype holds multi-country pricing strings for the credits screen:

```
1 CREDIT / 1 DM
6 CREDITS / 5 DM
1 CREDIT / 20 FR
1 CREDIT / 50 P
$1.00 / PLAY
CREDITS TO START
CREDITS TO CONTINUE
CREDITS PER PLAYER
MAXIMUM CREDITS!
```

The final 1.30 ROM has completely different content (animation/sprite data) at this
address. The country-specific denomination strings were removed from the released build.

---

### `0xFFFE8000` — Operator Menu Sprite Display Table (Table 1)

33+ entries, stride **9 words (18 bytes)** each. Every entry references the same image
at bit-address `0xFFD24AC0` (a 16-pixel-wide sprite). Entries differ in position
parameters and control flags:

| Field | Offset in entry | Notes |
|-------|----------------|-------|
| Control word | word[0] | Varies per entry |
| Flags | word[1] | `0x0454` / `0x0455` |
| Scale/palette | word[2] | `0x4000`, `0x4580`, `0x4A80`, `0x4B80`, `0x4F80` |
| Image ptr (lo) | word[3] | `0x4AC0` (constant) |
| Image ptr (hi) | word[4] | `0xFFD2` → 32-bit addr `0xFFD24AC0` (constant) |
| X position | word[5] | Varies: 9, 24, 44, 64, 84, 33, 65, 97, 129… |
| Y position | word[6] | Varies: 71, 91, 111, 31, 51, 71, 91, 11… |

Entries 0–2 form a vertical column at X=9, Y=71/91/111 (20-pixel row spacing),
suggesting a repeating border or scrolling element in the operator menu layout.

The final 1.30 ROM has blank (`0xFFFF`) data at `0xFFFE8000`.

---

### `0xFFFF0000` — Operator Menu Sprite Display Table (Table 2)

19+ entries, same **9-word stride**. All reference image at `0xFFD1B490` (also 16px wide).
Dimensions vary across groups of entries (18×13, 13×11, 12×14 pixels).
The incrementing control word increases by **0x3A8 (936)** per entry — consistent with a
scanline-stride display list.

The final 1.30 ROM has blank (`0xFFFF`) data at `0xFFFF0000`.

---

### Code path referencing `0xFFFE8000` (present in both builds)

Both the prototype (at `FFB37F60`) and the final (at `FFB25A00`) contain identical code
that conditionally loads `0xFFFE8000` as a display list pointer into a process field:

```asm
MOVE  *A13(2D0h),A0,1    ; read current display pointer
JRN   #done              ; if already negative (0x18000 set), skip
MOVI  FFFE8000h,A0       ; load operator menu display table address
MOVE  A0,*A13(2D0h),1    ; store as display pointer
ORI   200h,A1            ; set display flag
RETS
#done:
RETS
```

In the final, `0xFFFE8000` is unprogrammed Flash (`0xFFFF`), so this code path
effectively reads garbage and the operator menu graphics are never displayed.
The code was left in place; only the data was removed.

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
