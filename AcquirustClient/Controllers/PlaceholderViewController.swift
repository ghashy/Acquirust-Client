//
//  PlaceholderViewController.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 18.02.2024.
//

import Cocoa

class PlaceholderViewController: NSViewController {
    override func loadView() {
        view = NSView(frame: NSMakeRect(0.0, 0.0, 300, 300))

        let label = NSTextField(
            labelWithString: "NSViewController without Storyboard")
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
