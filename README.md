# localdic

A tool for managing the macOS local dictionary. Manage custom words for AppleSpell spell checking service.

## Products

### AppleSpell - macOS App

A beautiful native macOS app for managing your local dictionary with a modern UI.

![AppleSpell](https://github.com/SSBun/localdic/blob/main/AppleSpell/screenshot.png)

**Features:**
- 🖥️ Native macOS app with modern UI
- 🔍 Search and filter words
- ➕ Add new words easily
- 🗑️ Remove words with swipe or button
- 📥 Import words from text files
- 📤 Export words to text files
- 🔄 Auto-refresh when dictionary changes
- ⚙️ Settings page with update checker

**Download:**
- [Latest Release](https://github.com/SSBun/localdic/releases/latest)

---

### localdic - CLI Tool

A command-line tool for managing the local dictionary.

```shell
OVERVIEW: A tool for managing local dictionary on Mac.

USAGE: localdic list
       localdic learn <word>
       localdic forget <word>
       localdic --help

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  list                    List all words in the local dictionary on your Mac.
  learn                   Save words to the local dictionary.
  forget                  Remove words from the local dictionary.
```

#### Installation

```shell
brew tap ssbun/formulae
brew install localdic
```

#### Usage

```shell
# List all words in dictionary
localdic list

# Add words to dictionary
localdic learn ffmpeg llvm swift

# Remove words from dictionary
localdic forget ffmpeg

# Remove by index
localdic forget 0 5 10
```

## Development

### Requirements
- macOS 12.0+
- Xcode 15.0+
- Swift 5.9+

### Build AppleSpell App

```bash
cd AppleSpell
open AppleSpell.xcodeproj
```

Then build and run in Xcode.

### Build CLI Tool

```bash
swift build -c release
```

## License

MIT License
