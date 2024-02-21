//
//  CommandsViewController.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 16.02.2024.
//

import Cocoa

class CommandsViewController: NSViewController {

    @IBOutlet var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNibs()
    }

    func loadNibs() {
        // We don't need reusable cells
        // tableView.CommandType1.nib(), forIdentifier: .init("CommandType1"))
        tableView.selectionHighlightStyle = .none
    }

}

extension CommandsViewController: NSTableViewDelegate {
    func tableView(
        _ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int
    ) -> NSView? {
        // We don't need reusable cells
        // let view =
        //     tableView.makeView(
        //         withIdentifier: CommandType1.identifier, owner: self)
        //    as! CommandType1
        CommandsOrder(rawValue: row)?.getCommand()
    }

}

extension CommandsViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        4
    }
}

enum CommandsOrder: Int {
    case AddAccount = 0
    case DeleteAccount
    case OpenCredit
    case NewTransaction

    func getCommand() -> NSView {
        switch self {
        case .AddAccount:
            let addAccount = CommandType1.createFromNib()
            addAccount.setup("Add account", "Add", "Password")
            return addAccount
        case .DeleteAccount:
            let deleteAccount = CommandType1.createFromNib()
            deleteAccount.setup("Delete account", "Delete", "Card number")
            return deleteAccount
        case .OpenCredit:
            let openCredit = CommandType2.createFromNib()
            openCredit.setup("Open credit", "Open", "Card number", "Amount")
            return openCredit
        case .NewTransaction:
            let newTransaction = CommandType3.createFromNib()
            newTransaction.setup(
                "New transaction", "Create", "From", "To", "Amount")
            return newTransaction
        }
    }
}
