with open(r'D:\Projects\gongyu_guanjia\lib\models\room.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()
print(f"Total: {len(data)} bytes")
# Show first 3000 chars
print(data[:3000])
