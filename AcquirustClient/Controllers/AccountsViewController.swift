//
//  AccountsViewController.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 17.02.2024.
//

import Cocoa

class AccountsViewController: NSViewController {

    @IBOutlet var tableView: NSTableView!

    private var accountsList: [AccountInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        update()
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
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
                    self.tableView.reloadData()
                // TODO: show somehow error in gui, not just print
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}

extension AccountsViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return accountsList.count
    }
}

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
        default:
            fatalError()
        }
        cell.textField?.stringValue = value

        return cell
    }

}
