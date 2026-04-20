# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix 1: Line 230 - add extra ) to close ternary: "              ]),"  -> "              ])),"
old1 = "              ]),\n      )),"
new1 = "              ])),\n      ),"
# Fix 2: Line 237 - remove extra ): "    ])));" -> "    ]));"
old2 = "    ])));\n    ])));"
new2 = "    ])));\n    ]));"

# Fix 3: Line 229 - fix garbled unicode to proper: Text('\\u786e\\u8ba4\\u6dfb\\u52a0 '  ->  Text('\u786e\u8ba4\u6dfb\u52a0 $_typeLabel'
# Actually the file contains literal \u chars, so we replace the literal backslash-u sequences
old3 = "Text('\\\\u786e\\\\u8ba4\\\\u6dfb\\\\u52a0 ', style: const TextStyle"
new3 = "Text('\\\\u786e\\\\u8ba4\\\\u6dfb\\\\u52a0 \\${_typeLabel}', style: const TextStyle"

count = 0
for old, new, name in [(old1, new1, "Fix1 (ternary paren)"), (old2, new2, "Fix2 (extra paren)"), (old3, new3, "Fix3 (Chinese text)")]:
    if old in data:
        data = data.replace(old, new, 1)
        print(f"Applied {name}: {repr(old[:30])} -> {repr(new[:30])}")
        count += 1
    else:
        print(f"NOT FOUND: {name}")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f"\nTotal fixes: {count}/3. File size: {len(data)}")

# Verify
lines = data.split('\n')
print("\nVerification (lines 229-237):")
for i in range(228, 237):
    if i < len(lines):
        print(f"{i+1}: {repr(lines[i])}")
