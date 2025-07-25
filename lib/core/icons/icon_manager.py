#!/usr/bin/env python3
"""
Icon Manager for prbal_icons.dart
This script provides utilities to manage and analyze icons in the Dart icon file.
"""

import re
import os
from typing import List, Dict, Tuple, Set
from collections import Counter


class IconManager:
    def __init__(self, dart_file_path: str = "prbal_icons.dart"):
        self.dart_file_path = dart_file_path
        self.icons: List[Tuple[str, str]] = []  # (name, hex_code)
        self.load_icons()

    def load_icons(self):
        """Load icons from the Dart file."""
        if not os.path.exists(self.dart_file_path):
            print(f"❌ Error: File {self.dart_file_path} not found!")
            return

        try:
            with open(self.dart_file_path, 'r', encoding='utf-8') as file:
                content = file.read()
                
            # Pattern to match icon definitions
            # Matches: static const IconData iconName = IconData(0xe900, fontFamily: _fontFamily);
            pattern = r'static\s+const\s+IconData\s+(\w+)\s*=\s*IconData\(0x([a-fA-F0-9]+),'
            matches = re.findall(pattern, content)
            
            self.icons = [(name, hex_code) for name, hex_code in matches]
            print(f"✅ Loaded {len(self.icons)} icons from {self.dart_file_path}")
            
        except Exception as e:
            print(f"❌ Error reading file: {e}")

    def find_duplicate_names(self) -> Dict[str, List[str]]:
        """Find duplicate icon names."""
        print("\n🔍 Finding duplicate icon names...")
        
        name_counts = Counter([name for name, _ in self.icons])
        duplicates = {name: [hex_code for icon_name, hex_code in self.icons if icon_name == name] 
                     for name, count in name_counts.items() if count > 1}
        
        if duplicates:
            print(f"⚠️  Found {len(duplicates)} duplicate icon name(s):")
            for name, hex_codes in duplicates.items():
                print(f"   • {name}: {', '.join(hex_codes)}")
        else:
            print("✅ No duplicate icon names found!")
        
        return duplicates

    def find_numeric_names(self) -> List[str]:
        """Find icon names that start with numbers."""
        print("\n🔢 Finding icon names starting with numbers...")
        
        numeric_names = [name for name, _ in self.icons if name[0].isdigit()]
        
        if numeric_names:
            print(f"⚠️  Found {len(numeric_names)} icon name(s) starting with numbers:")
            for name in sorted(numeric_names):
                print(f"   • {name}")
        else:
            print("✅ No icon names starting with numbers found!")
        
        return numeric_names

    def add_icon_prefix(self, dry_run: bool = True) -> str:
        """Add 'icon' prefix to names starting with numbers."""
        print(f"\n🔧 {'Simulating' if dry_run else 'Applying'} icon prefix to numeric names...")
        
        numeric_names = self.find_numeric_names()
        if not numeric_names:
            return "No changes needed."

        try:
            with open(self.dart_file_path, 'r', encoding='utf-8') as file:
                content = file.read()

            modified_content = content
            changes_made = []

            for name in numeric_names:
                # Replace the icon definition
                old_pattern = f'static const IconData {name} ='
                new_pattern = f'static const IconData icon{name} ='
                
                if old_pattern in modified_content:
                    modified_content = modified_content.replace(old_pattern, new_pattern)
                    changes_made.append(f"{name} → icon{name}")

            if dry_run:
                print(f"📋 Would make {len(changes_made)} changes:")
                for change in changes_made:
                    print(f"   • {change}")
                return f"Dry run completed. {len(changes_made)} changes would be made."
            else:
                # Write back to file
                with open(self.dart_file_path, 'w', encoding='utf-8') as file:
                    file.write(modified_content)
                
                print(f"✅ Applied {len(changes_made)} changes:")
                for change in changes_made:
                    print(f"   • {change}")
                
                # Reload icons
                self.load_icons()
                return f"Successfully applied {len(changes_made)} changes."

        except Exception as e:
            return f"❌ Error: {e}"

    def sort_icons(self, dry_run: bool = True) -> str:
        """Sort icon definitions alphabetically."""
        print(f"\n📊 {'Simulating' if dry_run else 'Applying'} alphabetical sorting...")
        
        try:
            with open(self.dart_file_path, 'r', encoding='utf-8') as file:
                lines = file.readlines()

            # Find the start and end of icon definitions
            icon_start = -1
            icon_end = -1
            
            for i, line in enumerate(lines):
                if 'static const IconData' in line and icon_start == -1:
                    icon_start = i
                elif 'static const IconData' in line:
                    icon_end = i
            
            if icon_start == -1:
                return "No icon definitions found to sort."
            
            icon_end = icon_end + 1 if icon_end != -1 else len(lines)
            
            # Extract icon lines
            icon_lines = lines[icon_start:icon_end]
            
            # Sort icon lines alphabetically by icon name
            def get_icon_name(line):
                match = re.search(r'static\s+const\s+IconData\s+(\w+)', line)
                return match.group(1) if match else ''
            
            sorted_icon_lines = sorted(icon_lines, key=get_icon_name)
            
            if dry_run:
                print("📋 Icons would be sorted alphabetically")
                print("First 10 icons after sorting:")
                for i, line in enumerate(sorted_icon_lines[:10]):
                    name = get_icon_name(line)
                    if name:
                        print(f"   {i+1:2d}. {name}")
                return "Dry run completed. Icons would be sorted alphabetically."
            else:
                # Reconstruct the file
                new_lines = lines[:icon_start] + sorted_icon_lines + lines[icon_end:]
                
                with open(self.dart_file_path, 'w', encoding='utf-8') as file:
                    file.writelines(new_lines)
                
                print("✅ Icons sorted alphabetically!")
                self.load_icons()
                return "Successfully sorted icons alphabetically."

        except Exception as e:
            return f"❌ Error: {e}"

    def search_icons(self, search_term: str) -> List[Tuple[str, str]]:
        """Search for icons by name."""
        print(f"\n🔍 Searching for icons matching '{search_term}'...")
        
        if not search_term:
            print("❌ Please provide a search term.")
            return []

        search_term_lower = search_term.lower()
        matches = [(name, hex_code) for name, hex_code in self.icons 
                  if search_term_lower in name.lower()]
        
        if matches:
            print(f"✅ Found {len(matches)} matching icon(s):")
            for name, hex_code in matches:
                print(f"   • {name} (0x{hex_code})")
        else:
            print(f"❌ No icons found matching '{search_term}'")
        
        return matches

    def get_statistics(self):
        """Display icon statistics."""
        print(f"\n📊 Icon Statistics:")
        print(f"   Total icons: {len(self.icons)}")
        
        numeric_names = self.find_numeric_names()
        print(f"   Numeric names: {len(numeric_names)}")
        
        duplicates = self.find_duplicate_names()
        print(f"   Duplicate names: {len(duplicates)}")
        
        # Most common prefixes
        prefixes = Counter([name[:3] for name, _ in self.icons if len(name) >= 3])
        top_prefixes = prefixes.most_common(5)
        
        print("   Top 5 prefixes:")
        for prefix, count in top_prefixes:
            print(f"     • {prefix}: {count} icons")

    def fix_duplicate_names(self, dry_run: bool = True) -> str:
        """Add 'Alt' suffix to duplicate icon names."""
        print(f"\n🔧 {'Simulating' if dry_run else 'Applying'} fixes for duplicate icon names...")
        
        # Find duplicates first
        duplicates = self.find_duplicate_names()
        if not duplicates:
            return "No duplicate names found."

        try:
            with open(self.dart_file_path, 'r', encoding='utf-8') as file:
                content = file.read()

            modified_content = content
            changes_made = []

            for name, hex_codes in duplicates.items():
                if len(hex_codes) > 1:
                    # Find all occurrences of this icon name
                    pattern = f'static const IconData {name} ='
                    occurrences = []
                    
                    # Find all line positions where this icon appears
                    lines = modified_content.split('\n')
                    for i, line in enumerate(lines):
                        if pattern in line:
                            occurrences.append((i, line))
                    
                    # Rename all but the first occurrence
                    for idx, (line_num, line) in enumerate(occurrences[1:], 1):
                        old_line = line
                        new_icon_name = f"{name}Alt{idx}"
                        new_line = line.replace(f'IconData {name} =', f'IconData {new_icon_name} =')
                        
                        # Replace in the content
                        lines[line_num] = new_line
                        changes_made.append(f"{name} → {new_icon_name} (occurrence {idx + 1})")
                    
                    modified_content = '\n'.join(lines)

            if dry_run:
                print(f"📋 Would make {len(changes_made)} changes:")
                for change in changes_made:
                    print(f"   • {change}")
                return f"Dry run completed. {len(changes_made)} changes would be made."
            else:
                # Write back to file
                with open(self.dart_file_path, 'w', encoding='utf-8') as file:
                    file.write(modified_content)
                
                print(f"✅ Applied {len(changes_made)} changes:")
                for change in changes_made:
                    print(f"   • {change}")
                
                # Reload icons
                self.load_icons()
                return f"Successfully applied {len(changes_made)} changes."

        except Exception as e:
            return f"❌ Error: {e}"

    def fix_reserved_keywords(self, dry_run: bool = True) -> str:
        """Fix reserved Dart keywords by adding 'icon' prefix."""
        print(f"\n🔧 {'Simulating' if dry_run else 'Applying'} fixes for reserved keyword icon names...")
        
        # List of reserved Dart keywords that might appear as icon names
        reserved_keywords = ['new', 'switch', 'class', 'if', 'else', 'for', 'while', 
                           'do', 'break', 'continue', 'return', 'try', 'catch', 
                           'finally', 'throw', 'extends', 'implements', 'with', 
                           'abstract', 'static', 'final', 'const', 'var', 'void',
                           'dynamic', 'enum', 'typedef', 'assert', 'default',
                           'deferred', 'export', 'external', 'factory', 'get',
                           'import', 'library', 'operator', 'part', 'set',
                           'super', 'this', 'true', 'false', 'null', 'is', 'as']

        try:
            with open(self.dart_file_path, 'r', encoding='utf-8') as file:
                content = file.read()

            modified_content = content
            changes_made = []

            for keyword in reserved_keywords:
                # Look for icon definitions using reserved keywords
                # Also fix the syntax error (= instead of :)
                patterns = [
                    f'static const IconData {keyword} = IconData(',
                    f'static const IconData {keyword} =IconData(',  # no space
                    f'static const IconData {keyword}= IconData(',   # no space before =
                    f'static const IconData {keyword}=IconData(',    # no spaces
                ]
                
                for pattern in patterns:
                    if pattern in modified_content:
                        new_pattern = pattern.replace(f'IconData {keyword}', f'IconData icon{keyword.capitalize()}')
                        modified_content = modified_content.replace(pattern, new_pattern)
                        changes_made.append(f"{keyword} → icon{keyword.capitalize()}")

            # Also fix specific syntax errors with fontFamily assignment (= instead of :)
            syntax_fixes = [
                ('fontFamily = _fontFamily', 'fontFamily: _fontFamily'),
                ('fontFamily= _fontFamily', 'fontFamily: _fontFamily'),
                ('fontFamily =_fontFamily', 'fontFamily: _fontFamily'),
                ('fontFamily=_fontFamily', 'fontFamily: _fontFamily'),
            ]
            
            for old_syntax, new_syntax in syntax_fixes:
                if old_syntax in modified_content:
                    modified_content = modified_content.replace(old_syntax, new_syntax)
                    changes_made.append(f"Fixed syntax: {old_syntax} → {new_syntax}")

            if dry_run:
                if changes_made:
                    print(f"📋 Would make {len(changes_made)} changes:")
                    for change in changes_made:
                        print(f"   • {change}")
                else:
                    print("✅ No reserved keyword issues found!")
                return f"Dry run completed. {len(changes_made)} changes would be made."
            else:
                if changes_made:
                    # Write back to file
                    with open(self.dart_file_path, 'w', encoding='utf-8') as file:
                        file.write(modified_content)
                    
                    print(f"✅ Applied {len(changes_made)} changes:")
                    for change in changes_made:
                        print(f"   • {change}")
                    
                    # Reload icons
                    self.load_icons()
                    return f"Successfully applied {len(changes_made)} changes."
                else:
                    print("✅ No reserved keyword issues found!")
                    return "No changes needed."

        except Exception as e:
            return f"❌ Error: {e}"

    def fix_missing_imports(self, dry_run: bool = True) -> str:
        """Add missing Flutter material imports if not present."""
        print(f"\n🔧 {'Simulating' if dry_run else 'Applying'} import fixes...")
        
        try:
            with open(self.dart_file_path, 'r', encoding='utf-8') as file:
                content = file.read()

            # Check if material import is already present
            material_import = "import 'package:flutter/material.dart';"
            
            if material_import in content:
                print("✅ Material import already present!")
                return "No import fixes needed."

            # Find the right place to add the import (after comments, before class)
            lines = content.split('\n')
            insert_position = 0
            
            # Skip initial comments and find the right insertion point
            for i, line in enumerate(lines):
                stripped = line.strip()
                if stripped and not stripped.startswith('/*') and not stripped.startswith('*') and not stripped.startswith('//'):
                    # Found first non-comment line
                    insert_position = i
                    break
            
            # Insert the import
            lines.insert(insert_position, material_import)
            lines.insert(insert_position + 1, '')  # Add empty line for formatting
            
            modified_content = '\n'.join(lines)
            
            if dry_run:
                print(f"📋 Would add material import at line {insert_position + 1}")
                return "Dry run completed. Material import would be added."
            else:
                # Write back to file
                with open(self.dart_file_path, 'w', encoding='utf-8') as file:
                    file.write(modified_content)
                
                print(f"✅ Added material import at line {insert_position + 1}")
                return "Successfully added material import."

        except Exception as e:
            return f"❌ Error: {e}"

    def fix_all_issues(self, dry_run: bool = True) -> str:
        """Fix all identified issues: imports, duplicates, and reserved keywords."""
        print(f"\n🚀 {'Simulating' if dry_run else 'Applying'} comprehensive fixes...")
        
        results = []
        
        # 1. Fix missing imports
        result1 = self.fix_missing_imports(dry_run)
        results.append(f"Imports: {result1}")
        
        # 2. Fix reserved keywords  
        result2 = self.fix_reserved_keywords(dry_run)
        results.append(f"Keywords: {result2}")
        
        # 3. Fix duplicate names
        result3 = self.fix_duplicate_names(dry_run)
        results.append(f"Duplicates: {result3}")
        
        print(f"\n{'📋' if dry_run else '✅'} Complete fix summary:")
        for result in results:
            print(f"   • {result}")
        
        if not dry_run:
            print(f"\n🎉 All fixes applied! Reloading icons...")
            self.load_icons()
        
        return "Comprehensive fixes completed."


