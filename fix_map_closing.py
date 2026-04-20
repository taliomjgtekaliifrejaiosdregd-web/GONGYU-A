with open(r'D:\Projects\gongyu_guanjia\lib\pages\map_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# The issue: line 291 has '),' (extra closing paren)
# Looking at lines 290-292:
#   ],        // line 290 - closes Stack.children
# ),          // line 291 - closes Stack - BUT THIS IS EXTRA
# );          // line 292 - ends return

# After removing Scaffold, we have:
# ],\n      ),\n    );
# But we need:
# ],\n    );

# Find and replace the pattern
# The pattern in the file: '],\n      ),\n    );'
# But the actual content has extra nesting

# Let's look at what's around lines 285-294
idx290 = data.find('],\n      ),\n    );')
if idx290 >= 0:
    print(f'Found at {idx290}:', repr(data[idx290:idx290+50]))
    # This is: ],\n      ),\n    );
    # But we need: ],\n    );
    data = data.replace('],\n      ),\n    );', '],\n    );')
    print("Fixed!")
else:
    print("Pattern not found, trying alternate")
    # Find '],' followed by multiple '),'
    idx_close = data.find('],\n      ),\n      ),')
    if idx_close >= 0:
        print(f'Found at {idx_close}')
        # The closing structure has extra ),
        # Replace with just one )
        data = data.replace('],\n      ),\n      ),', '],\n    )')
        print("Fixed alternate!")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\map_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
