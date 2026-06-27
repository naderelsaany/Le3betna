import os
import subprocess

def find_flutter():
    for root, dirs, files in os.walk(r'C:\Users\naderelsadany\Desktop'):
        if 'flutter.bat' in files:
            return os.path.join(root, 'flutter.bat')
    return None

flutter_path = find_flutter()
if flutter_path:
    print(f"Found flutter at {flutter_path}")
    result = subprocess.run([flutter_path, 'analyze', 'le3betna_app'], capture_output=True, text=True, cwd=r'C:\Users\naderelsadany\Desktop\Le3betna')
    print("STDOUT:", result.stdout)
    print("STDERR:", result.stderr)
else:
    print("Flutter not found.")
