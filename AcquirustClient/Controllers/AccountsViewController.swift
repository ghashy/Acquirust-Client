//
//  AccountsViewController.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 17.02.2024.
//

import Cocoa
import Starscream

// MARK: AVC
class AccountsViewController: NSViewController {

    // Interface
    @IBOutlet var tableView: NSTableView!

    // Table data
    private var accountsList: [AccountInfo]!

    // Web socket
    private var socket: WebSocket!

    override func viewDidLoad() {
        super.viewDidLoad()
        Subscriber.shared.delegate = self
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(accounts: [AccountInfo]) {
        self.accountsList = accounts
        tableView.reloadData()
    }
}

// MARK: AVC table view data source
extension AccountsViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return accountsList.count
    }
}

// MARK: AVC table view delegate
extension AccountsViewController: NSTableViewDelegate {
    func tableView(
        _ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int
    ) -> NSView? {
        guard row != -1 else { return nil }
        guard
            let cell = tableView.makeView(
                withIdentifier: tableColumn!.identifier, owner: self)
                as? NSTableCellView
        else {
            return nil
        }
        let value: String
        switch tableColumn?.identifier.rawValue {
            case "Card number":
                value = accountsList[row].cardNumber
            case "Transactions count":
                value = accountsList[row].transactions.count.description
            case "Balance":
                value = accountsList[row].balance.description
            case "Exists":
                value = accountsList[row].exists.description
            default:
                fatalError()
        }
        cell.textField?.stringValue = value

        return cell
    }
}

