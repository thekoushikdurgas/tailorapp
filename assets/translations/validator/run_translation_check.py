#!/usr/bin/env python3
"""
Example Usage Script for Translation Manager AI Agent
====================================================

This script demonstrates how to use the Translation Manager AI Agent
to check and synchronize your multilingual JSON translation files.

Usage Examples:
1. Basic analysis: python run_translation_check.py
2. Dry run (preview only): python run_translation_check.py --dry-run
3. Custom directory: python run_translation_check.py --dir /path/to/translations
"""

from translation_manager import TranslationManagerAI
import sys
from pathlib import Path


def main():
    """Example usage of the Translation Manager AI Agent"""

    print("🤖 Translation Manager AI Agent")
    print("=" * 40)
    print("Starting translation file analysis...\n")

    try:
        # Initialize the AI agent
        # By default, it will look for JSON files in the current directory
        agent = TranslationManagerAI()

        # Run a dry-run first to see what would be changed
        print("🔍 Running preview analysis (dry-run)...")
        print("-" * 40)
        agent.run_full_analysis(dry_run=True, save_report=False)

        print("\n" + "🤔 Do you want to apply the changes? (y/n): ", end="")
        response = input().strip().lower()

        if response in ["y", "yes"]:
            print("\n🔧 Applying changes...")
            print("-" * 40)

            # Create a new agent instance for the actual run
            agent = TranslationManagerAI()
            report = agent.run_full_analysis(dry_run=False, save_report=True)

            print("\n✅ Translation synchronization complete!")
            print(f"📊 Analysis report saved as: translation_manager_report.json")

        else:
            print("\n⏹️  Operation cancelled. No files were modified.")

    except KeyboardInterrupt:
        print("\n\n⚠️  Analysis interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Error during analysis: {e}")
        sys.exit(1)


def run_quick_check():
    """Quick check without user interaction"""
    print("🚀 Quick Translation Check")
    print("=" * 30)

    agent = TranslationManagerAI()

    # Just analyze without making changes
    agent.analyze_translations()
    missing_keys = agent.find_missing_keys()

    if missing_keys:
        print(f"\n⚠️  Found missing keys in {len(missing_keys)} language files:")
        for lang, keys in missing_keys.items():
            print(f"   {lang}: {len(keys)} missing keys")
        print("\nRun with --apply to fix these issues.")
    else:
        print("\n✅ All translation files are synchronized!")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Run translation file analysis")
    parser.add_argument(
        "--quick", action="store_true", help="Quick check only (no changes)"
    )
    parser.add_argument(
        "--apply", action="store_true", help="Apply changes automatically"
    )

    args = parser.parse_args()

    if args.quick:
        run_quick_check()
    elif args.apply:
        # Auto-apply mode
        agent = TranslationManagerAI()
        agent.run_full_analysis(dry_run=False, save_report=True)
    else:
        # Interactive mode
        main()
