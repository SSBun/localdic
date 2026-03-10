import SwiftUI

struct AddWordView: View {
    @Binding var newWord: String
    let onAdd: () -> Void
    @FocusState private var isFocused: Bool
    @State private var isPressed: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            TextField("Enter word(s)...", text: $newWord)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.1))
                .cornerRadius(8)
                .focused($isFocused)
                .accessibilityLabel("Enter words to add")
                .accessibilityHint("Type one or more words separated by spaces or commas")
                .onSubmit {
                    if !newWord.isEmpty {
                        onAdd()
                    }
                }

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .foregroundColor(newWord.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : .white)
                    .background(
                        Circle()
                            .fill(newWord.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary.opacity(0.2) : Color.accentColor)
                    )
            }
            .buttonStyle(.plain)
            .disabled(newWord.trimmingCharacters(in: .whitespaces).isEmpty)
            .keyboardShortcut(.return, modifiers: [])
            .help("Add word to dictionary")
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    AddWordView(newWord: .constant("test"), onAdd: {})
        .background(Color(NSColor.windowBackgroundColor))
}
