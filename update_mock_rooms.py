# -*- coding: utf-8 -*-
"""
Update mock_service.dart:
1. Add isPublished and images to each Room
2. Make rooms 3 and 7 published (available rooms)
3. Add real house images from Unsplash
"""

import re

with open(r'D:\Projects\gongyu_guanjia\lib\services\mock_service.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Real house images from Unsplash (reliable, free to use)
# Each room gets 3-4 real estate photos
IMAGES = {
    1: [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
    ],
    2: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
    ],
    3: [
        'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=800&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
        'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=80',
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&q=80',
    ],
    4: [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&q=80',
    ],
    5: [
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800&q=80',
        'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?w=800&q=80',
        'https://images.unsplash.com/photo-1567767292278-a4f21aa2d36e?w=800&q=80',
    ],
    6: [
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80',
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=80',
        'https://images.unsplash.com/photo-1615529182904-14819c35db37?w=800&q=80',
    ],
    7: [
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
    ],
    8: [
        'https://images.unsplash.com/photo-1484154218962-a197022b25ba?w=800&q=80',
        'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=800&q=80',
        'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800&q=80',
    ],
}

# Which rooms are published (show in tenant hot listings)
PUBLISHED_IDS = {3, 7}

def format_images_list(room_id):
    imgs = IMAGES.get(room_id, [])
    if not imgs:
        return ''
    items = ',\n      '.join(f"'https://images.unsplash.com/photo-{url.split(\"photo-\")[1]}'" for url in imgs)
    # Use direct URLs
    items = ',\n      '.join(f"'{url}'" for url in imgs)
    return f'\n      images: [{items}],'

def update_room(match, room_id):
    room_text = match.group(0)
    
    # Check if this room already has images field
    has_images = 'images:' in room_text
    has_published = 'isPublished:' in room_text
    
    # Get current status to determine if should be published
    is_avail = 'RoomStatus.available' in room_text
    
    # Build the new fields to add
    new_parts = []
    if not has_published:
        new_parts.append(f'isPublished: {str(room_id in PUBLISHED_IDS).lower()}')
    if not has_images:
        imgs = IMAGES.get(room_id, [])
        if imgs:
            img_lines = ',\n      '.join(f"'{url}'" for url in imgs)
            new_parts.append(f'images: [{img_lines}]')
    
    if not new_parts:
        return room_text  # No change needed
    
    # Find the last field in the Room constructor
    # Insert before the closing '),'
    # Look for the last field and add after it
    # Strategy: find the last '),' that's the end of the Room, and insert before it
    
    # Remove trailing '),' from room text to insert before it
    if room_text.rstrip().endswith('),'):
        room_body = room_text.rstrip()[:-2]  # Remove '),'
        new_fields = ',\n      '.join(new_parts)
        return room_body + ',\n      ' + new_fields + '\n    ),\n'
    
    return room_text

# Find all Room( blocks
# Pattern: Room(\n      key: value,\n      ...) until the closing ),

# Process each Room
changes = 0

# Find all Room( blocks by finding their IDs
for room_id in range(1, 9):
    # Find the Room with this specific id
    pattern = rf"Room\(\n      id: {room_id},"
    idx = data.find(pattern)
    if idx < 0:
        print(f"Room {room_id}: pattern not found")
        continue
    
    # Find the end of this Room block (the closing ),)
    # Start from the pattern and find the matching ),
    start = idx
    # Find the opening (
    open_paren = data.find('(', idx)
    depth = 0
    end = open_paren
    for i in range(open_paren, len(data)):
        if data[i] == '(':
            depth += 1
        elif data[i] == ')':
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    
    room_text = data[start:end]
    
    # Check current state
    has_images = 'images:' in room_text
    has_published = 'isPublished:' in room_text
    
    new_room_text = room_text
    needs_change = False
    
    # Add isPublished if missing
    if not has_published:
        needs_change = True
        # Find a good insertion point - after rentExpireDate or before the last comma
        if "rentExpireDate:" in room_text:
            # Insert after rentExpireDate line
            rent_idx = room_text.rfind("rentExpireDate:")
            # Find end of that line
            line_end = room_text.find(',', rent_idx) + 1
            new_room_text = room_text[:line_end] + f'\n      isPublished: {str(room_id in PUBLISHED_IDS).lower()},' + room_text[line_end:]
        else:
            # Insert before closing
            new_room_text = room_text.rstrip()[:-2] + f',\n      isPublished: {str(room_id in PUBLISHED_IDS).lower()},\n    ),\n'
    
    # Add images if missing
    if not has_images:
        needs_change = True
        imgs = IMAGES.get(room_id, [])
        if imgs:
            img_lines = ',\n      '.join(f"'{url}'" for url in imgs)
            new_fields = f'\n      images: [{img_lines}],'
            # Insert before the closing ), 
            # Find the last line and insert before it
            if new_room_text.endswith('),\n'):
                new_room_text = new_room_text[:-3] + new_fields + '\n    ),\n'
            elif new_room_text.endswith('),\n'):
                new_room_text = new_room_text[:-3] + new_fields + '\n    ),\n'
    
    if needs_change:
        data = data[:start] + new_room_text + data[end:]
        changes += 1
        print(f"Room {room_id}: updated (images: {'images:' in new_room_text}, published: {'isPublished' in new_room_text})")
    else:
        print(f"Room {room_id}: no change needed")

print(f"\nTotal changes: {changes}")

with open(r'D:\Projects\gongyu_guanjia\lib\services\mock_service.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
