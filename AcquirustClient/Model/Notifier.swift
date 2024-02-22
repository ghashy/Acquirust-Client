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
    private var socketTask: URLSessionWebSocketTask!
    private var session: URLSession!
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
        session = URLSession(
            configuration: .default, delegate: self,
            delegateQueue: OperationQueue.main)
        updateConnection()
    }

    func updateConnection() {
        createSocketTask()
        update()
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

    private func createSocketTask() {
        socketTask = session.webSocketTask(with: prepareRequest())
        socketTask.delegate = self
        socketTask.resume()
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
        HttpClient.shared.getEmission { emission in
            DispatchQueue.main.async {
                self.emission = emission
                self.emissionDataDelegate?.update(emission: emission)
            }
        }
    }

    private func sendPing() {
        socketTask.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }

    private func close() {
        socketTask?.cancel(with: .goingAway, reason: "Close".data(using: .utf8))
    }
    
    private func resetState() {
        accountsList = []
        emission = "No data"
    }
    
    private func notify() {
        accountsViewDelegate?.update(accounts: accountsList)
        emissionDataDelegate?.update(emission: emission)
    }

    private func receive() {
        socketTask?.receive(completionHandler: { [weak self] result in
            switch result {
                case .success(let message):
                    switch message {
                        case .string(_):
                            self?.update()
                        default:
                            break
                    }
                case .failure(let error):
                    print("Failed to receive message over ws: \(error)")
                    self?.resetState()
                    self?.notify()
                    return
            }
            self?.receive()
        })
    }

}

// MARK: Notifier: URLSessionWebSocketDelegate
extension Notifier: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol p: String?
    ) {
        print("Did open url socket session with protocol: \(String(describing: p))")
        receive()
    }
    func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?
    ) {
        print("Did close url socket session with reason: \(String(describing: reason))")
    }
}

// MARK: URLSessionDelegate
extension Notifier: URLSessionDelegate {}
