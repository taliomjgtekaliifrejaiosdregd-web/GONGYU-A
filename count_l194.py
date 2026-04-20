l194 = "        child: Row(children: [const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 20), const SizedBox(width: 10), Expanded(child: Text('\xe9\xa6\x96\xe6\xac\xa1\xe6\xb7\xbb\xe5\x8a\xa0\xe5\xbb\xba\xe8\xae\xae\xe9\x80\x90\xe5\x8f\xb0\xe6\xb7\xbb\xe5\x8a\xa0\xef\xbc\x8c\xe6\x96\xb9\xe4\xbe\xbf\xe8\xb0\x83\xe8\xaf\x95\xe3\x80\x82\xe5\xa6\x82\xe8\xae\xbe\xe5\xa4\x87\xe8\xbe\x83\xe5\xa4\x9a\xef\xbc\x8c\xe5\x8f\xaf\xe6\x89\xb9\xe9\x87\x8f\xe5\xaf\xbc\xe5\x85\xa5\xe3\x80\x82', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)))])),\r"

# Count parens
opens = [(i,c) for i,c in enumerate(l194) if c == '(']
closes = [(i,c) for i,c in enumerate(l194) if c == ')']

print(f'Opens: {len(opens)}, Closes: {len(closes)}, Net: {len(opens)-len(closes)}')
print()
print('All characters with parens marked:')
for i, c in enumerate(l194):
    if c in '()[]':
        ctx = l194[max(0,i-3):i+8]
        print(f'  @{i} {repr(c)}: ...{repr(ctx)}...')
