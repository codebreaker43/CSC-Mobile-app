"""
Papaya Ripeness Dataset Downloader
Downloads 500 images each for:
- Unripe Papaya
- Ripening (Partially Ripe) Papaya
- Ripe Papaya
Total: 1,500 images organized by category.
"""

import os
import re
import sys
import time
import hashlib
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from PIL import Image
import requests

DATASET_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "papaya_dataset")
TARGET_COUNT_PER_CLASS = 500

CATEGORIES = {
    "unripe": [
        "raw green papaya fruit on tree",
        "unripe green papaya whole",
        "pepaya muda mentah",
        "green papaya fruit harvest",
        "fresh unripe green papaya",
        "betik muda hijau",
        "immature green papaya fruit",
    ],
    "ripening": [
        "semi ripe papaya fruit yellow green",
        "partially ripe papaya turning yellow",
        "ripening papaya fruit tree",
        "half ripe papaya green and yellow",
        "pepaya mengkal setengah matang",
        "papaya ripening stage",
        "betik separuh masak",
    ],
    "ripe": [
        "ripe yellow orange papaya whole fruit",
        "fully ripe papaya fruit fresh",
        "pepaya matang kuning oranye",
        "sweet ripe papaya fresh harvest",
        "ripe solo papaya fruit",
        "betik masak ranum",
        "ripe red lady papaya fruit",
    ],
}

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    )
}


def search_bing_images(query, max_results=300):
    image_urls = []
    base_url = "https://www.bing.com/images/async"
    offset = 0

    while len(image_urls) < max_results and offset < 1000:
        params = {
            "q": query,
            "first": offset,
            "count": 100,
            "adlt": "off",
            "qft": "+filterui:photo-photo",
        }
        try:
            resp = requests.get(base_url, params=params, headers=HEADERS, timeout=12)
            if resp.status_code != 200:
                break

            matches = re.findall(r'murl&quot;:&quot;(http[^&]+?)&quot;', resp.text)
            if not matches:
                matches = re.findall(r'"murl":"(http[^"]+?)"', resp.text)

            if not matches:
                break

            new_found = 0
            for url in matches:
                clean_url = urllib.parse.unquote(url)
                if clean_url not in image_urls:
                    image_urls.append(clean_url)
                    new_found += 1

            if new_found == 0:
                break
            offset += 100
            time.sleep(0.3)
        except Exception:
            break

    return image_urls


def download_and_validate(url, save_path, seen_hashes):
    try:
        req = requests.get(url, headers=HEADERS, timeout=8, stream=True)
        if req.status_code != 200:
            return False

        content = req.content
        if len(content) < 5000:  # Skip tiny files / icons
            return False

        # Deduplication using MD5 hash
        img_hash = hashlib.md5(content).hexdigest()
        if img_hash in seen_hashes:
            return False

        # Verify image integrity with Pillow
        import io
        img = Image.open(io.BytesIO(content))
        img.verify()

        # Reopen to convert to RGB (standardizes format and discards corruption)
        img = Image.open(io.BytesIO(content))
        img = img.convert("RGB")
        width, height = img.size
        if width < 120 or height < 120:
            return False

        img.save(save_path, "JPEG", quality=90)
        seen_hashes.add(img_hash)
        return True
    except Exception:
        return False


def collect_images_for_category(category_name, queries, target_count=500):
    cat_dir = os.path.join(DATASET_DIR, category_name)
    os.makedirs(cat_dir, exist_ok=True)

    existing_files = [f for f in os.listdir(cat_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
    current_count = len(existing_files)

    seen_hashes = set()
    for f in existing_files:
        try:
            with open(os.path.join(cat_dir, f), "rb") as fp:
                seen_hashes.add(hashlib.md5(fp.read()).hexdigest())
        except Exception:
            pass

    print(f"\n[{category_name.upper()}] Starting download... Currently has {current_count}/{target_count} images.")

    if current_count >= target_count:
        print(f"[{category_name.upper()}] Target already reached ({current_count} images).")
        return current_count

    all_urls = []
    for query in queries:
        if len(all_urls) >= target_count * 3:
            break
        print(f"  Searching: '{query}'...")
        urls = search_bing_images(query, max_results=200)
        for u in urls:
            if u not in all_urls:
                all_urls.append(u)

    print(f"  Found {len(all_urls)} candidate image URLs. Commencing downloads...")

    with ThreadPoolExecutor(max_workers=8) as executor:
        futures = []
        for url in all_urls:
            if current_count >= target_count:
                break
            current_count += 1
            filename = f"papaya_{category_name}_{current_count:04d}.jpg"
            save_path = os.path.join(cat_dir, filename)
            futures.append(executor.submit(download_and_validate, url, save_path, seen_hashes))

        saved = 0
        for future in as_completed(futures):
            if future.result():
                saved += 1
                sys.stdout.write(f"\r  [{category_name.upper()}] Saved: {saved}/{target_count} valid images")
                sys.stdout.flush()
                if saved >= target_count:
                    break

    final_count = len([f for f in os.listdir(cat_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))])
    print(f"\n  Finished {category_name}: {final_count} images stored in {cat_dir}")
    return final_count


def main():
    print("=" * 60)
    print("Papaya Ripeness Dataset Downloader (500 per category)")
    print("Categories: Unripe | Ripening | Ripe")
    print("Destination:", DATASET_DIR)
    print("=" * 60)

    for category, queries in CATEGORIES.items():
        collect_images_for_category(category, queries, target_count=TARGET_COUNT_PER_CLASS)

    print("\n" + "=" * 60)
    print("Dataset build complete!")
    print(f"Directory: {DATASET_DIR}")
    for category in CATEGORIES:
        count = len(os.listdir(os.path.join(DATASET_DIR, category)))
        print(f"  - {category}: {count} images")
    print("=" * 60)


if __name__ == "__main__":
    main()
