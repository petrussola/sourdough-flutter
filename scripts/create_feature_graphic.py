#!/usr/bin/env python3
"""Create a Play Store feature graphic (1024x500).

Usage:
    python3 scripts/create_feature_graphic.py
"""

from PIL import Image, ImageDraw, ImageFont
import os

BASE_DIR = "/Users/peresola/code/personal/sourdough-flutter"
RAW_DIR = f"{BASE_DIR}/screenshots_raw"
OUT_DIR = f"{BASE_DIR}/store_screenshots"

# Colors (warm sourdough palette)
PRIMARY = (101, 67, 33)          # Dark brown
PRIMARY_DARK = (68, 45, 22)      # Darker brown
ACCENT = (210, 160, 60)          # Golden wheat
WHITE = (255, 255, 255)
LIGHT_BG = (245, 230, 204)      # Warm beige
PHONE_BEZEL = (38, 38, 38)

W, H = 1024, 500

TITLE_LINES = ["Sourdough", "Making Toolkit"]
SUBTITLE_LINES = [
    "Everything you need to bake",
    "amazing sourdough bread",
    "at home.",
]
FEATURES = ["Starter Recipe", "Bread Recipe", "Calculator"]


def get_font(size):
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
    x0, y0, x1, y1 = bbox
    draw.ellipse([x0, y0, x0 + 2 * radius, y0 + 2 * radius], fill=fill)
    draw.ellipse([x1 - 2 * radius, y0, x1, y0 + 2 * radius], fill=fill)
    draw.ellipse([x0, y1 - 2 * radius, x0 + 2 * radius, y1], fill=fill)
    draw.ellipse([x1 - 2 * radius, y1 - 2 * radius, x1, y1], fill=fill)
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)


def create_feature_graphic():
    output = f"{OUT_DIR}/featureGraphic.png"
    os.makedirs(OUT_DIR, exist_ok=True)

    img = Image.new("RGBA", (W, H), LIGHT_BG + (255,))
    draw = ImageDraw.Draw(img)

    # Background: diagonal dark stripe on the right
    stripe_points = [
        (W * 0.55, 0),
        (W, 0),
        (W, H),
        (W * 0.40, H),
    ]
    draw.polygon(stripe_points, fill=PRIMARY + (255,))

    # Subtle inner stripe for depth
    inner_points = [
        (W * 0.58, 0),
        (W * 0.62, 0),
        (W * 0.47, H),
        (W * 0.43, H),
    ]
    draw.polygon(inner_points, fill=PRIMARY_DARK + (30,))

    # Phone mockup on the right (use starter recipe screenshot)
    screenshot_path = f"{RAW_DIR}/phone_02_starter.png"
    if os.path.exists(screenshot_path):
        screenshot = Image.open(screenshot_path).convert("RGBA")

        phone_h = int(H * 0.88)
        bezel = 6
        corner_r = 14
        screen_aspect = screenshot.width / screenshot.height
        screen_h = phone_h - 2 * bezel
        screen_w = int(screen_h * screen_aspect)
        phone_w = screen_w + 2 * bezel

        phone_x = int(W * 0.66)
        phone_y = int(H * 0.10)

        # Shadow
        shadow_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        shadow_draw = ImageDraw.Draw(shadow_layer)
        draw_rounded_rect(
            shadow_draw,
            (phone_x + 4, phone_y + 6, phone_x + phone_w + 4, phone_y + phone_h + 6),
            corner_r,
            (0, 0, 0, 60),
        )
        img = Image.alpha_composite(img, shadow_layer)
        draw = ImageDraw.Draw(img)

        # Phone frame
        draw_rounded_rect(
            draw,
            (phone_x, phone_y, phone_x + phone_w, phone_y + phone_h),
            corner_r,
            PHONE_BEZEL + (255,),
        )

        # Screenshot inside
        resized = screenshot.resize((screen_w, screen_h), Image.LANCZOS)
        img.paste(resized, (phone_x + bezel, phone_y + bezel), resized)

    # Title text on the left
    title_font = get_bold_font(56)
    sub_font = get_font(22)

    title_x = 50
    y = 70

    for line in TITLE_LINES:
        draw.text((title_x, y), line, fill=PRIMARY + (255,), font=title_font)
        y += 65

    # Golden accent line under title
    draw.rectangle(
        (title_x, y + 10, title_x + 120, y + 14),
        fill=ACCENT + (255,),
    )

    # Subtitle
    sub_y = y + 38
    for line in SUBTITLE_LINES:
        draw.text((title_x, sub_y), line, fill=(80, 80, 80, 255), font=sub_font)
        sub_y += 30

    # Feature badges
    badge_font = get_bold_font(14)
    badge_x = title_x
    badge_y = sub_y + 20

    for feat in FEATURES:
        bbox = draw.textbbox((0, 0), feat, font=badge_font)
        tw = bbox[2] - bbox[0]
        pad = 12
        draw_rounded_rect(
            draw,
            (badge_x, badge_y, badge_x + tw + 2 * pad, badge_y + 28),
            14,
            PRIMARY + (255,),
        )
        draw.text((badge_x + pad, badge_y + 6), feat, fill=WHITE + (255,), font=badge_font)
        badge_x += tw + 2 * pad + 10

    # Save
    img.convert("RGB").save(output, "PNG", optimize=True)
    print(f"Saved feature graphic: {output} ({W}x{H})")


if __name__ == "__main__":
    create_feature_graphic()
