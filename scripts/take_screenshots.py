#!/usr/bin/env python3
"""Take raw screenshots of the Sourdough app using Playwright.

Usage:
    python3 scripts/take_screenshots.py
"""

import subprocess, time, os, sys
from playwright.sync_api import sync_playwright

BASE_DIR = "/Users/peresola/code/personal/sourdough-flutter"
RAW_DIR = f"{BASE_DIR}/screenshots_raw"

# Device configs: viewport (logical px) + scale -> physical screenshot size
DEVICES = {
    "phone": {"viewport": {"width": 360, "height": 640}, "scale": 3},      # -> 1080x1920
    "tablet7": {"viewport": {"width": 720, "height": 1280}, "scale": 2},   # -> 1440x2560
    "tablet10": {"viewport": {"width": 900, "height": 1600}, "scale": 2},  # -> 1800x3200
}


def build_web():
    """Build Flutter web app."""
    cmd = ["flutter", "build", "web", "--release"]
    print("  Building for web...")
    result = subprocess.run(cmd, cwd=BASE_DIR, capture_output=True, text=True, timeout=120)
    if result.returncode != 0:
        print(f"  Build FAILED:\n{result.stderr[-500:]}")
        return False
    print("  Build OK")
    return True


def wait_for_app(page, timeout=15):
    """Wait for Flutter app to finish loading."""
    page.wait_for_load_state("networkidle")
    time.sleep(3)
    try:
        page.wait_for_function(
            "() => document.querySelector('flt-glass-pane') !== null || document.querySelector('canvas') !== null",
            timeout=timeout * 1000,
        )
    except Exception:
        pass
    time.sleep(2)


def nav_click(page, w, h, tab):
    """Click a bottom navigation tab (3-tab layout)."""
    nav_y = h - 40  # Center of nav bar
    positions = {
        "starter": w * 1 / 6,
        "bread": w * 3 / 6,
        "calculator": w * 5 / 6,
    }
    page.mouse.click(positions[tab], nav_y)
    time.sleep(1.5)


def screenshot(page, out_dir, name):
    """Save a screenshot."""
    path = f"{out_dir}/{name}.png"
    page.screenshot(path=path)
    print(f"    {name}.png")


def new_context_with_onboarding_seen(browser, device_cfg):
    """Create a browser context with onboarding already dismissed via localStorage."""
    context = browser.new_context(
        viewport=device_cfg["viewport"],
        device_scale_factor=device_cfg["scale"],
    )
    # Pre-set SharedPreferences flag (Flutter web stores these in localStorage
    # with a "flutter." prefix)
    context.add_init_script("""
        localStorage.setItem('flutter.hasSeenOnboarding', 'true');
    """)
    return context


def take_onboarding_screenshot(browser, url, device_cfg, out_dir, prefix):
    """Take just the onboarding screenshot (fresh context, no localStorage)."""
    context = browser.new_context(
        viewport=device_cfg["viewport"],
        device_scale_factor=device_cfg["scale"],
    )
    page = context.new_page()
    page.goto(url, wait_until="networkidle")
    wait_for_app(page)
    screenshot(page, out_dir, f"{prefix}_01_onboarding")
    context.close()


def take_app_screenshots(browser, url, device_cfg, out_dir, prefix):
    """Take app screenshots with onboarding already dismissed."""
    vp = device_cfg["viewport"]
    w, h = vp["width"], vp["height"]

    context = new_context_with_onboarding_seen(browser, device_cfg)
    page = context.new_page()
    page.goto(url, wait_until="networkidle")
    wait_for_app(page)

    # Starter Recipe (default tab)
    screenshot(page, out_dir, f"{prefix}_02_starter")

    # Bread Recipe
    nav_click(page, w, h, "bread")
    screenshot(page, out_dir, f"{prefix}_03_bread")

    # Calculator
    nav_click(page, w, h, "calculator")
    time.sleep(0.5)
    screenshot(page, out_dir, f"{prefix}_04_calculator")

    context.close()


def take_all_screenshots(port=8765):
    """Take all screenshots."""
    os.makedirs(RAW_DIR, exist_ok=True)

    # Start HTTP server
    server = subprocess.Popen(
        [sys.executable, "-m", "http.server", str(port)],
        cwd=f"{BASE_DIR}/build/web",
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    time.sleep(1)

    url = f"http://localhost:{port}"

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)

            for device_name, device_cfg in DEVICES.items():
                prefix = device_name
                print(f"  {prefix} screenshots:")
                take_onboarding_screenshot(browser, url, device_cfg, RAW_DIR, prefix)
                take_app_screenshots(browser, url, device_cfg, RAW_DIR, prefix)

            browser.close()
    finally:
        server.terminate()
        server.wait()


if __name__ == "__main__":
    print(f"\n{'=' * 60}")
    print("Sourdough Making Toolkit - Screenshots")
    print(f"{'=' * 60}")

    if build_web():
        take_all_screenshots()
    else:
        print("  Build failed, aborting.")

    print(f"\nDone! Raw screenshots in {RAW_DIR}/")
