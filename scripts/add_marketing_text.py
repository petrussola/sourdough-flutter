#!/usr/bin/env python3
"""Add marketing text + phone frame to Play Store screenshots.

Usage:
    python3 scripts/add_marketing_text.py
"""

from PIL import Image, ImageDraw, ImageFont
import os, sys

BASE_DIR = "/Users/peresola/code/personal/sourdough-flutter"
RAW_DIR = f"{BASE_DIR}/screenshots_raw"
OUT_DIR = f"{BASE_DIR}/store_screenshots"

# Colors (warm sourdough palette)
PHONE_BEZEL = (38, 38, 38)
BG_COLOR = (245, 230, 204)          # Warm bread-crust beige
TITLE_COLOR = (101, 67, 33)         # Dark brown
SUBTITLE_COLOR = (120, 100, 80)     # Muted brown

# Marketing text per screen: (title, subtitle)
MARKETING = {
    "onboarding": ("SOURDOUGH MADE SIMPLE", "Everything you need to start baking"),
    "starter": ("STARTER RECIPE", "Day-by-day guide to your first culture"),
    "bread": ("BREAD RECIPE", "Step-by-step baking instructions"),
    "calculator": ("INGREDIENT CALCULATOR", "Perfect proportions every time"),
}

PHONE_SCREENSHOTS = [
    ("phone_01_onboarding.png", "onboarding", "01"),
    ("phone_02_starter.png", "starter", "02"),
    ("phone_03_bread.png", "bread", "03"),
    ("phone_04_calculator.png", "calculator", "04"),
]

TABLET7_SCREENSHOTS = [
    ("tablet7_01_onboarding.png", "onboarding", "01"),
    ("tablet7_02_starter.png", "starter", "02"),
    ("tablet7_03_bread.png", "bread", "03"),
    ("tablet7_04_calculator.png", "calculator", "04"),
]

TABLET10_SCREENSHOTS = [
    ("tablet10_01_onboarding.png", "onboarding", "01"),
    ("tablet10_02_starter.png", "starter", "02"),
    ("tablet10_03_bread.png", "bread", "03"),
    ("tablet10_04_calculator.png", "calculator", "04"),
]


def get_font(size):
    """Load a regular font."""
    paths = [
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return ImageFont.load_default()


def get_bold_font(size):
    """Load a bold font."""
    paths = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return get_font(size)


def draw_rounded_rect(draw, bbox, radius, fill):
    """Draw a rounded rectangle."""
    x0, y0, x1, y1 = bbox
    draw.ellipse([x0, y0, x0 + 2 * radius, y0 + 2 * radius], fill=fill)
    draw.ellipse([x1 - 2 * radius, y0, x1, y0 + 2 * radius], fill=fill)
    draw.ellipse([x0, y1 - 2 * radius, x0 + 2 * radius, y1], fill=fill)
    draw.ellipse([x1 - 2 * radius, y1 - 2 * radius, x1, y1], fill=fill)
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)


