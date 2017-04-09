//
//  LNTextView.swift
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

let testColors: [NSColor] = [.yellow, .blue, .red, .orange, .green, .purple]


class LNTextView: NSView, NSTextStorageDelegate, NSTextViewDelegate, LineHighlightingTextViewDelegate {
	
   
	// MARK: Colors
	var textBackgroundColor: NSColor {
		set { _textView.backgroundColor = newValue }
		get { return _textView.backgroundColor }
	}
	
	var lineNumbersBackgroundColor: NSColor {
		set { _lineNumbers.backgroundColor = newValue }
		get { return _lineNumbers.backgroundColor }
	}
	
	var lineNumbersForegroundColor: NSColor {
		set { _lineNumbers.foregroundColor = newValue }
		get { return _lineNumbers.foregroundColor }
	}
	
	var currentLineColor: NSColor {
		set {
			_lineNumbers.selectionColor = newValue
			_textView.currentLineColor = newValue.withAlphaComponent(0.1)
		}
		get { return _lineNumbers.selectionColor }
	}
	
    var selectionColor: NSColor {
        set { _textView.selectedTextAttributes[NSBackgroundColorAttributeName] = newValue }
        get { return _textView.selectedTextAttributes[NSBackgroundColorAttributeName] as! NSColor }
    }
    
	var textColor: NSColor {
		set {
			_textView.textColor = newValue
			_textView.insertionPointColor = newValue
		}
		get { return _textView.textColor ?? NSColor.black }
	}
	
    var font: NSFont? {
        set { _textView.font = newValue }
        get { return _textView.font }
    }
    

	
	var selectedRanges: [NSValue] { return _textView.selectedRanges }

	
	private var _textView: LineHighlightingTextView!
	
    var storageDelegate: NSTextStorageDelegate?
	
    
    private var _lineNumbers: LineNumberView!
    private var _scrollView: NSScrollView!
	private var _textStorage: NSTextStorage { return _textView.textStorage! }
	
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		
		_scrollView = NSScrollView(frame: self.bounds)
		
		_scrollView.hasVerticalScroller   = true
		_scrollView.hasHorizontalScroller = false
		_scrollView.hasVerticalRuler      = true
		_scrollView.rulersVisible         = true
		
		_scrollView.borderType = .noBorder
		_scrollView.autoresizingMask = [.viewWidthSizable , .viewHeightSizable]
		
		
		_textView = LineHighlightingTextView(frame: NSRect(origin: NSZeroPoint, size: _scrollView.contentSize))
		_textView.minSize = NSSize(width: 0, height: _scrollView.contentSize.height)
		_textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude,height: CGFloat.greatestFiniteMagnitude)
		_textView.isVerticallyResizable = true
		_textView.isHorizontallyResizable = false
		_textView.autoresizingMask = .viewWidthSizable
		_textView.textContainer?.containerSize = NSSize(width: _scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
		_textView.textContainer?.widthTracksTextView = true
		_textView.highlightingDelegate = self
		
		_lineNumbers = LineNumberView(frame: NSRect(x: 0, y: 0, width: 50, height: 0))
		_lineNumbers.scrollView = _scrollView
		_lineNumbers.orientation = .verticalRuler
		_lineNumbers.clientView = _textView
		
		
		_scrollView.verticalRulerView = _lineNumbers
		_scrollView.documentView = _textView
		
		
		_textStorage.delegate = self
		_textView.delegate = self

		addSubview(_scrollView)

		font = NSFont(name: "Menlo-Regular", size: 9)
	}
	
	
	
	func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
		_lineNumbers.needsDisplay = true
		storageDelegate?.textStorage?(textStorage, willProcessEditing: editedMask, range: editedRange, changeInLength: delta)
	}
	
	
	
	func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
		storageDelegate?.textStorage?(textStorage, didProcessEditing: editedMask, range: editedRange, changeInLength: delta)
	}
	
	
	override func layout() {
		super.layout();
		_lineNumbers.needsDisplay = true
	}
	
	func selectionNeedsDisplay() {
		_lineNumbers.needsDisplay = true
	}

	
}









