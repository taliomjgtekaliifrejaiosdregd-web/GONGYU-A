data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()

# L195: 11 bytes with 4 parens -> change to 10 bytes with 3 parens
# Remove one \x29 before \x3b
old1 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d'  # 11 bytes: 4sp ] ) ) ) ) ;
new1 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d'        # 10 bytes: 4sp ] ) ) ) ;

# L237: 9 bytes with 2 parens -> change to 10 bytes with 3 parens
# Add one \x29 between the two existing \x29 and before \x3b
old2 = b'\x20\x20\x20\x20\x5d\x29\x29\x3b\x0d'            # 9 bytes: 4sp ] ) ) ;
new2 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d'        # 10 bytes: 4sp ] ) ) ) ;

print(f'old1 len={len(old1)}, count in file={data.count(old1)}')
print(f'old2 len={len(old2)}, count in file={data.count(old2)}')

c1 = 0
c2 = 0
if old1 in data:
    data = data.replace(old1, new1, 1)
    c1 = 1
    print('Fix 1: L195 4->3 parens OK')
if old2 in data:
    data = data.replace(old2, new2, 1)
    c2 = 1
    print('Fix 2: L237 2->3 parens OK')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
    f.write(data)
print(f'Applied {c1+c2}/2 fixes')

# Verify
lines = data.split(b'\n')
l195n = lines[194]
l237n = lines[236]
print(f'L195: {len(l195n)} bytes, parens={sum(1 for b in l195n if b==0x29)}, brackets={sum(1 for b in l195n if b==0x5d)}')
print(f'L237: {len(l237n)} bytes, parens={sum(1 for b in l237n if b==0x29)}, brackets={sum(1 for b in l237n if b==0x5d)}')
