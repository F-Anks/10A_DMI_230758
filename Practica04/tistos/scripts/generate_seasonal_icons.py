import os
# pyrefly: ignore [missing-import]
from PIL import Image, ImageDraw

def create_rounded_icon(img_path, size, crop_scale=1.0, corner_ratio=0.22):
    with Image.open(img_path) as img:
        img = img.convert('RGBA')
        w, h = img.size
        
        # Central crop if crop_scale > 1.0
        if crop_scale > 1.0:
            crop_w = int(w / crop_scale)
            crop_h = int(h / crop_scale)
            left = (w - crop_w) // 2
            top = (h - crop_h) // 2
            img = img.crop((left, top, left + crop_w, top + crop_h))
            
        # Resize to target size with Lanczos
        img = img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Apply smooth rounded corner mask
        mask = Image.new('L', (size * 4, size * 4), 0)
        draw = ImageDraw.Draw(mask)
        r = int(size * 4 * corner_ratio)
        draw.rounded_rectangle([0, 0, size * 4 - 1, size * 4 - 1], radius=r, fill=255)
        mask = mask.resize((size, size), Image.Resampling.LANCZOS)
        
        output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        output.paste(img, (0, 0), mask=mask)
        return output

def main():
    base_dir = r'c:\Users\Andro\OneDrive\Desktop\10A_DMI_230758\Practica04\tistos'
    assets_dir = os.path.join(base_dir, 'assets', 'images')
    res_dir = os.path.join(base_dir, 'android', 'app', 'src', 'main', 'res')
    
    densities = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    # Find files
    files = os.listdir(assets_dir)
    logo_file = next((f for f in files if f.lower() == 'logo.png'), 'Logo.png')
    anniv_file = next((f for f in files if 'aniversary' in f.lower()), 'aniversary_logo.jpg')
    hallo_file = next((f for f in files if 'halloween' in f.lower()), 'halloween_logo.jpg')
    xmas_file = next((f for f in files if 'chrismas' in f.lower() or 'christmas' in f.lower()), 'chrismas_logo.jpg')
    val_file = next((f for f in files if 'valentine' in f.lower()), None)
    
    targets = {
        'ic_launcher_normal': (os.path.join(assets_dir, logo_file), 1.0),
        'ic_launcher_anniversary': (os.path.join(assets_dir, anniv_file), 1.25),
        'ic_launcher_halloween': (os.path.join(assets_dir, hallo_file), 1.25),
        'ic_launcher_christmas': (os.path.join(assets_dir, xmas_file), 1.25),
        'ic_launcher_valentine': (os.path.join(assets_dir, val_file), 1.25),
    }
    
    for folder, size in densities.items():
        out_folder = os.path.join(res_dir, folder)
        os.makedirs(out_folder, exist_ok=True)
        for icon_name, (path, crop) in targets.items():
            if os.path.exists(path):
                icon = create_rounded_icon(path, size, crop_scale=crop)
                out_path = os.path.join(out_folder, f'{icon_name}.png')
                icon.save(out_path, 'PNG')
                print(f'Generated: {out_path} ({size}x{size})')
                
        # Also copy anniversary as current ic_launcher for today
        anniv_path = os.path.join(out_folder, 'ic_launcher_anniversary.png')
        default_launcher = os.path.join(out_folder, 'ic_launcher.png')
        if os.path.exists(anniv_path):
            with open(anniv_path, 'rb') as f_in, open(default_launcher, 'wb') as f_out:
                f_out.write(f_in.read())
            print(f'Default ic_launcher set to anniversary in {folder}')

if __name__ == '__main__':
    main()
