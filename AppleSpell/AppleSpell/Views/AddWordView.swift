import SwiftUI

struct AddWordView: View {
    @Binding var newWord: String
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Enter word(s)...", text: $newWord)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.1))
                .cornerRadius(8)
                .onSubmit {
                    if !newWord.isEmpty {
                        onAdd()
                    }
                }

            Button(action: onAdd) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(newWord.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

#Preview {
    AddWordView(newWord: .constant("test"), onAdd: {})
        .padding()
        .background(.ultraThinMaterial)
}
