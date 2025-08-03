# 🌍 TailorAI Translation Manager

An intelligent, interactive Python tool for managing translation files in the TailorAI Flutter application. This tool helps maintain consistency across all 23 supported languages with automated validation, key synchronization, and comprehensive reporting.

## ✨ Features

- **🔍 JSON Validation**: Verify all translation files are properly formatted
- **🔑 Key Analysis**: Find missing keys across all language files
- **🔄 Smart Synchronization**: Add missing keys with empty strings automatically
- **📊 Comprehensive Reports**: Generate detailed translation status reports
- **💾 Backup System**: Automatic backups before making changes
- **🌐 Multi-Language Support**: Supports all 23 TailorAI languages
- **🖥️ Interactive Menu**: User-friendly command-line interface
- **🤖 Automation Ready**: Command-line arguments for CI/CD integration

## 📋 Supported Languages

The tool manages translations for **23 languages** total:

### English
- `en-US` 🇺🇸 English (Primary/Default)

### Indian Languages (22)
- `hi-IN` 🇮🇳 हिन्दी (Hindi)
- `bn-IN` 🇮🇳 বাংলা (Bengali)
- `te-IN` 🇮🇳 తెలుగు (Telugu)
- `mr-IN` 🇮🇳 मराठी (Marathi)
- `ta-IN` 🇮🇳 தமிழ் (Tamil)
- `gu-IN` 🇮🇳 ગુજરાતી (Gujarati)
- `kn-IN` 🇮🇳 ಕನ್ನಡ (Kannada)
- `ml-IN` 🇮🇳 മലയാളം (Malayalam)
- `pa-IN` 🇮🇳 ਪੰਜਾਬੀ (Punjabi)
- `as-IN` 🇮🇳 অসমীয়া (Assamese)
- `brx-IN` 🇮🇳 बड़ो (Bodo)
- `doi-IN` 🇮🇳 डोगरी (Dogri)
- `ks-IN` 🇮🇳 کٲشُر (Kashmiri)
- `kok-IN` 🇮🇳 कोंकणी (Konkani)
- `mai-IN` 🇮🇳 मैथिली (Maithili)
- `mni-IN` 🇮🇳 ꯃꯤꯇꯩ (Meitei)
- `ne-IN` 🇮🇳 नेपाली (Nepali)
- `or-IN` 🇮🇳 ଓଡ଼ିଆ (Odia)
- `sa-IN` 🇮🇳 संस्कृतम् (Sanskrit)
- `sat-IN` 🇮🇳 ᱥᱟᱱᱛᱟᱲᱤ (Santali)
- `sd-IN` 🇮🇳 سنڌي (Sindhi)
- `ur-IN` 🇮🇳 اردو (Urdu)

## 🚀 Installation

### Prerequisites
- Python 3.7 or higher
- Access to the TailorAI translation files

### Setup
1. **Clone or download** the `translation_manager.py` script to your `assets/translations/` directory
2. **Install optional dependencies** (recommended):
   ```bash
   pip install -r requirements.txt
   ```
3. **Make the script executable** (Linux/Mac):
   ```bash
   chmod +x translation_manager.py
   ```

### Directory Structure
```
assets/translations/
├── json/                    # Translation files directory
│   ├── en-US.json          # English (template)
│   ├── hi-IN.json          # Hindi
│   ├── bn-IN.json          # Bengali
│   └── ...                 # Other language files
├── backups/                # Auto-generated backups
├── translation_manager.py  # Main script
├── requirements.txt        # Python dependencies
└── README.md              # This file
```

## 🖥️ Usage

### Interactive Mode (Recommended)
```bash
cd assets/translations/
python translation_manager.py
```

This launches an interactive menu with the following options:

1. **🔍 Validate JSON Files** - Check if all files are valid JSON
2. **🔑 Analyze Translation Keys** - Find missing keys across languages
3. **🔄 Synchronize Keys (Dry Run)** - Preview key synchronization
4. **✅ Synchronize Keys (Execute)** - Actually add missing keys
5. **📄 Create Missing Files** - Create missing language files
6. **📊 Generate Report** - Create comprehensive status report
7. **💾 Create Backup** - Manual backup creation
8. **🔤 Format JSON Keys (Dry Run)** - Preview alphabetical key sorting
9. **✨ Format JSON Keys (Execute)** - Sort all JSON keys alphabetically
10. **📋 List Supported Languages** - Show all supported languages
11. **🚪 Exit** - Close the application

### Command Line Mode
```bash
# Generate report only
python translation_manager.py --report-only

# Auto-sync missing keys
python translation_manager.py --auto-sync

# Use different directory
python translation_manager.py --dir custom_translations/

# Show help
python translation_manager.py --help
```

## 📊 Example Usage Scenarios

### Scenario 1: New Project Setup
```bash
# 1. Create missing language files using English as template
python translation_manager.py
# Select option 5, use 'en-US' as template

# 2. Validate all files
# Select option 1

# 3. Generate initial report
# Select option 6
```

