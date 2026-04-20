import os

# Search all tenant dart files for guide-related content
patterns = ['指南', '引导', '新手', 'guide', 'Guide', 'onboarding', 'tour', 'Tour']

for root, dirs, files in os.walk(r'D:\Projects\gongyu_guanjia\lib\pages\tenant'):
    for fname in files:
        if fname.endswith('.dart'):
            path = os.path.join(root, fname)
            try:
                with open(path, 'r', encoding='utf-8', errors='replace') as f:
                    content = f.read()
                for p in patterns:
                    if p.lower() in content.lower():
                        # Find lines with this pattern
                        for i, line in enumerate(content.split('\n')):
                            if p.lower() in line.lower():
                                print(f'{os.path.basename(path)}:{i+1}: {line.strip()[:120]}')
            except Exception as e:
                print(f'Error reading {path}: {e}')
