//
//  ViewController.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 09.02.2024.
//

import Cocoa

// MARK: VC
class ViewController: NSSplitViewController {
    
    var toggled: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        for item in self.splitViewItems {
            item.collapseBehavior = .useConstraints
        }
    }
}

// MARK: First responder actions
extension ViewController {
    @IBAction func toggleSidebarCustom(_ sender: AnyObject?) {
        toggled.toggle()
        // Set view as first responder
        self.view.window?.makeFirstResponder(splitViewItems[1].viewController)
        self.splitViewItems[0].animator().isCollapsed = self.toggled
    }
}
