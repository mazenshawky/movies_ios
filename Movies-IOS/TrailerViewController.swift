import SafariServices
import UIKit

/// Opens a YouTube trailer in SFSafariViewController.
///
/// SFSafariViewController uses the full Safari engine, which correctly sends
/// Referer headers that YouTube requires — unlike WKWebView's loadHTMLString,
/// which omits them and triggers Error 153.
class TrailerViewController: UIViewController {

    private let youtubeKey: String

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
        presentTrailer()
    }

    private func presentTrailer() {
        let urlString = "https://www.youtube.com/watch?v=\(youtubeKey)"
        guard let url = URL(string: urlString) else { return }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true

        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.preferredBarTintColor = .black
        safariVC.preferredControlTintColor = .white
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .fullScreen

        present(safariVC, animated: true)
    }
}

// MARK: - SFSafariViewControllerDelegate

extension TrailerViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // User tapped "Done" — pop back to the previous screen
        navigationController?.popViewController(animated: true)
    }
}
