# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\web\index.html', 'r', encoding='utf-8', errors='replace') as f:
    html = f.read()

old = '  <meta name="mobile-web-app-capable" content="yes">\n  <meta name="apple-mobile-web-app-status-bar-style" content="black">'

new = '  <meta name="mobile-web-app-capable" content="yes">\n  <meta name="apple-mobile-web-app-status-bar-style" content="black">\n  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">\n  <script src="https://cdn.jsdelivr.net/npm/html5-qrcode@2.3.8/html5-qrcode.min.js"></script>'

if old in html:
    html = html.replace(old, new)
    with open(r'D:\Projects\gongyu_guanjia\web\index.html', 'w', encoding='utf-8') as f:
        f.write(html)
    print('Updated index.html')
else:
    print('Pattern not found, checking current content...')
    if 'html5-qrcode' in html:
        print('html5-qrcode already in html')
    else:
        # Try to find a close match
        idx = html.find('mobile-web-app-capable')
        if idx >= 0:
            print(f'Found at {idx}: {repr(html[idx-10:idx+100])}')
