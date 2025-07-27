# Translation Manager AI Agent 🤖

An intelligent Python agent that manages multilingual JSON translation files for your application. This tool ensures all your translation files are properly formatted, synchronized, and complete.

## Features ✨

- **🔍 JSON Validation**: Automatically detects and reports JSON formatting issues
- **🔑 Key Synchronization**: Finds missing keys across all language files
- **🔧 Auto-Repair**: Adds missing keys with empty strings to maintain structure
- **📊 Comprehensive Reports**: Generates detailed analysis reports with completeness statistics
- **🌍 Multi-Language Support**: Supports all Indian regional languages and more
- **🎯 AI Recommendations**: Provides intelligent suggestions for translation management
- **⚡ Dry-Run Mode**: Preview changes before applying them
- **📈 Progress Tracking**: Real-time logging and statistics

## Supported Languages 🌐

The agent supports the following language codes:
- `as-IN` (Assamese)
- `bn-IN` (Bengali) 
- `brx-IN` (Bodo)
- `doi-IN` (Dogri)
- `en-US` (English)
- `gu-IN` (Gujarati)
- `hi-IN` (Hindi)
- `kn-IN` (Kannada)
- `kok-IN` (Konkani)
- `ks-IN` (Kashmiri)
- `mai-IN` (Maithili)
- `ml-IN` (Malayalam)
- `mni-IN` (Manipuri)
- `mr-IN` (Marathi)
- `ne-IN` (Nepali)
- `or-IN` (Odia)
- `pa-IN` (Punjabi)
- `sa-IN` (Sanskrit)
- `sat-IN` (Santali)
- `sd-IN` (Sindhi)
- `ta-IN` (Tamil)
- `te-IN` (Telugu)
- `ur-IN` (Urdu)

## Installation 📦

No external dependencies required! The agent uses only Python standard library modules.

**Requirements:**
- Python 3.8 or higher
- Standard modules: `json`, `pathlib`, `argparse`, `datetime`, `typing`

## Quick Start 🚀

### 1. Basic Usage

```bash
# Navigate to your translations directory
cd assets/translations

# Run the translation manager
python translation_manager.py
```

### 2. Preview Changes (Dry Run)

```bash
# See what would be changed without modifying files
python translation_manager.py --dry-run
```

### 3. Custom Directory

```bash
# Specify a different directory
python translation_manager.py --dir /path/to/your/translations
```

### 4. Interactive Mode

```bash
# Use the interactive script for guided operation
python run_translation_check.py
```

## Usage Examples 💡

### Command Line Interface

```bash
# Full analysis with automatic fixes
python translation_manager.py

# Preview changes only
python translation_manager.py --dry-run

# Skip report generation
python translation_manager.py --no-report

# Custom directory
python translation_manager.py --dir ../other-translations
```

### Interactive Scripts

```bash
# Interactive mode with confirmation prompts
python run_translation_check.py

# Quick check without changes
python run_translation_check.py --quick

# Automatic application of fixes
python run_translation_check.py --apply
```

### Programmatic Usage

```python
from translation_manager import TranslationManagerAI

# Initialize the agent
agent = TranslationManagerAI("path/to/translations")

# Run analysis
report = agent.run_full_analysis(dry_run=False)

# Check specific missing keys
missing_keys = agent.find_missing_keys()
print(f"Missing keys found: {len(missing_keys)}")
```

## What the Agent Does 🔧

### 1. Discovery Phase
- Scans the directory for JSON translation files
- Identifies supported language files
- Reports missing language files

### 2. Validation Phase
- Validates JSON syntax in all files
- Reports formatting errors and issues
- Counts keys in each file

### 3. Analysis Phase
- Extracts all nested keys using dot notation
- Compares key structures across languages
- Identifies missing keys in each file
- Calculates completeness percentages

### 4. Synchronization Phase
- Adds missing keys with empty string values
- Maintains nested object hierarchy
- Preserves existing translations
- Updates files with proper formatting

### 5. Reporting Phase
- Generates comprehensive analysis reports
- Provides completeness statistics
- Offers AI-powered recommendations
- Saves detailed JSON reports

## Sample Output 📋

