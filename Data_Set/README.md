# Papaya Fruit Ripeness & Maturity Dataset (4 Classes, Multi-Angle)

A complete, balanced computer vision classification dataset containing **2,000 images** across the four postharvest maturity stages of Papaya fruit (*Carica papaya*):

```
papaya_dataset/
├── unripe/       # 500 images (vibrant green, firm raw papaya across 360° rotations & 3D tilt angles)
├── ripening/     # 500 images (transitioning yellow-green color breaks, partially mature)
├── ripe/         # 500 images (golden yellow/orange skin, fully mature fruit)
└── overripe/     # 500 images (deep amber/brown skin, anthracnose sunken dark spots, softening decay)
```

---

## Dataset Summary

| Maturity Stage | Count | Visual Characteristics | Typical Usage |
| :--- | :--- | :--- | :--- |
| **Unripe (Mentah)** | 500 | 100% solid vibrant green, very hard, no yellow breaks | Cooking (salads, stews), long-distance transport |
| **Ripening (Mengkal)** | 500 | Yellow streaks emerging along ribs from blossom end (25%–50% yellow) | Market shelf stocking, ripening chambers |
| **Ripe (Matang)** | 500 | Uniform golden-yellow to orange peel, soft to gentle touch | Ready for fresh consumption / retail |
| **Overripe (Terlalu Matang)**| 500 | Deep amber/brown skin, circular sunken necrotic rot spots, soft collapse | Quality inspection rejection, processing / waste sorting |

- **Total Images**: **2,000 images** (perfectly balanced 500 per class).
- **Format**: RGB JPEG (`.jpg`).
- **Angle Invariance**: Each class includes multi-angle rotations (0°, 90°, 180°, 270°), lateral face flips, and perspective viewing variations.

---

## Scripts in this Workspace

- [`generate_custom_papaya_angles.py`](file:///c:/Users/Jess%20No%20Limit/Desktop/Data%20Set/generate_custom_papaya_angles.py): Generates multi-angle rotations and 3D perspective tilts for clean reference fruit.
- [`organize_papaya_dataset.py`](file:///c:/Users/Jess%20No%20Limit/Desktop/Data%20Set/organize_papaya_dataset.py): Organizes and balances classes from academic benchmarks.
- [`build_overripe_papaya.py`](file:///c:/Users/Jess%20No%20Limit/Desktop/Data%20Set/build_overripe_papaya.py): Builds the 500-image multi-angle overripe senescence dataset.
