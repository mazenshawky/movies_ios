import UIKit
import WebKit

/// Opens a YouTube trailer in WKWebView using an HTML relay page.
///
/// Instead of directly embedding the YouTube player via `loadHTMLString`
/// (which omits Referer headers and triggers Error 153), we load a local
/// HTML file via `loadFileURL` that uses an iframe pointed at
/// youtube-nocookie.com with proper referrer policy.
class TrailerViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private let youtubeKey: String
    private var webView: WKWebView!

    init(youtubeKey: String) {
        self.youtubeKey = youtubeKey
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trailer"
        view.backgroundColor = .black
        setupWebView()
        loadTrailer()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func loadTrailer() {
        // Load the relay HTML file from the app bundle, passing the video ID
        // as a query parameter. The relay page handles building the
        // youtube-nocookie.com embed URL with the correct referrer policy.
        guard
            let relayURL = Bundle.main.url(
                forResource: "youtube_relay",
                withExtension: "html")
        else {
            print("youtube_relay.html not found in bundle")
            return
        }

        // We build a file URL with a query string. loadFileURL doesn't
        // support query parameters directly, so we load the HTML as a string,
        // inject the video ID, and use loadHTMLString with baseURL set to a
        // real origin so the iframe Referer header is sent correctly.
        //
        // Actually, the better approach: read the HTML, replace a placeholder
        // with the video ID, and load it with a proper base URL.
        guard var htmlString = try? String(contentsOf: relayURL, encoding: .utf8) else {
            print("Failed to read youtube_relay.html")
            return
        }

        // Inject the video key directly into the HTML instead of relying on
        // URL query parameters (since loadHTMLString doesn't have a real URL).
        htmlString = htmlString.replacingOccurrences(of: "{{VIDEO_ID}}", with: youtubeKey)

        // Using a real HTTPS base URL so the iframe's referrer policy works
        // and YouTube doesn't reject the embed with Error 153.
        let baseURL = URL(string: "https://www.youtube-nocookie.com")
        webView.loadHTMLString(htmlString, baseURL: baseURL)
    }

    // MARK: - WKNavigationDelegate

    /// Intercept navigation so the "Watch on YouTube" button works.
    /// Allow iframe loads (`.other`) but open user-initiated links externally.
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Allow initial page load and iframe content
        if navigationAction.navigationType == .other {
            decisionHandler(.allow)
            return
        }

        // User-initiated link (e.g. "Watch on YouTube") → open externally
        UIApplication.shared.open(url)
        decisionHandler(.cancel)
    }

    // MARK: - WKUIDelegate

    /// Handle target="_blank" links from the YouTube iframe.
    /// The "Watch on YouTube" button opens a new window — without this,
    /// WKWebView silently ignores the tap.
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        return nil
    }
}
