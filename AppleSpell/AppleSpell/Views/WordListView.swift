import SwiftUI

struct WordListView: View {
    let words: [String]
    let onDelete: (IndexSet) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if words.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No words in dictionary")
                        .foregroundColor(.secondary)
                    Text("Add words using the field below")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.7))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(words, id: \.self) { word in
                        HStack {
                            Text(word)
                                .font(.system(.body, design: .monospaced))

                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if let index = words.firstIndex(of: word) {
                                    onDelete(IndexSet(integer: index))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
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
        onDelete: { _ in }
    )
    .background(.ultraThinMaterial)
}