def create_framed_screenshot(input_path, output_path, title, subtitle, target_size):
    """Create a Play Store screenshot with phone frame and marketing text."""
    screenshot = Image.open(input_path).convert("RGBA")
    out_w, out_h = target_size

    # Layout: text top 22%, phone in remaining 78%
    text_area_h = int(out_h * 0.22)
    phone_area_h = out_h - text_area_h

    # Phone frame sizing
    bezel_w = int(out_w * 0.03)
    bezel_top = int(out_w * 0.02)
    bezel_bot = int(out_w * 0.02)
    corner_r = int(out_w * 0.04)

    frame_w = int(out_w * 0.72)
    screen_w = frame_w - 2 * bezel_w
    scale = screen_w / screenshot.width
    screen_h = int(screenshot.height * scale)
    frame_h = screen_h + bezel_top + bezel_bot

    max_frame_h = phone_area_h + int(out_h * 0.08)
    if frame_h > max_frame_h:
        screen_h = max_frame_h - bezel_top - bezel_bot
        frame_h = max_frame_h
        crop_h = int(screen_h / scale)
        screenshot = screenshot.crop((0, 0, screenshot.width, crop_h))

    resized_ss = screenshot.resize((screen_w, screen_h), Image.LANCZOS)

    # Create final image
    final = Image.new("RGBA", (out_w, out_h), BG_COLOR + (255,))
    draw = ImageDraw.Draw(final)

    # Phone frame position
    frame_x = (out_w - frame_w) // 2
    frame_y = text_area_h + int((phone_area_h - frame_h) * 0.15)

    # Shadow
    shadow_layer = Image.new("RGBA", (out_w, out_h), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_offset = int(out_w * 0.008)
    draw_rounded_rect(
        shadow_draw,
        (
            frame_x + shadow_offset,
            frame_y + shadow_offset,
            frame_x + frame_w + shadow_offset,
            frame_y + frame_h + shadow_offset,
        ),
        corner_r,
        (0, 0, 0, 50),
    )
    final = Image.alpha_composite(final, shadow_layer)
    draw = ImageDraw.Draw(final)

    # Phone frame
    draw_rounded_rect(
        draw,
        (frame_x, frame_y, frame_x + frame_w, frame_y + frame_h),
        corner_r,
        PHONE_BEZEL + (255,),
    )

    # Paste screenshot
    screen_x = frame_x + bezel_w
    screen_y = frame_y + bezel_top
    final.paste(resized_ss, (screen_x, screen_y), resized_ss)

    # Marketing text
    title_size = int(out_w * 0.062)
    subtitle_size = int(out_w * 0.035)
    title_font = get_bold_font(title_size)
    subtitle_font = get_font(subtitle_size)

    # Title - centered
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_tw = title_bbox[2] - title_bbox[0]
    title_x = (out_w - title_tw) // 2
    title_y = int(text_area_h * 0.25)
    draw.text((title_x, title_y), title, fill=TITLE_COLOR + (255,), font=title_font)

    # Subtitle - centered
    sub_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    sub_tw = sub_bbox[2] - sub_bbox[0]
    sub_x = (out_w - sub_tw) // 2
    sub_y = title_y + int(title_size * 1.6)
    draw.text((sub_x, sub_y), subtitle, fill=SUBTITLE_COLOR + (255,), font=subtitle_font)

    # Save
    final_rgb = final.convert("RGB")
    final_rgb.save(output_path, "PNG", optimize=True)
    print(f"  Saved: {os.path.basename(output_path)} ({out_w}x{out_h})")


def process_batch(screenshots, output_dir, label, target_size):
    """Process a batch of screenshots."""
    os.makedirs(output_dir, exist_ok=True)
    print(f"\n{'='*50}")
    print(f"Processing {label}")
    print(f"{'='*50}")

    for raw_file, marketing_key, num in screenshots:
        input_path = f"{RAW_DIR}/{raw_file}"
        if not os.path.exists(input_path):
            print(f"  SKIP (not found): {raw_file}")
            continue
        title, subtitle = MARKETING[marketing_key]
        output_path = f"{output_dir}/{num}_{marketing_key}.png"
        create_framed_screenshot(input_path, output_path, title, subtitle, target_size)


def main():
    print("\nGenerating store screenshots for Sourdough Making Toolkit")

    process_batch(
        PHONE_SCREENSHOTS,
        f"{OUT_DIR}/phoneScreenshots",
        "Phone (1080x1920)",
        (1080, 1920),
    )
    process_batch(
        TABLET7_SCREENSHOTS,
        f"{OUT_DIR}/sevenInchScreenshots",
        "7-inch Tablet (1440x2560)",
        (1440, 2560),
    )
    process_batch(
        TABLET10_SCREENSHOTS,
        f"{OUT_DIR}/tenInchScreenshots",
        "10-inch Tablet (1800x3200)",
        (1800, 3200),
    )

    print(f"\nDone! Store screenshots saved to {OUT_DIR}/")


if __name__ == "__main__":
    main()
