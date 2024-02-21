//
//  CommandType3.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 17.02.2024.
//

import AppKit
import Foundation

class CommandType3: NSTableCellView, NibLoadable {
    @IBOutlet var operationName: NSTextField!
    @IBOutlet var submitButton: NSButton!
    @IBOutlet var operationInput1: NSTextField!
    @IBOutlet var operationInput2: NSTextField!
    @IBOutlet var operationInput3: NSTextField!
    
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
        guard let amount = Int(operationInput3.stringValue) else {
            responseText.stringValue = "Faild to parse amount as Int"
            return
        }
        HttpClient.shared.newTransaction(fromCardNumber: operationInput1.stringValue, toCardNumber: operationInput2.stringValue, amount: amount) { response in
            DispatchQueue.main.async {
                self.responseText.stringValue = response
            }
        }
    }
    
    func setup(
        _ operationName: String, _ buttonText: String,
        _ inputPlaceholder1: String, _ inputPlaceholder2: String,
        _ inputPlaceholder3: String
    ) {
        self.operationName.stringValue = operationName
        self.submitButton.stringValue = buttonText
        self.operationInput1.placeholderString = inputPlaceholder1
        self.operationInput2.placeholderString = inputPlaceholder2
        self.operationInput3.placeholderString = inputPlaceholder3
    }

    func initResponseTextCell() {
        let cell = CustomTextFieldCell(textCell: "Response")
        let text = NSTextField()
        text.cell = cell
        text.translatesAutoresizingMaskIntoConstraints = false
        text.alignment = .center
        text.isSelectable = true
        responseText = text
        addSubview(text)

        text.setContentHuggingPriority(.init(749), for: .vertical)
        text.topAnchor.constraint(equalTo: operationName.topAnchor).isActive =
            true
        text.leadingAnchor.constraint(
            equalTo: operationInput2.trailingAnchor, constant: 5
        ).isActive = true
        text.bottomAnchor.constraint(equalTo: submitButton.bottomAnchor)
            .isActive = true
        text.trailingAnchor.constraint(
            equalTo: self.trailingAnchor, constant: -5
        ).isActive = true
    }
}
