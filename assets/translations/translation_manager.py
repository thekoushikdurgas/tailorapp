#!/usr/bin/env python3
"""
TailorAI Translation Management Tool

This interactive tool helps manage translation files for the TailorAI Flutter application.
It provides functionality to:
- Validate JSON structure
- Find missing keys across language files
- Synchronize keys across all translations
- Generate comprehensive reports
- Backup files before modifications

Author: AI Assistant for TailorAI
Version: 1.0.0
"""

import json
import os
import sys
import shutil
import datetime
from pathlib import Path
from typing import Dict, List, Set, Any, Optional, Tuple
from collections import defaultdict
import argparse


class TranslationManager:
    """Main class for managing translation files."""

    def __init__(self, translations_dir: str = "json"):
        """Initialize the Translation Manager.

        Args:
            translations_dir: Directory containing translation JSON files
        """
        self.base_dir = Path(__file__).parent
        self.translations_dir = self.base_dir / translations_dir
        self.backup_dir = self.base_dir / "backups"

        # Supported languages based on project configuration
        self.supported_languages = [
            "en-US",  # English (Primary)
            "as-IN",
            "bn-IN",
            "brx-IN",
            "doi-IN",
            "gu-IN",
            "hi-IN",
            "kn-IN",
            "kok-IN",
            "ks-IN",
            "mai-IN",
            "ml-IN",
            "mni-IN",
            "mr-IN",
            "ne-IN",
            "or-IN",
            "pa-IN",
            "sa-IN",
            "sat-IN",
            "sd-IN",
            "ta-IN",
            "te-IN",
            "ur-IN",
        ]

        # Initialize directories
        self._setup_directories()

        print("🌍 TailorAI Translation Manager v1.0.0")
        print(f"📁 Working directory: {self.translations_dir}")
        print(f"🔧 Supporting {len(self.supported_languages)} languages")
        print("=" * 60)

    def _setup_directories(self):
        """Create necessary directories if they don't exist."""
        self.translations_dir.mkdir(exist_ok=True)
        self.backup_dir.mkdir(exist_ok=True)

    def get_translation_files(self) -> Dict[str, Path]:
        """Get all translation files in the directory.

        Returns:
            Dictionary mapping language codes to file paths
        """
        files = {}
        for lang in self.supported_languages:
            file_path = self.translations_dir / f"{lang}.json"
            if file_path.exists():
                files[lang] = file_path
        return files

    def validate_json_files(self) -> Dict[str, Any]:
        """Validate all JSON translation files.

        Returns:
            Dictionary with validation results
        """
        print("\n🔍 Validating JSON files...")

        files = self.get_translation_files()
        results = {
            "valid": [],
            "invalid": [],
            "missing": [],
            "total_files": len(files),
            "total_supported": len(self.supported_languages),
        }

        # Check for missing files
        for lang in self.supported_languages:
            if lang not in files:
                results["missing"].append(lang)

        # Validate existing files
        for lang, file_path in files.items():
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    json.load(f)
                results["valid"].append(lang)
                print(f"  ✅ {lang}.json - Valid")
            except json.JSONDecodeError as e:
                results["invalid"].append(
                    {
                        "language": lang,
                        "error": str(e),
                        "line": getattr(e, "lineno", "unknown"),
                        "column": getattr(e, "colno", "unknown"),
                    }
                )
                print(f"  ❌ {lang}.json - Invalid: {e}")
            except Exception as e:
                results["invalid"].append(
                    {
                        "language": lang,
                        "error": str(e),
                        "line": "unknown",
                        "column": "unknown",
                    }
                )
                print(f"  ❌ {lang}.json - Error: {e}")

        return results

    def get_all_keys(self, data: Dict, prefix: str = "") -> Set[str]:
        """Recursively get all keys from a nested dictionary.

        Args:
            data: Dictionary to extract keys from
            prefix: Prefix for nested keys

        Returns:
            Set of all dot-notation keys
        """
        keys = set()
        for key, value in data.items():
            current_key = f"{prefix}.{key}" if prefix else key
            keys.add(current_key)

            if isinstance(value, dict):
                keys.update(self.get_all_keys(value, current_key))

        return keys

    def analyze_translation_keys(self) -> Dict[str, Any]:
        """Analyze keys across all translation files.

        Returns:
            Dictionary with key analysis results
        """
        print("\n🔑 Analyzing translation keys...")

        files = self.get_translation_files()
        all_keys = set()
        file_keys = {}

        # Load all files and extract keys
        for lang, file_path in files.items():
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                keys = self.get_all_keys(data)
                file_keys[lang] = keys
                all_keys.update(keys)
                print(f"  📄 {lang}.json - {len(keys)} keys")
            except Exception as e:
                print(f"  ❌ {lang}.json - Error reading: {e}")
                file_keys[lang] = set()

        # Find missing keys for each file
        missing_keys = {}
        for lang in files:
            missing = all_keys - file_keys.get(lang, set())
            if missing:
                missing_keys[lang] = missing

        results = {
            "total_unique_keys": len(all_keys),
            "all_keys": sorted(all_keys),
            "file_keys": file_keys,
            "missing_keys": missing_keys,
            "files_with_missing_keys": len(missing_keys),
            "complete_files": [lang for lang in files if lang not in missing_keys],
        }

        return results

    def set_nested_value(self, data: Dict, key_path: str, value: Any):
        """Set a value in a nested dictionary using dot notation.

        Args:
            data: Dictionary to modify
            key_path: Dot-notation path (e.g., 'auth.phoneLogin.title')
            value: Value to set
        """
        keys = key_path.split(".")
        current = data

        for key in keys[:-1]:
            if key not in current:
                current[key] = {}
            elif not isinstance(current[key], dict):
                # If the existing value is not a dict (e.g., it's a string),
                # we need to convert it to a dict to allow nesting
                print(
                    f"    ⚠️  Converting '{key}' from {type(current[key]).__name__} to dict for nesting"
                )
                current[key] = {}
            current = current[key]

        current[keys[-1]] = value

    def synchronize_keys(self, dry_run: bool = True) -> Dict[str, Any]:
        """Synchronize keys across all translation files.

        Args:
            dry_run: If True, only simulate changes without writing files

        Returns:
            Dictionary with synchronization results
        """
        print(f"\n🔄 {'Simulating' if dry_run else 'Executing'} key synchronization...")

        if not dry_run:
            self.create_backup()

        analysis = self.analyze_translation_keys()
        files = self.get_translation_files()
        changes_made = {}

        for lang, missing_keys in analysis["missing_keys"].items():
            if not missing_keys:
                continue

            file_path = files[lang]
            changes_made[lang] = list(missing_keys)

            print(f"  📝 {lang}.json - Adding {len(missing_keys)} missing keys")

            if not dry_run:
                # Load current data
                with open(file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)

                # Add missing keys with empty strings
                for key in missing_keys:
                    self.set_nested_value(data, key, "")
                    print(f"    + {key}")

                # Write back to file
                with open(file_path, "w", encoding="utf-8") as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)

        result = {
            "dry_run": dry_run,
            "files_modified": len(changes_made),
            "changes_made": changes_made,
            "total_keys_added": sum(len(keys) for keys in changes_made.values()),
        }

        return result

    def create_backup(self) -> str:
        """Create a backup of all translation files.

        Returns:
            Path to the backup directory
        """
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = self.backup_dir / f"backup_{timestamp}"
        backup_path.mkdir(exist_ok=True)

        files = self.get_translation_files()
        for lang, file_path in files.items():
            shutil.copy2(file_path, backup_path / f"{lang}.json")

        print(f"💾 Backup created: {backup_path}")
        return str(backup_path)

    def generate_report(self) -> str:
        """Generate a comprehensive translation status report.

        Returns:
            Report as a formatted string
        """
        print("\n📊 Generating comprehensive report...")

        validation = self.validate_json_files()
        analysis = self.analyze_translation_keys()

        report_lines = [
            "=" * 80,
            "🌍 TAILORAI TRANSLATION STATUS REPORT",
            "=" * 80,
            f"Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            f"Directory: {self.translations_dir}",
            "",
            "📈 SUMMARY",
            "-" * 40,
            f"Total Supported Languages: {len(self.supported_languages)}",
            f"Files Present: {validation['total_files']}",
            f"Valid JSON Files: {len(validation['valid'])}",
            f"Invalid JSON Files: {len(validation['invalid'])}",
            f"Missing Files: {len(validation['missing'])}",
            "",
            f"Total Unique Keys: {analysis['total_unique_keys']}",
            f"Files with Missing Keys: {analysis['files_with_missing_keys']}",
            f"Complete Files: {len(analysis['complete_files'])}",
            "",
        ]

        # Missing files section
        if validation["missing"]:
            report_lines.extend(
                [
                    "❌ MISSING FILES",
                    "-" * 40,
                ]
            )
            for lang in validation["missing"]:
                report_lines.append(f"  • {lang}.json")
            report_lines.append("")

        # Invalid files section
        if validation["invalid"]:
            report_lines.extend(
                [
                    "🚫 INVALID JSON FILES",
                    "-" * 40,
                ]
            )
            for error_info in validation["invalid"]:
                lang = error_info["language"]
                error = error_info["error"]
                line = error_info["line"]
                col = error_info["column"]
                report_lines.append(
                    f"  • {lang}.json - Line {line}, Col {col}: {error}"
                )
            report_lines.append("")

        # Missing keys section
        if analysis["missing_keys"]:
            report_lines.extend(
                [
                    "🔑 MISSING KEYS BY FILE",
                    "-" * 40,
                ]
            )
            for lang, missing_keys in analysis["missing_keys"].items():
                report_lines.append(
                    f"  📄 {lang}.json ({len(missing_keys)} missing keys):"
                )
                for key in sorted(missing_keys)[:10]:  # Show first 10
                    report_lines.append(f"    - {key}")
                if len(missing_keys) > 10:
                    report_lines.append(f"    ... and {len(missing_keys) - 10} more")
                report_lines.append("")

        # Complete files section
        if analysis["complete_files"]:
            report_lines.extend(
                [
                    "✅ COMPLETE FILES (All keys present)",
                    "-" * 40,
                ]
            )
            for lang in analysis["complete_files"]:
                key_count = len(analysis["file_keys"].get(lang, []))
                report_lines.append(f"  • {lang}.json ({key_count} keys)")
            report_lines.append("")

        # Language coverage
        report_lines.extend(
            [
                "🌐 LANGUAGE COVERAGE",
                "-" * 40,
            ]
        )
        for lang in self.supported_languages:
            status = "✅" if lang in validation["valid"] else "❌"
            key_count = len(analysis["file_keys"].get(lang, []))
            missing_count = len(analysis["missing_keys"].get(lang, []))
            report_lines.append(
                f"  {status} {lang:6} - {key_count:3} keys, {missing_count:3} missing"
            )

        report_lines.extend(
            [
                "",
                "=" * 80,
            ]
        )

        return "\n".join(report_lines)

    def create_missing_files(self, template_lang: str = "en-US") -> Dict[str, Any]:
        """Create missing translation files using a template.

        Args:
            template_lang: Language to use as template

        Returns:
            Dictionary with creation results
        """
        print(f"\n📄 Creating missing files using {template_lang} as template...")

        template_path = self.translations_dir / f"{template_lang}.json"
        if not template_path.exists():
            return {"error": f"Template file {template_lang}.json not found"}

        # Load template
        with open(template_path, "r", encoding="utf-8") as f:
            template_data = json.load(f)

        # Create empty version of template
        def create_empty_structure(data):
            if isinstance(data, dict):
                return {k: create_empty_structure(v) for k, v in data.items()}
            else:
                return ""

        empty_structure = create_empty_structure(template_data)

        validation = self.validate_json_files()
        created_files = []

        for lang in validation["missing"]:
            file_path = self.translations_dir / f"{lang}.json"
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(empty_structure, f, ensure_ascii=False, indent=2)
            created_files.append(lang)
            print(f"  ✅ Created {lang}.json")

        return {
            "created_files": created_files,
            "template_used": template_lang,
            "files_created": len(created_files),
        }

    def sort_json_keys_alphabetically(self, data: Any) -> Any:
        """Recursively sort JSON keys alphabetically.

        Args:
            data: JSON data to sort (dict, list, or primitive)

        Returns:
            Data with alphabetically sorted keys
        """
        if isinstance(data, dict):
            # Sort keys alphabetically and recursively sort nested structures
            return {
                k: self.sort_json_keys_alphabetically(v)
                for k, v in sorted(data.items())
            }
        elif isinstance(data, list):
            # Process each item in the list
            return [self.sort_json_keys_alphabetically(item) for item in data]
        else:
            # Return primitive values as-is
            return data

    def format_json_files(self, dry_run: bool = True) -> Dict[str, Any]:
        """Format JSON files with alphabetically sorted keys.

        Args:
            dry_run: If True, only simulate changes without writing files

        Returns:
            Dictionary with formatting results
        """
        print(f"\n🔤 {'Simulating' if dry_run else 'Executing'} JSON key formatting...")

        if not dry_run:
            self.create_backup()

        files = self.get_translation_files()
        results = {
            "dry_run": dry_run,
            "files_processed": 0,
            "files_modified": 0,
            "formatting_details": {},
        }

        for lang, file_path in files.items():
            try:
                # Read current file
                with open(file_path, "r", encoding="utf-8") as f:
                    original_data = json.load(f)

                # Sort keys alphabetically
                sorted_data = self.sort_json_keys_alphabetically(original_data)

                # Convert to JSON strings for comparison
                original_json = json.dumps(
                    original_data, ensure_ascii=False, indent=2, sort_keys=False
                )
                sorted_json = json.dumps(
                    sorted_data, ensure_ascii=False, indent=2, sort_keys=False
                )

                results["files_processed"] += 1

                if original_json != sorted_json:
                    results["files_modified"] += 1
                    results["formatting_details"][lang] = {
                        "keys_reordered": True,
                        "file_size_before": len(original_json),
                        "file_size_after": len(sorted_json),
                    }

                    print(f"  📝 {lang}.json - Keys will be alphabetically sorted")

                    if not dry_run:
                        # Write sorted data back to file
                        with open(file_path, "w", encoding="utf-8") as f:
                            json.dump(sorted_data, f, ensure_ascii=False, indent=2)
                        print(f"    ✅ Formatted and saved")
                else:
                    results["formatting_details"][lang] = {
                        "keys_reordered": False,
                        "already_sorted": True,
                    }
                    print(f"  ✅ {lang}.json - Already alphabetically sorted")

            except Exception as e:
                print(f"  ❌ {lang}.json - Error: {e}")
                results["formatting_details"][lang] = {
                    "error": str(e),
                    "keys_reordered": False,
                }

        return results

    def empty_all_json_files(self, dry_run: bool = True) -> Dict[str, Any]:
        """Empty all JSON files, making them just {}.

        Args:
            dry_run: If True, only simulate changes without writing files

        Returns:
            Dictionary with operation results
        """
        print(f"\n🗑️  {'Simulating' if dry_run else 'Executing'} JSON file emptying...")

        if not dry_run:
            self.create_backup()

        files = self.get_translation_files()
        results = {
            "dry_run": dry_run,
            "files_processed": 0,
            "files_emptied": 0,
            "operation_details": {},
        }

        empty_json = {}

        for lang, file_path in files.items():
            try:
                # Read current file to check if it's already empty
                with open(file_path, "r", encoding="utf-8") as f:
                    current_data = json.load(f)

                results["files_processed"] += 1

                if current_data != empty_json:
                    results["files_emptied"] += 1
                    key_count = len(self.get_all_keys(current_data))
                    results["operation_details"][lang] = {
                        "was_empty": False,
                        "keys_before": key_count,
                        "file_size_before": file_path.stat().st_size,
                    }

                    print(
                        f"  🗑️  {lang}.json - Will be emptied ({key_count} keys removed)"
                    )

                    if not dry_run:
                        # Write empty JSON to file
                        with open(file_path, "w", encoding="utf-8") as f:
                            json.dump(empty_json, f, ensure_ascii=False, indent=2)
                        print(f"    ✅ Emptied and saved")
                        results["operation_details"][lang][
                            "file_size_after"
                        ] = file_path.stat().st_size
                else:
                    results["operation_details"][lang] = {
                        "was_empty": True,
                        "keys_before": 0,
                    }
                    print(f"  ✅ {lang}.json - Already empty")

            except Exception as e:
                print(f"  ❌ {lang}.json - Error: {e}")
                results["operation_details"][lang] = {
                    "error": str(e),
                    "was_empty": False,
                }

        return results


