# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

lines = data.split(b'\n')
l193 = lines[192]  # 0-indexed

print(f'L193 length: {len(l193)} bytes')
print(f'L193 raw opens: {l193.count(b"(")}, closes: {l193.count(b")")}')

# Remove all strings (single and double quoted, including raw strings)
# Strategy: find all string boundaries and remove string content
s = bytearray(l193)
result = bytearray()
i = 0
in_str = False
str_char = None
while i < len(s):
    c = s[i]
    if not in_str:
        if c in (0x22, 0x27):  # " or '
            in_str = True
            str_char = c
            result.append(c)  # keep the opening quote
        else:
            result.append(c)
    else:
        if c == str_char:
            # Check for raw string or triple quote
            # r'...' or r"..."
            # Look at the opening: was it r' or r"?
            if (i >= 1 and s[i-1] == 0x72):  # 'r'
                # Raw string - find the next matching quote
                in_str = False
                str_char = None
                result.append(c)
            elif (i >= 3 and s[i-3:i] in (b"'''", b'"""')):
                # Triple quoted - find next triple quote
                j = i + 1
                while j < len(s) - 2:
                    if s[j:j+3] in (b"'''", b'"""'):
                        result.append(c)  # keep the closing quote
                        i = j + 2  # skip past the triple quote
                        break
                    j += 1
                else:
                    result.append(c)
            else:
                in_str = False
                str_char = None
                result.append(c)
        elif c == 0x5c:  # backslash
            result.append(c)
            result.append(s[i+1] if i+1 < len(s) else 0)
            i += 1
        else:
            result.append(c)
    i += 1

clean = result.decode('utf-8', errors='replace')
print(f'After string removal: opens={clean.count("(")}, closes={clean.count(")")}')

# Show which parens remain
for j, c in enumerate(clean):
    if c in '()[]':
        ctx = clean[max(0,j-10):j+20]
        print(f'  @{j} {repr(c)}: {repr(ctx)}')
