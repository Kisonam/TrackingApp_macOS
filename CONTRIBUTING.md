# Contributing to TrackingApp

Thank you for your interest in contributing to TrackingApp! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Bugs

- Use the [Issues](https://github.com/yourusername/TrackingApp/issues) page
- Provide detailed information:
  - macOS version
  - Steps to reproduce
  - Expected vs actual behavior
  - Screenshots if applicable

### Suggesting Features

- Open an issue with the "enhancement" label
- Describe the feature and why it would be useful
- Consider if it fits the app's purpose

### Code Contributions

1. **Fork** the repository
2. **Create** a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make** your changes
4. **Test** thoroughly:
   ```bash
   swift build
   bash build_app.sh
   open TrackingApp.app
   ```
5. **Commit** your changes:
   ```bash
   git commit -m "feat: add your feature description"
   ```
6. **Push** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create** a Pull Request

## 🛠️ Development Setup

### Prerequisites

- macOS 14.0+
- Xcode 15+ or Swift 6.2+
- Git

### Build Instructions

```bash
# Clone your fork
git clone https://github.com/yourusername/TrackingApp.git
cd TrackingApp

# Build from source
swift build

# Create .app bundle
bash build_app.sh

# Run the app
open TrackingApp.app
```

## 📝 Code Style

- Follow Swift conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small
- Update documentation for new features

## 🌐 Localization

Adding a new language:

1. Update `Strings.swift`:
   ```swift
   private func t(_ en: String, _ ua: String, _ pl: String, _ new: String) -> String {
       switch language {
       case "en": return en
       case "pl": return pl
       case "ua": return ua
       case "new": return new  // Add your language code
       default: return ua
       }
   }
   ```

2. Add language code to `AppLanguage` enum in `AppSettings.swift`

3. Update all string functions to include the new language

## 🧪 Testing

- Test all UI flows
- Verify Firebase sync works
- Check all language localizations
- Test on different macOS versions if possible

## 📋 Pull Request Process

1. Update README.md if needed
2. Ensure all tests pass
3. Update documentation
4. Link relevant issues
5. Wait for code review

## 🎯 Areas for Contribution

- UI/UX improvements
- Performance optimizations
- New features (discuss first)
- Bug fixes
- Documentation
- Additional languages
- Better error handling

## 📞 Getting Help

- Check existing issues
- Read the documentation
- Ask questions in issues

---

Thank you for contributing to TrackingApp! 🎉
