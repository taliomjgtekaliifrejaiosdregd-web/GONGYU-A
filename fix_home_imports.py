# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Add RoomDetailPage import
if "import 'package:gongyu_guanjia/pages/room_detail_page.dart';" not in data:
    # Add after the first non-package import
    # Find the first import line
    first_import = data.find("import 'package:")
    if first_import >= 0:
        # Find the end of this line
        end_line = data.find('\n', first_import)
        # Insert after the first import
        data = data[:end_line+1] + "import 'package:gongyu_guanjia/pages/room_detail_page.dart';\n" + data[end_line+1:]
        print('Added RoomDetailPage import')
    else:
        # Add at the beginning after the library/import block
        data = "import 'package:gongyu_guanjia/pages/room_detail_page.dart';\n" + data
        print('Added RoomDetailPage import at beginning')
else:
    print('RoomDetailPage already imported')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('landlord_home.dart updated!')