def main():
    """Main interactive menu."""
    print("🎯 Prbal Icons Manager")
    print("=" * 50)
    
    # Initialize icon manager
    icon_manager = IconManager()
    
    if not icon_manager.icons:
        print("❌ No icons loaded. Exiting.")
        return

    while True:
        print("\n📋 Menu Options:")
        print("1. 🔍 Find duplicate icon names")
        print("2. 🔢 Add 'icon' prefix to names starting with numbers")
        print("3. 📊 Sort icon names alphabetically")
        print("4. 🔍 Search icon names")
        print("5. 📊 Show statistics")
        print("6. 🔄 Reload icons from file")
        print("7. 🔧 Fix duplicate names (add Alt suffix)")
        print("8. 🔑 Fix reserved keywords (add icon prefix)")
        print("9. 📥 Fix missing imports")
        print("10. 🚀 Fix all issues (comprehensive)")
        print("11. ❌ Exit")
        
        try:
            choice = input("\n➤ Enter your choice (1-11): ").strip()
            
            if choice == '1':
                icon_manager.find_duplicate_names()
                
            elif choice == '2':
                print("\n⚠️  This will modify your Dart file!")
                dry_run = input("➤ Run in dry-run mode first? (y/n): ").strip().lower() == 'y'
                result = icon_manager.add_icon_prefix(dry_run=dry_run)
                print(f"\n📋 Result: {result}")
                
                if dry_run and input("\n➤ Apply changes? (y/n): ").strip().lower() == 'y':
                    result = icon_manager.add_icon_prefix(dry_run=False)
                    print(f"\n📋 Result: {result}")
                
            elif choice == '3':
                print("\n⚠️  This will modify your Dart file!")
                dry_run = input("➤ Run in dry-run mode first? (y/n): ").strip().lower() == 'y'
                result = icon_manager.sort_icons(dry_run=dry_run)
                print(f"\n📋 Result: {result}")
                
                if dry_run and input("\n➤ Apply changes? (y/n): ").strip().lower() == 'y':
                    result = icon_manager.sort_icons(dry_run=False)
                    print(f"\n📋 Result: {result}")
                
            elif choice == '4':
                search_term = input("➤ Enter search term: ").strip()
                icon_manager.search_icons(search_term)
                
            elif choice == '5':
                icon_manager.get_statistics()
                
            elif choice == '6':
                icon_manager.load_icons()
                
            elif choice == '7':
                print("\n⚠️  This will modify your Dart file!")
                dry_run = input("➤ Run in dry-run mode first? (y/n): ").strip().lower() == 'y'
                result = icon_manager.fix_duplicate_names(dry_run=dry_run)
                print(f"\n📋 Result: {result}")
                
                if dry_run and input("\n➤ Apply changes? (y/n): ").strip().lower() == 'y':
                    result = icon_manager.fix_duplicate_names(dry_run=False)
                    print(f"\n📋 Result: {result}")
                    
            elif choice == '8':
                print("\n⚠️  This will modify your Dart file!")
                dry_run = input("➤ Run in dry-run mode first? (y/n): ").strip().lower() == 'y'
                result = icon_manager.fix_reserved_keywords(dry_run=dry_run)
                print(f"\n📋 Result: {result}")
                
                if dry_run and input("\n➤ Apply changes? (y/n): ").strip().lower() == 'y':
                    result = icon_manager.fix_reserved_keywords(dry_run=False)
                    print(f"\n📋 Result: {result}")
                    
            elif choice == '9':
                print("\n⚠️  This will modify your Dart file!")
                dry_run = input("➤ Run in dry-run mode first? (y/n): ").strip().lower() == 'y'
                result = icon_manager.fix_missing_imports(dry_run=dry_run)
                print(f"\n📋 Result: {result}")
                
                if dry_run and input("\n➤ Apply changes? (y/n): ").strip().lower() == 'y':
                    result = icon_manager.fix_missing_imports(dry_run=False)
                    print(f"\n📋 Result: {result}")
                
            elif choice == '10':
                print("\n⚠️  This will modify your Dart file!")
                dry_run = input("➤ Run in dry-run mode first? (y/n): ").strip().lower() == 'y'
                result = icon_manager.fix_all_issues(dry_run=dry_run)
                print(f"\n📋 Result: {result}")
                
                if dry_run and input("\n➤ Apply changes? (y/n): ").strip().lower() == 'y':
                    result = icon_manager.fix_all_issues(dry_run=False)
                    print(f"\n📋 Result: {result}")
                
            elif choice == '11':
                print("\n👋 Goodbye!")
                break
                
            else:
                print("❌ Invalid choice. Please try again.")
                
        except KeyboardInterrupt:
            print("\n\n👋 Goodbye!")
            break
        except Exception as e:
            print(f"❌ Error: {e}")


if __name__ == "__main__":
    main() 