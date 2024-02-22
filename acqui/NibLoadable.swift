//
//  NibLoadable.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 17.02.2024.
//

import Foundation
import AppKit

// For views that can be loaded from nib file
protocol NibLoadable {
    // Name of the nib file
    static var nibName: String { get }
    static func createFromNib(in bundle: Bundle) -> Self
}

//extension NSTableCellView {
extension NibLoadable where Self: NSView {
    // Default nib name must be same as class name
    static var nibName: String {
        return String(describing: Self.self)
    }

    static func createFromNib(in bundle: Bundle = Bundle.main) -> Self {
        var topLevelArray: NSArray? = nil
        bundle.loadNibNamed(
            NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
        let views = [Any](topLevelArray!).filter { $0 is Self }
        return views.last as! Self
    }
}
