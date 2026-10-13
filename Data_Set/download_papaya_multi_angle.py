"""
Papaya Ripeness Dataset Downloader (Multi-Angle Edition)
Fast parallel downloader for:
- unripe (500 images)
- ripening (500 images)
- ripe (500 images)
"""

import os
import re
import sys
import time
import hashlib
import urllib.parse
from concurrent.futures import ThreadPoolExecutor, as_completed
from PIL import Image, ImageOps
import requests

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATASET_DIR = os.path.join(BASE_DIR, "papaya_dataset")
TARGET_COUNT = 500

CATEGORIES = {
    "unripe": [
        "unripe green papaya side view",
        "raw green papaya horizontal profile",
        "green unripe papaya top down aerial view",
        "unripe papaya 45 degree angle perspective",
        "green papaya hanging on tree close up angle",
        "pepaya muda mentah tampak samping",
        "raw green papaya isolated white background",
        "fresh unripe green papaya on table",
        "unripe papaya harvest crate",
        "green papaya stem end view",
    ],
    "ripening": [
        "semi ripe papaya side view turning yellow",
        "partially ripe papaya side profile yellow green",
        "half ripe papaya top down view flat surface",
        "ripening papaya fruit overhead angle",
        "semi ripe papaya 45 degree perspective",
        "partially ripe papaya tilted angle isolated",
        "ripening papaya fruit hanging tree angle",
        "pepaya mengkal tampak samping setengah matang",
        "semi ripe papaya fruit market crate",
        "ripening papaya blossom end view",
    ],
    "ripe": [
        "fully ripe papaya fruit side view isolated",
        "ripe yellow orange papaya horizontal profile",
        "ripe papaya top down view wooden table",
        "ripe golden papaya overhead view flat lay",
        "ripe papaya fruit 45 degree angle studio shot",
        "ripe yellow papaya tilted perspective view",
        "ripe papaya hanging on tree angled shot",
        "pepaya matang kuning tampak samping",
        "ripe papaya fruit whole white background",
        "sweet ripe papaya fresh harvest crate",
    ],
}

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    )
}


def fetch_image_urls(query, max_count=80):
    urls = []
    base_url = "https://www.bing.com/images/async"
    offset = 0

    while len(urls) < max_count and offset < 250:
        params = {
            "q": query,
            "first": offset,
            "count": 50,
            "adlt": "off",
            "qft": "+filterui:photo-photo",
        }
        try:
            r = requests.get(base_url, params=params, headers=HEADERS, timeout=8)
            if r.status_code != 200:
                break
            matches = re.findall(r'murl&quot;:&quot;(http[^&]+?)&quot;', r.text)
            if not matches:
                matches = re.findall(r'"murl":"(http[^"]+?)"', r.text)
            if not matches:
                break

            added = 0
            for u in matches:
                cu = urllib.parse.unquote(u)
                if cu not in urls:
                    urls.append(cu)
                    added += 1
            if added == 0:
                break
            offset += 50
        except Exception:
            break
    return urls


def download_single_image(url, save_path, seen_hashes):
    try:
        resp = requests.get(url, headers=HEADERS, timeout=6, stream=True)
        if resp.status_code != 200:
            return False
        content = resp.content
        if len(content) < 4000:
            return False

        h = hashlib.md5(content).hexdigest()
        if h in seen_hashes:
            return False

        import io
        img = Image.open(io.BytesIO(content))
        img = ImageOps.exif_transpose(img)
        img = img.convert("RGB")
        w, h_px = img.size
        if w < 100 or h_px < 100:
            return False

        img.save(save_path, "JPEG", quality=90)
        seen_hashes.add(h)
        return True
    except Exception:
        return False


def run_download():
    os.makedirs(DATASET_DIR, exist_ok=True)
    print("=" * 65)
    print("STARTING PAPAYA RIPENESS DATASET DOWNLOAD")
    print(f"Target: {TARGET_COUNT} images per category into '{DATASET_DIR}'")
    print("=" * 65)

    for category, queries in CATEGORIES.items():
        cat_dir = os.path.join(DATASET_DIR, category)
        os.makedirs(cat_dir, exist_ok=True)

        existing = [f for f in os.listdir(cat_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
        count = len(existing)
        seen_hashes = set()
        for f in existing:
            try:
                with open(os.path.join(cat_dir, f), "rb") as fp:
                    seen_hashes.add(hashlib.md5(fp.read()).hexdigest())
            except Exception:
                pass

        print(f"\n--> Class: '{category.upper()}' | Current count: {count}/{TARGET_COUNT}")
        if count >= TARGET_COUNT:
            print(f"    Already reached target for {category}!")
            continue

        # Gather URLs across diverse queries
        candidate_urls = []
        with ThreadPoolExecutor(max_workers=5) as query_executor:
            futures = [query_executor.submit(fetch_image_urls, q, 70) for q in queries]
            for f in as_completed(futures):
                try:
                    for u in f.result():
                        if u not in candidate_urls:
                            candidate_urls.append(u)
                except Exception:
                    pass

        print(f"    Found {len(candidate_urls)} candidate image URLs across all angles.")

        # Download images in parallel
        with ThreadPoolExecutor(max_workers=16) as dl_executor:
            dl_futures = []
            for u in candidate_urls:
                if count >= TARGET_COUNT:
                    break
                count += 1
                out_path = os.path.join(cat_dir, f"papaya_{category}_{count:04d}.jpg")
                dl_futures.append(dl_executor.submit(download_single_image, u, out_path, seen_hashes))

            saved = len([f for f in os.listdir(cat_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))])
            for f in as_completed(dl_futures):
                try:
                    if f.result():
                        saved += 1
                        sys.stdout.write(f"\r    [{category.upper()}] Downloaded & validated: {saved}/{TARGET_COUNT}")
                        sys.stdout.flush()
                        if saved >= TARGET_COUNT:
                            break
                except Exception:
                    pass

        final_count = len([f for f in os.listdir(cat_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))])
        print(f"\n    Finished {category}: {final_count} images in {cat_dir}")

    print("\n" + "=" * 65)
    print("DOWNLOAD COMPLETE!")
    for cat in CATEGORIES:
        p = os.path.join(DATASET_DIR, cat)
        c = len(os.listdir(p)) if os.path.exists(p) else 0
        print(f"  • {cat}: {c} images")
    print(f"Images are saved in: {DATASET_DIR}")
    print("=" * 65)


if __name__ == "__main__":
    run_download()
