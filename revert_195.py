# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

# Current L195: b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d' (4 parens)
# Change to 3 parens: b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d' (3 parens)
old = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d'  # 4 parens
new = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d'      # 3 parens

if old in data:
    data = data.replace(old, new, 1)
    with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
        f.write(data)
    print('Changed L195 from 4 parens to 3 parens')
else:
    print('Pattern not found!')
