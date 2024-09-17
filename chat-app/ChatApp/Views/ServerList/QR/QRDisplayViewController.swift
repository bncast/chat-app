//
//  QRDisplayViewController.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 9/12/24.
//

import UIKit
import SuperEasyLayout

class QRDisplayViewController: BaseViewController {
    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.effect = UIBlurEffect(style: .regular)
        return view
    }()

    private lazy var tapRecognizer: BaseTapGestureRecognizer = {
        let recognizer = BaseTapGestureRecognizer(on: visualEffectView)
        return recognizer
    }()

    private lazy var containerView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .background(.mainLight)
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .title
        view.textColor = .textColor(.title)
        view.textAlignment = .center
        return view
    }()

    private lazy var hostLabel: UILabel = {
        let view = UILabel()
        view.font = .body
        view.textColor = .text
        view.textAlignment = .center
        return view
    }()

    private lazy var qrImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .background(.profileImage)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    typealias ServerInfo = ServerListViewController.ServerInfo
    private var info: ServerInfo? { didSet {
        guard let info,
              let name = info.name,
              let address = info.address,
              let port = info.port
        else { return }
        titleLabel.text = "Scan QR for \(name)"
        hostLabel.text = "\(address):\(port)"
        qrImage.image = generateQRCode(from: "chesmes-ios:/?name=\(name)&address=\(address)&port=\(port)")
    } }

    // MARK: - Setups

    override func setupLayout() {
        view.backgroundColor = .clear

        addSubviews([
            visualEffectView,
            containerView.addSubviews([
                titleLabel,
                hostLabel,
                qrImage
            ])
        ])
    }

    override func setupConstraints() {
        visualEffectView.setLayoutEqualTo(view)

        containerView.width == AppConstant.shared.screen(.width) - 48
        containerView.centerX == view.centerX
        containerView.centerY == view.centerY

        titleLabel.left == containerView.left + 16
        titleLabel.right == containerView.right - 16
        titleLabel.top == containerView.top + 16
        titleLabel.height == 40

        hostLabel.left == titleLabel.left
        hostLabel.right == titleLabel.right
        hostLabel.top == titleLabel.bottom

        qrImage.left == titleLabel.left
        qrImage.right == titleLabel.right
        qrImage.top == hostLabel.bottom + 16
        qrImage.bottom == containerView.bottom - 16
        qrImage.width == titleLabel.width
        qrImage.height == qrImage.width
    }

    override func setupActions() {
        tapRecognizer.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }

    func generateQRCode(from qrString: String) -> UIImage? {
        // Create a CIFilter for QR code generation
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(qrString.data(using: .utf8), forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")

            // Get the QR code image from the filter
            if let outputImage = filter.outputImage {
                // Scale the image to make it visible
                let scaleX = 200 / outputImage.extent.size.width
                let scaleY = 200 / outputImage.extent.size.height

                let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

                return UIImage(ciImage: transformedImage)
            }
        }

        return nil
    }
}

// MARK: - Navigation
extension QRDisplayViewController {
    static func show(on parentViewController: UIViewController, with info: ServerInfo) async {
        let qRDisplayViewController = Self()
        qRDisplayViewController.modalPresentationStyle = .overFullScreen
        qRDisplayViewController.transitioningDelegate = qRDisplayViewController.fadeInAnimator
        qRDisplayViewController.info = info
        parentViewController.present(qRDisplayViewController, animated: true)
    }
}
