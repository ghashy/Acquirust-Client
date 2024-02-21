//
//  TableCellViewWithButton.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 21.02.2024.
//

import Cocoa

class TableCellViewWithButton: NSTableCellView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    @IBAction func insertCardNumber(sender: NSButton) {
        if let cardNumber = (sender.superview as? TableCellViewWithButton)?
            .textField?.stringValue
        {
            window?.firstResponder?.tryToPerform(
                #selector(setter: NSTextField.stringValue),
                with: cardNumber
            )

        }
    }

}
