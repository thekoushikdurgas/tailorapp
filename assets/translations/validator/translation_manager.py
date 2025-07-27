#!/usr/bin/env python3
"""
Translation Manager AI Agent
===========================

An intelligent agent to manage multilingual JSON translation files.
This script ensures all translation files are:
- Properly formatted JSON
- Have consistent key structures
- Missing keys are filled with empty strings
- Maintains nested object hierarchy

Author: AI Translation Manager
Version: 1.0.0
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Set, Any, Union
from collections import defaultdict
import argparse
from datetime import datetime


class TranslationManagerAI:
    """AI Agent for managing translation JSON files"""

    def __init__(self, translations_dir: str = None):
        self.translations_dir = (
            Path(translations_dir) if translations_dir else Path(__file__).parent
        )
        self.language_files = {}
        self.all_keys = set()
        self.errors = []
        self.warnings = []
        self.stats = {
            "total_files": 0,
            "valid_files": 0,
            "invalid_files": 0,
            "total_keys": 0,
            "missing_keys_added": 0,
            "files_updated": 0,
        }

        # Supported language codes
        self.supported_languages = {
            "as-IN",
            "bn-IN",
            "brx-IN",
            "doi-IN",
            "en-US",
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
        }

    def log(self, message: str, level: str = "INFO"):
        """Enhanced logging with timestamps"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] {level}: {message}")

        if level == "ERROR":
            self.errors.append(message)
        elif level == "WARNING":
            self.warnings.append(message)

    def discover_translation_files(self) -> List[Path]:
        """Discover all translation JSON files in the directory"""
        files = []
        for lang_code in self.supported_languages:
            file_path = self.translations_dir / f"{lang_code}.json"
            if file_path.exists():
                files.append(file_path)
                self.log(f"Found translation file: {file_path.name}")
            else:
                self.log(f"Missing translation file: {file_path.name}", "WARNING")

        # Also check for any other JSON files
        for json_file in self.translations_dir.glob("*.json"):
            if (
                json_file not in files
                and json_file.name != "translation_manager_report.json"
            ):
                files.append(json_file)
                self.log(f"Found additional JSON file: {json_file.name}")

        self.stats["total_files"] = len(files)
        return files

    def validate_json_format(
        self, file_path: Path
    ) -> tuple[bool, Dict[str, Any] | None]:
        """Validate JSON format and return parsed data"""
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read().strip()

            if not content:
                self.log(f"Empty file: {file_path.name}", "ERROR")
                return False, None

            data = json.loads(content)
            self.log(f"✓ Valid JSON format: {file_path.name}")
            return True, data

        except json.JSONDecodeError as e:
            self.log(f"✗ Invalid JSON in {file_path.name}: {e}", "ERROR")
            return False, None
        except Exception as e:
            self.log(f"✗ Error reading {file_path.name}: {e}", "ERROR")
            return False, None

    def extract_nested_keys(self, data: Dict[str, Any], prefix: str = "") -> Set[str]:
        """Extract all nested keys from a dictionary with dot notation"""
        keys = set()

        for key, value in data.items():
            current_key = f"{prefix}.{key}" if prefix else key
            keys.add(current_key)

            if isinstance(value, dict):
                keys.update(self.extract_nested_keys(value, current_key))

        return keys

    def set_nested_value(self, data: Dict[str, Any], key_path: str, value: Any):
        """Set a value in a nested dictionary using dot notation"""
        keys = key_path.split(".")
        current = data

        for key in keys[:-1]:
            if key not in current:
                current[key] = {}
            elif not isinstance(current[key], dict):
                # Convert non-dict values to dict if needed
                current[key] = {}
            current = current[key]

        current[keys[-1]] = value

    def get_nested_value(self, data: Dict[str, Any], key_path: str) -> Any:
        """Get a value from nested dictionary using dot notation"""
        keys = key_path.split(".")
        current = data

        try:
            for key in keys:
                current = current[key]
            return current
        except (KeyError, TypeError):
            return None

    def analyze_translations(self):
        """Analyze all translation files"""
        self.log("🤖 Starting Translation Analysis...")

        files = self.discover_translation_files()

        if not files:
            self.log("No translation files found!", "ERROR")
            return

        # Load and validate all files
        for file_path in files:
            is_valid, data = self.validate_json_format(file_path)

            if is_valid and data:
                lang_code = file_path.stem
                self.language_files[lang_code] = data
                file_keys = self.extract_nested_keys(data)
                self.all_keys.update(file_keys)
                self.stats["valid_files"] += 1
                self.log(f"Loaded {len(file_keys)} keys from {file_path.name}")
            else:
                self.stats["invalid_files"] += 1

        self.stats["total_keys"] = len(self.all_keys)
        self.log(
            f"📊 Analysis complete: {len(self.all_keys)} unique keys found across {len(self.language_files)} files"
        )

    def find_missing_keys(self) -> Dict[str, Set[str]]:
        """Find missing keys in each language file"""
        missing_keys = {}

        self.log("🔍 Analyzing missing keys...")

        for lang_code, data in self.language_files.items():
            file_keys = self.extract_nested_keys(data)
            missing = self.all_keys - file_keys

            if missing:
                missing_keys[lang_code] = missing
                self.log(f"📋 {lang_code}: {len(missing)} missing keys")

                # Log some examples of missing keys
                sample_keys = list(missing)[:5]
                for key in sample_keys:
                    self.log(f"   - {key}", "WARNING")
                if len(missing) > 5:
                    self.log(f"   ... and {len(missing) - 5} more", "WARNING")
            else:
                self.log(f"✅ {lang_code}: No missing keys")

        return missing_keys

    def add_missing_keys(
        self, missing_keys: Dict[str, Set[str]], dry_run: bool = False
    ):
        """Add missing keys with empty strings to maintain structure"""
        if not missing_keys:
            self.log("✅ No missing keys to add!")
            return

        self.log(f"🔧 {'[DRY RUN] ' if dry_run else ''}Adding missing keys...")

        for lang_code, missing in missing_keys.items():
            if lang_code not in self.language_files:
                continue

            data = self.language_files[lang_code].copy()
            keys_added = 0

            for key_path in sorted(missing):
                # Try to get a reference value from another language file
                reference_value = ""

                # Check if it's a nested object by looking at other files
                for other_lang, other_data in self.language_files.items():
                    if other_lang != lang_code:
                        existing_value = self.get_nested_value(other_data, key_path)
                        if existing_value is not None:
                            if isinstance(existing_value, dict):
                                reference_value = {}
                            else:
                                reference_value = ""
                            break

                self.set_nested_value(data, key_path, reference_value)
                keys_added += 1
                self.log(f"   + {lang_code}: {key_path}")

            if not dry_run:
                self.language_files[lang_code] = data
                self.save_language_file(lang_code, data)
                self.stats["files_updated"] += 1

            self.stats["missing_keys_added"] += keys_added
            self.log(
                f"📝 {'[DRY RUN] ' if dry_run else ''}Added {keys_added} keys to {lang_code}"
            )

    def save_language_file(self, lang_code: str, data: Dict[str, Any]):
        """Save language file with proper formatting"""
        file_path = self.translations_dir / f"{lang_code}.json"

        try:
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False, sort_keys=True)

            self.log(f"💾 Saved: {file_path.name}")

        except Exception as e:
            self.log(f"✗ Error saving {file_path.name}: {e}", "ERROR")

    def generate_report(self) -> Dict[str, Any]:
        """Generate comprehensive analysis report"""
        missing_keys = self.find_missing_keys()

        # Calculate completeness for each language
        completeness = {}
        for lang_code in self.language_files:
            file_keys = self.extract_nested_keys(self.language_files[lang_code])
            completeness[lang_code] = {
                "total_keys": len(file_keys),
                "missing_keys": len(missing_keys.get(lang_code, set())),
                "completeness_percentage": (
                    (len(file_keys) / len(self.all_keys)) * 100 if self.all_keys else 0
                ),
            }

        # Find most complete language as reference
        reference_lang = (
            max(
                completeness.keys(),
                key=lambda x: completeness[x]["completeness_percentage"],
            )
            if completeness
            else None
        )

        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": {
                "total_files_processed": self.stats["total_files"],
                "valid_files": self.stats["valid_files"],
                "invalid_files": self.stats["invalid_files"],
                "total_unique_keys": self.stats["total_keys"],
                "reference_language": reference_lang,
            },
            "language_analysis": completeness,
            "missing_keys_by_language": {
                lang: list(keys) for lang, keys in missing_keys.items()
            },
            "errors": self.errors,
            "warnings": self.warnings,
            "recommendations": self._generate_recommendations(
                missing_keys, completeness
            ),
        }

        return report

    def _generate_recommendations(
        self, missing_keys: Dict[str, Set[str]], completeness: Dict[str, Dict]
    ) -> List[str]:
        """Generate AI recommendations based on analysis"""
        recommendations = []

        if missing_keys:
            # Find languages with most missing keys
            most_incomplete = sorted(
                missing_keys.items(), key=lambda x: len(x[1]), reverse=True
            )[:3]

            recommendations.append(
                f"Priority translation needed for: {', '.join([lang for lang, _ in most_incomplete])}"
            )

        # Check for completely empty files
        empty_files = [
            lang for lang, comp in completeness.items() if comp["total_keys"] == 0
        ]
        if empty_files:
            recommendations.append(
                f"Empty translation files need attention: {', '.join(empty_files)}"
            )

        # Find well-maintained languages
        complete_langs = [
            lang
            for lang, comp in completeness.items()
            if comp["completeness_percentage"] > 95
        ]
        if complete_langs:
            recommendations.append(
                f"Well-maintained languages (>95% complete): {', '.join(complete_langs)}"
            )

        if not missing_keys:
            recommendations.append("✅ All translation files are synchronized!")

        return recommendations

    def save_report(self, report: Dict[str, Any]):
        """Save analysis report to JSON file"""
        report_path = self.translations_dir / "translation_manager_report.json"

        try:
            with open(report_path, "w", encoding="utf-8") as f:
                json.dump(report, f, indent=2, ensure_ascii=False)

            self.log(f"📊 Report saved: {report_path.name}")

        except Exception as e:
            self.log(f"✗ Error saving report: {e}", "ERROR")

    def print_summary(self, report: Dict[str, Any]):
        """Print a beautiful summary of the analysis"""
        print("\n" + "=" * 60)
        print("🤖 TRANSLATION MANAGER AI - ANALYSIS SUMMARY")
        print("=" * 60)

        summary = report["summary"]
        print(f"📁 Files Processed: {summary['total_files_processed']}")
        print(f"✅ Valid Files: {summary['valid_files']}")
        print(f"❌ Invalid Files: {summary['invalid_files']}")
        print(f"🔑 Total Unique Keys: {summary['total_unique_keys']}")
        print(f"🏆 Reference Language: {summary.get('reference_language', 'N/A')}")

        print(f"\n📊 LANGUAGE COMPLETENESS:")
        print("-" * 40)
        for lang, data in sorted(
            report["language_analysis"].items(),
            key=lambda x: x[1]["completeness_percentage"],
            reverse=True,
        ):
            percentage = data["completeness_percentage"]
            status = "🟢" if percentage > 95 else "🟡" if percentage > 80 else "🔴"
            print(
                f"{status} {lang:8} {percentage:6.1f}% ({data['total_keys']:4}/{summary['total_unique_keys']} keys)"
            )

        if report["recommendations"]:
            print(f"\n🎯 AI RECOMMENDATIONS:")
            print("-" * 40)
            for i, rec in enumerate(report["recommendations"], 1):
                print(f"{i}. {rec}")

        print(f"\n📈 OPERATION STATS:")
        print("-" * 40)
        print(f"Keys Added: {self.stats['missing_keys_added']}")
        print(f"Files Updated: {self.stats['files_updated']}")

        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            print("-" * 40)
            for error in self.errors[:5]:  # Show first 5 errors
                print(f"• {error}")
            if len(self.errors) > 5:
                print(f"... and {len(self.errors) - 5} more errors")

        print("\n" + "=" * 60)

    def run_full_analysis(self, dry_run: bool = False, save_report: bool = True):
        """Run complete translation analysis and synchronization"""
        self.log("🚀 Starting Full Translation Analysis...")

        # Step 1: Analyze all files
        self.analyze_translations()

        if not self.language_files:
            self.log("No valid translation files found. Exiting.", "ERROR")
            return

        # Step 2: Find missing keys
        missing_keys = self.find_missing_keys()

        # Step 3: Add missing keys
        self.add_missing_keys(missing_keys, dry_run)

        # Step 4: Generate report
        report = self.generate_report()

        # Step 5: Save report
        if save_report:
            self.save_report(report)

        # Step 6: Print summary
        self.print_summary(report)

        self.log("🎉 Translation analysis complete!")

        return report


def main():
    """Main function with command line interface"""
    parser = argparse.ArgumentParser(
        description="AI-powered Translation Manager for JSON files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python translation_manager.py                    # Run full analysis
  python translation_manager.py --dry-run          # Preview changes only
  python translation_manager.py --dir /path/to/translations  # Custom directory
  python translation_manager.py --no-report        # Skip report generation
        """,
    )

    parser.add_argument(
        "--dir",
        type=str,
        help="Directory containing translation files (default: current directory)",
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="Preview changes without modifying files"
    )
    parser.add_argument(
        "--no-report", action="store_true", help="Skip generating analysis report"
    )

    args = parser.parse_args()

    # Initialize AI agent
    agent = TranslationManagerAI(args.dir)

    # Run analysis
    try:
        agent.run_full_analysis(dry_run=args.dry_run, save_report=not args.no_report)
    except KeyboardInterrupt:
        print("\n⚠️  Analysis interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
