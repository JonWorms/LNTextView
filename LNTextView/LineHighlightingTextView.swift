//
//  LineHighlightingTextView.swift
//
//  Copyright (c) 2017 Jon Worms
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Cocoa
//TODO: Find out what this is: kATSULineHighlightCGColorTag


protocol LineHighlightingTextViewDelegate {
	func selectionNeedsDisplay()
}


public class LineHighlightingTextView: NSTextView {

	
	var highlightingDelegate: LineHighlightingTextViewDelegate?
	
	var currentLineColor: NSColor = NSColor(calibratedRed: 0.96, green: 0.96, blue: 0.97, alpha: 1)
    var selectionColor: NSColor {
        set { selectedTextAttributes[NSBackgroundColorAttributeName] = newValue }
        get { return selectedTextAttributes[NSBackgroundColorAttributeName] as! NSColor }
    }
    
    
	
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
        setup()
	}
	
	override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
		super.init(frame: frameRect, textContainer: container)
        setup()
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    private func setup() {
        selectionColor = NSColor(calibratedRed: 0.69, green: 0.84, blue: 1.0, alpha: 1.0)
    }

	
	override public var drawsBackground: Bool {
		set {} // always return false, we'll draw the background
		get { return false }
	}
	
	
	var selectedLineRect: NSRect? {
		guard let layout = layoutManager,
		let container = textContainer,
		let text = textStorage else { return nil }
		
		if selectedRange().length > 0 { return nil }
		
		return layout.boundingRect(forGlyphRange: text.rangeOfLineAtLocation(selectedRange().location), in: container)
	}
	
	override public func draw(_ dirtyRect: NSRect) {
		guard let context = NSGraphicsContext.current()?.cgContext else { return }
		
		context.setFillColor(backgroundColor.cgColor)
		context.fill(dirtyRect)
		
		if let textRect = selectedLineRect {
			let lineRect = NSRect(x: 0, y: textRect.origin.y, width: dirtyRect.width, height: textRect.height)
			context.setFillColor(currentLineColor.cgColor)
			context.fill(lineRect)
		}
		
		super.draw(dirtyRect)

	}
	
	/*
	override func setSelectedRange(_ charRange: NSRange) {
		super.setSelectedRange(charRange)
		needsDisplay = true
		highlightingDelegate?.selectionNeedsDisplay()
	}*/


	override public func setSelectedRange(_ charRange: NSRange, affinity: NSSelectionAffinity, stillSelecting stillSelectingFlag: Bool) {
		super.setSelectedRange(charRange, affinity: affinity, stillSelecting: stillSelectingFlag)
		needsDisplay = true
		highlightingDelegate?.selectionNeedsDisplay()
	}
	
	
}





extension UnicodeScalar {
	var isWhitespace: Bool {
		return NSCharacterSet.whitespaces.contains(self) || NSCharacterSet.newlines.contains(self)
	}
	
	var isNewline: Bool {
		return NSCharacterSet.newlines.contains(self)
	}
}

extension String.UnicodeScalarView {
	subscript(index: Int) -> UnicodeScalar {
		var i = self.startIndex
		self.formIndex(&i, offsetBy: index)
		return self[i]
	}
}


extension NSAttributedString {
	
	///
	/// Returns an NSRange containing the argument location that starts after 
	/// a newline (or the beginning of the string) and ends at a new line (or
	/// the end of the string)
	///
	func rangeOfLineAtLocation(_ location: Int) -> NSRange {
		let scalars = string.unicodeScalars
		
		if scalars[location].isNewline {
			var start = location
			while(start > 0 && !scalars[start-1].isNewline) {
				start -= 1
			}
			return NSMakeRange(start, location-start)
		}
		
		var start: Int = location
		while(start > 0 && !scalars[start-1].isNewline) {
			start -= 1
		}
		
		var end = location
		while(end < scalars.count-1 && !scalars[end+1].isNewline) {
			end += 1
		}
		
		return NSMakeRange(start, end-start)
	}
	
	
}
