//
//  Subscriber.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 21.02.2024.
//

import Foundation
import Starscream

// MARK: Notifier
/// We could implement different types for storing state (accounts info, emission data, etc),
/// store all subscribers in the array, and set each subscriber to be responsible for fetching it's data,
/// but for simplicity we store all data in that `Notifier` type.
class Notifier: NSObject {

    // Singletone
    static var shared = Notifier()

    // State
    private var socket: WebSocket?
    private var isConnected = false
    private var accountsList: [AccountInfo] = []
    private var emission: String = ""

    // Delegates
    weak var accountsViewDelegate: AccountsViewController? {
        didSet {
            accountsViewDelegate!.update(accounts: self.accountsList)
        }
    }
    weak var emissionDataDelegate: WindowController? {
        didSet {
            emissionDataDelegate!.update(emission: emission)
        }
    }

    private override init() {
        super.init()
        socket = WebSocket(request: prepareRequest())
        socket?.delegate = self
        socket?.connect()
    }

    func updateConnection() {
        socket?.disconnect()
        socket = WebSocket(request: prepareRequest())
        socket?.delegate = self
        socket?.connect()
    }

}

// MARK: Notifier, internals
extension Notifier {
    private func prepareRequest() -> URLRequest {
        let config = AppConfig.shared
        let endpoint = config.data.endpoint
        var request = URLRequest(
            endpoint: endpoint, path: ["system", "subscribe_on_accounts"],
            method: "GET")
        request.basicAuth(
            username: config.data.username, password: config.data.password)
        request.timeoutInterval = 5
        return request
    }

    private func update() {
        HttpClient.shared.listAccounts { list in
            DispatchQueue.main.async {
                guard let list = list else {
                    print("is empty")
                    return
                }
                switch list {
                    case let .success(list):
                        self.accountsList = list
                        self.accountsViewDelegate?.update(accounts: list)
                    // TODO: show somehow error in gui, not just print
                    case let .failure(error):
                        print(error)
                }
            }
        }
        HttpClient.shared.fetchSimpleValue(endpoint: "emission") { emission in
            DispatchQueue.main.async {
                self.emission = emission
                self.emissionDataDelegate?.update(emission: emission)
            }
        }
    }

    private func resetState() {
        accountsList = []
        emission = "No data"
    }

    private func notify() {
        accountsViewDelegate?.update(accounts: accountsList)
        emissionDataDelegate?.update(emission: emission)
    }
}

// MARK: Notifier: WebSocketDelegate
extension Notifier: WebSocketDelegate {
    func didReceive(
        event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient
    ) {
        switch event {
            case .connected(let m):
                print("Notifier WS connected, message: \(m)")
                isConnected = true
                self.update()
            case .disconnected(let reason, let code):
                print("Notifier WS disconnected: \(reason), \(code)")
                isConnected = false
            case .text(_):
                self.update()
            case .error(let error):
                print("Notifier WS error: \(String(describing: error))")
                isConnected = false
            case .cancelled:
                print("Notifier WS cancelled")
                isConnected = false
            case .peerClosed:
                print("Notifier WS perr closed")
                isConnected = false
            default:
                print("Notifier WS event: \(event)")
        }

        if !isConnected {
            self.resetState()
            self.notify()
        }
    }
}
