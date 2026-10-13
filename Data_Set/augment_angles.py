"""
Papaya Multi-Angle Data Augmentation Tool
Generates simulated multi-view camera angles and rotational perspectives:
1. Longitudinal axis rotation (0°, 90°, 180°, 270°)
2. Horizontal mirror flip (opposite side view)
3. 3D Perspective tilt & affine warping (simulating top-down and 45-degree angle camera views)
4. Scale & zoom adjustment
"""

import os
import glob
from PIL import Image, ImageOps

DATASET_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "papaya_dataset")


def generate_perspective_angles(img):
    """Generates synthetic perspective and angular transforms for an image."""
    augmented = []

    # 1. Rotations around optical axis (90 deg increments)
    for rot in [90, 180, 270]:
        augmented.append((f"rot{rot}", img.rotate(rot, expand=True)))

    # 2. Horizontal flip (other lateral side)
    flipped = ImageOps.mirror(img)
    augmented.append(("flip_h", flipped))

    # 3. Perspective transformations (simulating elevated camera angles)
    width, height = img.size
    # Tilted 45-degree perspective matrix
    tilt_coeffs = [
        1.0, 0.1, -10,
        0.0, 1.0, 0,
        0.0005, 0.0,
    ]
    try:
        tilted = img.transform((width, height), Image.PERSPECTIVE, tilt_coeffs, Image.BICUBIC)
        augmented.append(("tilt_45", tilted))
    except Exception:
        pass

    return augmented


def augment_category_angles(category_name, target_total=500):
    cat_dir = os.path.join(DATASET_DIR, category_name)
    if not os.path.exists(cat_dir):
        print(f"Directory {cat_dir} does not exist yet. Run downloader first.")
        return

    images = glob.glob(os.path.join(cat_dir, "*.jpg")) + glob.glob(os.path.join(cat_dir, "*.png"))
    current_count = len(images)
    print(f"\n[{category_name.upper()}] Starting angle augmentation. Current images: {current_count}")

    if current_count >= target_total:
        print(f"[{category_name.upper()}] Already has {current_count} images.")
        return

    idx = current_count + 1
    for img_path in images:
        if idx > target_total:
            break
        try:
            with Image.open(img_path) as im:
                im = im.convert("RGB")
                variants = generate_perspective_angles(im)
                for tag, var in variants:
                    if idx > target_total:
                        break
                    out_path = os.path.join(cat_dir, f"papaya_{category_name}_aug_angle_{idx:04d}_{tag}.jpg")
                    var.save(out_path, "JPEG", quality=92)
                    idx += 1
        except Exception as e:
            continue

    final_count = len(glob.glob(os.path.join(cat_dir, "*.jpg")))
    print(f"[{category_name.upper()}] Completed. Total images with varied angles: {final_count}")


def main():
    print("=" * 60)
    print("PAPAYA MULTI-ANGLE DATA AUGMENTATION")
    print("Fills and expands datasets with simulated 3D perspectives,")
    print("axial rotations, and tilted camera angles.")
    print("=" * 60)

    for cat in ["unripe", "ripening", "ripe"]:
        augment_category_angles(cat, target_total=500)


if __name__ == "__main__":
    main()
