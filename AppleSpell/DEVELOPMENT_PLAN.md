# AppleSpell App Development Plan

## Project Overview

- **Project Name**: AppleSpell
- **Type**: macOS Application (SwiftUI)
- **Core Functionality**: A native macOS app for managing custom words in AppleSpell's local dictionary
- **Target Users**: macOS users who want to manage their spell-check dictionary with a GUI
- **Minimum macOS Version**: macOS 12.0

---

## Features

### 1. Word List Display
- Display all words from the local dictionary in a scrollable list
- Show word count in the UI
- Support searching/filtering words

### 2. Add Words
- Text field to input new words
- Support adding multiple words at once (space or comma separated)
- Validation: prevent adding duplicate words
- Visual feedback on successful add

### 3. Remove Words
- Select and remove individual words
- Support multi-select for bulk deletion
- Confirmation dialog before deletion

### 4. Import/Export (Optional)
- Export words to a text file
- Import words from a text file

### 5. Auto-refresh
- Detect external changes to the dictionary file
- Auto-restart AppleSpell service after modifications

---

## UI/UX Design

### Window Structure
- Single main window
- Window size: 500x600 (min), resizable
- Navigation: Vertical layout with sidebar or simple list view

### Visual Design
- **Color Scheme**: System default (adapts to light/dark mode)
- **Typography**: System font, standard sizes
- **Spacing**: Standard macOS spacing guidelines

### Layout
```
+----------------------------------+
|  Title: AppleSpell Dictionary   |
+----------------------------------+
|  [Search Field]                  |
+----------------------------------+
|  Word List (Table/List)          |
|  - Word 1                   [x]  |
|  - Word 2                   [x]  |
|  - Word 3                   [x]  |
|  ...                            |
+----------------------------------+
|  [Text Field: Add word] [Add]   |
+----------------------------------+
|  Words: 150  |  [Export] [Import]|
+----------------------------------+
```

---

## Technical Implementation

### Data Layer
- **Model**: `Word` struct with id and value
- **Storage**: Read/write to `~/Library/Spelling/LocalDictionary`
- **Service**: `DictionaryService` to handle file operations

### Architecture
- **Pattern**: MVVM (Model-View-ViewModel)
- **ViewModel**: `DictionaryViewModel` (ObservableObject)
  - `@Published var words: [String]`
  - `@Published var searchText: String`
  - Functions: `loadWords()`, `addWords(_:)`, `removeWords(_:)`

### Dependencies
- No external dependencies required
- Uses native SwiftUI and Foundation

---

## File Structure

```
AppleSpell/
├── AppleSpell/
│   ├── AppleSpellApp.swift        # App entry point
│   ├── ContentView.swift          # Main view
│   ├── Views/
│   │   ├── WordListView.swift     # Word list component
│   │   ├── AddWordView.swift      # Add word component
│   │   └── SearchBarView.swift    # Search bar component
│   ├── ViewModels/
│   │   └── DictionaryViewModel.swift
│   ├── Models/
│   │   └── Word.swift
│   ├── Services/
│   │   └── DictionaryService.swift
│   └── Resources/
│       └── Assets.xcassets
├── AppleSpell.entitlements
└── project.yml (or use existing .xcodeproj)
```

---

## Implementation Order

1. **Phase 1**: Core functionality
   - Create `DictionaryService` to read/write dictionary file
   - Create `DictionaryViewModel` with basic CRUD operations
   - Implement basic word list display

2. **Phase 2**: UI enhancements
   - Add search/filter functionality
   - Add word removal with confirmation
   - Add word addition with validation

3. **Phase 3**: Polish
   - Add word count display
   - Auto-refresh after external changes
   - Error handling and user feedback
   - Export/Import functionality (optional)

---

## Testing

- Test reading/writing to dictionary file
- Test duplicate word prevention
- Test AppleSpell service restart
- Test with empty dictionary
- Test with large dictionary (1000+ words)
