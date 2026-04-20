with open(r'D:\Projects\gongyu_guanjia\lib\pages\map_page.dart', 'rb') as f:
    data = f.read()
idx = data.find(b'class _MapBtn')
snippet = data[idx-200:idx]
print(repr(snippet))
print(') count:', snippet.count(b')'))
print('( count:', snippet.count(b'('))
# Find the return statement
ret_idx = snippet.find(b'return Stack(')
if ret_idx >= 0:
    print('return Stack( at', ret_idx)
    print(repr(snippet[ret_idx:]))