### Scenario 2: Adding New Translation Keys
```bash
# 1. Add new keys to en-US.json manually
# 2. Run synchronization preview
python translation_manager.py
# Select option 3 to see what will be added

# 3. Execute synchronization
# Select option 4 to add missing keys to all files
```

### Scenario 3: Quality Assurance
```bash
# Generate comprehensive report
python translation_manager.py --report-only

# Or run interactive validation
python translation_manager.py
# Select option 1 for validation
# Select option 2 for key analysis
```

### Scenario 4: JSON Key Formatting
```bash
# Preview which files need key formatting
python translation_manager.py
# Select option 8 to preview changes

# Apply alphabetical key sorting
# Select option 9 to execute formatting
```

### Scenario 5: CI/CD Integration
```bash
# In your CI/CD pipeline
python translation_manager.py --auto-sync
python translation_manager.py --report-only > translation_report.txt
```

## 🔧 Key Features Explained

### JSON Validation
- **Syntax Check**: Verifies each file is valid JSON
- **Encoding Check**: Ensures UTF-8 encoding for international characters
- **Error Reporting**: Detailed error messages with line/column numbers

### Key Analysis
- **Nested Key Support**: Handles nested JSON structures with dot notation
- **Missing Key Detection**: Finds keys present in some files but missing in others
- **Completeness Tracking**: Identifies fully synchronized files

### Smart Synchronization
- **Dry Run Mode**: Preview changes before applying them
- **Backup Creation**: Automatic backups before modifications
- **Empty String Values**: Adds missing keys with empty strings for translation
- **Structure Preservation**: Maintains nested JSON structure

### JSON Key Formatting
- **Alphabetical Sorting**: Sorts all JSON keys alphabetically at every nesting level
- **Nested Structure Support**: Recursively sorts keys in nested objects
- **Content Preservation**: Maintains all values while reorganizing key order
- **Consistency**: Ensures uniform structure across all language files
- **Version Control Friendly**: Reduces merge conflicts and improves diffs

### Reporting System
- **Comprehensive Status**: Complete overview of translation health
- **Missing Key Lists**: Detailed breakdown of what's missing where
- **Language Coverage**: Per-language statistics and status
- **Export Options**: Save reports to files for documentation

## 🛡️ Safety Features

### Automatic Backups
- **Timestamp-based**: Each backup has unique timestamp
- **Complete Copy**: Full copy of all translation files
- **Location**: `assets/translations/backups/backup_YYYYMMDD_HHMMSS/`

### Dry Run Mode
- **Preview Changes**: See exactly what will be modified
- **No File Writes**: Safe inspection without file modifications
- **Change Summary**: Clear overview of planned modifications

### Error Handling
- **Graceful Failures**: Continues processing other files if one fails
- **Detailed Logging**: Clear error messages and suggestions
- **Validation**: Multiple validation layers before file operations

## 📈 Workflow Integration

### Development Workflow
1. **Developer adds new features** with new translation keys in `en-US.json`
2. **Run translation manager** to sync keys across all languages
3. **Translators fill in** the empty strings with appropriate translations
4. **QA validates** using the reporting system

### Maintenance Workflow
1. **Regular validation** using automated reports
2. **Key synchronization** when inconsistencies are found
3. **Backup management** for version control
4. **Quality monitoring** through comprehensive reports

## 🔍 Troubleshooting

### Common Issues

**Issue**: "File not found" errors
**Solution**: Ensure you're running the script from the `assets/translations/` directory

**Issue**: "Permission denied" errors
**Solution**: Check file permissions or run with appropriate privileges

**Issue**: "Encoding errors" with international characters
**Solution**: Ensure all files are saved with UTF-8 encoding

**Issue**: "JSON syntax errors"
**Solution**: Use the validation feature to identify and fix syntax issues

### Debug Mode
```bash
# Enable verbose output
python translation_manager.py --debug

# Check individual file
python -c "
import json
with open('json/hi-IN.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
    print('File is valid JSON')
"
```

## 🤝 Contributing

### Extending the Tool
The `TranslationManager` class is designed for extensibility:

- **Add new languages**: Update `supported_languages` list
- **Custom validation**: Extend the `validate_json_files` method
- **New report formats**: Extend the `generate_report` method
- **Integration hooks**: Add new command-line arguments

### Best Practices
- **Always create backups** before bulk operations
- **Use dry run mode** first to preview changes
- **Regular validation** to catch issues early
- **Consistent key naming** using dot notation for nested structures

## 📄 License

This tool is part of the TailorAI project. See the main project license for details.

## 🆘 Support

For issues or questions:
1. **Check this README** for common solutions
2. **Run validation** to identify specific problems
3. **Generate reports** to understand current status
4. **Create issues** in the main project repository

---

**Made with ❤️ for TailorAI - Empowering global fashion through AI and multilingual support** 