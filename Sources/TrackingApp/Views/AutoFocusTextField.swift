import SwiftUI
import AppKit

struct AutoFocusTextField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var autoFocus: Bool = true

    func makeNSView(context: Context) -> NSTextField {
        let tf = NSTextField()
        tf.placeholderString = placeholder
        tf.delegate = context.coordinator
        tf.bezelStyle = .roundedBezel
        tf.font = .systemFont(ofSize: NSFont.systemFontSize)
        tf.lineBreakMode = .byTruncatingTail
        tf.cell?.sendsActionOnEndEditing = true
        if autoFocus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                tf.window?.makeFirstResponder(tf)
            }
        }
        return tf
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }

        func controlTextDidChange(_ obj: Notification) {
            if let tf = obj.object as? NSTextField {
                text = tf.stringValue
            }
        }
    }
}
