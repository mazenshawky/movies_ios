import Flutter
import UIKit

class HomeViewController: UIViewController {

    private var methodChannel: FlutterMethodChannel?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        let filmIcon = UIImageView(
            image: UIImage(systemName: "film", withConfiguration: iconConfig))
        filmIcon.tintColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        filmIcon.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Discover Movies"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Browse the most popular movies\nand watch their trailers"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = UIColor.lightGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let browseButton = UIButton(type: .system)
        browseButton.setTitle("  Browse Movies", for: .normal)
        browseButton.setImage(UIImage(systemName: "popcorn.fill"), for: .normal)
        browseButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        browseButton.tintColor = .white
        browseButton.backgroundColor = UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0)
        browseButton.layer.cornerRadius = 14
        browseButton.translatesAutoresizingMaskIntoConstraints = false
        browseButton.addTarget(self, action: #selector(openFlutterMovies), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            filmIcon, titleLabel, subtitleLabel, browseButton,
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.setCustomSpacing(24, after: subtitleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            browseButton.heightAnchor.constraint(equalToConstant: 54),
            browseButton.widthAnchor.constraint(equalToConstant: 240),
        ])
    }

    // MARK: - Flutter Integration

    @objc private func openFlutterMovies() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let engine = appDelegate.flutterEngine

        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        flutterVC.title = "Popular Movies"

        // Set up the MethodChannel to listen for trailer playback requests
        methodChannel = FlutterMethodChannel(
            name: "com.movies/trailer",
            binaryMessenger: engine.binaryMessenger
        )

        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard call.method == "playTrailer",
                let youtubeKey = call.arguments as? String
            else {
                result(FlutterMethodNotImplemented)
                return
            }

            DispatchQueue.main.async {
                let trailerVC = TrailerViewController(youtubeKey: youtubeKey)
                self?.navigationController?.pushViewController(trailerVC, animated: true)
            }
            result(nil)
        }

        navigationController?.pushViewController(flutterVC, animated: true)
    }
}
