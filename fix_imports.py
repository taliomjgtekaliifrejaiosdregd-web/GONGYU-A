import os
files = [
    r'D:\Projects\gongyu_guanjia\lib\pages\tenant\rent_orders_page.dart',
    r'D:\Projects\gongyu_guanjia\lib\pages\tenant\my_favorites_page.dart',
    r'D:\Projects\gongyu_guanjia\lib\pages\tenant\browse_history_page.dart',
]
for f in files:
    with open(f, 'r', encoding='utf-8', errors='replace') as fp:
        data = fp.read()
    # Check for backslash import
    backslash_pattern = "import 'package:gongyu_guanjia/models\\tenant_order.dart';"
    forward_pattern = "import 'package:gongyu_guanjia/models/tenant_order.dart';"
    if backslash_pattern in data:
        data = data.replace(backslash_pattern, forward_pattern)
        with open(f, 'w', encoding='utf-8') as fp:
            fp.write(data)
        print('Fixed import in', os.path.basename(f))
    else:
        # Check if import exists at all
        if 'tenant_order' in data:
            idx = data.find('tenant_order')
            print('OK:', os.path.basename(f), repr(data[max(0,idx-40):idx+50]))
        else:
            print('NO IMPORT:', os.path.basename(f))
