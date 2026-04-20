# -*- coding: utf-8 -*-
# Add mobile_scanner to pubspec.yaml
with open(r'D:\Projects\gongyu_guanjia\pubspec.yaml', 'r', encoding='utf-8', errors='replace') as f:
    pub = f.read()

if 'mobile_scanner' not in pub:
    # Add after file_picker
    pub = pub.replace(
        "  file_picker: ^8.0.0\n",
        "  file_picker: ^8.0.0\n  mobile_scanner: ^5.1.1\n"
    )
    with open(r'D:\Projects\gongyu_guanjia\pubspec.yaml', 'w', encoding='utf-8') as f:
        f.write(pub)
    print('Added mobile_scanner to pubspec.yaml')
else:
    print('mobile_scanner already in pubspec.yaml')

# Add camera permission to web/index.html for QR scanning
with open(r'D:\Projects\gongyu_guanjia\web\index.html', 'r', encoding='utf-8', errors='replace') as f:
    html = f.read()

if 'mobile_scanner' not in html and 'html5-qrcode' not in html:
    # Add camera permission meta tag and script
    if '<meta name="viewport"' in html:
        html = html.replace(
            '<meta name="viewport"',
            '<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">\n  <meta name="mobile-web-app-capable" content="yes">\n  <meta name="apple-mobile-web-app-capable" content="yes">\n  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">\n  <script src="https://cdn.jsdelivr.net/npm/html5-qrcode@2.3.8/html5-qrcode.min.js"></script>\n  <script src="https://cdn.jsdelivr.net/npm/@aspect-ratio/quagga/lib/quagga.js"></script>\n  '
            '<meta name="viewport"'
        )
        with open(r'D:\Projects\gongyu_guanjia\web\index.html', 'w', encoding='utf-8') as f:
            f.write(html)
        print('Added camera permissions to index.html')
    else:
        print('WARNING: could not find viewport meta tag')
else:
    print('Camera permissions already in index.html')
