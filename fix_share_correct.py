# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find where _LandlordHomePageState ends
end_page_state = 18059  # from analysis

# Find the insertion point: just before '// ==================== 共享组件'
insert_marker = '// ==================== 共享组件'
insert_pos = data.find(insert_marker)
print(f'Insert marker at {insert_pos}')
print(f'_LandlordHomePageState ends at {end_page_state}')

# Extract the new widgets (from _VacantRoomShareSheet to the end of file)
# They are currently inside _LandlordHomeWrapperState (at the end)
# Find where they start inside _LandlordHomeWrapperState
# They start at 26915 (_VacantRoomShareSheet)
widget_start = data.find('\nclass _VacantRoomShareSheet extends StatefulWidget')
print(f'Widget start at {widget_start}')

# The new widgets are everything from _VacantRoomShareSheet to the end (minus the final closing brace)
# Find the final closing brace of _LandlordHomeWrapperState
final_close = data.rfind('\n}')
print(f'Final closing brace at {final_close}')

# Extract the new widgets (from widget_start to just before the final closing brace)
new_widgets = data[widget_start:final_close]
print(f'New widgets length: {len(new_widgets)}')

# Remove the new widgets from their current location (inside _LandlordHomeWrapperState)
# Also remove the final closing brace that was part of _LandlordHomeWrapperState
data_without_widgets = data[:widget_start] + '\n\n}'
print(f'Data without widgets: {len(data_without_widgets)}')

# Now insert the new widgets inside _LandlordHomePageState (before the shared components section)
# The insert position should be just before the '// ==================== 共享组件' line
# But _LandlordHomePageState ends at 18059, which is BEFORE this comment
# We need to insert just before the comment, inside _LandlordHomePageState

# Actually: _LandlordHomePageState ends at 18059. The next content is '\n\n// ===================='
# We want to insert our widgets just before the shared components section
# and after the closing of _LandlordHomePageState

# The content before insert_marker is:
# '...}\n\n// ===================='
# We want to change it to:
# '...}\n\n[NEW WIDGETS]\n\n// ===================='

# Find the actual insertion point
old_end = data_without_widgets.find(insert_marker)
print(f'Insert at {old_end}')

# Insert the new widgets before the shared components section
fixed_data = data_without_widgets[:old_end] + '\n\n' + new_widgets + '\n\n' + data_without_widgets[old_end:]

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'w', encoding='utf-8') as f:
    f.write(fixed_data)
print(f'Final size: {len(fixed_data)}')
print('Saved!')
