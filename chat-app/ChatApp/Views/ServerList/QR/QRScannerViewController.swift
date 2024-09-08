//
//  QRScannerViewController.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 9/10/24.
//

import AVFoundation
import QRScanner

class QRScannerViewController: BaseViewController {
    var continuation: CheckedContinuation<String?, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await setupQRScanner() }
    }

    private func setupQRScanner() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        self?.setupQRScannerView()
                    }
                }
            }
        default:
            await AsyncAlertController<Void>(
                title: "Error",
                message: "Camera is required to use in this application"
            )
            .addButton(title: "OK", returnValue: Void())
            .register(in: self)
        }
    }

    private func setupQRScannerView() {
        let qrScannerView = QRScannerView(frame: view.bounds)
        view.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        qrScannerView.startRunning()
    }

    static func show(on parentViewController: BaseViewController) async -> String? {
        await withCheckedContinuation { continuation in
            let viewController = QRScannerViewController()
            viewController.continuation = continuation
            viewController.modalPresentationStyle = .overFullScreen
            viewController.transitioningDelegate = viewController.fadeInAnimator

            parentViewController.present(viewController, animated: true)
        }
    }
}

extension QRScannerViewController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScanner.QRScannerView, didFailure error: QRScanner.QRScannerError) {
        Task {
            await AsyncAlertController<Void>(
                title: "Error",
                message: "\(error.localizedDescription)"
            )
            .addButton(title: "OK", returnValue: Void())
            .register(in: self)
        }
    }
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        dismiss(animated: true) {
            self.continuation?.resume(returning: code)
        }
    }
}
