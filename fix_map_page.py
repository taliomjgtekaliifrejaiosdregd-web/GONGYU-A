with open(r'D:\Projects\gongyu_guanjia\lib\pages\map_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

orig_len = len(data)
print(f"Original size: {orig_len}")

# Fix: Change 'return Scaffold(' to 'return Stack('
# And change 'body: Stack(' to just 'Stack(' (remove the body: prefix)
# Then adjust the closing '),' for Scaffold to just close the Stack

# Step 1: Replace 'return Scaffold(\n      body: Stack(' with 'return Stack('
data = data.replace('return Scaffold(\n      body: Stack(', 'return Stack(')
print(f"After step 1 (remove Scaffold wrapper): {len(data)}")

# Step 2: After 'children: [...]', change the closing pattern
# Old: '],\n        ),\n      ),\n    );\n  }\n}'
# New: '],\n    );\n  }\n}'
# Find the specific pattern - after the last ], in the build method

# Find the build method end
idx = data.find('Widget build(BuildContext context)')
if idx >= 0:
    # Look for the pattern after the Stack's children close
    # The pattern is: ],\n        ),\n      ),\n    );\n  }\n}
    # which closes: Stack children ], Stack ), Scaffold body ), Scaffold ), return );
    # We want to remove: body: ), Scaffold body: ), and one ),
    
    # Find the last ],\n        ),\n      ),\n    );\n  }\n} in the build method
    # This should be near the end of the build method
    last_build_section = data[idx:idx+2500]
    
    # Find the specific pattern: ],\n        ),\n      ),\n    );\n  }\n}
    pattern_idx = last_build_section.find('],\n        ),\n      ),\n    );\n  }\n}')
    if pattern_idx >= 0:
        # Replace with: ],\n    );\n  }\n}
        replacement = '],\n    );\n  }\n}'
        new_section = last_build_section[:pattern_idx] + replacement + last_build_section[pattern_idx+len('],\n        ),\n      ),\n    );\n  }\n}'):]
        data = data[:idx] + new_section
        print(f"After step 2 (adjust closing): {len(data)}")
    else:
        print("Pattern not found, trying alternate...")
        # Try different indentation
        pattern_idx = last_build_section.find("],\n      ),\n    ),\n  );")
        if pattern_idx >= 0:
            print(f"Found alternate at {pattern_idx}")
            print(repr(last_build_section[pattern_idx-20:pattern_idx+80]))

# Step 3: Also need to remove the 'body:' prefix from 'body: Stack('
# Actually step 1 already did this

# Verify
idx = data.find('Scaffold')
if idx >= 0:
    print(f"WARNING: Scaffold still at {idx}:", repr(data[idx:idx+50]))
else:
    print("Scaffold removed!")

print(f"Final size: {len(data)} (removed {orig_len - len(data)} chars)")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\map_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
