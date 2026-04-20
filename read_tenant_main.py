with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

idx = data.find('class _TenantMainPage')
if idx >= 0:
    content = data[idx:idx+6000]
    with open(r'D:\Projects\gongyu_guanjia\tenant_main_output.txt', 'w', encoding='utf-8') as out:
        out.write(content)
    print("Written to tenant_main_output.txt")
else:
    print("Not found")
    # Also check for TenantMainPage
    idx2 = data.find('TenantMainPage')
    print(f"TenantMainPage at: {idx2}")
    if idx2 >= 0:
        print(data[max(0,idx2-100):idx2+200])
