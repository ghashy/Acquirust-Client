//
//  CommandType1.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 17.02.2024.
//

import AppKit
import Foundation

class CommandType1: NSTableCellView, NibLoadable {
    @IBOutlet var operationName: NSTextField!
    @IBOutlet var submitButton: NSButton!
    @IBOutlet var operationInput: NSTextField!

    var responseText: NSTextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        initResponseTextCell()
    }

    static let identifier = NSUserInterfaceItemIdentifier("CommandType1")

    static func nib() -> NSNib {
        NSNib(nibNamed: "CommandType1", bundle: nil)!
    }

    @IBAction func submitCommand(_ sender: Any) {
        switch operationName.stringValue {
        case "Add account":
            HttpClient.shared.addAccount(password: operationInput.stringValue) {
                response in
                DispatchQueue.main.async {
                    self.responseText.stringValue = response
                }
            }
        case "Delete account":
            HttpClient.shared.deleteAccount(
                cardNumber: operationInput.stringValue
            ) { response in
                DispatchQueue.main.async {
                    self.responseText.stringValue = response
                }
            }
        default: fatalError()
        }
    }

    func setup(
        _ operationName: String, _ buttonText: String,
        _ inputPlaceholder: String
    ) {
        self.operationName.stringValue = operationName
        self.submitButton.title = buttonText
        self.operationInput.placeholderString = inputPlaceholder
    }

    func initResponseTextCell() {
        let cell = CustomTextFieldCell(textCell: "Response")
        let text = NSTextField()
        text.cell = cell
        text.translatesAutoresizingMaskIntoConstraints = false
        text.alignment = .center
        text.isSelectable = true
        self.responseText = text
        addSubview(text)

        text.topAnchor.constraint(equalTo: operationName.topAnchor).isActive =
            true
        text.leadingAnchor.constraint(
            equalTo: operationInput.trailingAnchor, constant: 5
        ).isActive = true
        text.bottomAnchor.constraint(equalTo: submitButton.bottomAnchor)
            .isActive = true
        text.trailingAnchor.constraint(
            equalTo: self.trailingAnchor, constant: -5
        ).isActive = true
    }
}
