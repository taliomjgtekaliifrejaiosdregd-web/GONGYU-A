with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f"File size: {len(data)}")

# The broken card starts at 'atitle:' around 34692
broken = "atitle:"
idx = data.find(broken)
if idx >= 0:
    print(f"Broken at {idx}:", repr(data[max(0,idx-300):idx+400]))
    
    # Find the SizedBox before
    sbox = data.rfind('const SizedBox(width: 12)', max(0, idx-500), idx)
    print(f"\nSizedBox at {sbox}:", repr(data[sbox:sbox+30]))
    
    # Find end of the Row: look for 'const SizedBox(height: 20),' which closes the Row's parent Container
    # The Row ends at '        ]),\n' or similar
    end_search = data.find(']);', idx, idx+600)
    print(f"\n]); found at {end_search}:", repr(data[end_search:end_search+10] if end_search >= 0 else "NOT FOUND"))
    
    # Also find 'const SizedBox(height:' as alternative end marker
    height20 = data.find('const SizedBox(height:', idx, idx+600)
    print(f"SizedBox(height at {height20}:", repr(data[height20:height20+50] if height20 >= 0 else "NOT FOUND"))
    
    # Try to find where this Row ends
    # After the broken card, there should be '        ]),\n        const SizedBox(height: 20),'
    # Let's look for the pattern
    for end_marker in ['        ]),\n\n        const SizedBox', '        ]),\n        const SizedBox', 'const SizedBox(height: 20),\n\n        // 密码列表']:
        found = data.find(end_marker, idx, idx+800)
        if found >= 0:
            print(f"\nFound end marker at {found}:", repr(data[found:found+50]))
            # Remove from SizedBox(width: 12) to end_marker
            print(f"\nRemoving from {sbox} to {found+len(end_marker)}")
            removed = data[sbox:found+len(end_marker)]
            print(f"Removed {len(removed)} chars:", repr(removed[:200]))
            data = data[:sbox] + data[found+len(end_marker):]
            print(f"New size: {len(data)}")
            break
