import SwiftUI


class  EditorCoordinator : NSObject, NSTextViewDelegate {
  let textView: NSTextView;
  let scrollView : NSScrollView
  let text : Binding<String>

  init(binding: Binding<String>) {
    text = binding

    textView = NSTextView(frame: .zero)
    textView.autoresizingMask = [.height, .width]
    textView.string = text.wrappedValue
    textView.textColor = NSColor.textColor
    textView.isRulerVisible = true
    textView.isRichText = false
    textView.isGrammarCheckingEnabled = false
    textView.isAutomaticTextReplacementEnabled = false
    textView.isAutomaticLinkDetectionEnabled = false
    textView.isContinuousSpellCheckingEnabled = false
    textView.isAutomaticDataDetectionEnabled = false
    textView.isAutomaticQuoteSubstitutionEnabled = false
    textView.isAutomaticDashSubstitutionEnabled = false
    textView.isAutomaticTextCompletionEnabled = false
    textView.isAutomaticSpellingCorrectionEnabled = false
    textView.font = NSFont.init(name: "Monaco", size: 12)

    scrollView = NSScrollView(frame: .zero)
    scrollView.hasVerticalScroller = true
    scrollView.autohidesScrollers = false
    scrollView.autoresizingMask = [.height, .width]
    scrollView.documentView = textView

    super.init()
    textView.delegate = self
  }

  func textDidChange(_ notification: Notification) {
    switch  notification.name {
    case NSText.didChangeNotification :
      text.wrappedValue = (notification.object as? NSTextView)?.string ?? ""
    default:
      print("Coordinator received unwanted notification")
    }
  }

}

struct MultilineTextView: View, NSViewRepresentable {
    func makeCoordinator() -> EditorCoordinator {
        let coordinator =  EditorCoordinator(binding: $text)
        return coordinator
    }
    
    typealias Coordinator = EditorCoordinator
    typealias NSViewType = NSScrollView

    @Binding var text: String

    func makeNSView(context: Self.Context) -> Self.NSViewType{
        return context.coordinator.scrollView
    }

    func updateNSView(_ nsView: Self.NSViewType, context: Self.Context) {
    }
}

