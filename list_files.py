import os
base = r'D:\Projects\gongyu_guanjia\lib\pages'
for sub in ['landlord', 'tenant']:
    files = os.listdir(os.path.join(base, sub))
    for f in files:
        if f.endswith('.dart') and any(k in f for k in ['repair', 'termination', 'alert', 'repair_list']):
            size = os.path.getsize(os.path.join(base, sub, f))
            print(f'{sub}/{f}: {size} bytes')
