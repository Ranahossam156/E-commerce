//import UIKit
//import SwiftUI
//import WebKit
//
//class PayPalWebViewController: UIViewController {
//    private let webView: WKWebView
//    private let url: URL
//    var onSuccess: ((String) -> Void)?
//    var onCancel: (() -> Void)?
//    private var hasCompletedCheckout = false
//    
//    init(url: URL) {
//        self.url = url
//        let configuration = WKWebViewConfiguration()
//        self.webView = WKWebView(frame: .zero, configuration: configuration)
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupWebView()
//        setupNavigationBar()
//        loadPayPalURL()
//    }
//    
//    private func setupWebView() {
//        view.addSubview(webView)
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            webView.topAnchor.constraint(equalTo: view.topAnchor),
//            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//        
//        webView.navigationDelegate = self
//    }
//    
//    private func setupNavigationBar() {
//        let closeButton = UIBarButtonItem(
//            title: "Close",
//            style: .plain,
//            target: self,
//            action: #selector(closeTapped)
//        )
//        navigationItem.rightBarButtonItem = closeButton
//        navigationItem.title = "PayPal Checkout"
//    }
//    
//    private func loadPayPalURL() {
//        let request = URLRequest(url: url)
//        webView.load(request)
//    }
//    
//    @objc private func closeTapped() {
//        onCancel?()
//        dismiss(animated: true)
//    }
//}
//
//extension PayPalWebViewController: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if let url = navigationAction.request.url {
//            print("Navigating to URL: \(url.absoluteString)")
//            
//            // Allow initial PayPal checkout URL
//            if url.absoluteString.contains("checkoutnow?token=") {
//                decisionHandler(.allow)
//                return
//            }
//            
//            // Check for PayPal success URLs after user action
//            if !hasCompletedCheckout && (
//                url.absoluteString.contains("return?token=") ||
//                url.absoluteString.contains("return?orderID=") ||
//                url.absoluteString.contains("approveWebPayment")
//            ) {
//                hasCompletedCheckout = true
//                onSuccess?("SUCCESS")
//                decisionHandler(.cancel)
//                dismiss(animated: true)
//                return
//            }
//            
//            // Check for PayPal cancel
//            if url.absoluteString.contains("cancel=true") || url.absoluteString.contains("/cancel") {
//                onCancel?()
//                decisionHandler(.cancel)
//                dismiss(animated: true)
//                return
//            }
//            
//            // Allow navigation within PayPal domains
//            if url.host?.contains("paypal.com") == true ||
//               url.host?.contains("sandbox.paypal.com") == true {
//                decisionHandler(.allow)
//                return
//            }
//        }
//        decisionHandler(.allow)
//    }
//    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("WebView finished loading: \(webView.url?.absoluteString ?? "nil")")
//    }
//    
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        print("WebView failed with error: \(error.localizedDescription)")
//    }
//    
//    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        print("WebView provisional navigation failed: \(error.localizedDescription)")
//        
//        // Only cancel if error is not from user cancellation and not already completed
//        if !hasCompletedCheckout && error._code != NSURLErrorCancelled {
//            onCancel?()
//            dismiss(animated: true)
//        }
//    }
//}// MARK: - SwiftUI Integration Helper
//extension View {
//    func presentPayPalPayment(
//        items: [CartItem],
//        total: Double,
//        onSuccess: @escaping () -> Void,
//        onError: @escaping (String) -> Void
//    ) {
//        Task {
//            do {
//                let orderId = try await PayPalService.shared.createOrder(for: items, total: total)
//                let approvalURL = try await PayPalService.shared.getApprovalURL(orderId: orderId)
//                
//                DispatchQueue.main.async {
//                    self.presentPayPalWebView(approvalURL: approvalURL, orderId: orderId, onSuccess: onSuccess, onError: onError)
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    onError("PayPal error: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    private func presentPayPalWebView(
//        approvalURL: URL,
//        orderId: String,
//        onSuccess: @escaping () -> Void,
//        onError: @escaping (String) -> Void
//    ) {
//        let webViewController = PayPalWebViewController(url: approvalURL)
//        let navigationController = UINavigationController(rootViewController: webViewController)
//        
//        webViewController.onSuccess = { _ in
//            Task {
//                do {
//                    let success = try await PayPalService.shared.captureOrder(orderId: orderId)
//                    DispatchQueue.main.async {
//                        if success {
//                            onSuccess()
//                        } else {
//                            onError("Payment capture failed")
//                        }
//                        navigationController.dismiss(animated: true)
//                    }
//                } catch {
//                    DispatchQueue.main.async {
//                        onError("PayPal capture failed: \(error.localizedDescription)")
//                        navigationController.dismiss(animated: true)
//                    }
//                }
//            }
//        }
//        
//        webViewController.onCancel = {
//            DispatchQueue.main.async {
//                onError("PayPal payment cancelled")
//                navigationController.dismiss(animated: true)
//            }
//        }
//        
//        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let window = scene.windows.first,
//           let rootViewController = window.rootViewController {
//            navigationController.modalPresentationStyle = .fullScreen
//            rootViewController.present(navigationController, animated: true)
//        }
//    }
//}
