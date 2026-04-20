with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find TenantMainPage
for pattern in ['class TenantMainPage', 'class _TenantMainPage', 'TenantMainPage', 'tenant_main']:
    idx = data.find(pattern)
    if idx >= 0:
        content = data[idx:idx+3000]
        with open(r'D:\Projects\gongyu_guanjia\tenant_main2.txt', 'w', encoding='utf-8') as out:
            out.write(content)
        print(f"Found {pattern} at {idx}. Written to tenant_main2.txt")
        break
else:
    print("Not found")
