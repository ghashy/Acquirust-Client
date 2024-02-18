//
//  SidebarViewController.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 14.02.2024.
//

import Cocoa

class SidebarViewController: NSViewController {

    @IBOutlet var tableView: NSTableView!
    var selectedSection: Int = 0

    static let entries: [(String, String)] = [
        ("Commands", "square.and.pencil"),
        ("Accounts", "person.circle"),
        ("Transactions", "creditcard.circle"),
        ("Logs", "exclamationmark.bubble"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        let indexPath = IndexSet(integer: 0)
        tableView.selectRowIndexes(indexPath, byExtendingSelection: false)
    }

}

extension SidebarViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        SidebarViewController.entries.count
    }

    func tableView(
        _ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int
    ) -> NSView? {
        guard row != -1 else { return nil }
        guard
            let wv = tableView.makeView(
                withIdentifier: tableColumn!.identifier, owner: self)
                as? NSTableCellView
        else {
            return nil
        }
        wv.imageView?.image = NSImage(
            systemSymbolName: SidebarViewController.entries[row].1,
            accessibilityDescription: nil)
        wv.textField?.stringValue = SidebarViewController.entries[row].0
        return wv
    }
}

extension SidebarViewController: NSTableViewDelegate {

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard
            tableView.selectedRow != -1
                && tableView.selectedRow != selectedSection
        else { return }
        guard let splitVC = parent as? NSSplitViewController else { return }

        // Despawn old
        if let last = splitVC.splitViewItems.last,
            splitVC.splitViewItems.count > 1
        {
            splitVC.removeSplitViewItem(last)
        } else {
            return
        }

        // Spawn new
        let view: NSViewController
        switch tableView.selectedRow {
        case 0:
            view =
                self.storyboard!.instantiateController(
                    withIdentifier: "CommandsViewController")
                as! CommandsViewController
        default:
            view = AccountsViewController(
                nibName: "AccountsView", bundle: Bundle.main)
                
        }
        // Make new split view item
        let item = NSSplitViewItem(viewController: view)
        splitVC.addSplitViewItem(item)
        // Set selected section as active
        selectedSection = tableView.selectedRow
    }
}
