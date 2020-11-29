//
//  OverlayView.swift
//  LibUniWinC
//
//  Created by Kirurobo on 2020/11/28.
//  Copyright © 2020 Kirurobo. All rights reserved.
//

import Cocoa

protocol FileDroppedDelegate {
    func complete(result: String)
}

class OverlayView: NSView {
    // References:
    // https://qiita.com/ohbashunsuke/items/8b9d6dc07408091690c6
    // https://stackoverflow.com/questions/31657523/get-file-path-using-drag-and-drop-swift-macos
    
    var enabled = false

    public func setEnabled(enabled: Bool) {
        self.enabled = enabled
    }
    
    private func setup() {
        self.registerForDraggedTypes(
            [NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL]
        )
    }
    
    public func fitToSuperView() -> Void {
        guard let parent = superview
        else {
            return
        }
                
        // Fit to the parent frame
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            self.topAnchor.constraint(equalTo: parent.topAnchor, constant: 0),
            self.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 0),
            self.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: 0)
        ]
        parent.addConstraints(constraints)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
        setup()
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if (enabled) {
            return .link
        } else {
            return []
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if (!self.enabled) {
            return false
        }
        
        guard let urls = sender.draggingPasteboard.propertyList(
                forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
            ) as? NSArray
        else {
            return false
        }
        
        // Make new-line separated string
        let files: String = urls.componentsJoined(by: "¥n")
        
        let count = files.utf16.count
        if (count <= 0) {
            return false
        }
        
        let buffer = UnsafeMutablePointer<uint16>.allocate(capacity: count + 1)
        var i = 0
        for c in files.utf16 {
            buffer[i] = c
            i += 1
        }
        buffer[count] = uint16.zero     // End of the string
        
        // Do callback
        LibUniWinC.fileDropCallback?(buffer)
        
        buffer.deallocate()
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        //super.draw(dirtyRect)
        
// for debugging
//        // Drawing code here.
//        NSColor.red.set()
//        let figure = NSBezierPath()
//        figure.move(to: dirtyRect.origin)
//        figure.line(to: NSMakePoint(dirtyRect.width, dirtyRect.height))
//        figure.line(to: NSMakePoint(dirtyRect.width - 5, dirtyRect.height))
//        figure.line(to: NSMakePoint(dirtyRect.width, dirtyRect.height - 5))
//        figure.line(to: NSMakePoint(dirtyRect.width, dirtyRect.height))
//        figure.lineWidth = 2
//        figure.stroke()
    }
}