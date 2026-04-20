# Fix import paths in all three files
files = [
    r'D:\Projects\gongyu_guanjia\lib\pages\tenant\my_favorites_page.dart',
    r'D:\Projects\gongyu_guanjia\lib\pages\tenant\browse_history_page.dart',
]

for fpath in files:
    with open(fpath, 'r', encoding='utf-8', errors='replace') as f:
        data = f.read()
    # Fix backslash import
    if r"models\tenant_order.dart" in data:
        data = data.replace(r"import 'package:gongyu_guanjia/models\tenant_order.dart';", 
                           "import 'package:gongyu_guanjia/models/tenant_order.dart';")
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(data)
        print(f'Fixed import in {fpath.split("\\")[-1]}')
    else:
        print(f'No backslash import found in {fpath.split("\\")[-1]}')

# Also fix the const issue in browse_history_page.dart
with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\browse_history_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix the const padding issue
data = data.replace(
    "padding: const EdgeInsets.only(left: 4, bottom: 8, top: i == 0 ? 0 : 8),",
    "padding: EdgeInsets.only(left: 4, bottom: 8, top: i == 0 ? 0 : 8),"
)

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\browse_history_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('browse_history_page.dart const fixed')
