# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'rb') as f:
    raw = f.read()

# Confirmed byte positions:
# 10907: )  (closes GestureDetector)
# 10908: ,  (separator in parent Row's children)
# 10909: \r
# 10910: \n
# 10911-10922: 12 spaces
# 10923: ]  (closes main Row children)
# 10924: ,
# 10925: \r
# 10926: \n

# Build account_info as a string with proper indentation
# GestureDetector is at 16 spaces, account_info content at 18 spaces
# account_info ] at 16 spaces, ), at 16 spaces (same as GestureDetector))
account_info = (
    "\r\n"
    "              // \xe8\xb4\xa6\xe6\x88\xb7\xe5\xa4\xb4\xe5\x83\x8f + \xe7\xae\x80\xe7\xa7\xb0\r\n"
    "              GestureDetector(\r\n"
    "                onTap: () => ScaffoldMessenger.of(context).showSnackBar(\r\n"
    "                  const SnackBar(content: Text('\xe4\xb8\xaa\xe4\xba\xba\xe4\xb8\xad\xe5\xbf\x83'), behavior: SnackBarBehavior.floating),\r\n"
    "                ),\r\n"
    "                child: Row(\r\n"
    "                  mainAxisSize: MainAxisSize.min,\r\n"
    "                  children: [\r\n"
    "                    Container(\r\n"
    "                      width: 22,\r\n"
    "                      height: 22,\r\n"
    "                      decoration: const BoxDecoration(\r\n"
    "                        color: Colors.white,\r\n"
    "                        shape: BoxShape.circle,\r\n"
    "                      ),\r\n"
    "                      child: Center(\r\n"
    "                        child: Text(\r\n"
    "                          _avatarInitial(MockService.currentUser.name),\r\n"
    "                          style: const TextStyle(\r\n"
    "                            color: Color(0xFF6366F1),\r\n"
    "                            fontSize: 10,\r\n"
    "                            fontWeight: FontWeight.bold,\r\n"
    "                          ),\r\n"
    "                        ),\r\n"
    "                      ),\r\n"
    "                    ),\r\n"
    "                    const SizedBox(width: 2),\r\n"
    "                    ConstrainedBox(\r\n"
    "                      constraints: const BoxConstraints(maxWidth: 30),\r\n"
    "                      child: Text(\r\n"
    "                        _shortName(MockService.currentUser.name),\r\n"
    "                        style: const TextStyle(\r\n"
    "                          color: Colors.white,\r\n"
    "                          fontSize: 9,\r\n"
    "                          fontWeight: FontWeight.w500,\r\n"
    "                        ),\r\n"
    "                        overflow: TextOverflow.ellipsis,\r\n"
    "                      ),\r\n"
    "                    ),\r\n"
    "                  ],\r\n"
    "                ),\r\n"
    "              ),\r\n"
    "    "  # 4 spaces so ], aligns: GestureDetector at 16, ], at 16 → '    ]'
)

account_info_bytes = account_info.encode('utf-8')
print(f'Account info length: {len(account_info_bytes)}')

# Verify old bytes
old_bytes = raw[10909:10923]
print(f'Old bytes: {repr(old_bytes)}')
assert old_bytes == b'\r\n' + b' ' * 12, f'Expected \\r\\n + 12 spaces, got {repr(old_bytes)}'

# Replace
new_raw = raw[:10909] + account_info_bytes + raw[10923:]
print(f'Original size: {len(raw)}, New size: {len(new_raw)}, diff: {len(new_raw)-len(raw)}')

# Verify the replacement - check that the new content ends with '    ],'
end_check = new_raw[10909+len(account_info_bytes)-7:10909+len(account_info_bytes)]
print(f'End of insertion: {repr(end_check)}')

# Add helper functions before class _BannerItem
banner_pos = new_raw.find(b'class _BannerItem {')
print(f'class _BannerItem at: {banner_pos}')

helper_funcs = (
    "\n"
    "// ==================== \xe8\xb4\xa6\xe6\x88\xb7\xe5\x90\x8d\xe7\xa7\xb0\xe8\xbe\x85\xe5\x8a\xa9\xe5\x87\xbd\xe6\x95\xb0 ====================\n"
    "String _avatarInitial(String name) {\n"
    "  if (name.isEmpty) return '?';\n"
    "  final clean = name.replaceFirst(RegExp(r'^(\xe5\x85\x88\xe7\x94\x9f|\xe5\xa5\xb3\xe5\xaf\x92|\xe5\xb0\x8f\xe5\xa7\x90|\xe8\x80\x81\xe6\x9d\xbf|\xe6\x88\xbf\xe4\xb8\x9c|\xe7\xa7\x9f\xe5\xae\xa2)'), '').trim();\n"
    "  if (clean.isEmpty) return name[0];\n"
    "  return clean[0];\n"
    "}\n"
    "\n"
    "String _shortName(String name) {\n"
    "  if (name.isEmpty) return '\xe8\xae\xbf\xe5\xae\xa2';\n"
    "  final clean = name.replaceFirst(RegExp(r'^(\xe5\x85\x88\xe7\x94\x9f|\xe5\xa5\xb3\xe5\xaf\x92|\xe5\xb0\x8f\xe5\xa7\x90|\xe8\x80\x81\xe6\x9d\xbf|\xe6\x88\xbf\xe4\xb8\x9c)'), '').trim();\n"
    "  if (clean.isEmpty) return name.length <= 2 ? name : name.substring(0, 2);\n"
    "  return clean.length <= 2 ? clean : clean.substring(0, 2);\n"
    "}\n"
    "\n"
).encode('utf-8')

if banner_pos >= 0:
    new_raw = new_raw[:banner_pos] + helper_funcs + new_raw[banner_pos:]
    print('Added helper functions!')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'wb') as f:
    f.write(new_raw)
print(f'Final size: {len(new_raw)}')
print('Saved!')