```
🤖 TRANSLATION MANAGER AI - ANALYSIS SUMMARY
============================================================
📁 Files Processed: 23
✅ Valid Files: 22
❌ Invalid Files: 1
🔑 Total Unique Keys: 278
🏆 Reference Language: en-US

📊 LANGUAGE COMPLETENESS:
----------------------------------------
🟢 en-US      100.0% ( 278/278 keys)
🟢 hi-IN       98.2% ( 273/278 keys)
🟡 bn-IN       87.4% ( 243/278 keys)
🔴 sa-IN       45.3% ( 126/278 keys)

🎯 AI RECOMMENDATIONS:
----------------------------------------
1. Priority translation needed for: sa-IN, ur-IN, ks-IN
2. Well-maintained languages (>95% complete): en-US, hi-IN, gu-IN
3. Empty translation files need attention: new-lang-IN

📈 OPERATION STATS:
----------------------------------------
Keys Added: 127
Files Updated: 8
```

## Generated Reports 📊

The agent generates a detailed JSON report (`translation_manager_report.json`) containing:

- **Summary Statistics**: File counts, key counts, reference language
- **Language Analysis**: Completeness percentages for each language
- **Missing Keys**: Detailed list of missing keys per language
- **Error Log**: Any issues encountered during processing
- **AI Recommendations**: Intelligent suggestions for improvement

## File Structure 📁

After running the agent, your translation directory will contain:

```
translations/
├── translation_manager.py       # Main AI agent script
├── run_translation_check.py     # Interactive usage script
├── requirements.txt             # Dependencies (none needed!)
├── README.md                    # This documentation
├── translation_manager_report.json  # Generated analysis report
├── en-US.json                   # Your translation files
├── hi-IN.json
├── bn-IN.json
└── ... (other language files)
```

## Best Practices 🎯

### 1. Regular Maintenance
- Run the agent after adding new features
- Use dry-run mode to preview changes
- Keep your reference language (usually English) complete

### 2. Translation Workflow
1. Update your primary language file (e.g., `en-US.json`)
2. Run the agent to sync structure: `python translation_manager.py`
3. Fill in the empty strings with actual translations
4. Validate with another run: `python translation_manager.py --dry-run`

### 3. Team Collaboration
- Commit the agent scripts to your repository
- Share analysis reports with translators
- Use completeness percentages to track progress

## Troubleshooting 🔍

### Common Issues

1. **"No translation files found"**
   - Ensure you're in the correct directory
   - Check file naming conventions (e.g., `en-US.json`)
   - Use `--dir` parameter to specify path

2. **JSON parsing errors**
   - The agent will report specific syntax issues
   - Fix JSON formatting before re-running
   - Use a JSON validator if needed

3. **Permission errors**
   - Ensure write permissions for the directory
   - Check if files are being used by other applications

### Getting Help

```bash
# See all available options
python translation_manager.py --help

# Get detailed error information
python translation_manager.py 2>&1 | tee debug.log
```

## Advanced Features 🚀

### 1. Custom Key Handling
The agent intelligently handles nested JSON structures:

```json
{
  "auth": {
    "login": "Login",
    "logout": "Logout",
    "phoneLogin": {
      "title": "Enter phone number",
      "validation": {
        "invalidPhone": "Invalid phone number"
      }
    }
  }
}
```

### 2. Intelligent Reference Values
- Detects object vs string values from other languages
- Maintains proper nesting structure
- Preserves existing translations

### 3. Batch Processing
- Processes all supported languages simultaneously  
- Provides progress updates for large translation sets
- Optimized for performance with many files

## Contributing 🤝

This AI agent is designed to be extensible:

1. **Add Language Support**: Update the `supported_languages` set
2. **Custom Validations**: Extend the validation methods
3. **Enhanced Reporting**: Add new analysis metrics
4. **Integration**: Embed in CI/CD pipelines

## License 📄

This Translation Manager AI Agent is provided as-is for managing your multilingual applications. Feel free to modify and adapt it to your specific needs.

---

**Happy Translating! 🌍✨**

> 💡 **Pro Tip**: Set up a git hook to run the translation manager before commits to ensure your translations stay synchronized! 