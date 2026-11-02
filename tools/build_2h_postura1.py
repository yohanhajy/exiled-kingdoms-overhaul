#!/usr/bin/env python3
"""
build_2h_postura1.py — Gerador de Spritesheets 2H (Postura 1: Empunhadura Central Dupla)
Exiled Kingdoms Overhaul

Arquitetura "Anatomical Slice-Shift + Head-Delta Walk Tracking" V8 (Cobertura Universal 100%):
1. Todos os 50 corpos compostos masculinos e femininos (`mods/data/sprites/composite/*_2h.png`),
   incluindo roupas base (`clothes`, `naked`, `shorts`, `varannari`), túnicas de mago e armaduras.
2. Todas as 12 armas de duas mãos compostas (`zweihander`, `greatsword`, `battleaxe`, `maul`,
   `staff`, `greatstaff` — masculino e feminino).
3. Todos os 3 corpos de NPCs/Chefes standalone (`mods/data/sprites/male_tunic_blue_2h.png`,
   `male_tunic_red_2h.png`, `vampire_2h.png`) que empunham armas compostas de 2 mãos em `bestiary.txt`.
"""

import io
import os
import zipfile
import numpy as np
from PIL import Image

JAR_PATH = "/home/yhn/.local/share/Steam/steamapps/common/Exiled Kingdoms/exiledkingdoms.jar"
MOD_SPRITES_DIR = "/home/yhn/Projetos/exiled-kingdoms-mod/mods/data/sprites"
MOD_COMPOSITE_DIR = os.path.join(MOD_SPRITES_DIR, "composite")

MALE_BODIES = [
    "male_clothes",
    "male_clothesblack",
    "male_clothesblue",
    "male_clothesred",
    "male_leather",
    "male_mail",
    "male_naked",
    "male_plate",
    "male_shorts",
    "male_tunic",
    "male_tunic_blue",
    "male_tunic_green",
    "male_tunic_purple",
    "male_tunic_red",
    "male_tunic_white",
    "male_varannari",
    # Mod custom armors
    "male_leather_green",
    "male_mail_blue",
    "male_mail_forest",
    "male_mail_red",
    "male_plate_black",
    "male_plate_blue",
    "male_plate_epic",
    "male_plate_gold",
]

FEMALE_BODIES = [
    "female_clothes",
    "female_clothesblue",
    "female_clothespurple",
    "female_clothesred",
    "female_clotheswhite",
    "female_clothesyellow",
    "female_leather",
    "female_mail",
    "female_naked",
    "female_plate",
    "female_shorts",
    "female_tunic",
    "female_tunic_blue",
    "female_tunic_green",
    "female_tunic_purple",
    "female_tunic_red",
    "female_tunic_white",
    "female_varannari",
    # Mod custom armors
    "female_leather_green",
    "female_mail_blue",
    "female_mail_forest",
    "female_mail_red",
    "female_plate_black",
    "female_plate_blue",
    "female_plate_epic",
    "female_plate_gold",
]

STANDALONE_NPC_BODIES = [
    "male_tunic_blue",
    "male_tunic_red",
    "vampire",
]

WEAPONS_2H = [
    "zweihander",
    "greatsword",
    "battleaxe",
    "maul",
    "greatstaff",
    "staff",
]

MALE_WEP_SHIFTS = {0: (-5, 0), 1: (0, 0), 2: (3, 0), 3: (8, 0), 4: (6, 1)}
FEMALE_WEP_SHIFTS = {0: (-6, 0), 1: (0, -1), 2: (1, -1), 3: (8, 0), 4: (6, 0)}


def shift_cell(cell, dx, dy):
    out = np.zeros_like(cell)
    h, w = cell.shape[:2]
    src_x0 = max(0, -dx)
    src_x1 = min(w, w - dx)
    src_y0 = max(0, -dy)
    src_y1 = min(h, h - dy)
    out[src_y0 + dy : src_y1 + dy, src_x0 + dx : src_x1 + dx] = cell[src_y0:src_y1, src_x0:src_x1]
    return out


def compute_head_deltas(zf, head_entry):
    head = np.array(Image.open(io.BytesIO(zf.read(head_entry))).convert("RGBA"))
    deltas = {}
    for r in range(5):
        h0 = head[r * 140 : (r + 1) * 140, 0:140]
        ys0, xs0 = np.where((h0[:, :, 3] > 100) & ((h0[:, :, 0] > 20) | (h0[:, :, 1] > 20) | (h0[:, :, 2] > 20)))
        hx0, hy0 = xs0.mean(), ys0.mean()
        deltas[r] = [(0, 0)]
        for c in range(1, 9):
            hc = head[r * 140 : (r + 1) * 140, c * 140 : (c + 1) * 140]
            ysc, xsc = np.where((hc[:, :, 3] > 100) & ((hc[:, :, 0] > 20) | (hc[:, :, 1] > 20) | (hc[:, :, 2] > 20)))
            dx = int(round(xsc.mean() - hx0))
            dy = int(round(ysc.mean() - hy0))
            deltas[r].append((dx, dy))
    return deltas


