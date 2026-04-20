import subprocess
import os

os.chdir(r'D:\Projects\gongyu_guanjia')

# Commit
result = subprocess.run(
    ['git', 'commit', '-m', 'Initial commit - apartment-ai Flutter Web'],
    capture_output=True, text=True
)
print('COMMIT:')
print('stdout:', result.stdout)
print('stderr:', result.stderr)
print('returncode:', result.returncode)

# Push
result = subprocess.run(
    ['git', 'push', '-u', 'origin', 'master', '--force'],
    capture_output=True, text=True
)
print('\nPUSH:')
print('stdout:', result.stdout)
print('stderr:', result.stderr)
print('returncode:', result.returncode)
