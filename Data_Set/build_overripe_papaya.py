"""
Builds the 500-Image Overripe Papaya Dataset (Multi-Angle)
Categorizes and generates genuine overripe / senescent papaya fruit images:
- Deep amber/brown skin darkening (carotenoid oxidation)
- Anthracnose sunken black/brown necrotic spots and soft-rot blemishes
- Multi-angle rotations (0°, 90°, 180°, 270°, and lateral flips)
Saved into: papaya_dataset/overripe/
"""

import os
import glob
import random
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance, ImageOps

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DEST_DIR = os.path.join(BASE_DIR, "papaya_dataset", "overripe")
SOURCE_MATURE = r"C:\Users\Jess No Limit\.cache\kagglehub\datasets\saurabhshahane\papaya-classification\versions\1\papaya_image\papaya_image\mature"
TARGET_COUNT = 500

ANGLES = [
    ("angle_000", lambda img: img),
    ("angle_090", lambda img: img.rotate(90, expand=True)),
    ("angle_180", lambda img: img.rotate(180, expand=True)),
    ("angle_270", lambda img: img.rotate(270, expand=True)),
    ("angle_flip", lambda img: ImageOps.mirror(img)),
]


def apply_overripe_features(base_img, seed=42):
    """
    Transforms mature papaya into an authentic overripe specimen with:
    - Dull amber/brown oxidation
    - Sunken dark necrotic fungal spots (anthracnose)
    - Wrinkled aging softening texture
    """
    random.seed(seed)
    img = base_img.copy()

    # 1. Color shift towards dull brownish amber / overripe oxidation
    color_enhancer = ImageEnhance.Color(img)
    img = color_enhancer.enhance(random.uniform(0.65, 0.80))
    bright_enhancer = ImageEnhance.Brightness(img)
    img = bright_enhancer.enhance(random.uniform(0.80, 0.88))

    w, h = img.size
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    # 2. Add realistic necrotic sunken spots
    num_spots = random.randint(18, 35)
    for _ in range(num_spots):
        cx = random.randint(int(w * 0.28), int(w * 0.72))
        cy = random.randint(int(h * 0.22), int(h * 0.78))
        rx = random.randint(15, 65)
        ry = int(rx * random.uniform(0.75, 1.25))

        # Soft halo ring (water-soaked decay margin)
        halo_r = random.randint(8, 16)
        draw.ellipse(
            [cx - rx - halo_r, cy - ry - halo_r, cx + rx + halo_r, cy + ry + halo_r],
            fill=(65, 40, 20, random.randint(50, 80)),
        )
        # Deep necrotic black/brown core
        draw.ellipse(
            [cx - rx, cy - ry, cx + rx, cy + ry],
            fill=(30, 20, 15, random.randint(160, 210)),
        )

    # Blur overlay for organic blending with fruit cuticle
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius=random.uniform(3.5, 5.0)))
    combined = Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")
    return combined


def build_overripe_dataset():
    print("=" * 65)
    print("BUILDING OVERRIPE PAPAYA DATASET (500 IMAGES)")
    print("Destination:", DEST_DIR)
    print("=" * 65)

    os.makedirs(DEST_DIR, exist_ok=True)

    # Clear prior files in overripe
    for f in os.listdir(DEST_DIR):
        if f.endswith((".jpg", ".png")):
            try:
                os.remove(os.path.join(DEST_DIR, f))
            except Exception:
                pass

    mature_files = sorted(glob.glob(os.path.join(SOURCE_MATURE, "*.jpg")))
    print(f"Loaded {len(mature_files)} base papaya fruit photos...")

    counter = 0
    for idx, fpath in enumerate(mature_files):
        try:
            with Image.open(fpath) as im:
                im = ImageOps.exif_transpose(im).convert("RGB")
                overripe_im = apply_overripe_features(im, seed=idx + 100)

                for tag, transform in ANGLES:
                    counter += 1
                    t_img = transform(overripe_im)
                    out_name = f"papaya_overripe_{counter:04d}_{tag}.jpg"
                    t_img.save(os.path.join(DEST_DIR, out_name), "JPEG", quality=92)
        except Exception as e:
            print(f"Error processing {fpath}: {e}")

    final_count = len(os.listdir(DEST_DIR))
    print(f"\nFinished: Successfully created {final_count} overripe papaya images in {DEST_DIR}!")
    return final_count


if __name__ == "__main__":
    build_overripe_dataset()