def make_male_idle_2h_cell(cell, row):
    out = cell.copy()
    if row == 0:  # NW / North (Costas)
        for y in range(91, 99):
            erase_x1 = 62 if y <= 94 else 64
            out[y, 52:erase_x1] = 0
        for y in range(94, 106):
            row_px = cell[y].copy()
            out[y, 73:88] = 0
            dx_r = 1 if y <= 95 else (2 if y <= 97 else 3)
            for x in range(73, 86):
                if row_px[x, 3] > 0:
                    out[y, x - dx_r] = row_px[x]
        for y in range(98, 106):
            target_x = 70 + (y - 98) // 2
            for dx in range(6):
                src_y = min(103, 98 + (y - 98))
                src_p = cell[src_y, 76 + dx]
                if src_p[3] > 0:
                    out[y, target_x + dx] = src_p
    elif row == 1:  # NE
        out[91:99, 75:82] = 0
        for y in range(96, 105):
            dy = y - 96
            out[y, 70:75] = cell[min(106, 98 + dy // 2), 66:71]
    elif row == 2:  # East
        out[91:103, 74:86] = 0
        for y in range(96, 108):
            dy = y - 96
            out[y, 66:71] = cell[min(108, 97 + dy), 61:66]
    elif row == 3:  # SW (Diagonal Frontal-Esquerda e Paperdoll do Inventário)
        for y in range(94, 107):
            dx_r = min(5, 1 + (y - 94) // 2)
            row_px = cell[y].copy()
            out[y, 50:61] = 0
            for x in range(52, 60):
                if row_px[x, 3] > 0:
                    out[y, x + dx_r] = row_px[x]
        for y in range(94, 106):
            row_px = cell[y].copy()
            erase_x0 = 75 if y <= 101 else 77
            out[y, erase_x0:85] = 0
            dx_l = min(11, 2 + int((y - 94) * 1.0))
            for src_x in range(74, 82):
                if row_px[src_x, 3] > 0:
                    dst_x = src_x - dx_l
                    if 63 <= dst_x <= 76:
                        out[y, dst_x] = row_px[src_x]
        for y in range(100, 105):
            for dx in range(4):
                src_p = cell[y - 1, 77 + dx]
                if src_p[3] > 0:
                    out[y, 63 + dx] = src_p
    elif row == 4:  # South (Frontal)
        for y in range(93, 101):
            dx_r = min(4, 1 + (y - 93) // 2)
            row_px = cell[y].copy()
            out[y, 50:61] = 0
            for x in range(52, 60):
                if row_px[x, 3] > 0:
                    out[y, x + dx_r] = row_px[x]
        for y in range(96, 103):
            erase_x0 = 75 if y <= 97 else 74
            out[y, erase_x0:82] = 0
            target_x = 70 - int((y - 96) * 1.3)
            for dx in range(5):
                src_y = min(100, y)
                src_p = cell[src_y, 73 + dx]
                if src_p[3] > 0:
                    out[y, target_x + dx] = src_p
    return out


def make_female_idle_2h_cell(cell, row):
    out = cell.copy()
    if row == 0:  # NW / North (Costas)
        for y in range(93, 104):
            out[y, 54:64] = 0
        for y in range(95, 106):
            row_px = cell[y].copy()
            out[y, 73:88] = 0
            dx_r = 1 if y <= 96 else (2 if y <= 98 else 3)
            for x in range(73, 86):
                if row_px[x, 3] > 0:
                    out[y, x - dx_r] = row_px[x]
        for y in range(99, 106):
            target_x = 69 + (y - 99) // 2
            for dx in range(5):
                src_y = min(103, 98 + (y - 99))
                src_p = cell[src_y, 75 + dx]
                if src_p[3] > 0:
                    out[y, target_x + dx] = src_p
    elif row == 1:  # NE
        out[91:99, 73:80] = 0
        for y in range(96, 105):
            dy = y - 96
            out[y, 70:74] = cell[min(106, 98 + dy // 2), 67:71]
    elif row == 2:  # East
        out[98:103, 75:82] = 0
        for y in range(96, 106):
            dy = y - 96
            out[y, 67:71] = cell[min(106, 96 + dy), 63:67]
    elif row == 3:  # SW (Diagonal Frontal-Esquerda e Paperdoll)
        for y in range(94, 106):
            dx_r = min(4, 1 + (y - 94) // 2)
            row_px = cell[y].copy()
            out[y, 55:64] = 0
            for x in range(56, 63):
                if row_px[x, 3] > 0:
                    out[y, x + dx_r] = row_px[x]
        for y in range(95, 106):
            row_px = cell[y].copy()
            erase_x0 = 76 if y <= 101 else 78
            out[y, erase_x0:85] = 0
            dx_l = min(10, 2 + int((y - 95) * 1.0))
            for src_x in range(74, 82):
                if row_px[src_x, 3] > 0:
                    dst_x = src_x - dx_l
                    if 64 <= dst_x <= 75:
                        out[y, dst_x] = row_px[src_x]
        for y in range(100, 105):
            for dx in range(4):
                src_p = cell[y - 1, 76 + dx]
                if src_p[3] > 0:
                    out[y, 64 + dx] = src_p
    elif row == 4:  # South (Frontal)
        for y in range(93, 102):
            dx_r = min(4, 1 + (y - 93) // 2)
            row_px = cell[y].copy()
            out[y, 55:64] = 0
            for x in range(56, 63):
                if row_px[x, 3] > 0:
                    out[y, x + dx_r] = row_px[x]
        for y in range(96, 109):
            if y <= 98:
                erase_x0 = 75
            elif y <= 102:
                erase_x0 = 74
            else:
                erase_x0 = 76
            out[y, erase_x0:84] = 0
            if y <= 103:
                target_x = 70 - int((y - 96) * 1.2)
                for dx in range(5):
                    src_y = min(102, y)
                    src_p = cell[src_y, 73 + dx]
                    if src_p[3] > 0:
                        out[y, target_x + dx] = src_p
    return out


def make_attack_2h_cell(cell, row, col):
    out = cell.copy()
    if row == 5:  # NW (Back)
        if col == 0:
            out[86:104, 48:63] = 0
        elif col == 1:
            out[86:106, 48:63] = 0
        elif col == 2:
            out[88:104, 54:62] = 0
    elif row == 6:  # NE
        if col == 1:
            out[88:104, 54:67] = 0
        elif col == 2:
            out[88:105, 52:68] = 0
        elif col == 3:
            out[88:103, 55:67] = 0
    elif row == 7:  # East
        if col == 2:
            out[90:101, 58:68] = 0
            for y in range(95, 102):
                out[y, 75:82] = cell[y, 70:77]
        elif col == 3:
            out[90:101, 56:68] = 0
            for y in range(96, 104):
                out[y, 74:81] = cell[y, 69:76]
    elif row == 8:  # SW
        if col == 0:
            out[91:107, 76:90] = 0
            for y in range(86, 94):
                out[y, 67:75] = cell[y + 6, 74:82]
        elif col == 1:
            out[91:106, 77:90] = 0
            for y in range(88, 96):
                out[y, 71:79] = cell[y + 3, 76:84]
        elif col == 3:
            out[89:98, 58:68] = 0
    elif row == 9:  # South
        if col == 0:
            out[91:110, 74:88] = 0
            for y in range(85, 95):
                out[y, 61:69] = cell[y + 8, 73:81]
        elif col == 1:
            out[91:110, 75:90] = 0
            for y in range(87, 97):
                out[y, 60:68] = cell[y + 6, 73:81]
        elif col == 2:
            out[94:103, 75:85] = 0
    return out


def splice_walk_cell(walk_cell, idle_2h, r, dx, dy):
    out = walk_cell.copy()
    y_split = 104 + dy
    if r == 2:
        out[y_split:108, 74:90] = 0
        su = shift_cell(idle_2h, dx, dy)
        out[:98, :] = su[:98, :]
        out[98:y_split, 58:] = su[98:y_split, 58:]
    elif r == 0:
        out[y_split:109, 52:63] = 0
        out[y_split:109, 74:90] = 0
        su = shift_cell(idle_2h, dx, dy)
        out[:y_split, :] = su[:y_split, :]
    else:
        if r == 3:
            out[y_split:110, 74:90] = 0
            out[y_split:107, 44:56] = 0
        elif r == 4:
            out[y_split:110, 74:86] = 0
            out[y_split:107, 48:58] = 0
        elif r == 1:
            out[y_split:108, 74:86] = 0
        su = shift_cell(idle_2h, dx, dy)
        out[:y_split, :] = su[:y_split, :]
    return out


def build_body_2h_sheet(sheet, head_deltas, is_female=False):
    out = sheet.copy()
    make_idle = make_female_idle_2h_cell if is_female else make_male_idle_2h_cell

    for r in range(5):
        idle_cell = sheet[r * 140 : (r + 1) * 140, 0:140]
        idle_2h = make_idle(idle_cell, r)
        out[r * 140 : (r + 1) * 140, 0:140] = idle_2h

        for c in range(1, 9):
            walk_cell = sheet[r * 140 : (r + 1) * 140, c * 140 : (c + 1) * 140]
            dx, dy = head_deltas[r][c]
            out[r * 140 : (r + 1) * 140, c * 140 : (c + 1) * 140] = splice_walk_cell(
                walk_cell, idle_2h, r, dx, dy
            )

    for r in range(5, 10):
        for c in range(4):
            atk_cell = sheet[r * 140 : (r + 1) * 140, c * 140 : (c + 1) * 140]
            out[r * 140 : (r + 1) * 140, c * 140 : (c + 1) * 140] = make_attack_2h_cell(atk_cell, r, c)

    return out


def build_weapon_2h_sheet(sheet, male_sheet, head_deltas, is_female=False):
    out = sheet.copy()
    wep_shifts = FEMALE_WEP_SHIFTS if is_female else MALE_WEP_SHIFTS
    base_idle_source = male_sheet if is_female else sheet

    for r in range(5):
        idle_w = base_idle_source[r * 140 : (r + 1) * 140, 0:140]
        dx_base, dy_base = wep_shifts[r]
        idle_w_2h = shift_cell(idle_w, dx_base, dy_base)
        out[r * 140 : (r + 1) * 140, 0:140] = idle_w_2h

        for c in range(1, 9):
            dx, dy = head_deltas[r][c]
            out[r * 140 : (r + 1) * 140, c * 140 : (c + 1) * 140] = shift_cell(idle_w_2h, dx, dy)

    return out


def load_sprite(zf, name):
    mod_path = os.path.join(MOD_COMPOSITE_DIR, f"{name}.png")
    if os.path.exists(mod_path):
        return np.array(Image.open(mod_path).convert("RGBA"))
    jar_entry = f"data/sprites/composite/{name}.png"
    return np.array(Image.open(io.BytesIO(zf.read(jar_entry))).convert("RGBA"))


def main():
    os.makedirs(MOD_COMPOSITE_DIR, exist_ok=True)
    zf = zipfile.ZipFile(JAR_PATH, "r")

    male_deltas = compute_head_deltas(zf, "data/sprites/composite/male_head.png")
    female_deltas = compute_head_deltas(zf, "data/sprites/composite/female_head3.png")

    count = 0
    for body_name in MALE_BODIES:
        sheet = load_sprite(zf, body_name)
        out_sheet = build_body_2h_sheet(sheet, male_deltas, is_female=False)
        out_path = os.path.join(MOD_COMPOSITE_DIR, f"{body_name}_2h.png")
        Image.fromarray(out_sheet).save(out_path, optimize=True)
        count += 1

    for body_name in FEMALE_BODIES:
        sheet = load_sprite(zf, body_name)
        out_sheet = build_body_2h_sheet(sheet, female_deltas, is_female=True)
        out_path = os.path.join(MOD_COMPOSITE_DIR, f"{body_name}_2h.png")
        Image.fromarray(out_sheet).save(out_path, optimize=True)
        count += 1

    for npc_body in STANDALONE_NPC_BODIES:
        jar_entry = f"data/sprites/{npc_body}.png"
        sheet = np.array(Image.open(io.BytesIO(zf.read(jar_entry))).convert("RGBA"))
        out_sheet = build_body_2h_sheet(sheet, male_deltas, is_female=False)
        out_path = os.path.join(MOD_SPRITES_DIR, f"{npc_body}_2h.png")
        Image.fromarray(out_sheet).save(out_path, optimize=True)
        count += 1

    for wep in WEAPONS_2H:
        male_sheet = load_sprite(zf, f"male_mainhand_{wep}")
        for prefix, is_fem, deltas in [
            ("male_mainhand_", False, male_deltas),
            ("female_mainhand_", True, female_deltas),
        ]:
            full_name = f"{prefix}{wep}"
            sheet = load_sprite(zf, full_name)
            out_sheet = build_weapon_2h_sheet(sheet, male_sheet, deltas, is_female=is_fem)
            out_path = os.path.join(MOD_COMPOSITE_DIR, f"{full_name}_2h.png")
            Image.fromarray(out_sheet).save(out_path, optimize=True)
            count += 1

    print(f"[OK] Gerados {count} spritesheets _2h.png (V8 Universal: 50 corpos + 3 NPCs + 12 armas)")


if __name__ == "__main__":
    main()
