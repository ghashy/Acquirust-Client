//
//  Subscriber.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 21.02.2024.
//

import Foundation
import Starscream

class Subscriber: NSObject {

    private var socket: WebSocket!

    static var shared = Subscriber()
    
    private var accountsList: [AccountInfo] = []

    weak var delegate: AccountsViewController? {
        didSet {
            delegate!.update(accounts: self.accountsList)
        }
    }

    private override init() {
        super.init()
        let config = AppConfig.shared
        let endpoint = config.data.endpoint
        var request = URLRequest(
            endpoint: endpoint, path: ["system", "subscribe_on_accounts"],
            method: "GET")
        request.basicAuth(
            username: config.data.username, password: config.data.password)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
        update()
    }

    func update() {
        HttpClient.shared.listAccounts { list in
            DispatchQueue.main.async {
                guard let list = list else {
                    print("is empty")
                    return
                }
                switch list {
                    case let .success(list):
                        self.accountsList = list
                        self.delegate?.update(accounts: list)
                    // TODO: show somehow error in gui, not just print
                    case let .failure(error):
                        print(error)
                }
            }
        }
    }
}

extension Subscriber: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
            case .text(_):
                self.update()
            default: {}()
        }
    }
}
