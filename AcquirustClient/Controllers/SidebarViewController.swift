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
        //        ("Accounts", "person.circle"),
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
        let selected = tableView.selectedRow
        guard selected != -1 && selected != selectedSection else {
            return
        }
        guard let splitVC = parent as? NSSplitViewController else { return }

        let append = { view in
            // Make new split view item
            let item = NSSplitViewItem(viewController: view)
            splitVC.addSplitViewItem(item)
        }
        
        // Despawn old
        if selectedSection == 0 {
            // Commands view
            splitVC.removeSplitViewItem(splitVC.splitViewItems[2])
            splitVC.removeSplitViewItem(splitVC.splitViewItems[1])
        } else {
            // Other views
            splitVC.removeSplitViewItem(splitVC.splitViewItems[1])

        }

        // Spawn new
        switch selected {
            case 0:
                let view0 =
                    self.storyboard!.instantiateController(
                        withIdentifier: "CommandsViewController")
                    as! CommandsViewController
                append(view0)
                let view1 =
                    self.storyboard!.instantiateController(
                        withIdentifier: "AccountsViewController")
                    as! AccountsViewController
                append(view1)
            case 2:
                let view = TracingViewController()
                append(view)
            default:
                let view = PlaceholderViewController()
                append(view)
        }
        // Set selected section as active
        selectedSection = tableView.selectedRow
    }
}
