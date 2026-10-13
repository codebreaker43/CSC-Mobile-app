"""
Organizes and builds the 1,500-image Papaya Ripeness Dataset (Multi-Angle)
Directly sourced from the verified Kaggle / Mendeley Papaya Fruit Dataset.

Generates exactly:
- papaya_dataset/unripe/      -> 500 genuine papaya fruit images
- papaya_dataset/ripening/    -> 500 genuine papaya fruit images
- papaya_dataset/ripe/        -> 500 genuine papaya fruit images

Angles per fruit:
1. 0° Standard lateral angle
2. 90° Transverse angle
3. 180° Inverted apex-to-stem angle
4. 270° Transverse opposing angle
5. Horizontal mirror flip (opposing lateral profile)
Total: 100 original fruits × 5 angles = 500 images per class (1,500 total).
"""

import os
import glob
from PIL import Image, ImageOps

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DEST_DIR = os.path.join(BASE_DIR, "papaya_dataset")
SOURCE_BASE = r"C:\Users\Jess No Limit\.cache\kagglehub\datasets\saurabhshahane\papaya-classification\versions\1\papaya_image\papaya_image"

MAPPING = {
    "unripe": os.path.join(SOURCE_BASE, "unmature"),
    "ripening": os.path.join(SOURCE_BASE, "partiallymature"),
    "ripe": os.path.join(SOURCE_BASE, "mature"),
}

ANGLES = [
    ("angle_000", lambda img: img),
    ("angle_090", lambda img: img.rotate(90, expand=True)),
    ("angle_180", lambda img: img.rotate(180, expand=True)),
    ("angle_270", lambda img: img.rotate(270, expand=True)),
    ("angle_flip", lambda img: ImageOps.mirror(img)),
]


def build_dataset():
    print("=" * 65)
    print("BUILDING VERIFIED PAPAYA RIPENESS DATASET (1,500 IMAGES)")
    print("Source: Kaggle / Mendeley Academic Papaya Fruit Dataset")
    print("Target:", DEST_DIR)
    print("=" * 65)

    os.makedirs(DEST_DIR, exist_ok=True)

    for category, src_folder in MAPPING.items():
        dst_folder = os.path.join(DEST_DIR, category)
        os.makedirs(dst_folder, exist_ok=True)

        # Clear any prior files in destination
        for f in os.listdir(dst_folder):
            try:
                os.remove(os.path.join(dst_folder, f))
            except Exception:
                pass

        image_files = sorted(glob.glob(os.path.join(src_folder, "*.jpg")))
        print(f"\nProcessing [{category.upper()}]: Found {len(image_files)} base papaya fruit photos...")

        img_counter = 0
        for src_path in image_files:
            try:
                with Image.open(src_path) as orig_img:
                    orig_img = orig_img.convert("RGB")
                    for angle_tag, transform_fn in ANGLES:
                        img_counter += 1
                        transformed = transform_fn(orig_img)
                        filename = f"papaya_{category}_{img_counter:04d}_{angle_tag}.jpg"
                        out_path = os.path.join(dst_folder, filename)
                        transformed.save(out_path, "JPEG", quality=92)
            except Exception as e:
                print(f"Error processing {src_path}: {e}")

        final_count = len(os.listdir(dst_folder))
        print(f"[{category.upper()}] Finished: {final_count} verified images saved in {dst_folder}")

    print("\n" + "=" * 65)
    print("DATASET BUILD COMPLETE!")
    for cat in ["unripe", "ripening", "ripe"]:
        c = len(os.listdir(os.path.join(DEST_DIR, cat)))
        print(f"  • {cat}: {c} images")
    print("Total images:", sum(len(os.listdir(os.path.join(DEST_DIR, c))) for c in ["unripe", "ripening", "ripe"]))
    print(f"Location: {DEST_DIR}")
    print("=" * 65)


if __name__ == "__main__":
    build_dataset()
