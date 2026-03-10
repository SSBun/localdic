import SwiftUI

struct WordListView: View {
    let words: [String]
    let onDelete: (IndexSet) -> Void
    let onRemove: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if words.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No words in dictionary")
                        .foregroundColor(.secondary)
                    Text("Add words using the field below")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(words, id: \.self) { word in
                        HStack {
                            Text(word)
                                .font(.system(.body, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Spacer()

                            Button(action: { onRemove(word) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Remove \"\(word)\" from dictionary")
                            .accessibilityLabel("Remove \(word)")
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: onDelete)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    WordListView(
        words: ["hello", "world", "swift", "apple"],
        onDelete: { _ in },
        onRemove: { _ in }
    )
    .background(.ultraThinMaterial)
}
