import SwiftUI
import Combine
import WebKit

struct PrivacySparkPage: View {
    @Environment(\.dismiss) private var dismiss

    let url: URL

    var body: some View {
        NavigationStack {
            PrivacyCanvas(url: url)
                .navigationTitle("Privacy")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

private struct PrivacyCanvas: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)
        view.navigationDelegate = context.coordinator
        view.allowsBackForwardNavigationGestures = true
        view.scrollView.contentInsetAdjustmentBehavior = .automatic

        let request = URLRequest(url: url)
        view.load(request)

        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard !context.coordinator.didLoadInitial else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
        context.coordinator.didLoadInitial = true
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var didLoadInitial: Bool = false

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation?,
            withError error: Error
        ) {
            // Errors are intentionally not surfaced directly to keep the page simple
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation?,
            withError error: Error
        ) {
            // Same as above
        }
    }
}