def display_menu():
    """Display the interactive menu."""
    print("\n" + "=" * 60)
    print("🌍 TAILORAI TRANSLATION MANAGER")
    print("=" * 60)
    print("1. 🔍 Validate JSON Files")
    print("2. 🔑 Analyze Translation Keys")
    print("3. 🔄 Synchronize Keys (Dry Run)")
    print("4. ✅ Synchronize Keys (Execute)")
    print("5. 📄 Create Missing Files")
    print("6. 📊 Generate Report")
    print("7. 💾 Create Backup")
    print("8. 🔤 Format JSON Keys (Dry Run)")
    print("9. ✨ Format JSON Keys (Execute)")
    print("10. 📋 List Supported Languages")
    print("11. 🗑️  Empty JSON Files (Dry Run)")
    print("12. 🗑️  Empty JSON Files (Execute)")
    print("13. 🚪 Exit")
    print("=" * 60)


def main():
    """Main function to run the translation manager."""
    parser = argparse.ArgumentParser(description="TailorAI Translation Manager")
    parser.add_argument("--dir", default="json", help="Translation files directory")
    parser.add_argument(
        "--auto-sync", action="store_true", help="Auto-sync missing keys"
    )
    parser.add_argument(
        "--report-only", action="store_true", help="Generate report and exit"
    )

    args = parser.parse_args()

    try:
        manager = TranslationManager(args.dir)

        # Handle command line arguments
        if args.report_only:
            report = manager.generate_report()
            print(report)
            return

        if args.auto_sync:
            print("🔄 Auto-synchronizing keys...")
            result = manager.synchronize_keys(dry_run=False)
            print(
                f"✅ Synchronized {result['total_keys_added']} keys across {result['files_modified']} files"
            )
            return

        # Interactive menu
        while True:
            display_menu()
            choice = input("\n🎯 Select an option (1-13): ").strip()

            if choice == "1":
                validation = manager.validate_json_files()
                print(f"\n📊 Validation Summary:")
                print(f"  Valid files: {len(validation['valid'])}")
                print(f"  Invalid files: {len(validation['invalid'])}")
                print(f"  Missing files: {len(validation['missing'])}")

            elif choice == "2":
                analysis = manager.analyze_translation_keys()
                print(f"\n📊 Key Analysis Summary:")
                print(f"  Total unique keys: {analysis['total_unique_keys']}")
                print(
                    f"  Files with missing keys: {analysis['files_with_missing_keys']}"
                )
                print(f"  Complete files: {len(analysis['complete_files'])}")

            elif choice == "3":
                result = manager.synchronize_keys(dry_run=True)
                print(f"\n📊 Synchronization Preview:")
                print(f"  Files to modify: {result['files_modified']}")
                print(f"  Total keys to add: {result['total_keys_added']}")

            elif choice == "4":
                confirm = (
                    input("\n⚠️  This will modify files. Continue? (y/N): ")
                    .strip()
                    .lower()
                )
                if confirm == "y":
                    result = manager.synchronize_keys(dry_run=False)
                    print(f"\n✅ Synchronization Complete:")
                    print(f"  Files modified: {result['files_modified']}")
                    print(f"  Total keys added: {result['total_keys_added']}")
                else:
                    print("❌ Synchronization cancelled")

            elif choice == "5":
                template = (
                    input("\n📝 Template language (default: en-US): ").strip()
                    or "en-US"
                )
                result = manager.create_missing_files(template)
                if "error" in result:
                    print(f"❌ Error: {result['error']}")
                else:
                    print(
                        f"✅ Created {result['files_created']} files using {result['template_used']} template"
                    )

            elif choice == "6":
                report = manager.generate_report()
                print(report)

                save_report = input("\n💾 Save report to file? (y/N): ").strip().lower()
                if save_report == "y":
                    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                    report_file = (
                        manager.base_dir / f"translation_report_{timestamp}.txt"
                    )
                    with open(report_file, "w", encoding="utf-8") as f:
                        f.write(report)
                    print(f"📄 Report saved to: {report_file}")

            elif choice == "7":
                backup_path = manager.create_backup()
                print(f"✅ Backup created successfully")

            elif choice == "8":
                result = manager.format_json_files(dry_run=True)
                print(f"\n📊 JSON Formatting Preview:")
                print(f"  Files processed: {result['files_processed']}")
                print(f"  Files to modify: {result['files_modified']}")

                if result["files_modified"] > 0:
                    print(f"\n📝 Files that will be formatted:")
                    for lang, details in result["formatting_details"].items():
                        if details.get("keys_reordered", False):
                            print(f"    • {lang}.json")

            elif choice == "9":
                confirm = (
                    input("\n⚠️  This will modify files. Continue? (y/N): ")
                    .strip()
                    .lower()
                )
                if confirm == "y":
                    result = manager.format_json_files(dry_run=False)
                    print(f"\n✅ JSON Formatting Complete:")
                    print(f"  Files processed: {result['files_processed']}")
                    print(f"  Files modified: {result['files_modified']}")

                    if result["files_modified"] > 0:
                        print(f"\n✨ Formatted files:")
                        for lang, details in result["formatting_details"].items():
                            if details.get("keys_reordered", False):
                                print(f"    • {lang}.json - Keys alphabetically sorted")
                else:
                    print("❌ JSON formatting cancelled")

            elif choice == "10":
                print(f"\n🌐 Supported Languages ({len(manager.supported_languages)}):")
                for i, lang in enumerate(manager.supported_languages, 1):
                    marker = "🇺🇸" if lang == "en-US" else "🇮🇳"
                    print(f"  {i:2d}. {marker} {lang}")

            elif choice == "11":
                result = manager.empty_all_json_files(dry_run=True)
                print(f"\n📊 JSON Emptying Preview:")
                print(f"  Files processed: {result['files_processed']}")
                print(f"  Files to empty: {result['files_emptied']}")

                if result["files_emptied"] > 0:
                    print(f"\n🗑️  Files that will be emptied:")
                    for lang, details in result["operation_details"].items():
                        if not details.get("was_empty", True):
                            keys_count = details.get("keys_before", 0)
                            print(
                                f"    • {lang}.json ({keys_count} keys will be removed)"
                            )

            elif choice == "12":
                confirm = (
                    input(
                        "\n⚠️  This will PERMANENTLY DELETE all translation content! Continue? (y/N): "
                    )
                    .strip()
                    .lower()
                )
                if confirm == "y":
                    double_confirm = input(
                        "\n⚠️  Are you ABSOLUTELY SURE? This cannot be undone! Type 'DELETE' to confirm: "
                    ).strip()
                    if double_confirm == "DELETE":
                        result = manager.empty_all_json_files(dry_run=False)
                        print(f"\n✅ JSON Emptying Complete:")
                        print(f"  Files processed: {result['files_processed']}")
                        print(f"  Files emptied: {result['files_emptied']}")

                        if result["files_emptied"] > 0:
                            print(f"\n🗑️  Emptied files:")
                            for lang, details in result["operation_details"].items():
                                if not details.get("was_empty", True):
                                    keys_removed = details.get("keys_before", 0)
                                    print(
                                        f"    • {lang}.json - {keys_removed} keys removed"
                                    )
                    else:
                        print("❌ JSON emptying cancelled - incorrect confirmation")
                else:
                    print("❌ JSON emptying cancelled")

            elif choice == "13":
                print("\n👋 Thank you for using TailorAI Translation Manager!")
                break

            else:
                print("\n❌ Invalid option. Please select 1-13.")

            input("\n📱 Press Enter to continue...")

    except KeyboardInterrupt:
        print("\n\n👋 Goodbye!")
    except Exception as e:
        print(f"\n❌ An error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
