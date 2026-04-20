# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# The issue: _LandlordHomePageState ends at 18059, but new widgets start at 18064.
# The new widgets are after the state class, so they can't be accessed.
# Fix: Move the closing brace of _LandlordHomePageState to the end of file.

# Find the current closing brace of _LandlordHomePageState
# It's the '}' at position 18059 (before '// ====== shared components ======')
current_close = 18059

# Find the end of _LandlordHomeWrapperState (the last '}' before the final '}')
# The file ends with '\n}'
# The last meaningful '}' is at position 43784 (from analysis)
# _LandlordHomeWrapperState ends at 43784, and then there's '\n}'
# Actually the file ends at 43785 with '\n}'
# Let me find the exact positions

# Find the last '}' in the file
last_brace = data.rfind('}')
print(f'Last brace at {last_brace}')
print(f'Content around last brace: {repr(data[last_brace-5:last_brace+5])}')

# Find the second-to-last '}' (end of _LandlordHomeWrapperState)
second_last = data.rfind('}', 0, last_brace)
print(f'Second last brace at {second_last}')
print(f'Content around second last: {repr(data[second_last-5:second_last+5])}')

# The structure is:
# ... _LandlordHomeWrapperState body ...
# }  <- second_last: closing of _LandlordHomeWrapperState
# 
# }  <- last_brace: final closing of LandlordHomePage

# We want to REMOVE the closing brace at second_last (end of _LandlordHomeWrapperState)
# and KEEP the last_brace (final closing of LandlordHomePage)

# Actually: we want _LandlordHomePageState to end at the SECOND LAST '}' 
# (which is where _LandlordHomeWrapperState ends)
# Then all new widgets would be INSIDE _LandlordHomePageState

# But _LandlordHomeWrapperState is ALSO inside LandlordHomePage.
# If _LandlordHomePageState ends at second_last, then _LandlordHomeWrapperState 
# would also be inside LandlordHomePage.

# Wait, that's wrong. _LandlordHomeWrapperState is a SEPARATE class.
# It has its own class definition and closing brace.
# So: _LandlordHomePageState is a State class
# And _LandlordHomeWrapperState is a SEPARATE State class

# If we make _LandlordHomePageState end at second_last, then 
# _LandlordHomeWrapperState (defined at 41423, ends at second_last) would also be 
# inside _LandlordHomePageState. But they're SEPARATE classes!

# Hmm, this is getting confusing. Let me think differently.

# What if I just need to move the new widgets INSIDE _LandlordHomePageState?
# _LandlordHomePageState ends at 18059. I need to find a place inside it to insert them.
# But there's no good place inside the state class.

# Alternative: Keep the new widgets at file level, but make sure they're 
# accessible from _LandlordHomePageState. Since they're at file level (not inside 
# any class), they should be accessible from any class in the same file!

# Wait, ARE they at file level? Let me check.
# The new widgets start at 18064 (_VacantRoomShareSheet)
# _LandlordHomePageState ends at 18059
# So new widgets are AFTER _LandlordHomePageState
# Are they INSIDE LandlordHomePage? No - LandlordHomePage ends at 1703.

# So new widgets are at FILE LEVEL.
# And _LandlordHomePageState is also at FILE LEVEL.
# Widget classes at file level should be accessible from _LandlordHomePageState!

# The build error was NOT about accessibility. The error was about the 
# 'extends' keyword. Let me re-read the error...

# Error: 'StatelessWidget' is already declared in this scope.
# class _InfoTag extends StatelessWidget {
#             ^^^^^^^^^^^^^^^

# This error means _InfoTag is being declared INSIDE a class that already has
# StatelessWidget declared. This would happen if _InfoTag was inside 
# _LandlordHomePageState.

# But _LandlordHomePageState ends at 18059 and _InfoTag starts at 31251.
# So _InfoTag should be at FILE LEVEL. Unless...

# Unless the analysis is wrong. Let me verify the ACTUAL structure by 
# finding where LandlordHomePage ends and where the new widgets actually are.

# LandlordHomePage widget ends at 1703
# _LandlordHomePageState state starts at 1704 and... ends where?

# Let me find the closing brace of _LandlordHomePageState more carefully.
# It's the } that matches the { of 'class _LandlordHomePageState'
# Start: data.find('class _LandlordHomePageState') -> 1704
# Then find matching {

idx = data.find('class _LandlordHomePageState')
depth = 0
i = data.find('{', idx)
end_pos = -1
while i < len(data):
    if data[i] == '{':
        depth += 1
    elif data[i] == '}':
        depth -= 1
        if depth == 0:
            end_pos = i
            break
    i += 1
print(f'_LandlordHomePageState ends at {end_pos}')
print(f'Content: {repr(data[end_pos-30:end_pos+30])}')

# Find LandlordHomeWrapper (the StatefulWidget, not the State)
idx3 = data.find('class LandlordHomeWrapper')
if idx3 < 0:
    idx3 = data.find('class _LandlordHomeWrapper')
print(f'LandlordHomeWrapper at {idx3}')
i3 = data.find('{', idx3)
end_pos3 = -1
depth3 = 0
while i3 < len(data):
    if data[i3] == '{':
        depth3 += 1
    elif data[i3] == '}':
        depth3 -= 1
        if depth3 == 0:
            end_pos3 = i3
            break
    i3 += 1
print(f'LandlordHomeWrapper ends at {end_pos3}')
print(f'Content: {repr(data[end_pos3-30:end_pos3+30])}')
