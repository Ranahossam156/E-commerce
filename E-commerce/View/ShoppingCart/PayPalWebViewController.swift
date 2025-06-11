//
//  PayPalWebViewController.swift
//  E-commerce
//
//  Created by Kerolos on 11/06/2025.
//

import Foundation
// MARK: - PayPal Web View Controller
import SafariServices
import SwiftUICore

class PayPalWebViewController: SFSafariViewController {
    var onSuccess: ((String) -> Void)?
    var onCancel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension PayPalWebViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        onCancel?()
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            onCancel?()
        }
    }
}

// MARK: - SwiftUI Integration Helper
extension View {
    func presentPayPalPayment(
        items: [CartItem],
        total: Double,
        onSuccess: @escaping () -> Void,
        onError: @escaping (String) -> Void
    ) {
        Task {
            do {
                let orderId = try await PayPalService.shared.createOrder(for: items, total: total)
                let approvalURL = try await PayPalService.shared.getApprovalURL(orderId: orderId)
                
                DispatchQueue.main.async {
                    self.presentPayPalWebView(approvalURL: approvalURL, orderId: orderId, onSuccess: onSuccess, onError: onError)
                }
            } catch {
                DispatchQueue.main.async {
                    onError("PayPal error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func presentPayPalWebView(
        approvalURL: URL,
        orderId: String,
        onSuccess: @escaping () -> Void,
        onError: @escaping (String) -> Void
    ) {
        let webViewController = PayPalWebViewController(url: approvalURL)
        
        webViewController.onSuccess = { _ in
            Task {
                do {
                    let success = try await PayPalService.shared.captureOrder(orderId: orderId)
                    if success {
                        DispatchQueue.main.async {
                            onSuccess()
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        onError("PayPal capture failed: \(error.localizedDescription)")
                    }
                }
            }
            webViewController.dismiss(animated: true)
        }
        
        webViewController.onCancel = {
            DispatchQueue.main.async {
                onError("PayPal payment cancelled")
            }
            webViewController.dismiss(animated: true)
        }
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(webViewController, animated: true)
        }
    }
}
