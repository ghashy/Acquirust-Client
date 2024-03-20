//
//  WindowController.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 17.02.2024.
//

import AppKit
import Cocoa
import Foundation
import SwiftUI

// MARK: WC
class WindowController: NSWindowController, NSWindowDelegate {
    @State var appConfig = AppConfig.shared
    var settingsHostingController: NSViewController?

    @IBOutlet var emissionLabel: NSTextField!
    @IBOutlet var emissionValue: NSTextField!

    @IBOutlet var storeCardLabel: NSTextField!
    @IBOutlet var storeCardValue: NSTextField!
    @IBOutlet var storeCardRefButton: NSButton!

    @IBOutlet var storeBalanceLabel: NSTextField!
    @IBOutlet var storeBalanceValue: NSTextField!

    @IBAction func toggleSidebar(_ sender: Any) {
        window?.firstResponder?.tryToPerform(
            #selector(ViewController.toggleSidebarCustom(_:)),
            with: nil
        )
    }

    @IBAction func showSettings(_ sender: Any) {
        let settingsView = SettingsView()
            .environmentObject(appConfig)
        let hostingController = NSHostingController(rootView: settingsView)
        settingsHostingController = hostingController
        self.contentViewController?.presentAsSheet(hostingController)
    }

    @IBAction func updateConnection(_ sender: Any) {
        Notifier.shared.updateConnection()
        Tracing.shared.updateConnection()
    }

    @IBAction func insertStoreCard(_ sender: Any) {
        window?.firstResponder?.tryToPerform(
            #selector(setter: NSTextField.stringValue),
            with: storeCardValue.stringValue
        )

    }

    override func windowDidLoad() {
        Notifier.shared.emissionDataDelegate = self
    }

    func printResponderChain(_ responder: NSResponder?) {
        guard let responder = responder else { return }

        print(responder)
        printResponderChain(responder.nextResponder)
    }

    func update(_ emission: String, _ storeCard: String, _ storeBalance: String) {
        emissionValue.stringValue = emission
        storeCardValue.stringValue = storeCard
        storeCardRefButton.isEnabled = storeCard != "No data"
        storeBalanceValue.stringValue = storeBalance
    }

}

// MARK: First responder actions
extension WindowController {
    func dismissSettings(_ sender: Any) {
        self.contentViewController!.dismiss(settingsHostingController!)
    }

}

//class ModalController: NSViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Create a button to show the modal window
//        let button = NSButton(
//            frame: NSRect(x: 100, y: 100, width: 100, height: 30))
//        button.title = "Show Modal"
//        button.target = self
//        button.action = #selector(showModal)
//        view.addSubview(button)
//    }
//
//    @objc func showModal() {
//        // Create the modal window
//        let modalWindow = NSWindow(
//            contentRect: NSRect(x: 100, y: 100, width: 300, height: 200),
//            styleMask: [.titled, .closable],
//            backing: .buffered, defer: false)
//        modalWindow.title = "Modal Window"
//
//        // Create the content view for the modal window
//        let contentView = NSView(frame: modalWindow.contentView!.bounds)
//        contentView.wantsLayer = true
//        contentView.layer?.backgroundColor = NSColor.white.cgColor
//
//        // Create a button to close the modal window
//        let closeButton = NSButton(
//            frame: NSRect(x: 100, y: 100, width: 100, height: 30))
//        closeButton.title = "Close"
//        closeButton.target = self
//        closeButton.action = #selector(closeModal)
//        contentView.addSubview(closeButton)
//
//        // Set the content view of the modal window
//        modalWindow.contentView = contentView
//
//        // Present the modal window
//        modalWindow.makeKeyAndOrderFront(nil)
//
//        // Run the modal event loop
//        NSApp.runModal(for: modalWindow)
//    }
//
//    @objc func closeModal() {
//        // Close the modal window
//        NSApp.stopModal(withCode: .OK)
//    }
//}
