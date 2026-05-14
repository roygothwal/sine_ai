import re
import os

file_path = 'lib/core/theme/app_theme_data.dart'

with open(file_path, 'r') as f:
    content = f.read()

# Pattern to find AppThemeData constructor calls
# Looking for const AppThemeData( ... ) where the closing ) is on a new line with 4 spaces
theme_pattern = re.compile(r'const AppThemeData\((.*?)\n\s{4}\),', re.DOTALL)

count = 0
def update_theme(match):
    global count
    theme_body = match.group(1)
    
    if 'inputBorderFocus:' in theme_body:
        return match.group(0)
    
    accent_match = re.search(r'accentPrimary:\s*(Color\(.*?\)),', theme_body)
    if not accent_match:
        return match.group(0)
    
    accent_value = accent_match.group(1)
    
    # Try to find inputBorder and insert inputBorderFocus after it
    if 'inputBorder:' in theme_body:
        new_body = theme_body.replace(
            'inputBorder:', 
            f'inputBorderFocus: {accent_value},\n      inputBorder:'
        )
        count += 1
        return f'const AppThemeData({new_body}\n    ),'
    
    return match.group(0)

new_content = theme_pattern.sub(update_theme, content)

with open(file_path, 'w') as f:
    f.write(new_content)

print(f"Successfully updated {count} themes.")
