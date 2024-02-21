//
//  TracingViewController.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 18.02.2024.
//

import Cocoa

class TracingViewController: NSViewController {
    
    var textView: NSTextView!
    var scrollView: NSScrollView!
    var clipView: NSClipView!
    
    override func loadView() {
        textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isHorizontallyResizable = false
        textView.font = NSFont.systemFont(ofSize: 20)
        textView.textColor = NSColor.textColor
        textView.backgroundColor = NSColor.textBackgroundColor
        
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.autoresizingMask = [.width, .height]
        
        clipView = NSClipView(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        clipView.documentView = textView
        
        scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        scrollView.contentView = clipView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        view = scrollView
        
        Tracing.delegate = self
    }
}

extension TracingViewController {
    @objc func append(with attributedString: NSAttributedString) {
        textView.textStorage?.append(attributedString)
    }
}

