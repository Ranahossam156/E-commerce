import Foundation
import Reachability

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private var reachability: Reachability?

    @Published var isConnected: Bool

    private init() {
        do {
            reachability = try Reachability()

            if reachability?.connection == .unavailable || reachability?.connection == nil {
                isConnected = false
            } else {
                isConnected = true
            }
            print("NetworkMonitor: Initial connection status: \(reachability?.connection ?? .unavailable), isConnected set to: \(isConnected)")

            reachability?.whenReachable = { [weak self] _ in
                DispatchQueue.main.async {
                    if self?.isConnected == false {
                        print("NetworkMonitor: Network became reachable.")
                        self?.isConnected = true
                    }
                }
            }

            reachability?.whenUnreachable = { [weak self] _ in
                DispatchQueue.main.async {
                    if self?.isConnected == true {
                        print("NetworkMonitor: Network became unreachable.")
                        self?.isConnected = false
                    }
                }
            }

            try reachability?.startNotifier()

        } catch {
            print("Unable to start notifier or setup Reachability: \(error.localizedDescription)")
            isConnected = false
        }
    }

    deinit {
        reachability?.stopNotifier()
    }
}
