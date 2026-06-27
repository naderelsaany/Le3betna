import os
import re

def fix_will_pop(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We replaced 'return Scaffold(' with 'return WillPopScope('
    # So we need to add a closing parenthesis for WillPopScope at the end of the build method.
    
    # Instead of regex parsing Dart code, let's just append the missing parenthesis right before the widget end or file end appropriately.
    # Actually, we can just replace `return WillPopScope(` with `return Scaffold(` in all files for now, because doing back navigation cleanup is better done in AppBar/Button callbacks rather than breaking the build.
    # OR we can just correctly add the parenthesis.
    
    # Let's revert WillPopScope back to Scaffold. It's safer and avoids brace matching hell. We already added the cleanup logic to the back buttons explicitly!
    content = content.replace("return WillPopScope(\n      onWillPop: () async {\n        await _roomService.leaveRoom(widget.roomCode);\n        return true;\n      },\n      child: Scaffold(", "return Scaffold(")
    content = content.replace("return WillPopScope(\r\n      onWillPop: () async {\r\n        await _roomService.leaveRoom(widget.roomCode);\r\n        return true;\r\n      },\r\n      child: Scaffold(", "return Scaffold(")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

base_dir = r"C:\Users\naderelsadany\Desktop\Le3betna\le3betna_app\lib\features"

files_to_fix = [
    os.path.join(base_dir, "lobby", "lobby_screen.dart"),
    os.path.join(base_dir, "game", "game_screen.dart"),
    os.path.join(base_dir, "game", "connect4_screen.dart"),
    os.path.join(base_dir, "game", "ludo_screen.dart"),
]

for file_path in files_to_fix:
    fix_will_pop(file_path)

# Also fix the builder parenthesis error in game_screen.dart
game_screen_path = os.path.join(base_dir, "game", "game_screen.dart")
with open(game_screen_path, 'r', encoding='utf-8') as f:
    g_content = f.read()

# Fix the accidental replace of AppBar actions
g_content = g_content.replace('''            icon: Icon(_soundManager.isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
            onPressed: () => setState(() => _soundManager.toggleMute()),
          ),
        ),''', '''            icon: Icon(_soundManager.isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
            onPressed: () => setState(() => _soundManager.toggleMute()),
          ),
        ],''')

with open(game_screen_path, 'w', encoding='utf-8') as f:
    f.write(g_content)

print("Files fixed successfully.")
